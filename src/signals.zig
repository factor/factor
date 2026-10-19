// signals.zig - Signal handling infrastructure for Factor VM
// Implements Unix signal handlers for SIGSEGV, SIGBUS, SIGFPE, SIGINT, etc.

const std = @import("std");
const builtin = @import("builtin");

const code_blocks = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const io = @import("io.zig");
const layouts = @import("layouts.zig");
const math_mod = @import("fixnum.zig");
const objects = @import("objects.zig");
const safepoints = @import("safepoints.zig");
const vm_mod = @import("vm.zig");
const freebsd_context = @import("freebsd_context.zig");
const linux_arm64_fpsimd = @import("linux_arm64_fpsimd.zig");

const Cell = layouts.Cell;

// Call C sigaction directly - avoids Zig std.posix enum type issues
fn sigactionInt(sig_num: anytype, act: ?*const std.posix.Sigaction, oact: ?*std.posix.Sigaction) void {
    const c_sig: c_int = switch (@typeInfo(@TypeOf(sig_num))) {
        .comptime_int, .int => @intCast(sig_num),
        .@"enum" => @intCast(@backingInt(sig_num)),
        else => @compileError("sigactionInt: unsupported signal type"),
    };
    if (builtin.os.tag == .linux and contexts.sparc_frames) {
        const bridge = struct { extern fn factor_sparc_sigaction_bridge(c_int, ?*const std.posix.Sigaction, ?*std.posix.Sigaction) callconv(.c) c_int; }.factor_sparc_sigaction_bridge;
        _ = bridge(c_sig, act, oact);
        return;
    }
    const C = struct {
        extern "c" fn sigaction(c_int, ?*const std.posix.Sigaction, ?*std.posix.Sigaction) c_int;
        extern "c" fn __sigaction_siginfo(c_int, ?*const std.posix.Sigaction, ?*std.posix.Sigaction) c_int;
    };
    _ = if (builtin.os.tag == .netbsd) C.__sigaction_siginfo(c_sig, act, oact) else C.sigaction(c_sig, act, oact);
}

pub const VMError = enum(u32) {
    expired = 0,
    io = 1,
    unused = 2,
    type_error = 3,
    divide_by_zero = 4,
    signal = 5,
    array_size = 6,
    out_of_fixnum_range = 7,
    ffi = 8,
    undefined_symbol = 9,
    datastack_underflow = 10,
    datastack_overflow = 11,
    retainstack_underflow = 12,
    retainstack_overflow = 13,
    callstack_underflow = 14,
    callstack_overflow = 15,
    memory = 16,
    fp_trap = 17,
    interrupt = 18,
    callback_space_overflow = 19,
    float_unsupported = 20,
};

pub const KERNEL_ERROR = 0xfac7;

// FPU status bits
const FPU_STATUS_IE: u32 = 0x01; // Invalid operation
const FPU_STATUS_DE: u32 = 0x02; // Denormal
const FPU_STATUS_ZE: u32 = 0x04; // Divide by zero
const FPU_STATUS_OE: u32 = 0x08; // Overflow
const FPU_STATUS_UE: u32 = 0x10; // Underflow
const FPU_STATUS_PE: u32 = 0x20; // Precision

// Per-thread VM pointer (for signal handlers)
threadlocal var g_current_vm: ?*vm_mod.FactorVM = null;

// Thread->VM map for Mach exception handling (non-signal context)
var thread_vm_map: std.AutoHashMapUnmanaged(usize, *vm_mod.FactorVM) = .{};
const SpinMutex = @import("mutex.zig").SpinMutex;
var thread_vm_map_lock: SpinMutex = .{};
var thread_vm_map_allocator: ?std.mem.Allocator = null;

fn currentThreadKey() usize {
    if (builtin.os.tag == .windows) return @import("platform.zig").win.GetCurrentThreadId();
    return pthreadKey(std.c.pthread_self());
}

fn pthreadKey(pthread_id: std.c.pthread_t) usize {
    return switch (@typeInfo(std.c.pthread_t)) {
        .pointer => @intFromPtr(pthread_id),
        .int, .comptime_int => @intCast(pthread_id),
        else => @intFromPtr(@as(*const anyopaque, @ptrCast(pthread_id))),
    };
}

pub fn registerVmWithThread(vm: *vm_mod.FactorVM) void {
    g_current_vm = vm;

    const key = currentThreadKey();

    thread_vm_map_lock.lock();
    defer thread_vm_map_lock.unlock();

    const alloc = thread_vm_map_allocator orelse vm.allocator;
    if (thread_vm_map_allocator == null) {
        thread_vm_map_allocator = alloc;
    }

    thread_vm_map.put(alloc, key, vm) catch @panic("OOM");
}

pub fn unregisterVmFromThread() void {
    g_current_vm = null;
    const key = currentThreadKey();

    thread_vm_map_lock.lock();
    defer thread_vm_map_lock.unlock();

    _ = thread_vm_map.remove(key);
    if (thread_vm_map.count() == 0) {
        if (thread_vm_map_allocator) |allocator| thread_vm_map.deinit(allocator);
        thread_vm_map = .{};
        thread_vm_map_allocator = null;
    }
}

pub fn setCurrentVM(vm: *vm_mod.FactorVM) void {
    registerVmWithThread(vm);
}

pub fn getCurrentVM() ?*vm_mod.FactorVM {
    return g_current_vm;
}

test "unregister clears the current VM and releases the thread map" {
    const vm = try vm_mod.FactorVM.init(std.testing.allocator);
    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();
    defer vm.deinit();

    registerVmWithThread(vm);
    try std.testing.expectEqual(vm, getCurrentVM().?);
    unregisterVmFromThread();
    try std.testing.expect(getCurrentVM() == null);
    try std.testing.expect(thread_vm_map.get(currentThreadKey()) == null);
    try std.testing.expect(thread_vm_map_allocator == null);
    // Teardown can also be reached without a successful registration.
    unregisterVmFromThread();
    registerVmWithThread(vm);
    unregisterVmFromThread();
}

pub fn getVmForThread(pthread_id: std.c.pthread_t) ?*vm_mod.FactorVM {
    const key = pthreadKey(pthread_id);
    thread_vm_map_lock.lock();
    defer thread_vm_map_lock.unlock();
    return thread_vm_map.get(key);
}

// Linux x86_64 ucontext_t structure (from kernel headers)
const Linux_x86_64_fpregset = extern struct {
    cwd: u16,
    swd: u16,
    ftw: u16,
    fop: u16,
    rip: u64,
    rdp: u64,
    mxcsr: u32,
    mxcr_mask: u32,
    st: [8][16]u8,
    xmm: [16][16]u8,
    reserved: [96]u8,
};

const Linux_x86_64_mcontext = extern struct {
    gregs: [23]i64,
    fpregs: ?*Linux_x86_64_fpregset,
    reserved: [8]u64,
};

const Linux_x86_64_ucontext = extern struct {
    uc_flags: c_ulong,
    uc_link: ?*Linux_x86_64_ucontext,
    uc_stack: std.posix.stack_t,
    uc_mcontext: Linux_x86_64_mcontext,
    uc_sigmask: std.c.sigset_t,
};

// glibc i386 ucontext/mcontext, including the legacy x87 prefix used by
// Linux's signal-frame FP state. Extended FXSR data follows this prefix.
const Linux_x86_fpregset = extern struct {
    cw: u32, sw: u32, tag: u32, ipoff: u32, cssel: u32,
    dataoff: u32, datasel: u32, st: [8][10]u8,
    status: u16, magic: u16, fxsr_env: [6]u32, mxcsr: u32, reserved: u32,
};
const Linux_x86_mcontext = extern struct {
    gregs: [19]i32,
    fpregs: ?*Linux_x86_fpregset,
    oldmask: u32,
    cr2: u32,
};
const Linux_x86_ucontext = extern struct {
    uc_flags: c_ulong,
    uc_link: ?*Linux_x86_ucontext,
    uc_stack: std.posix.stack_t,
    uc_mcontext: Linux_x86_mcontext,
    uc_sigmask: std.c.sigset_t,
};

// Linux ARM64 ucontext_t structure
const Linux_aarch64_mcontext = extern struct {
    fault_address: u64,
    regs: [31]u64,
    sp: u64,
    pc: u64,
    pstate: u64,
    reserved: [4096]u8 align(16),
};

const Linux_aarch64_ucontext = extern struct {
    uc_flags: c_ulong,
    uc_link: ?*Linux_aarch64_ucontext,
    uc_stack: std.posix.stack_t,
    uc_sigmask: std.c.sigset_t,
    padding: [1024 / 8 - @sizeOf(std.c.sigset_t)]u8,
    uc_mcontext: Linux_aarch64_mcontext,
};

// glibc RV64 ucontext: the FP union reserves space for the Q extension.
const Linux_riscv_mcontext = extern struct {
    gregs: [32]Cell,
    fpregs: [528]u8 align(16),
};
const Linux_riscv_ucontext = extern struct {
    uc_flags: c_ulong,
    uc_link: ?*Linux_riscv_ucontext,
    uc_stack: std.posix.stack_t,
    uc_sigmask: std.c.sigset_t,
    padding: [128 - @sizeOf(std.c.sigset_t)]u8,
    uc_mcontext: Linux_riscv_mcontext,
};

const Linux_arm_mcontext = extern struct { gregs: [21]u32 };
const Linux_arm_ucontext = extern struct {
    uc_flags: u32,
    uc_link: ?*Linux_arm_ucontext,
    uc_stack: std.posix.stack_t,
    uc_mcontext: Linux_arm_mcontext,
    uc_sigmask: [128]u8,
    uc_regspace: [128]u32 align(8),
};
const linux_arm32_vfp = @import("linux_arm32_vfp.zig");

// Platform-specific ucontext_t type alias
const powerpc = builtin.cpu.arch == .powerpc or builtin.cpu.arch == .powerpc64 or builtin.cpu.arch == .powerpc64le;
extern "c" fn factor_powerpc_unwind(code: Cell, quotation: Cell, stack: Cell) noreturn;
extern "c" fn factor_powerpc_signal_registers(context: *anyopaque) [*]Cell;
extern "c" fn factor_powerpc_signal_pc(context: *anyopaque) *Cell;
extern "c" fn factor_powerpc_signal_lr(context: *anyopaque) *Cell;
extern "c" fn factor_powerpc_frame_state(entry: Cell, end: Cell, pc: Cell, frame_size: Cell, prologue: Cell) c_uint;
extern "c" fn factor_powerpc_signal_stack_size() Cell;
extern "c" fn factor_powerpc_signal_fpscr(context: *anyopaque) u32;
extern "c" fn factor_powerpc_signal_clear_fpscr(context: *anyopaque) void;

const mips = @import("contexts.zig").mips_frames;
extern "c" fn factor_mips_signal_pc(context: *anyopaque) *Cell;
extern "c" fn factor_mips_signal_sp(context: *anyopaque) *Cell;
extern "c" fn factor_mips_signal_t9(context: *anyopaque, target: Cell) void;
extern "c" fn factor_mips_signal_fcsr(context: *anyopaque) u32;
extern "c" fn factor_mips_signal_clear_fcsr(context: *anyopaque) void;
extern "c" fn factor_mips_unwind(code: Cell, quotation: Cell, stack: Cell) noreturn;

extern "c" fn factor_loongarch_signal_pc(context: *anyopaque) *Cell;
extern "c" fn factor_loongarch_signal_sp(context: *anyopaque) *Cell;
extern "c" fn factor_loongarch_signal_fcsr(context: *anyopaque) u32;
extern "c" fn factor_loongarch_signal_clear_fcsr(context: *anyopaque) void;

const Linux_ucontext_t = if (powerpc or mips or builtin.cpu.arch == .loongarch64) struct {} else if (builtin.cpu.arch == .x86_64)
    Linux_x86_64_ucontext
else if (builtin.cpu.arch == .x86)
    Linux_x86_ucontext
else if (builtin.cpu.arch == .arm)
    Linux_arm_ucontext
else if (builtin.cpu.arch == .aarch64)
    Linux_aarch64_ucontext
else if (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .riscv32)
    Linux_riscv_ucontext
else if (builtin.cpu.arch == .s390x)
    @import("s390x.zig").LinuxContext
else
    @compileError("Unsupported architecture for Linux signal handling");

// Architecture-specific context access
// These functions extract PC and SP from ucontext_t

// macOS ucontext_t structure (simplified)
// On macOS, uc_mcontext is a POINTER to mcontext, not inline
const MacOS_ucontext_t = extern struct {
    uc_onstack: c_int,
    uc_sigmask: u32,
    uc_stack: extern struct {
        ss_sp: ?*anyopaque,
        ss_size: usize,
        ss_flags: c_int,
    },
    uc_link: ?*anyopaque,
    uc_mcsize: usize,
    uc_mcontext: *anyopaque, // Pointer to mcontext!
};

// macOS x86_64 mcontext structure offsets
// __ss (thread state) starts at offset 0 in mcontext
// x86_thread_state64 layout:
//   __rax at offset 0
//   __rbx at offset 1
//   __rcx at offset 2
//   __rdx at offset 3
//   __rdi at offset 4
//   __rsi at offset 5
//   __rbp at offset 6
//   __rsp at offset 7
//   __r8-__r15 at offsets 8-15
//   __rip at offset 16
//   __rflags at offset 17
//   __cs, __fs, __gs at offsets 18-20

const netbsd_context = @import("os-netbsd.zig");

// OpenBSD passes struct sigcontext directly to SA_SIGINFO handlers.
// RV64 machine/signal.h orders ra,sp,gp,tp,t[7],s[12],a[8],sepc after
// two 32-bit fields; floating registers and fcsr follow (pc=256, sp=16, fcsr=520).
const OpenBSDContext = struct {
    fn words(context: *anyopaque) [*]Cell {
        return @ptrCast(@alignCast(context));
    }
    fn pc(context: *anyopaque) *Cell {
        return &words(context)[
            switch (builtin.cpu.arch) {
                .x86_64 => 21,
                .x86 => 11,
                .aarch64 => 3,
                .arm => 19,
                .riscv64 => 32,
                else => unreachable,
            }
        ];
    }
    fn sp(context: *anyopaque) *Cell {
        return &words(context)[
            switch (builtin.cpu.arch) {
                .x86_64 => 24,
                .x86 => 14,
                .aarch64 => 1,
                .arm => 16,
                .riscv64 => 2,
                else => unreachable,
            }
        ];
    }
    fn fp(context: *anyopaque) ?[*]u8 {
        return @ptrFromInt(words(context)[if (builtin.cpu.arch == .x86_64) 26 else 20]);
    }
    fn status(context: *anyopaque) u32 {
        // machine/signal.h: sc_fcsr follows 32 floating-point registers.
        if (builtin.cpu.arch == .riscv64) return @truncate(words(context)[65]);
        if (builtin.cpu.arch == .arm) return if (words(context)[20] != 0) @truncate(words(context)[21]) else 0;
        if (builtin.cpu.arch == .aarch64) return @truncate(asm volatile ("mrs %[status], fpsr"
            : [status] "=r" (-> u64),
        ));
        const state = fp(context) orelse return 0;
        const sw: *align(1) const u16 = @ptrCast(state + 2);
        const mxcsr: *align(1) const u32 = @ptrCast(state + 24);
        return sw.* | mxcsr.*;
    }
    fn clear(context: *anyopaque) void {
        if (builtin.cpu.arch == .riscv64) { words(context)[65] &= ~@as(Cell, 0x1f); return; }
        if (builtin.cpu.arch == .aarch64) { asm volatile ("msr fpsr, xzr"); return; }
        if (builtin.cpu.arch == .arm) {
            if (words(context)[20] != 0) words(context)[21] &= ~@as(Cell, 0x9f);
            return;
        }
        const state = fp(context) orelse return;
        const sw: *align(1) u16 = @ptrCast(state + 2);
        const mxcsr: *align(1) u32 = @ptrCast(state + 24);
        sw.* = 0; mxcsr.* &= 0xffffffc0;
    }
};

fn getProgramCounter(ucontext_ptr: *anyopaque) *Cell {
    if (mips and builtin.os.tag == .linux) return factor_mips_signal_pc(ucontext_ptr);
    if (builtin.os.tag == .linux and contexts.sparc_frames) {
        const Context = if (@sizeOf(Cell) == 8) @import("sparc.zig").LinuxContext64 else @import("sparc.zig").LinuxContext32;
        return &@as(*Context, @ptrCast(@alignCast(ucontext_ptr))).pc;
    }
    if (builtin.os.tag == .linux and builtin.cpu.arch == .loongarch64) return factor_loongarch_signal_pc(ucontext_ptr);
    if (builtin.os.tag == .linux and builtin.cpu.arch == .s390x) {
        return &@as(*@import("s390x.zig").LinuxContext, @ptrCast(@alignCast(ucontext_ptr))).pc;
    }
    if (powerpc and (builtin.os.tag == .linux or builtin.os.tag == .freebsd)) return factor_powerpc_signal_pc(ucontext_ptr);
    if (builtin.os.tag == .openbsd) return OpenBSDContext.pc(ucontext_ptr);
    if (builtin.os.tag == .freebsd) return freebsd_context.programCounter(ucontext_ptr);
    if (builtin.os.tag == .netbsd) return netbsd_context.programCounter(ucontext_ptr);

    if (builtin.os.tag == .macos) {
        if (builtin.cpu.arch == .x86_64) {
            // On macOS, need to dereference uc_mcontext pointer first
            // mcontext64 structure layout:
            //   __es (exception state): 16 bytes = 2 u64 slots
            //   __ss (thread state): starts at index 2
            //     __rax-__rsp at indices 0-7
            //     __r8-__r15 at indices 8-15
            //     __rip at index 16 within __ss
            // So __rip is at mcontext[2 + 16] = mcontext[18]
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mcontext: [*]u64 = @ptrCast(@alignCast(ucontext.uc_mcontext));
            return @ptrCast(&mcontext[18]); // __rip = 2 (skip __es) + 16
        } else if (builtin.cpu.arch == .aarch64) {
            // macOS _STRUCT_MCONTEXT64 (arm): __es (2 u64: __far,__esr/__exception),
            // then __ss { __x[29], __fp, __lr, __sp, __pc, ... }.
            //   __x[0]=mc[2] .. __x[28]=mc[30], __fp=mc[31], __lr=mc[32],
            //   __sp=mc[33], __pc=mc[34].
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mcontext: [*]u64 = @ptrCast(@alignCast(ucontext.uc_mcontext));
            return @ptrCast(&mcontext[34]); // __pc
        }
    } else if (builtin.os.tag == .dragonfly and builtin.cpu.arch == .x86_64) {
        // DragonFly 6.4 amd64 ucontext: mc at 64, mc_fpregs at 320.
        const bytes: [*]u8 = @ptrCast(ucontext_ptr);
        return @ptrCast(@alignCast(bytes + 232));
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.gregs[16]); // REG_RIP
        } else if (builtin.cpu.arch == .x86) {
            const ucontext: *Linux_x86_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.gregs[14]); // REG_EIP
        } else if (builtin.cpu.arch == .aarch64) {
            const ucontext: *Linux_aarch64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.pc);
        } else if (builtin.cpu.arch == .arm) {
            const ucontext: *Linux_arm_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return &ucontext.uc_mcontext.gregs[18];
        } else if (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .riscv32) {
            const ucontext: *Linux_riscv_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.gregs[0]);
        }
    }
    @panic("Unsupported architecture for signal handling");
}

fn getStackPointer(ucontext_ptr: *anyopaque) *Cell {
    if (mips and builtin.os.tag == .linux) return factor_mips_signal_sp(ucontext_ptr);
    if (builtin.os.tag == .linux and contexts.sparc_frames) {
        const Context = if (@sizeOf(Cell) == 8) @import("sparc.zig").LinuxContext64 else @import("sparc.zig").LinuxContext32;
        return &@as(*Context, @ptrCast(@alignCast(ucontext_ptr))).regs[14];
    }
    if (builtin.os.tag == .linux and builtin.cpu.arch == .loongarch64) return factor_loongarch_signal_sp(ucontext_ptr);
    if (builtin.os.tag == .linux and builtin.cpu.arch == .s390x) {
        return &@as(*@import("s390x.zig").LinuxContext, @ptrCast(@alignCast(ucontext_ptr))).gregs[15];
    }
    if (powerpc and (builtin.os.tag == .linux or builtin.os.tag == .freebsd)) return &factor_powerpc_signal_registers(ucontext_ptr)[1];
    if (builtin.os.tag == .openbsd) return OpenBSDContext.sp(ucontext_ptr);
    if (builtin.os.tag == .freebsd) return freebsd_context.stackPointer(ucontext_ptr);
    if (builtin.os.tag == .netbsd) return netbsd_context.stackPointer(ucontext_ptr);

    if (builtin.os.tag == .macos) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mcontext: [*]u64 = @ptrCast(@alignCast(ucontext.uc_mcontext));
            return @ptrCast(&mcontext[9]); // __rsp = 2 (skip __es) + 7
        } else if (builtin.cpu.arch == .aarch64) {
            // See getProgramCounter: __sp is mcontext[33] (after the 2-u64 __es
            // prefix and __x[29]/__fp/__lr).
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mcontext: [*]u64 = @ptrCast(@alignCast(ucontext.uc_mcontext));
            return @ptrCast(&mcontext[33]); // __sp
        }
    } else if (builtin.os.tag == .dragonfly and builtin.cpu.arch == .x86_64) {
        // DragonFly 6.4 amd64 ucontext: mc at 64, mc_fpregs at 320.
        const bytes: [*]u8 = @ptrCast(ucontext_ptr);
        return @ptrCast(@alignCast(bytes + 256));
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.gregs[15]); // REG_RSP
        } else if (builtin.cpu.arch == .x86) {
            const ucontext: *Linux_x86_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.gregs[7]); // REG_ESP
        } else if (builtin.cpu.arch == .aarch64) {
            const ucontext: *Linux_aarch64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.sp);
        } else if (builtin.cpu.arch == .arm) {
            const ucontext: *Linux_arm_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return &ucontext.uc_mcontext.gregs[16];
        } else if (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .riscv32) {
            const ucontext: *Linux_riscv_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.gregs[2]);
        }
    }
    @panic("Unsupported architecture for signal handling");
}

const FP_TRAP_INVALID_OPERATION: u32 = 1 << 0;
const FP_TRAP_OVERFLOW: u32 = 1 << 1;
const FP_TRAP_UNDERFLOW: u32 = 1 << 2;
const FP_TRAP_ZERO_DIVIDE: u32 = 1 << 3;
const FP_TRAP_INEXACT: u32 = 1 << 4;

// Get FPU status from signal context
fn getFPUStatus(ucontext_ptr: *anyopaque) u32 {
    if (mips and builtin.os.tag == .linux) return factor_mips_signal_fcsr(ucontext_ptr);
    if (builtin.os.tag == .linux and contexts.sparc_frames) {
        const get = struct { extern fn factor_sparc_fpu_status(*anyopaque) callconv(.c) u32; }.factor_sparc_fpu_status;
        return get(ucontext_ptr);
    }
    if (builtin.os.tag == .linux and builtin.cpu.arch == .loongarch64) return factor_loongarch_signal_fcsr(ucontext_ptr);
    if (builtin.os.tag == .linux and builtin.cpu.arch == .s390x) {
        return @as(*@import("s390x.zig").LinuxContext, @ptrCast(@alignCast(ucontext_ptr))).fpc;
    }
    if (powerpc and (builtin.os.tag == .linux or builtin.os.tag == .freebsd)) return factor_powerpc_signal_fpscr(ucontext_ptr);
    if (builtin.os.tag == .openbsd) return OpenBSDContext.status(ucontext_ptr);
    if (builtin.os.tag == .freebsd) return freebsd_context.status(ucontext_ptr);
    if (builtin.os.tag == .netbsd) return netbsd_context.fpuStatus(ucontext_ptr);

    if (builtin.os.tag == .macos) {
        if (builtin.cpu.arch == .x86_64) {
            // macOS x86_64: access __fs (float state) from ucontext
            // mcontext layout: exception_state(16) + thread_state(168) + float_state
            // float_state: reserved(8) + fcw(2) + fsw(2) + ... + mxcsr(4) at offset 32
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mc: [*]const u8 = @ptrCast(ucontext.uc_mcontext);
            const fs_base = 16 + 168; // float state offset in mcontext
            const fsw = std.mem.readInt(u16, mc[fs_base + 10 ..][0..2], .little);
            const mxcsr = std.mem.readInt(u32, mc[fs_base + 32 ..][0..4], .little);
            return mxcsr | @as(u32, fsw);
        } else if (builtin.cpu.arch == .aarch64) {
            // macOS ARM64: NEON state starts after exception(16) + thread(272)
            // fpsr is at offset 512 within NEON state
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mc: [*]const u8 = @ptrCast(ucontext.uc_mcontext);
            return std.mem.readInt(u32, mc[800..][0..4], .little);
        }
    } else if (builtin.os.tag == .dragonfly and builtin.cpu.arch == .x86_64) {
        // DragonFly 6.4 amd64 ucontext: mc at 64, mc_fpregs at 320.
        const bytes: [*]const u8 = @ptrCast(ucontext_ptr);
        const format = std.mem.readInt(u32, bytes[276..][0..4], .little);
        if (format != 0x10002 and format != 0x10003) return 0;
        return @as(u32, std.mem.readInt(u16, bytes[322..][0..2], .little)) | std.mem.readInt(u32, bytes[344..][0..4], .little);
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            // Linux x86_64: fpregs->swd | fpregs->mxcsr
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            if (ucontext.uc_mcontext.fpregs) |fpregs| {
                return fpregs.swd | fpregs.mxcsr;
            }
        } else if (builtin.cpu.arch == .x86) {
            const ucontext: *Linux_x86_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            if (ucontext.uc_mcontext.fpregs) |fpregs| return fpregs.sw |
                (if (fpregs.magic == 0) fpregs.mxcsr else @as(u32, 0));
        } else if (builtin.cpu.arch == .aarch64) {
            const ucontext: *Linux_aarch64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return linux_arm64_fpsimd.status(&ucontext.uc_mcontext.reserved);
        } else if (builtin.cpu.arch == .arm) {
            const ucontext: *Linux_arm_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return linux_arm32_vfp.status(&ucontext.uc_regspace);
        } else if (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .riscv32) {
            const ucontext: *Linux_riscv_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return std.mem.readInt(u32, ucontext.uc_mcontext.fpregs[256..][0..4], .little);
        }
    }
    return 0;
}

// Clear FPU status bits
fn clearFPUStatus(ucontext_ptr: *anyopaque) void {
    if (mips and builtin.os.tag == .linux) return factor_mips_signal_clear_fcsr(ucontext_ptr);
    if (builtin.os.tag == .linux and contexts.sparc_frames) {
        const clear = struct { extern fn factor_sparc_clear_fpu_status(*anyopaque) callconv(.c) void; }.factor_sparc_clear_fpu_status;
        clear(ucontext_ptr);
        return;
    }
    if (builtin.os.tag == .linux and builtin.cpu.arch == .loongarch64) { factor_loongarch_signal_clear_fcsr(ucontext_ptr); return; }
    if (builtin.os.tag == .linux and builtin.cpu.arch == .s390x) {
        @as(*@import("s390x.zig").LinuxContext, @ptrCast(@alignCast(ucontext_ptr))).clearFpuStatus();
        return;
    }
    if (powerpc and (builtin.os.tag == .linux or builtin.os.tag == .freebsd)) return factor_powerpc_signal_clear_fpscr(ucontext_ptr);
    if (builtin.os.tag == .openbsd) return OpenBSDContext.clear(ucontext_ptr);
    if (builtin.os.tag == .freebsd) return freebsd_context.clearStatus(ucontext_ptr);
    if (builtin.os.tag == .netbsd) return netbsd_context.clearFpuStatus(ucontext_ptr);

    if (builtin.os.tag == .macos) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mc: [*]u8 = @ptrCast(ucontext.uc_mcontext);
            const fs_base = 16 + 168;
            // Clear MXCSR exception bits (bits 0-5)
            var mxcsr = std.mem.readInt(u32, mc[fs_base + 32 ..][0..4], .little);
            mxcsr &= 0xffffffc0;
            std.mem.writeInt(u32, mc[fs_base + 32 ..][0..4], mxcsr, .little);
            // Clear x87 status word
            std.mem.writeInt(u16, mc[fs_base + 10 ..][0..2], 0, .little);
        } else if (builtin.cpu.arch == .aarch64) {
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mc: [*]u8 = @ptrCast(ucontext.uc_mcontext);
            std.mem.writeInt(u32, mc[800..][0..4], 0, .little);
        }
    } else if (builtin.os.tag == .dragonfly and builtin.cpu.arch == .x86_64) {
        // DragonFly 6.4 amd64 ucontext: mc at 64, mc_fpregs at 320.
        const bytes: [*]u8 = @ptrCast(ucontext_ptr);
        const format = std.mem.readInt(u32, bytes[276..][0..4], .little);
        if (format != 0x10002 and format != 0x10003) return;
        std.mem.writeInt(u16, bytes[322..][0..2], 0, .little);
        const mxcsr = std.mem.readInt(u32, bytes[344..][0..4], .little);
        std.mem.writeInt(u32, bytes[344..][0..4], mxcsr & 0xffffffc0, .little);
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            if (ucontext.uc_mcontext.fpregs) |fpregs| {
                fpregs.swd = 0;
                fpregs.mxcsr &= 0xffffffc0;
            }
        } else if (builtin.cpu.arch == .x86) {
            const ucontext: *Linux_x86_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            if (ucontext.uc_mcontext.fpregs) |fpregs| {
                fpregs.sw = 0;
                if (fpregs.magic == 0) fpregs.mxcsr &= 0xffffffc0;
            }
        } else if (builtin.cpu.arch == .aarch64) {
            const ucontext: *Linux_aarch64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            linux_arm64_fpsimd.clearStatus(&ucontext.uc_mcontext.reserved);
        } else if (builtin.cpu.arch == .arm) {
            const ucontext: *Linux_arm_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            linux_arm32_vfp.clearStatus(&ucontext.uc_regspace);
        } else if (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .riscv32) {
            const ucontext: *Linux_riscv_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            const fp = ucontext.uc_mcontext.fpregs[256..][0..4];
            std.mem.writeInt(u32, fp, std.mem.readInt(u32, fp, .little) & ~@as(u32, 0x1f), .little);
        }
    }
}

// Convert FPU status word to Factor format
pub fn processFPUStatus(status: u32) u32 {
    if (contexts.sparc_frames) return @import("sparc.zig").trapStatus(status);
    if (builtin.cpu.arch == .loongarch64) return @import("loongarch.zig").trapStatus(status);
    if (builtin.cpu.arch == .s390x) return @import("s390x.zig").trapStatus(status);
    var r: u32 = 0;
    if (mips) {
        const bits = ((status >> 2) | (status >> 12)) & 0x1f;
        if (bits & 0x10 != 0) r |= FP_TRAP_INVALID_OPERATION;
        if (bits & 0x08 != 0) r |= FP_TRAP_ZERO_DIVIDE;
        if (bits & 0x04 != 0) r |= FP_TRAP_OVERFLOW;
        if (bits & 0x02 != 0) r |= FP_TRAP_UNDERFLOW;
        if (bits & 0x01 != 0) r |= FP_TRAP_INEXACT;
        return r;
    }
    if (builtin.cpu.arch == .x86_64 or builtin.cpu.arch == .x86) {
        // x86 MXCSR/FSW: IE=0, ZE=2, OE=3, UE=4, PE=5
        if (status & 0x01 != 0) r |= FP_TRAP_INVALID_OPERATION;
        if (status & 0x04 != 0) r |= FP_TRAP_ZERO_DIVIDE;
        if (status & 0x08 != 0) r |= FP_TRAP_OVERFLOW;
        if (status & 0x10 != 0) r |= FP_TRAP_UNDERFLOW;
        if (status & 0x20 != 0) r |= FP_TRAP_INEXACT;
    } else if (powerpc) {
        if (status & 0x20000000 != 0) r |= FP_TRAP_INVALID_OPERATION;
        if (status & 0x10000000 != 0) r |= FP_TRAP_OVERFLOW;
        if (status & 0x08000000 != 0) r |= FP_TRAP_UNDERFLOW;
        if (status & 0x04000000 != 0) r |= FP_TRAP_ZERO_DIVIDE;
        if (status & 0x02000000 != 0) r |= FP_TRAP_INEXACT;
    } else if (builtin.cpu.arch == .aarch64 or builtin.cpu.arch == .arm) {
        // ARM64 FPSR: IOC=0, DZC=1, OFC=2, UFC=3, IXC=4
        if (status & 0x01 != 0) r |= FP_TRAP_INVALID_OPERATION;
        if (status & 0x02 != 0) r |= FP_TRAP_ZERO_DIVIDE;
        if (status & 0x04 != 0) r |= FP_TRAP_OVERFLOW;
        if (status & 0x08 != 0) r |= FP_TRAP_UNDERFLOW;
        if (status & 0x10 != 0) r |= FP_TRAP_INEXACT;
    } else if (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .riscv32) {
        if (status & 0x10 != 0) r |= FP_TRAP_INVALID_OPERATION;
        if (status & 0x08 != 0) r |= FP_TRAP_ZERO_DIVIDE;
        if (status & 0x04 != 0) r |= FP_TRAP_OVERFLOW;
        if (status & 0x02 != 0) r |= FP_TRAP_UNDERFLOW;
        if (status & 0x01 != 0) r |= FP_TRAP_INEXACT;
    } else {
        r = status & 0x1F;
    }
    return r;
}

// Platform-specific siginfo_t type - use std.posix.siginfo_t on all platforms
const SiginfoType = std.posix.siginfo_t;

// Memory signal handler (SIGSEGV, SIGBUS, SIGTRAP)
// This handles both safepoint checks and actual memory errors
fn memorySignalHandler(sig: std.posix.SIG, siginfo: *const SiginfoType, ucontext_ptr: ?*anyopaque) callconv(.c) void {
    const vm = g_current_vm orelse {
        fatalError("Foreign thread received signal", @backingInt(sig));
    };
    const ucontext = ucontext_ptr orelse abort();

    // Get fault address - structure varies by platform
    const fault_addr: Cell = if (builtin.os.tag == .linux)
        @intFromPtr(siginfo.fields.sigfault.addr)
    else if (builtin.os.tag == .netbsd)
        @import("os-netbsd.zig").faultAddress(siginfo)
    else if (builtin.os.tag == .openbsd)
        @intFromPtr(siginfo.data.fault.addr)
    else
        // macOS uses .addr field directly
        @intFromPtr(siginfo.addr);

    const pc_ptr = getProgramCounter(ucontext);
    const fault_pc = pc_ptr.*;

    // Check for fatal conditions
    if (vm_mod.g_fatal_erroring_p) {
        fatalErrorInFatalError();
    }

    // Check for double fault - use the error count as an absolute limit
    const err_count = general_error_count.load(.monotonic);
    if (err_count > 5) {
        std.debug.print("FATAL: Too many errors ({}) - likely infinite loop.\n", .{err_count});
        std.debug.print("  fault_addr=0x{x} fault_pc=0x{x} faulting_p={}\n", .{ fault_addr, fault_pc, vm.vm_asm.faulting_p });
        std.c._exit(1);
    }

    // Check for double fault (traditional check)
    if (vm.vm_asm.faulting_p and !safepoints.isSafepoint(vm, fault_addr)) {
        fatalError("Double fault", fault_addr);
    }

    if (vm.fep_p) {
        fatalError("Memory protection fault during low-level debugger", fault_addr);
    }

    if (vm.current_gc_p) {
        fatalError("Memory protection fault during gc", fault_addr);
    }

    // Store fault information for handler
    vm.signal_fault_addr = fault_addr;
    vm.signal_fault_pc = fault_pc;

    // Dispatch to signal handler
    dispatchSignalFromContext(vm, ucontext, @intFromPtr(&memory_signal_handler_impl));
}

fn faultWithoutVm() void {
    const unmapped: *allowzero volatile u8 = @ptrFromInt(0);
    unmapped.* = 0;
}

test "memory fault on a foreign thread without a VM is a fatal error" {
    if (builtin.os.tag == .windows) return error.SkipZigTest;
    const pid = std.c.fork();
    try std.testing.expect(pid >= 0);
    if (pid == 0) {
        const act = std.posix.Sigaction{
            .handler = .{ .sigaction = memorySignalHandler },
            .mask = std.posix.sigemptyset(),
            .flags = std.posix.SA.SIGINFO,
        };
        sigactionInt(std.c.SIG.SEGV, &act, null);
        sigactionInt(std.c.SIG.BUS, &act, null);
        const dev_null = std.c.open("/dev/null", .{ .ACCMODE = .WRONLY });
        _ = std.c.dup2(dev_null, std.posix.STDERR_FILENO);
        _ = std.c.alarm(10);
        const thread = WorkerThread.spawn(.{}, faultWithoutVm, .{}) catch std.c._exit(2);
        thread.join();
        std.c._exit(0);
    }
    var status: c_int = 0;
    try std.testing.expectEqual(pid, std.c.waitpid(pid, &status, 0));
    const wait_status: u32 = @bitCast(status);
    try std.testing.expect(std.posix.W.IFEXITED(wait_status));
    try std.testing.expectEqual(@as(u8, 1), std.posix.W.EXITSTATUS(wait_status));
}

// Floating point exception handler (SIGFPE)
fn fpeSignalHandler(sig: std.posix.SIG, siginfo: *const SiginfoType, ucontext_ptr: ?*anyopaque) callconv(.c) void {
    const vm = g_current_vm orelse {
        fatalError("Foreign thread received signal", @backingInt(sig));
    };
    const ucontext = ucontext_ptr orelse abort();

    vm.signal_number = @backingInt(sig);
    vm.signal_fpu_status = if (builtin.cpu.arch == .loongarch64 and builtin.os.tag == .linux)
        @import("loongarch.zig").signalTrapStatus(getFPUStatus(ucontext), siginfo.code)
    else
        processFPUStatus(getFPUStatus(ucontext));
    clearFPUStatus(ucontext);

    dispatchSignalFromContext(vm, ucontext, fpeHandlerAddress(if (builtin.os.tag == .netbsd) siginfo.info.code else siginfo.code));
}

fn fpeHandlerAddress(si_code: c_int) Cell {
    const darwin = builtin.os.tag == .macos or builtin.os.tag == .ios;
    const FPE_INTDIV: c_int = if (darwin) 7 else 1;
    const FPE_INTOVF: c_int = if (darwin) 8 else 2;
    return if (si_code == FPE_INTDIV or si_code == FPE_INTOVF)
        @intFromPtr(&synchronous_signal_handler_impl)
    else
        @intFromPtr(&fp_signal_handler_impl);
}

test "SIGFPE distinguishes native integer and floating point si_code values" {
    if (builtin.os.tag == .windows) return error.SkipZigTest;
    const integer_handler = @intFromPtr(&synchronous_signal_handler_impl);
    const fp_handler = @intFromPtr(&fp_signal_handler_impl);
    if (builtin.os.tag == .macos or builtin.os.tag == .ios) {
        // Darwin sys/signal.h: FLTDIV=1, FLTOVF=2, INTDIV=7, INTOVF=8.
        try std.testing.expectEqual(fp_handler, fpeHandlerAddress(1));
        try std.testing.expectEqual(fp_handler, fpeHandlerAddress(2));
        try std.testing.expectEqual(integer_handler, fpeHandlerAddress(7));
        try std.testing.expectEqual(integer_handler, fpeHandlerAddress(8));
    } else {
        // Linux: INTDIV=1, INTOVF=2, FLTDIV=3, FLTOVF=4.
        try std.testing.expectEqual(integer_handler, fpeHandlerAddress(1));
        try std.testing.expectEqual(integer_handler, fpeHandlerAddress(2));
        try std.testing.expectEqual(fp_handler, fpeHandlerAddress(3));
        try std.testing.expectEqual(fp_handler, fpeHandlerAddress(4));
    }
}

fn raiseFpeWithoutVm() void {
    _ = std.c.raise(.FPE);
}

test "SIGFPE on a foreign thread without a VM is a fatal error" {
    if (builtin.os.tag == .windows) return error.SkipZigTest;
    const pid = std.c.fork();
    try std.testing.expect(pid >= 0);
    if (pid == 0) {
        const act = std.posix.Sigaction{
            .handler = .{ .sigaction = fpeSignalHandler },
            .mask = std.posix.sigemptyset(),
            .flags = std.posix.SA.SIGINFO,
        };
        sigactionInt(std.c.SIG.FPE, &act, null);
        const dev_null = std.c.open("/dev/null", .{ .ACCMODE = .WRONLY });
        _ = std.c.dup2(dev_null, std.posix.STDERR_FILENO);
        _ = std.c.alarm(10);
        const thread = WorkerThread.spawn(.{}, raiseFpeWithoutVm, .{}) catch std.c._exit(2);
        thread.join();
        std.c._exit(0);
    }
    const status = try waitForChild(pid);
    try std.testing.expect(std.posix.W.IFEXITED(status));
    try std.testing.expectEqual(@as(u8, 1), std.posix.W.EXITSTATUS(status));
}

// Synchronous signal handler (SIGILL, etc.)
fn synchronousSignalHandler(sig: std.posix.SIG, _: *const SiginfoType, ucontext_ptr: ?*anyopaque) callconv(.c) void {
    if (vm_mod.g_fatal_erroring_p) return;

    const vm = g_current_vm orelse {
        fatalError("Foreign thread received signal", @backingInt(sig));
    };

    vm.signal_number = @backingInt(sig);

    const ucontext = ucontext_ptr orelse abort();

    // On Apple Silicon, FP exceptions enabled via FPCR trap bits arrive as
    // SIGILL (EXC_BAD_INSTRUCTION at the mach layer), NOT SIGFPE. The ESR in
    // the exception state identifies them: EC bits [31:26] == 0x2c is
    // "trapped floating-point exception", and ESR bits [7,4:0]
    // (IDF,IXF,UFF,OFF,DZF,IOF) use the same layout as the FPSR cumulative
    // flags. Route these to the FP-trap handler so `with-fp-traps` raises
    // ERROR-FP-TRAP instead of a generic signal-4 error.
    if (builtin.cpu.arch == .aarch64 and builtin.os.tag == .macos) {
        const uc: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext));
        const mcontext: [*]u64 = @ptrCast(@alignCast(uc.uc_mcontext));
        const esr = mcontext[1]; // __es.__esr (mc[0]=__far, mc[1]=__esr|__exception)
        const ec = (esr >> 26) & 0x3f;
        if (@backingInt(sig) == @backingInt(std.c.SIG.ILL) and ec == 0x2c) {
            vm.signal_fpu_status = processFPUStatus(@truncate(esr & 0x9f));
            clearFPUStatus(ucontext);
            dispatchSignalFromContext(vm, ucontext, @intFromPtr(&fp_signal_handler_impl));
            return;
        }
    }

    dispatchSignalFromContext(vm, ucontext, @intFromPtr(&synchronous_signal_handler_impl));
}

test "macOS ARM64 SIGILL uses ESR rather than stale FPSR flags" {
    if (builtin.os.tag != .macos or builtin.cpu.arch != .aarch64) return error.SkipZigTest;
    const allocator = std.testing.allocator;
    const vm = try vm_mod.FactorVM.init(allocator);
    vm.vm_asm.ctx = try vm.newContext();
    defer vm.deinit();
    var code_heap: vm_mod.CodeHeap = .{
        .seg = null,
        .safepoint_page = 0,
        .allocator = allocator,
        .remembered_sets = @import("write_barrier.zig").CodeHeapRememberedSets.init(allocator),
    };
    defer code_heap.deinit();
    vm.code = &code_heap;
    registerVmWithThread(vm);
    defer unregisterVmFromThread();

    var mc: [816]u8 align(16) = @splat(0);
    var uc: MacOS_ucontext_t = undefined;
    uc.uc_mcontext = &mc;
    const cases = [_]struct { esr: u32, fp_status: ?u32 }{
        .{ .esr = 0x02000000, .fp_status = null }, // Undefined instruction.
        .{ .esr = 0xb2800002, .fp_status = FP_TRAP_ZERO_DIVIDE },
        .{ .esr = 0x2c << 26, .fp_status = 0 }, // A trap even without cause bits.
    };
    for (cases) |case| {
        std.mem.writeInt(u32, mc[8..][0..4], case.esr, .little);
        std.mem.writeInt(u32, mc[800..][0..4], 1, .little); // Old invalid-operation flag.
        vm.signal_fpu_status = 0;
        var siginfo: SiginfoType = undefined;
        synchronousSignalHandler(.ILL, &siginfo, &uc);
        const expected_handler = if (case.fp_status != null)
            @intFromPtr(&fp_signal_handler_impl)
        else
            @intFromPtr(&synchronous_signal_handler_impl);
        try std.testing.expectEqual(expected_handler, getProgramCounter(&uc).*);
        try std.testing.expectEqual(@as(c_int, @backingInt(std.posix.SIG.ILL)), vm.signal_number);
        if (case.fp_status) |status| {
            try std.testing.expectEqual(status, vm.signal_fpu_status);
            try std.testing.expectEqual(@as(u32, 0), getFPUStatus(&uc));
        } else {
            try std.testing.expectEqual(@as(u32, 1), getFPUStatus(&uc));
        }
    }
}

// FEP (Factor Error Protocol) signal handler for SIGINT (Ctrl-C)
// This enters the low-level debugger instead of just enqueuing the signal
fn fepSignalHandler(sig: std.posix.SIG, _: *const SiginfoType, _: ?*anyopaque) callconv(.c) void {
    if (vm_mod.g_fatal_erroring_p) return;

    const vm = g_current_vm orelse {
        fatalError("Foreign thread received signal", @backingInt(sig));
    };

    // Best-effort: signal handler context, mprotect failure is non-recoverable
    safepoints.enqueueFep(vm) catch return;

    // Also enqueue the signal to the signal pipe for async processing
    enqueueSignal(vm, @intCast(@backingInt(sig)));
}

// Helper function to enqueue a signal to the signal pipe
fn enqueueSignal(vm: *vm_mod.FactorVM, sig: i32) void {
    if (vm.signal_pipe_output != -1) {
        const signal_val: i32 = sig;
        _ = std.c.write(vm.signal_pipe_output, std.mem.asBytes(&signal_val).ptr, @sizeOf(i32));
    }
}

// Enqueue signal to Factor's signal pipe (for async signals like SIGTERM)
fn enqueueSignalHandler(sig: std.posix.SIG, _: *const SiginfoType, _: ?*anyopaque) callconv(.c) void {
    if (vm_mod.g_fatal_erroring_p) return;

    const vm = g_current_vm orelse return;
    enqueueSignal(vm, @intCast(@backingInt(sig)));
}

// Sampling profiler signal handler (SIGALRM)
fn sampleSignalHandler(sig: std.posix.SIG, siginfo: *const SiginfoType, ucontext_ptr: ?*anyopaque) callconv(.c) void {
    const vm = g_current_vm orelse {
        enqueueSignalHandler(sig, siginfo, ucontext_ptr);
        return;
    };

    if (vm.sampling_profiler_p) {
        const ucontext = ucontext_ptr orelse {
            enqueueSignalHandler(sig, siginfo, ucontext_ptr);
            return;
        };
        const pc_ptr = getProgramCounter(ucontext);
        const pc = pc_ptr.*;

        // Best-effort: signal handler cannot propagate errors
        safepoints.enqueueSamples(vm, 1, pc, false) catch {};
    } else {
        enqueueSignalHandler(sig, siginfo, ucontext_ptr);
    }
}

// Ignore signal handler
fn ignoreSignalHandler(_: std.posix.SIG, _: *const SiginfoType, _: ?*anyopaque) callconv(.c) void {}

pub fn setMemoryProtectionError(vm: *vm_mod.FactorVM, fault_addr: Cell, fault_pc: Cell) void {
    if (vm_mod.g_fatal_erroring_p) {
        fatalErrorInFatalError();
    }
    if (vm.vm_asm.faulting_p and !safepoints.isSafepoint(vm, fault_addr)) {
        fatalError("Double fault", fault_addr);
    }
    if (vm.fep_p) {
        fatalError("Memory protection fault during low-level debugger", fault_addr);
    }
    if (vm.current_gc_p) {
        fatalError("Memory protection fault during gc", fault_addr);
    }
    vm.signal_fault_addr = fault_addr;
    vm.signal_fault_pc = fault_pc;
}

// Native ELFv2 functions require r12=global entry, while ELFv1 needs the
// descriptor's code and TOC values in PC and r2 before kernel sigreturn.
fn dispatchSignalFromContext(vm: *vm_mod.FactorVM, context: *anyopaque, handler: Cell) void {
    const pc = getProgramCounter(context);
    if (builtin.os.tag == .linux and contexts.sparc_frames) {
        dispatchContextSignal(vm, context, getStackPointer(context), pc, handler);
        return;
    }
    if (contexts.powerpc_frames and (builtin.os.tag == .linux or builtin.os.tag == .freebsd)) {
        dispatchSignalWithLink(vm, getStackPointer(context), pc, handler, factor_powerpc_signal_lr(context).*);
    } else {
        dispatchSignal(vm, getStackPointer(context), pc, handler);
    }
    if (builtin.os.tag == .linux and builtin.cpu.arch == .arm) {
        // sigreturn uses saved CPSR, rather than PC bit zero, to select Thumb.
        // Redirected handlers start outside the interrupted instruction's IT block.
        const uc: *Linux_arm_ucontext = @ptrCast(@alignCast(context));
        const entry = pc.*;
        uc.uc_mcontext.gregs[19] = (uc.uc_mcontext.gregs[19] & ~@as(u32, 0x0600fc20)) |
            @as(u32, @intCast((entry & 1) << 5));
        pc.* = entry & ~@as(Cell, 1);
    }
    if (mips and builtin.os.tag == .linux and !vm.signal_resumable) factor_mips_signal_t9(context, pc.*);
    if (powerpc and (builtin.os.tag == .linux or builtin.os.tag == .freebsd) and !vm.signal_resumable) {
        const registers = factor_powerpc_signal_registers(context);
        const callbacks = @import("callbacks.zig");
        pc.* = callbacks.functionEntry(handler);
        registers[12] = pc.*;
        if (callbacks.usesFunctionDescriptors) {
            const descriptor: *const [3]Cell = @ptrFromInt(handler);
            registers[2] = descriptor[1];
        }
    }
}

fn dispatchContextSignal(vm: *vm_mod.FactorVM, raw: *anyopaque, sp: *Cell, pc: *Cell, handler: Cell) void {
    if (builtin.os.tag != .linux or !contexts.sparc_frames) {
        dispatchSignal(vm, sp, pc, handler);
        return;
    }
    const sparc = @import("sparc.zig");
    const F = sparc.Frame(Cell);
    const ctx = vm.vm_asm.ctx;
    const physical_sp = F.physicalStack(sp.*);
    const limit = ctx.callstack_seg.?.start + contexts.stack_reserved;
    var available: ?*sparc.PendingSignal = null;
    for (&vm.sparc_signal_slots) |*slot| {
        if (slot.active and slot.owner == @as(*anyopaque, @ptrCast(ctx)) and physical_sp >= slot.frame) slot.active = false;
        if (!slot.active and available == null) available = slot;
    }
    const code = vm.code orelse fatalError("Signal without code heap", 0);
    vm.signal_resumable = pc.* >= code.code_start and pc.* < code.code_start + code.code_size and
        physical_sp >= limit + F.minimum_size + 16 and available != null;
    vm.vm_asm.signal_handler_addr = handler;
    if (vm.signal_resumable) {
        const prepare = struct { extern fn factor_sparc_prepare_signal_bridge(*anyopaque, *anyopaque, Cell) callconv(.c) Cell; }.factor_sparc_prepare_signal_bridge;
        const cell = vm.vm_asm.special_objects[@backingInt(objects.SpecialObject.signal_handler_word)];
        if (!layouts.hasTag(cell, .word)) fatalError("Signal handler word not initialized", cell);
        const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(cell));
        const slot = available.?;
        slot.owner = ctx;
        slot.frame = prepare(raw, &slot.saved, word.entry_point);
        slot.active = true;
    } else {
        var frame = ctx.callstack_top;
        if (frame < ctx.callstack_seg.?.start) frame = contexts.frameParent(frame);
        while (frame < ctx.callstack_bottom and frame < limit) {
            const parent = contexts.frameParent(frame);
            if (parent <= frame) fatalError("Invalid SPARC stack chain", frame);
            frame = parent;
        }
        ctx.callstack_top = frame;
        const Context = if (@sizeOf(Cell) == 8) sparc.LinuxContext64 else sparc.LinuxContext32;
        const context: *Context = @ptrCast(@alignCast(raw));
        context.regs[1] = handler;
        context.regs[2] = ctx.datastack;
        context.regs[3] = ctx.retainstack;
        context.regs[4] = @intFromPtr(&vm.vm_asm);
        context.regs[5] = @intFromPtr(ctx);
        context.regs[14] = F.rawStack(frame);
        const enter = struct { extern fn sparc_signal_enter_window() callconv(.c) void; }.sparc_signal_enter_window;
        sparc.redirectSignal(context, @intFromPtr(&enter));
    }
    vm.data_roots.clearRetainingCapacity();
    vm.code_roots.clearRetainingCapacity();
}

pub export fn sparc_signal_resume_frame(frame: Cell) callconv(.c) Cell {
    const vm = g_current_vm orelse fatalError("Signal resume without VM", frame);
    if (!contexts.sparc_frames) fatalError("Signal resume on unsupported CPU", frame);
    var all: std.c.sigset_t = undefined;
    const libc = struct {
        extern fn sigfillset(*std.c.sigset_t) callconv(.c) c_int;
        extern fn sigprocmask(c_int, *const std.c.sigset_t, ?*std.c.sigset_t) callconv(.c) c_int;
    };
    if (libc.sigfillset(&all) != 0 or libc.sigprocmask(1, &all, null) != 0)
        fatalError("SPARC signal resume mask failed", frame);
    for (&vm.sparc_signal_slots) |*slot| {
        if (slot.active and @intFromPtr(&slot.saved) == frame) {
            slot.active = false;
            return frame;
        }
    }
    fatalError("SPARC signal continuation has no owner", frame);
}

// Dispatch signal to Factor code
pub fn dispatchSignal(vm: *vm_mod.FactorVM, sp: *Cell, pc: *Cell, handler: Cell) void {
    if (contexts.powerpc_frames) {
        dispatchSignalWithLink(vm, sp, pc, handler, null);
        return;
    }
    const ctx = vm.vm_asm.ctx;

    const code_heap = vm.code orelse {
        fatalError("Signal without code heap", 0);
    };

    if (code_heap.code_size != 0) {
        std.debug.assert(code_heap.code_size <= std.math.maxInt(Cell) - code_heap.code_start);
    }
    const code_heap_end = code_heap.code_start + code_heap.code_size;

    // Check if we're in Factor code and have a valid stack
    const in_code_seg = code_heap.code_start != 0 and code_heap.code_size != 0 and
        code_heap.code_start <= pc.* and
        pc.* < code_heap_end;

    std.debug.assert(ctx.callstack_seg.?.start <= std.math.maxInt(Cell) - contexts.stack_reserved);
    const cs_limit = ctx.callstack_seg.?.start + contexts.stack_reserved;

    vm.signal_resumable = in_code_seg and sp.* >= cs_limit;

    if (vm.signal_resumable) {
        dispatchResumableSignal(vm, sp, pc, handler);
    } else {
        dispatchNonResumableSignal(vm, sp, pc, handler, cs_limit);
    }

    // Clear data roots as stack pointers have been modified
    vm.data_roots.clearRetainingCapacity();
    vm.code_roots.clearRetainingCapacity();
}

fn powerpcFrameLayout(block: *@import("code_blocks.zig").CodeBlock) struct { end: Cell, prologue: Cell } {
    var prologue = block.entryPoint();
    const frame_size = if (block.blockType() == .pic) 0 else block.stackFrameSize();
    const info = block.blockGcInfo() orelse fatalError("PowerPC code without GC footer", block.entryPoint());
    var end = @intFromPtr(info.gcInfoBitmap());
    if (layouts.hasTag(block.relocation, .byte_array)) {
        const relocation: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
        const count = layouts.untagFixnumUnsigned(relocation.capacity) / @sizeOf(code_blocks.RelocationEntry);
        const entries: [*]const code_blocks.RelocationEntry = @ptrCast(@alignCast(relocation.data()));
        for (entries[0..count]) |entry| {
            const op = code_blocks.InstructionOperand.init(entry, block, 0);
            if (entry.getType() != .here) continue;
            if (op.pointer + 4 > end) continue;
            const next = @as(*const u32, @ptrFromInt(op.pointer)).*;
            if (next >> 26 == 48 or next >> 26 == 50 or (next & 0xfc0007fe) == 0x7c0000ce) {
                const literal: Cell = @bitCast(op.loadValue());
                if (literal >= block.entryPoint() and literal < end) end = literal;
            }
        }
        for (entries[0..count]) |entry| {
            if (entry.getType() != .this or frame_size == 0) continue;
            const op = code_blocks.InstructionOperand.init(entry, block, 0);
            const load_size: Cell = if (@sizeOf(Cell) == 8) 20 else 8;
            if (op.pointer < block.entryPoint() + load_size + 8 or op.pointer > end or
                @as(Cell, @bitCast(op.loadValue())) != block.entryPoint()) continue;
            const candidate = op.pointer - load_size - 8;
            if (factor_powerpc_frame_state(block.entryPoint(), end, candidate, frame_size, candidate) == @backingInt(contexts.PpcSignalFrameState.pre))
                prologue = candidate;
        }
    }
    return .{ .end = end, .prologue = prologue };
}

fn dispatchSignalWithLink(vm: *vm_mod.FactorVM, sp: *Cell, pc: *Cell, handler: Cell, link: ?Cell) void {
    const ctx = vm.vm_asm.ctx;

    const code_heap = vm.code orelse {
        fatalError("Signal without code heap", 0);
    };

    if (code_heap.code_size != 0) {
        std.debug.assert(code_heap.code_size <= std.math.maxInt(Cell) - code_heap.code_start);
    }
    const code_heap_end = code_heap.code_start + code_heap.code_size;

    // Check if we're in Factor code and have a valid stack
    const in_code_seg = code_heap.code_start != 0 and code_heap.code_size != 0 and
        code_heap.code_start <= pc.* and
        pc.* < code_heap_end;

    std.debug.assert(ctx.callstack_seg.?.start <= std.math.maxInt(Cell) - contexts.stack_reserved);
    const cs_limit = ctx.callstack_seg.?.start + contexts.stack_reserved;

    vm.signal_resumable = in_code_seg and sp.* >= cs_limit;

    if (vm.signal_resumable) {
        const previous = sp.*;
        var frame_state: contexts.PpcSignalFrameState = .active;
        if (contexts.powerpc_frames) {
            if (previous > ctx.callstack_bottom or previous & 15 != 0)
                fatalError("Invalid PowerPC interrupted stack pointer", previous);
            const owner = code_heap.codeBlockForAddress(pc.*) orelse fatalError("PowerPC signal without code owner", pc.*);
            const layout = powerpcFrameLayout(owner);
            // PPC PIC hit/miss templates transfer without allocating a frame,
            // including old images whose PIC header records JIT_FRAME_SIZE.
            const frame_size = if (owner.blockType() == .pic) 0 else owner.stackFrameSize();
            const state = factor_powerpc_frame_state(owner.entryPoint(), layout.end, pc.*, frame_size, layout.prologue);
            if (state == 0 or state > 6) fatalError("Unsupported PowerPC interrupted frame layout", pc.*);
            frame_state = @fromBackingInt(@intCast(@as(u3, @intCast(state))));
            if (frame_state == .active and contexts.frameParent(previous) - previous != owner.stackFrameSize())
                fatalError("Unsupported PowerPC temporary stack reservation", pc.*);
            if (frame_state == .temporary and
                (ctx.callstack_bottom - previous <= 32 or
                 contexts.frameParent(previous) - previous != 32 or
                 contexts.frameParent(previous + 32) - previous - 32 != owner.stackFrameSize()))
                fatalError("Invalid PowerPC FPSCR stack reservation", pc.*);
            if (frame_state == .temporary_leaf and
                (ctx.callstack_bottom - previous < 32 or contexts.frameParent(previous) - previous != 32))
                fatalError("Invalid PowerPC leaf FPSCR stack reservation", pc.*);
        }
        dispatchResumableSignal(vm, sp, pc, handler);
        if (contexts.powerpc_frames) {
            contexts.setPpcSignalFrameState(sp.*, frame_state);
            if (frame_state == .leaf or frame_state == .pre or frame_state == .temporary_leaf)
                contexts.setFrameReturnAddress(previous + @as(Cell, if (frame_state == .temporary_leaf) 32 else 0), link orelse fatalError("PowerPC signal without saved LR", previous));
        }
    } else {
        dispatchNonResumableSignal(vm, sp, pc, handler, cs_limit);
    }

    // Clear data roots as stack pointers have been modified
    vm.data_roots.clearRetainingCapacity();
    vm.code_roots.clearRetainingCapacity();
}

fn leafSignalHandlerAvailable(vm: *vm_mod.FactorVM) bool {
    const handler_word_cell = vm.vm_asm.special_objects[@backingInt(objects.SpecialObject.leaf_signal_handler_word)];
    if (!layouts.hasTag(handler_word_cell, .word)) return false;
    const handler_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(handler_word_cell));
    return handler_word.subprimitive != layouts.false_object;
}

// Dispatch resumable signal (fault in Factor code with good stack)
fn dispatchResumableSignal(vm: *vm_mod.FactorVM, sp: *Cell, pc: *Cell, handler: Cell) void {
    vm.vm_asm.signal_handler_addr = handler;

    if (powerpc) {
        const old_sp = sp.*;
        sp.* -= if (@sizeOf(Cell) == 8) 32 else 16;
        @as(*Cell, @ptrFromInt(sp.*)).* = old_sp;
        @as(*Cell, @ptrFromInt(sp.* + contexts.FRAME_RETURN_ADDRESS)).* = pc.*;
        if (contexts.powerpc_frames) contexts.setPpcSignalFrameState(sp.*, .active);
        const handler_cell = vm.vm_asm.special_objects[@backingInt(objects.SpecialObject.signal_handler_word)];
        if (!layouts.hasTag(handler_cell, .word)) fatalError("Signal handler word not initialized", handler_cell);
        const handler_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(handler_cell));
        pc.* = handler_word.entry_point;
        return;
    }

    if (mips or builtin.cpu.arch == .loongarch64 or builtin.cpu.arch == .arm or builtin.cpu.arch == .aarch64 or builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .riscv32 or builtin.cpu.arch == .s390x) {
        // Match C++ dispatch_resumable_signal (vm/cpu-arm.64.cpp).
        const code_heap = vm.code orelse fatalError("Signal without code heap", 0);
        const block = code_heap.codeBlockForAddress(pc.*) orelse
            fatalError("Signal outside a code block", pc.*);
        const frameless = (block.stackFrameSize() == 0 or pc.* == block.entryPoint()) and
            leafSignalHandlerAvailable(vm);
        const word_object: objects.SpecialObject = if (frameless) .leaf_signal_handler_word else .signal_handler_word;
        sp.* -= if (frameless) 16 + code_blocks.CodeBlock.LEAF_FRAME_SIZE else 16;
        @as(*Cell, @ptrFromInt(sp.* + @import("contexts.zig").FRAME_RETURN_ADDRESS)).* = pc.*;

        const handler_word_cell = vm.vm_asm.special_objects[@backingInt(word_object)];
        if (!layouts.hasTag(handler_word_cell, .word)) {
            fatalError("Signal handler word not initialized", handler_word_cell);
        }
        const handler_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(handler_word_cell));
        pc.* = handler_word.entry_point;
        return;
    }

    // x86-64: true stack frames are 16-byte aligned; leaf procedures without a
    // frame are misaligned by sizeof(Cell) and need a fake frame.
    const offset = sp.* % 16;
    var delta: Cell = 0;
    var index: usize = 0;

    if (offset == 0) {
        delta = @sizeOf(Cell);
        index = @backingInt(objects.SpecialObject.signal_handler_word);
    } else if (offset == 16 - @sizeOf(Cell)) {
        delta = 16;
        index = @backingInt(objects.SpecialObject.leaf_signal_handler_word);
    } else {
        fatalError("Invalid stack alignment in signal", offset);
    }

    std.debug.assert(sp.* >= delta);

    const new_sp = sp.* - delta;
    sp.* = new_sp;

    // Store return address
    const return_addr: *Cell = @ptrFromInt(new_sp);
    return_addr.* = pc.*;

    // Jump to signal handler word
    const handler_word_cell = vm.vm_asm.special_objects[index];
    if (layouts.hasTag(handler_word_cell, .word)) {
        const handler_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(handler_word_cell));
        pc.* = handler_word.entry_point;
    } else {
        fatalError("Signal handler word not initialized", handler_word_cell);
    }

    const ctx = vm.vm_asm.ctx;
    ctx.callstack_top = sp.*;
}

// Dispatch non-resumable signal (fault outside Factor code)
//
// This function modifies the ucontext's SP and PC, then RETURNS.
// When sigreturn restores the modified context, execution continues
// at the handler address on the main stack (not signal stack).
fn dispatchNonResumableSignal(vm: *vm_mod.FactorVM, sp: *Cell, pc: *Cell, handler: Cell, limit: Cell) void {
    const ctx = vm.vm_asm.ctx;

    const code_heap = vm.code orelse {
        fatalError("Signal without code heap", 0);
    };

    // A generated-code overflow can occur without any intervening native
    // call saving the context. Its last saved frame may already be reused.
    // The interrupted PowerPC SP names the live linked frame in that case.
    const interrupted_factor_frame = powerpc and code_heap.code_start != 0 and
        pc.* >= code_heap.code_start and pc.* - code_heap.code_start < code_heap.code_size;
    var frame_top = if (interrupted_factor_frame) sp.* else ctx.callstack_top;
    const seg_start = ctx.callstack_seg.?.start;

    if (frame_top < seg_start) {
        // Callstack pointer is outside bounds, try to recover by stepping one frame
        const fault_pc = vm.signal_fault_pc;
        if (code_heap.codeBlockForAddress(fault_pc)) |block| {
            const frame_size = block.stackFrameSizeForAddress(fault_pc);
            std.debug.assert(frame_size <= std.math.maxInt(Cell) - frame_top);
            const frame_top_next = frame_top + frame_size;
            frame_top = frame_top_next;
        }
    }

    // Cut callstack down to shallowest frame that leaves room for handler
    if (frame_top >= seg_start) {
        var iteration: usize = 0;
        while (frame_top < ctx.callstack_bottom and frame_top < limit) {
            frame_top = code_heap.framePredecessor(frame_top);
            iteration += 1;
            if (iteration > 10000) break;
        }
    }

    ctx.callstack_top = frame_top;

    // CRITICAL: Modify the ucontext's SP and PC
    // When the signal handler returns, sigreturn will restore this modified context
    // and execution will continue at 'handler' with stack at 'frame_top'
    // System z native callees spill into a 160-byte caller save area.
    // Reserve it below the Factor header so error reporting preserves roots.
    if (comptime builtin.cpu.arch == .s390x) {
        sp.* = frame_top - 160;
        @as(*Cell, @ptrFromInt(sp.*)).* = frame_top;
    } else if (comptime powerpc) {
        // Native callees write LR and parameter homes in caller linkage slots.
        // Keep those writes below the Factor frame retained for error recovery.
        const linkage_size: Cell = if (builtin.cpu.arch == .powerpc) 80 else if (@import("callbacks.zig").usesFunctionDescriptors) 144 else 128;
        sp.* = frame_top - linkage_size;
        @as(*Cell, @ptrFromInt(sp.*)).* = frame_top;
    } else {
        sp.* = frame_top;
    }
    pc.* = handler;
}

fn initHandlerAddress() void {
    // No-op - address is passed through inline assembly input
}

const Arm64UnwindProbe = struct {
    fn entry() callconv(.naked) void {
        asm volatile (
            \\cmp x29, #0x123
            \\b.ne 1f
            \\cmp x30, #0x456
            \\b.ne 1f
            \\sub x0, sp, x1
            \\cmp x0, #16
            \\b.ne 1f
            \\mov x0, #0
            \\b 2f
            \\1: mov x0, #1
            \\2:
        );
        asm volatile (if (builtin.os.tag == .macos) "b __exit" else "b _exit");
    }
};

test "ARM64 error unwind restores the saved frame before entering Factor" {
    if (builtin.cpu.arch != .aarch64 or builtin.os.tag == .windows) return error.SkipZigTest;
    const pid = std.c.fork();
    try std.testing.expect(pid >= 0);
    if (pid == 0) {
        _ = std.c.alarm(10);
        const vm = vm_mod.FactorVM.init(std.heap.page_allocator) catch std.c._exit(2);
        vm.vm_asm.ctx = vm.newContext() catch std.c._exit(2);
        const to = vm.vm_asm.ctx.callstack_bottom - 16;
        @as(*Cell, @ptrFromInt(to)).* = 0x123;
        @as(*Cell, @ptrFromInt(to + 8)).* = 0x456;
        var word: layouts.Word align(layouts.data_alignment) = undefined;
        vm.vm_asm.special_objects[@backingInt(objects.SpecialObject.unwind_native_frames_word)] = layouts.tag(layouts.Word, &word);
        var quot: layouts.Quotation align(layouts.data_alignment) = undefined;
        quot.entry_point = @intFromPtr(&Arm64UnwindProbe.entry);
        unwindNativeFrames(vm, layouts.tag(layouts.Quotation, &quot), to);
    }
    const status = try waitForChild(pid);
    try std.testing.expect(std.posix.W.IFEXITED(status));
    try std.testing.expectEqual(@as(u8, 0), std.posix.W.EXITSTATUS(status));
}

// This function raises a Factor-level error that Factor's error handling can catch,
// semantics to transfer control to Factor's error handler.
pub fn memory_signal_handler_impl() callconv(.c) void {
    const vm = g_current_vm orelse {
        fatalError("Memory signal handler without VM", 0);
    };

    if (safepoints.isSafepoint(vm, vm.signal_fault_addr)) {
        // Safepoint hit - handle GC coordination, then return to Factor code.
        // Must return immediately — falling through to error handling would
        // corrupt the signal handler's stack frame.
        handleSafepoint(vm, vm.signal_fault_pc);
        return;
    }

    // Memory error - determine type and raise Factor error
    const error_type = addressToError(vm, vm.signal_fault_addr);
    const fault_addr_cell = math_mod.fromUnsignedCell(vm, vm.signal_fault_addr);
    generalError(vm, error_type, fault_addr_cell, layouts.false_object);

    // For non-resumable signals, raise a generic signal error
    if (!vm.signal_resumable) {
        const ctx = vm.vm_asm.ctx;
        ctx.fixStacks();
        generalError(vm, .callstack_overflow, layouts.false_object, layouts.false_object);
    }
}

// Native x87 calls can fault with operands still occupying its register stack.
// Abandoning their C frames also abandons the instructions that would pop those
// operands. Match the C++ VM's fpu-state/set-fpu-state pair: reset the x87 stack
// and exceptions while preserving the caller's precision, rounding, and traps.
fn resetX87AfterTrap() void {
    if (builtin.cpu.arch == .x86 or builtin.cpu.arch == .x86_64) {
        var control: u16 = undefined;
        asm volatile (
            \\fnstcw (%[control])
            \\fninit
            \\fldcw (%[control])
            :
            : [control] "r" (&control),
            : .{ .memory = true });
    }
}

pub fn fp_signal_handler_impl() callconv(.c) void {
    const vm = g_current_vm orelse {
        fatalError("FP signal handler without VM", 0);
    };

    resetX87AfterTrap();
    generalError(vm, .fp_trap, tagFixnum(vm.signal_fpu_status), layouts.false_object);
}

pub fn synchronous_signal_handler_impl() callconv(.c) void {
    const vm = g_current_vm orelse {
        fatalError("Sync signal handler without VM", 0);
    };

    generalError(vm, .signal, tagFixnum(vm.signal_number), layouts.false_object);
}

// Handle safepoint (GC checkpoint)
fn handleSafepoint(vm: *vm_mod.FactorVM, pc: Cell) void {
    safepoints.handleSafepoint(vm, pc) catch |err| {
        fatalError("Failed to handle safepoint", @intFromError(err));
    };
}

// Convert memory address to error type
// This must check the guard pages, not just the usable segment!
fn addressToError(vm: *vm_mod.FactorVM, addr: Cell) VMError {
    if (addr == 0) return .memory;
    const ctx = vm.vm_asm.ctx;
    return ctx.addressToError(addr);
}

// Counter for generalError calls - used to detect infinite error loops.
// Atomic because generalError can be called from signal handlers.
var general_error_count: std.atomic.Value(u32) = std.atomic.Value(u32).init(0);

// Raise a general VM error
// This allocates memory and may trigger GC
pub fn generalError(vm: *vm_mod.FactorVM, error_type: VMError, arg1: Cell, arg2: Cell) noreturn {
    _ = general_error_count.fetchAdd(1, .monotonic);

    // Set faulting flag to prevent recursive faults
    vm.vm_asm.faulting_p = true;

    // If we had an underflow or overflow, stack pointers might be out of bounds
    // Fix them before allocating anything
    const ctx = vm.vm_asm.ctx;

    ctx.fixStacks();

    // If error was thrown during heap scan, re-enable GC
    vm.gc_off = false;

    // Check if error handler is set and we're not in GC
    const error_handler_quot = vm.vm_asm.special_objects[@backingInt(objects.SpecialObject.error_handler_quot)];

    if (!vm.current_gc_p and error_handler_quot != layouts.false_object) {
        // Root arg1 and arg2 against GC - allotUninitializedArray can trigger GC
        var rooted_arg1 = arg1;
        var rooted_arg2 = arg2;
        vm.data_roots.appendAssumeCapacity(&rooted_arg1);
        defer _ = vm.data_roots.pop();
        vm.data_roots.appendAssumeCapacity(&rooted_arg2);
        defer _ = vm.data_roots.pop();

        // Allocate error object: 4-element array with [KERNEL_ERROR, error_type, arg1, arg2]
        const error_array = vm.allotArray(4, layouts.false_object) orelse {
            fatalError("Out of memory allocating error object", @backingInt(error_type));
        };

        // Fill in the error array elements (use rooted values in case GC moved them)
        const arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(error_array));
        const arr_data = arr.data();
        arr_data[0] = tagFixnum(KERNEL_ERROR);
        arr_data[1] = tagFixnum(@backingInt(error_type));
        arr_data[2] = rooted_arg1;
        arr_data[3] = rooted_arg2;

        // Push error object to datastack
        ctx.push(error_array);

        // Clear data roots (we're about to unwind, so root references become invalid)
        vm.data_roots.clearRetainingCapacity();
        vm.code_roots.clearRetainingCapacity();
        vm.current_jit_count = 0;

        // Re-read error handler quotation from special_objects in case GC moved it
        // (allotUninitializedArray above can trigger GC which updates special_objects)
        const current_handler_quot = vm.vm_asm.special_objects[@backingInt(objects.SpecialObject.error_handler_quot)];

        // Unwind to Factor's error handler
        unwindNativeFrames(vm, current_handler_quot, ctx.callstack_top);
    } else {
        // Error during GC or before error handler is set - fatal error
        std.debug.print("You have triggered a bug in Factor. Please report.\n", .{});
        std.debug.print("error: {}\n", .{error_type});
        std.debug.print("arg 1: 0x{x}\n", .{arg1});
        std.debug.print("arg 2: 0x{x}\n", .{arg2});
        fatalError("Error before handler initialized or during GC", @backingInt(error_type));
    }
}

// Call the unwind-native-frames word to unwind C stack and jump to Factor error handler
fn unwindNativeFrames(vm: *vm_mod.FactorVM, quot: Cell, to: Cell) noreturn {
    // Get the unwind_native_frames_word from special objects
    const unwind_word_cell = vm.vm_asm.special_objects[@backingInt(objects.SpecialObject.unwind_native_frames_word)];

    if (!layouts.hasTag(unwind_word_cell, .word)) {
        fatalError("unwind_native_frames_word not initialized", unwind_word_cell);
    }

    // Get quotation entry point for the JMP
    const quot_ptr: *const layouts.Quotation = @ptrFromInt(layouts.UNTAG(quot));
    const quot_entry = quot_ptr.entry_point;

    std.debug.assert(quot_entry != 0);

    // Clear faulting_p BEFORE the jump
    vm.vm_asm.faulting_p = false;

    // Reset error counter since we successfully handled the error
    general_error_count.store(0, .monotonic);

    // We are about to jump into the Factor error handler (JIT code) on the
    // Factor callstack, abandoning every C frame between the fault and here.
    // Force the code heap executable AND reset the W^X writable-nesting depth
    // to 0: any jit_protect.Scope open at fault time (inlineCacheMiss /
    // lazyJitCompile / GC) lives in one of those abandoned frames, so its
    // `defer deinit()` will never run. Leaving the depth >0 would desync all
    // later Scope nesting and leave code pages writable, faulting the handler
    // (ERROR_MEMORY at a code address) into an error-recursion that ends in
    // `die`. No-op on non-W^X platforms (x86-64).
    @import("jit_protect.zig").resetForUnwind();

    // Do the unwind via inline asm
    const vm_asm_ptr = @intFromPtr(&vm.vm_asm);

    if (comptime builtin.cpu.arch == .x86_64) {
        // Explicit register constraints prevent LLVM from placing inputs
        // in r12-r15, which the asm overwrites before the jmp.
        // Use movq to specify 64-bit operand size explicitly.
        asm volatile (
            \\movq %%rsi, %%rsp
            \\movq %%rcx, %%r13
            \\movq (%%r13), %%r12
            \\movq 0x10(%%r12), %%r14
            \\movq 0x18(%%r12), %%r15
            \\jmp *%%rax
            :
            : [vm_asm] "{rcx}" (vm_asm_ptr),
              [entry] "{rax}" (quot_entry),
              [quot_in] "{rdi}" (quot),
              [to_in] "{rsi}" (to),
        );
    } else if (comptime builtin.cpu.arch == .x86) {
        // Match bootstrap.assembler.x86.32 unwind-native-frames: the
        // quotation is in EAX and the restored Factor stack begins at `to`.
        asm volatile (
            \\movl %%edx, %%esp
            \\movl (%%ebx), %%ebp
            \\movl 8(%%ebp), %%esi
            \\movl 12(%%ebp), %%edi
            \\jmp *%%ecx
            :
            : [vm_asm] "{ebx}" (vm_asm_ptr),
              [entry] "{ecx}" (quot_entry),
              [quot_in] "{eax}" (quot),
              [to_in] "{edx}" (to),
        );
    } else if (comptime builtin.cpu.arch == .aarch64) {
        // x86-64 has no dedicated trampoline/safepoint registers, so its unwind
        // only restores vm/ctx/ds/rs. arm64 keeps fixed VM addresses in dedicated
        // registers loaded once at Factor entry (cpu/arm/64 c-to-factor):
        //   X24=SAFEPOINT X25=TRAMPOLINE X26=TRAMPOLINE2 X27=CACHE-MISS X28=MEGA-HITS
        // The error handler uses them (e.g. `blr TRAMPOLINE`=x25 to call a
        // primitive). When we unwind into the handler from a fault that happened
        // in VM C code, these registers hold C-side garbage, so we MUST reload
        // them — otherwise the handler branches through a stale register into
        // non-code memory (observed: blr x25 -> __thread_vars, infinite fault).
        // Values match the RelocationContext used to relocate this code (vm.zig).
        const trampolines = @import("trampolines.zig");
        const c_api = @import("c_api.zig");
        const safepoint_val: Cell = if (vm.code) |c| c.safepoint_page else 0;
        const tramp_val: Cell = @intFromPtr(&trampolines.trampoline);
        const tramp2_val: Cell = @intFromPtr(&trampolines.trampoline2);
        const cachemiss_val: Cell = @intFromPtr(&c_api.inline_cache_miss);
        const megahits_val: Cell = @intFromPtr(&vm.dispatch_stats.megamorphic_cache_hits);
        // Match unwind-native-frames: restore FP/LR and pop the saved frame
        // before entering Factor, abandoning the native function's frame.
        // x16 (IP0 scratch) holds entry to avoid conflicts with x19-x22.
        asm volatile (
            \\mov sp, x1
            \\ldp x29, x30, [sp], #16
            \\mov x19, x2
            \\ldr x20, [x19]
            \\ldr x21, [x20, #0x10]
            \\ldr x22, [x20, #0x18]
            \\mov x24, x3
            \\mov x25, x4
            \\mov x26, x5
            \\mov x27, x6
            \\mov x28, x7
            \\br x16
            :
            : [vm_asm] "{x2}" (vm_asm_ptr),
              [entry] "{x16}" (quot_entry),
              [quot_in] "{x0}" (quot),
              [to_in] "{x1}" (to),
              [safepoint] "{x3}" (safepoint_val),
              [tramp] "{x4}" (tramp_val),
              [tramp2] "{x5}" (tramp2_val),
              [cachemiss] "{x6}" (cachemiss_val),
              [megahits] "{x7}" (megahits_val),
        );
    } else if (comptime builtin.cpu.arch == .arm) {
        const unwind_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(unwind_word_cell));
        asm volatile (
            \\mov r7, r2
            \\bx r12
            :
            : [vm_asm] "{r2}" (vm_asm_ptr),
              [entry] "{r12}" (unwind_word.entry_point),
              [quot_in] "{r0}" (quot),
              [to_in] "{r1}" (to),
        );
    } else if (comptime builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .riscv32) {
        // The unwind word restores the linked frame and every VM register.
        const unwind_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(unwind_word_cell));
        asm volatile (
            \\mv s4, a2
            \\jr t0
            :
            : [vm_asm] "{a2}" (vm_asm_ptr),
              [entry] "{t0}" (unwind_word.entry_point),
              [quot_in] "{a0}" (quot),
              [to_in] "{a1}" (to),
        );
    } else if (comptime builtin.cpu.arch == .loongarch64) {
        const unwind_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(unwind_word_cell));
        asm volatile (
            \\or $s3, $a2, $zero
            \\jirl $zero, $t0, 0
            :
            : [vm_asm] "{r6}" (vm_asm_ptr),
              [entry] "{r12}" (unwind_word.entry_point),
              [quot_in] "{r4}" (quot),
              [to_in] "{r5}" (to),
        );
    } else if (comptime builtin.cpu.arch == .s390x) {
        const unwind_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(unwind_word_cell));
        asm volatile (
            \\lgr %r9,%r4
            \\br %r1
            :
            : [vm_asm] "{r4}" (vm_asm_ptr),
              [entry] "{r1}" (unwind_word.entry_point),
              [quot_in] "{r2}" (quot),
              [to_in] "{r3}" (to),
        );
    } else if (comptime builtin.cpu.arch == .sparc or builtin.cpu.arch == .sparc64) {
        const unwind_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(unwind_word_cell));
        // The generated unwind template consumes the quotation and physical
        // destination in o0/o1 and reloads VM/DS/RS before switching windows.
        asm volatile (
            \\jmpl %[entry], %g0
            \\nop
            :
            : [entry] "{o2}" (unwind_word.entry_point),
              [quot_in] "{o0}" (quot),
              [to_in] "{o1}" (to),
            : .{ .memory = true });
    } else if (comptime mips) {
        const unwind_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(unwind_word_cell));
        factor_mips_unwind(unwind_word.entry_point, quot, to);
    } else if (comptime powerpc) {
        const unwind_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(unwind_word_cell));
        factor_powerpc_unwind(unwind_word.entry_point, quot, to);
    } else @compileError("Unsupported architecture for unwindNativeFrames");

    // If we get here, something went wrong - the unwind word should never return
    abort();
}

// Helper functions - use layouts.tagFixnum for consistency
fn tagFixnum(n: anytype) Cell {
    return layouts.tagFixnum(@intCast(n));
}

fn restoreDefaultAbort() void {
    if (builtin.os.tag == .windows) return;
    const act = std.posix.Sigaction{
        .handler = .{ .handler = std.posix.SIG.DFL },
        .mask = std.posix.sigemptyset(),
        .flags = 0,
    };
    sigactionInt(std.c.SIG.ABRT, &act, null);
}

pub fn abort() noreturn {
    restoreDefaultAbort();
    std.process.abort();
}

pub fn panic(msg: []const u8, first_trace_addr: ?usize) noreturn {
    restoreDefaultAbort();
    std.debug.defaultPanic(msg, first_trace_addr);
}

fn fatalError(msg: []const u8, value: Cell) noreturn {
    if (vm_mod.g_fatal_erroring_p) fatalErrorInFatalError();
    vm_mod.g_fatal_erroring_p = true;
    std.debug.print("fatal_error: {s}: 0x{x}\n", .{ msg, value });
    // Use _exit to avoid atexit handlers and re-triggering signal handlers
    std.c._exit(1);
}

fn fatalErrorInFatalError() noreturn {
    std.debug.print("fatal_error in fatal_error!\n", .{});
    std.c._exit(86);
}

fn exitOnAbort(_: std.posix.SIG) callconv(.c) void {
    std.c._exit(0);
}

fn waitForChild(pid: std.c.pid_t) !u32 {
    var status: c_int = 0;
    try std.testing.expectEqual(pid, std.c.waitpid(pid, &status, 0));
    return @bitCast(status);
}

test "the VM's abort is not caught by an installed SIGABRT handler" {
    if (builtin.os.tag == .windows) return error.SkipZigTest;
    const pid = std.c.fork();
    try std.testing.expect(pid >= 0);
    if (pid == 0) {
        const act = std.posix.Sigaction{
            .handler = .{ .handler = exitOnAbort },
            .mask = std.posix.sigemptyset(),
            .flags = 0,
        };
        sigactionInt(std.c.SIG.ABRT, &act, null);
        _ = std.c.alarm(10);
        abort();
    }
    const status = try waitForChild(pid);
    try std.testing.expect(std.posix.W.IFSIGNALED(status));
    try std.testing.expectEqual(@as(u32, @backingInt(std.posix.SIG.ABRT)), @as(u32, @backingInt(std.posix.W.TERMSIG(status))));
}

test "a fatal error raised while fatal erroring exits with status 86" {
    if (builtin.os.tag == .windows) return error.SkipZigTest;
    const pid = std.c.fork();
    try std.testing.expect(pid >= 0);
    if (pid == 0) {
        const dev_null = std.c.open("/dev/null", .{ .ACCMODE = .WRONLY });
        _ = std.c.dup2(dev_null, std.posix.STDERR_FILENO);
        _ = std.c.alarm(10);
        vm_mod.g_fatal_erroring_p = true;
        fatalError("fatal error while fatal erroring", 0);
    }
    const status = try waitForChild(pid);
    try std.testing.expect(std.posix.W.IFEXITED(status));
    try std.testing.expectEqual(@as(u8, 86), std.posix.W.EXITSTATUS(status));
}

fn minimumSignalStackSize() Cell {
    if (powerpc and builtin.os.tag == .freebsd) return factor_powerpc_signal_stack_size();
    return if (builtin.os.tag == .dragonfly) 40960 else if (builtin.os.tag == .linux) std.os.linux.SIGSTKSZ else std.c.SIGSTKSZ;
}

fn signalStackSize(callstack_size: Cell) Cell {
    return @max(callstack_size, minimumSignalStackSize());
}

test "signal stack is never smaller than SIGSTKSZ" {
    if (builtin.os.tag == .windows) return error.SkipZigTest;
    try std.testing.expectEqual(minimumSignalStackSize(), signalStackSize(1024));
    try std.testing.expectEqual(@as(Cell, 1024 * 1024), signalStackSize(1024 * 1024));
    var seg = try @import("segments.zig").Segment.init(signalStackSize(16 * 1024), false);
    defer seg.deinit();
    var stack = std.posix.stack_t{
        .sp = @ptrFromInt(seg.start),
        .flags = 0,
        .size = @intCast(seg.size),
    };
    var old: std.posix.stack_t = undefined;
    try std.posix.sigaltstack(&stack, &old);
    try std.posix.sigaltstack(&old, null);
}

// Initialize signal handlers
pub fn initSignals(vm: *vm_mod.FactorVM) !void {
    setCurrentVM(vm);

    // Initialize handler addresses for naked wrappers
    initHandlerAddress();
    if (builtin.os.tag == .windows) return @import("windows_signals.zig").init(vm);

    // Create signal pipe for async signal delivery (uses io.zig helper)
    try io.initSignalPipe(vm);

    // NOTE: macOS hardware faults are handled entirely through the BSD signal
    // handlers below (SIGSEGV/SIGBUS/SIGILL/SIGFPE) running on the alternate
    // signal stack. There used to be a Mach exception path (mach_signal.zig),
    // but it never functioned on arm64 — its NEON thread-state struct was
    // mis-sized so thread_get_state always failed and every exception fell
    // through to BSD — so it was removed rather than kept as an illusory,
    // drift-prone second copy of the fault logic.

    // Allocate alternate signal stack
    vm.signal_callstack_seg = try @import("segments.zig").Segment.init(signalStackSize(vm.callstack_size), false);

    var signal_stack = std.posix.stack_t{
        .sp = @ptrFromInt(vm.signal_callstack_seg.?.start),
        .flags = 0,
        .size = @intCast(vm.signal_callstack_seg.?.size),
    };
    try std.posix.sigaltstack(&signal_stack, null);

    // Set up signal handlers using Zig std.posix API
    // On macOS, install both Unix signal handlers and Mach exceptions
    const use_unix_signals = true;
    if (use_unix_signals) {
        // Memory signals (SIGSEGV, SIGBUS, SIGTRAP)
        {
            const act = std.posix.Sigaction{
                .handler = .{ .sigaction = memorySignalHandler },
                .mask = std.posix.sigemptyset(),
                .flags = (std.posix.SA.SIGINFO | std.posix.SA.ONSTACK),
            };
            sigactionInt(std.c.SIG.SEGV, &act, null);
            sigactionInt(std.c.SIG.BUS, &act, null);
            sigactionInt(std.c.SIG.TRAP, &act, null);
        }

        // Floating point exception
        {
            const act = std.posix.Sigaction{
                .handler = .{ .sigaction = fpeSignalHandler },
                .mask = std.posix.sigemptyset(),
                .flags = (std.c.SA.SIGINFO | std.c.SA.ONSTACK),
            };
            sigactionInt(std.c.SIG.FPE, &act, null);
        }

        // Synchronous signals (SIGILL, SIGABRT, SIGQUIT)
        {
            const act = std.posix.Sigaction{
                .handler = .{ .sigaction = synchronousSignalHandler },
                .mask = std.posix.sigemptyset(),
                .flags = (std.c.SA.SIGINFO | std.c.SA.ONSTACK),
            };
            sigactionInt(std.c.SIG.ILL, &act, null);
            sigactionInt(std.c.SIG.ABRT, &act, null);
            sigactionInt(std.c.SIG.QUIT, &act, null);
        }
    }

    // FEP signal (SIGINT / Ctrl-C) - enters debugger
    {
        const act = std.posix.Sigaction{
            .handler = .{ .sigaction = fepSignalHandler },
            .mask = std.posix.sigemptyset(),
            .flags = (std.c.SA.SIGINFO | std.c.SA.ONSTACK),
        };
        sigactionInt(std.c.SIG.INT, &act, null);
    }

    // Enqueue child notifications; leave SIGTERM at its default termination action.
    {
        const act = std.posix.Sigaction{
            .handler = .{ .sigaction = enqueueSignalHandler },
            .mask = std.posix.sigemptyset(),
            .flags = (std.c.SA.SIGINFO | std.c.SA.ONSTACK),
        };
        sigactionInt(std.c.SIG.CHLD, &act, null);
    }

    // Additional async signals (SIGWINCH, SIGUSR1, SIGCONT, SIGURG, SIGIO, SIGPROF, SIGVTALRM)
    {
        const act = std.posix.Sigaction{
            .handler = .{ .sigaction = enqueueSignalHandler },
            .mask = std.posix.sigemptyset(),
            .flags = (std.c.SA.SIGINFO | std.c.SA.ONSTACK),
        };
        sigactionInt(std.c.SIG.WINCH, &act, null);
        sigactionInt(std.c.SIG.USR1, &act, null);
        sigactionInt(std.c.SIG.CONT, &act, null);
        sigactionInt(std.c.SIG.URG, &act, null);
        sigactionInt(std.c.SIG.IO, &act, null);
        sigactionInt(std.c.SIG.PROF, &act, null);
        sigactionInt(std.c.SIG.VTALRM, &act, null);
        // SIGINFO is macOS only
        if (builtin.os.tag == .macos) {
            sigactionInt(std.c.SIG.INFO, &act, null);
        }
    }

    // Sampling profiler (SIGALRM)
    {
        const act = std.posix.Sigaction{
            .handler = .{ .sigaction = sampleSignalHandler },
            .mask = std.posix.sigemptyset(),
            .flags = (std.c.SA.SIGINFO | std.c.SA.ONSTACK),
        };
        sigactionInt(std.c.SIG.ALRM, &act, null);
    }

    // Ignore SIGPIPE and SIGUSR2
    // We don't use SA_IGN here because then the ignore action is inherited
    // by subprocesses, which we don't want. There is a unit test in
    // io.launcher.unix for this.
    // We send SIGUSR2 to the stdin_loop thread to interrupt it on FEP
    {
        const act = std.posix.Sigaction{
            .handler = .{ .sigaction = ignoreSignalHandler },
            .mask = std.posix.sigemptyset(),
            .flags = std.c.SA.SIGINFO,
        };
        sigactionInt(std.c.SIG.PIPE, &act, null);
        sigactionInt(std.c.SIG.USR2, &act, null);
    }
}

// Set SIGINT to default handler (used while in factorbug debugger)
pub fn ignoreCtrlC() void {
    if (builtin.os.tag == .windows) return @import("windows_signals.zig").ignoreCtrlC();
    const act = std.posix.Sigaction{
        .handler = .{ .handler = std.c.SIG.DFL },
        .mask = std.posix.sigemptyset(),
        .flags = 0,
    };
    sigactionInt(std.c.SIG.INT, &act, null);
}

// Re-register SIGINT handler for safepoint-based Ctrl-C (used when leaving factorbug)
pub fn handleCtrlC() void {
    if (builtin.os.tag == .windows) return @import("windows_signals.zig").handleCtrlC();
    const act = std.posix.Sigaction{
        .handler = .{ .sigaction = fepSignalHandler },
        .mask = std.posix.sigemptyset(),
        .flags = (std.c.SA.SIGINFO | std.c.SA.ONSTACK),
    };
    sigactionInt(std.c.SIG.INT, &act, null);
}

// Cleanup signal handlers
pub fn deinitSignals(vm: *vm_mod.FactorVM) void {
    if (builtin.os.tag == .windows) {
        @import("windows_signals.zig").deinit(vm);
        unregisterVmFromThread();
        return;
    }
    if (vm.signal_pipe_input != -1) {
        _ = std.c.close(vm.signal_pipe_input);
        vm.signal_pipe_input = -1;
    }
    if (vm.signal_pipe_output != -1) {
        _ = std.c.close(vm.signal_pipe_output);
        vm.signal_pipe_output = -1;
    }
    if (vm.signal_callstack_seg) |seg| {
        seg.deinit();
        vm.signal_callstack_seg = null;
    }

    unregisterVmFromThread();
}

test "Linux RISC-V signal context follows native glibc layout" {
    if (builtin.os.tag != .linux or (builtin.cpu.arch != .riscv32 and builtin.cpu.arch != .riscv64)) return error.SkipZigTest;
    const gregs_offset = @offsetOf(Linux_riscv_ucontext, "uc_mcontext");
    const fpregs_offset = gregs_offset + @offsetOf(Linux_riscv_mcontext, "fpregs");
    try std.testing.expectEqual(@as(usize, if (@sizeOf(Cell) == 4) 160 else 176), gregs_offset);
    try std.testing.expectEqual(@as(usize, if (@sizeOf(Cell) == 4) 288 else 432), fpregs_offset);
    try std.testing.expectEqual(@as(usize, if (@sizeOf(Cell) == 4) 816 else 960), @sizeOf(Linux_riscv_ucontext));
    var context = std.mem.zeroes(Linux_riscv_ucontext);
    context.uc_mcontext.gregs[0] = 0x12345678;
    context.uc_mcontext.gregs[2] = 0x87654320;
    std.mem.writeInt(u32, context.uc_mcontext.fpregs[256..][0..4], 0x9f, .little);
    try std.testing.expectEqual(@as(Cell, 0x12345678), getProgramCounter(&context).*);
    try std.testing.expectEqual(@as(Cell, 0x87654320), getStackPointer(&context).*);
    try std.testing.expectEqual(@as(u32, 0x9f), getFPUStatus(&context));
    clearFPUStatus(&context);
    try std.testing.expectEqual(@as(u32, 0x80), getFPUStatus(&context));
}

test "Linux i386 signal context restores PC, SP, and FP exceptions" {
    if (builtin.os.tag != .linux or builtin.cpu.arch != .x86) return error.SkipZigTest;
    // Linux/glibc i386 signal ABI: mcontext begins after flags/link/stack_t;
    // the extended kernel FP state stores MXCSR at byte 136.
    try std.testing.expectEqual(@as(usize, 20), @offsetOf(Linux_x86_ucontext, "uc_mcontext"));
    try std.testing.expectEqual(@as(usize, 136), @offsetOf(Linux_x86_fpregset, "mxcsr"));
    var context = std.mem.zeroes(Linux_x86_ucontext);
    context.uc_mcontext.gregs[14] = 0x123456;
    context.uc_mcontext.gregs[7] = 0x789abc;
    try std.testing.expectEqual(@as(Cell, 0x123456), getProgramCounter(&context).*);
    try std.testing.expectEqual(@as(Cell, 0x789abc), getStackPointer(&context).*);
    getProgramCounter(&context).* = 0xfedcba;
    getStackPointer(&context).* = 0x654321;
    try std.testing.expectEqual(@as(i32, 0xfedcba), context.uc_mcontext.gregs[14]);
    try std.testing.expectEqual(@as(i32, 0x654321), context.uc_mcontext.gregs[7]);
    var fp = std.mem.zeroes(Linux_x86_fpregset);
    context.uc_mcontext.fpregs = &fp;
    fp.sw = 1;
    fp.mxcsr = 0x1f84;
    try std.testing.expectEqual(@as(u32, FP_TRAP_INVALID_OPERATION | FP_TRAP_ZERO_DIVIDE), processFPUStatus(getFPUStatus(&context)));
    clearFPUStatus(&context);
    try std.testing.expectEqual(@as(u32, 0), fp.sw);
    try std.testing.expectEqual(@as(u32, 0x1f80), fp.mxcsr);
    fp.magic = 0xffff;
    fp.sw = 0x08;
    fp.mxcsr = 0x04;
    try std.testing.expectEqual(@as(u32, FP_TRAP_OVERFLOW), processFPUStatus(getFPUStatus(&context)));
}

const WorkerThread = if (builtin.os.tag == .netbsd) @import("netbsd_thread.zig").Thread else std.Thread;

test "Linux System z saved signal context" {
    if (builtin.os.tag != .linux or builtin.cpu.arch != .s390x) return error.SkipZigTest;
    var context = std.mem.zeroes(@import("s390x.zig").LinuxContext);
    context.pc = 0x123456;
    context.gregs[15] = 0x789abc;
    try std.testing.expectEqual(@as(Cell, 0x123456), getProgramCounter(&context).*);
    try std.testing.expectEqual(@as(Cell, 0x789abc), getStackPointer(&context).*);
    getProgramCounter(&context).* = 0xfedcba;
    getStackPointer(&context).* = 0x654321;
    try std.testing.expectEqual(@as(u64, 0xfedcba), context.pc);
    try std.testing.expectEqual(@as(u64, 0x654321), context.gregs[15]);
    context.fpc = 0xc0804003;
    try std.testing.expectEqual(@as(u32, FP_TRAP_INVALID_OPERATION | FP_TRAP_ZERO_DIVIDE), processFPUStatus(getFPUStatus(&context)));
    clearFPUStatus(&context);
    try std.testing.expectEqual(@as(u32, 0xc0000003), context.fpc);
}

test "Linux ARM32 signal context restores PC, SP and FPSCR controls" {
    if (builtin.os.tag != .linux or builtin.cpu.arch != .arm) return error.SkipZigTest;
    try std.testing.expectEqual(@as(usize, 20), @offsetOf(Linux_arm_ucontext, "uc_mcontext"));
    try std.testing.expectEqual(@as(usize, 232), @offsetOf(Linux_arm_ucontext, "uc_regspace"));
    var context = std.mem.zeroes(Linux_arm_ucontext);
    context.uc_mcontext.gregs[18] = 0x123456;
    context.uc_mcontext.gregs[16] = 0x789abc;
    try std.testing.expectEqual(@as(Cell, 0x123456), getProgramCounter(&context).*);
    try std.testing.expectEqual(@as(Cell, 0x789abc), getStackPointer(&context).*);
    getProgramCounter(&context).* = 0xfedcba;
    getStackPointer(&context).* = 0x654321;
    try std.testing.expectEqual(@as(u32, 0xfedcba), context.uc_mcontext.gregs[18]);
    try std.testing.expectEqual(@as(u32, 0x654321), context.uc_mcontext.gregs[16]);
    context.uc_regspace[0] = 0x56465001;
    context.uc_regspace[1] = 288;
    context.uc_regspace[66] = 0x0040009f;
    try std.testing.expectEqual(@as(u32, 0x1f), processFPUStatus(getFPUStatus(&context)));
    clearFPUStatus(&context);
    try std.testing.expectEqual(@as(u32, 0x00400000), getFPUStatus(&context));
}

test "PowerPC signal dispatch preserves linked continuation and native entry ABI" {
    if (!powerpc or (builtin.os.tag != .linux and builtin.os.tag != .freebsd)) return error.SkipZigTest;
    const Native = struct {
        extern "c" fn getcontext(context: *anyopaque) c_int;
        fn handler() callconv(.c) void {}
    };
    const vm = try vm_mod.FactorVM.init(std.testing.allocator);
    vm.vm_asm.ctx = try vm.newContext();
    defer vm.deinit();
    var heap: vm_mod.CodeHeap = .{
        .seg = null,
        .safepoint_page = 0,
        .allocator = std.testing.allocator,
        .remembered_sets = @import("write_barrier.zig").CodeHeapRememberedSets.init(std.testing.allocator),
    };
    defer heap.deinit();
    vm.code = &heap;
    defer vm.code = null;
    var context: [8192]u8 align(16) = undefined;
    try std.testing.expectEqual(@as(c_int, 0), Native.getcontext(&context));
    const handler = @intFromPtr(&Native.handler);
    dispatchSignalFromContext(vm, &context, handler);
    const regs = factor_powerpc_signal_registers(&context);
    const callbacks = @import("callbacks.zig");
    try std.testing.expect(!vm.signal_resumable);
    try std.testing.expectEqual(callbacks.functionEntry(handler), factor_powerpc_signal_pc(&context).*);
    try std.testing.expectEqual(factor_powerpc_signal_pc(&context).*, regs[12]);
    try std.testing.expect(regs[1] < vm.vm_asm.ctx.callstack_bottom);
    try std.testing.expectEqual(vm.vm_asm.ctx.callstack_bottom, @as(*const Cell, @ptrFromInt(regs[1])).*);
    if (callbacks.usesFunctionDescriptors)
        try std.testing.expectEqual(@as(*const [3]Cell, @ptrFromInt(handler))[1], regs[2]);

    // The saved context frame is deliberately not part of the live chain.
    // Generated recursive overflow must follow the interrupted frame instead.
    const live_limit = vm.vm_asm.ctx.callstack_seg.?.start + contexts.stack_reserved;
    const live_top = live_limit - 32;
    @as(*Cell, @ptrFromInt(live_top)).* = live_limit;
    heap.code_start = 0x1000;
    heap.code_size = 0x1000;
    var overflow_sp = live_top;
    var overflow_pc: Cell = 0x1100;
    vm.vm_asm.ctx.callstack_top = vm.vm_asm.ctx.callstack_bottom;
    dispatchNonResumableSignal(vm, &overflow_sp, &overflow_pc, handler, live_limit);
    try std.testing.expect(overflow_sp < live_limit);
    try std.testing.expectEqual(live_limit, @as(*const Cell, @ptrFromInt(overflow_sp)).*);
    try std.testing.expectEqual(live_limit, vm.vm_asm.ctx.callstack_top);
    heap.code_start = 0;
    heap.code_size = 0;

    var word: layouts.Word align(layouts.data_alignment) = std.mem.zeroes(layouts.Word);
    word.entry_point = 0x1234;
    vm.vm_asm.special_objects[@backingInt(objects.SpecialObject.signal_handler_word)] = layouts.tag(layouts.Word, &word);
    const old_sp = vm.vm_asm.ctx.callstack_bottom;
    var sp = old_sp;
    var pc: Cell = 0x2468;
    dispatchResumableSignal(vm, &sp, &pc, handler);
    try std.testing.expectEqual(old_sp, @as(*const Cell, @ptrFromInt(sp)).*);
    try std.testing.expectEqual(@as(Cell, 0x2468), @as(*const Cell, @ptrFromInt(sp + contexts.FRAME_RETURN_ADDRESS)).*);
    try std.testing.expectEqual(word.entry_point, pc);
    try std.testing.expectEqual(handler, vm.vm_asm.signal_handler_addr);
}

extern "c" fn factor_mips_signal_context_probe() c_int;
test "MIPS libc signal context preserves target-width PC and SP cells" {
    if (!mips or builtin.os.tag != .linux) return error.SkipZigTest;
    try std.testing.expectEqual(@as(c_int, 0), factor_mips_signal_context_probe());
    try std.testing.expectEqual(@as(u32, FP_TRAP_INVALID_OPERATION | FP_TRAP_ZERO_DIVIDE | FP_TRAP_OVERFLOW | FP_TRAP_UNDERFLOW | FP_TRAP_INEXACT), processFPUStatus(0x1f << 12));
}

extern "c" fn factor_mips_fp_pair_probe() c_int;
test "MIPS O32 uses paired 32-bit floating registers" {
    if (!mips or builtin.os.tag != .linux or @sizeOf(Cell) != 4) return error.SkipZigTest;
    try std.testing.expectEqual(@as(c_int, 0), factor_mips_fp_pair_probe());
}
