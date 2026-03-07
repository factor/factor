// signals.zig - Signal handling infrastructure for Factor VM
// Implements Unix signal handlers for SIGSEGV, SIGBUS, SIGFPE, SIGINT, etc.
// Must be kept in sync with the C++ implementation in vm/os-unix.cpp and vm/errors.cpp

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

const Cell = layouts.Cell;

// Call C sigaction directly - avoids Zig std.posix enum type issues
fn sigactionInt(sig_num: anytype, act: ?*const std.posix.Sigaction, oact: ?*std.posix.Sigaction) void {
    const c_sig: c_int = switch (@typeInfo(@TypeOf(sig_num))) {
        .comptime_int, .int => @intCast(sig_num),
        .@"enum" => @intCast(@intFromEnum(sig_num)),
        else => @compileError("sigactionInt: unsupported signal type"),
    };
    const C = struct {
        extern "c" fn sigaction(c_int, ?*const std.posix.Sigaction, ?*std.posix.Sigaction) c_int;
    };
    _ = C.sigaction(c_sig, act, oact);
}

// VM error types - must match errors.hpp and basis/debugger/debugger.factor
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
// In C++ this is accessed via current_vm() TLS.
threadlocal var g_current_vm: ?*vm_mod.FactorVM = null;

// Thread->VM map for Mach exception handling (non-signal context)
var thread_vm_map: std.AutoHashMapUnmanaged(usize, *vm_mod.FactorVM) = .{};
const SpinMutex = @import("mutex.zig").SpinMutex;
var thread_vm_map_lock: SpinMutex = .{};
var thread_vm_map_allocator: ?std.mem.Allocator = null;

fn pthreadKey(pthread_id: std.c.pthread_t) usize {
    return switch (@typeInfo(std.c.pthread_t)) {
        .pointer => @intFromPtr(pthread_id),
        .int, .comptime_int => @intCast(pthread_id),
        else => @intFromPtr(@as(*const anyopaque, @ptrCast(pthread_id))),
    };
}

pub fn registerVmWithThread(vm: *vm_mod.FactorVM) void {
    g_current_vm = vm;

    const pthread_id = std.c.pthread_self();
    const key = pthreadKey(pthread_id);

    thread_vm_map_lock.lock();
    defer thread_vm_map_lock.unlock();

    const alloc = thread_vm_map_allocator orelse vm.allocator;
    if (thread_vm_map_allocator == null) {
        thread_vm_map_allocator = alloc;
    }

    thread_vm_map.put(alloc, key, vm) catch @panic("OOM");
}

pub fn unregisterVmFromThread() void {
    const pthread_id = std.c.pthread_self();
    const key = pthreadKey(pthread_id);

    thread_vm_map_lock.lock();
    defer thread_vm_map_lock.unlock();

    _ = thread_vm_map.remove(key);
}

pub fn setCurrentVM(vm: *vm_mod.FactorVM) void {
    registerVmWithThread(vm);
}

pub fn getCurrentVM() ?*vm_mod.FactorVM {
    return g_current_vm;
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

// Platform-specific ucontext_t type alias
const Linux_ucontext_t = if (builtin.cpu.arch == .x86_64)
    Linux_x86_64_ucontext
else if (builtin.cpu.arch == .aarch64)
    Linux_aarch64_ucontext
else
    @compileError("Unsupported architecture for Linux signal handling");

// Architecture-specific context access
// These functions extract PC and SP from ucontext_t
// Based on vm/os-unix.hpp and vm/cpu-x86.hpp

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

fn getProgramCounter(ucontext_ptr: *anyopaque) *Cell {
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
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mcontext: [*]u64 = @ptrCast(@alignCast(ucontext.uc_mcontext));
            return @ptrCast(&mcontext[32]); // __pc
        }
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.gregs[16]); // REG_RIP
        } else if (builtin.cpu.arch == .aarch64) {
            const ucontext: *Linux_aarch64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.pc);
        }
    }
    @panic("Unsupported architecture for signal handling");
}

fn getRAX(ucontext_ptr: *anyopaque) Cell {
    if (builtin.os.tag == .macos) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mcontext: [*]u64 = @ptrCast(@alignCast(ucontext.uc_mcontext));
            return mcontext[2]; // __rax = 2 (skip __es) + 0
        }
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @bitCast(ucontext.uc_mcontext.gregs[13]); // REG_RAX
        }
    }
    return 0;
}

fn getRDI(ucontext_ptr: *anyopaque) Cell {
    if (builtin.os.tag == .macos) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mcontext: [*]u64 = @ptrCast(@alignCast(ucontext.uc_mcontext));
            return mcontext[6]; // __rdi = 2 (skip __es) + 4
        }
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @bitCast(ucontext.uc_mcontext.gregs[8]); // REG_RDI
        }
    }
    return 0;
}

fn getStackPointer(ucontext_ptr: *anyopaque) *Cell {
    if (builtin.os.tag == .macos) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mcontext: [*]u64 = @ptrCast(@alignCast(ucontext.uc_mcontext));
            return @ptrCast(&mcontext[9]); // __rsp = 2 (skip __es) + 7
        } else if (builtin.cpu.arch == .aarch64) {
            const ucontext: *MacOS_ucontext_t = @ptrCast(@alignCast(ucontext_ptr));
            const mcontext: [*]u64 = @ptrCast(@alignCast(ucontext.uc_mcontext));
            return @ptrCast(&mcontext[31]); // __sp
        }
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.gregs[15]); // REG_RSP
        } else if (builtin.cpu.arch == .aarch64) {
            const ucontext: *Linux_aarch64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            return @ptrCast(&ucontext.uc_mcontext.sp);
        }
    }
    @panic("Unsupported architecture for signal handling");
}

// FP_TRAP constants from layouts.hpp
const FP_TRAP_INVALID_OPERATION: u32 = 1 << 0;
const FP_TRAP_OVERFLOW: u32 = 1 << 1;
const FP_TRAP_UNDERFLOW: u32 = 1 << 2;
const FP_TRAP_ZERO_DIVIDE: u32 = 1 << 3;
const FP_TRAP_INEXACT: u32 = 1 << 4;

// Get FPU status from signal context
fn getFPUStatus(ucontext_ptr: *anyopaque) u32 {
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
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            // Linux x86_64: fpregs->swd | fpregs->mxcsr
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            if (ucontext.uc_mcontext.fpregs) |fpregs| {
                return fpregs.swd | fpregs.mxcsr;
            }
        } else if (builtin.cpu.arch == .aarch64) {
            // Linux ARM64: fpsr not easily accessible in ucontext, return 0
            return 0;
        }
    }
    return 0;
}

// Clear FPU status bits
fn clearFPUStatus(ucontext_ptr: *anyopaque) void {
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
    } else if (builtin.os.tag == .linux) {
        if (builtin.cpu.arch == .x86_64) {
            const ucontext: *Linux_x86_64_ucontext = @ptrCast(@alignCast(ucontext_ptr));
            if (ucontext.uc_mcontext.fpregs) |fpregs| {
                fpregs.swd = 0;
                fpregs.mxcsr &= 0xffffffc0;
            }
        } else if (builtin.cpu.arch == .aarch64) {
            // Linux ARM64: fpsr not easily accessible in ucontext
        }
    }
}

// Convert FPU status word to Factor format
// Based on cpu-x86.hpp fpu_status() and cpu-arm.64.hpp fpu_status()
pub fn processFPUStatus(status: u32) u32 {
    var r: u32 = 0;
    if (builtin.cpu.arch == .x86_64) {
        // x86 MXCSR/FSW: IE=0, ZE=2, OE=3, UE=4, PE=5
        if (status & 0x01 != 0) r |= FP_TRAP_INVALID_OPERATION;
        if (status & 0x04 != 0) r |= FP_TRAP_ZERO_DIVIDE;
        if (status & 0x08 != 0) r |= FP_TRAP_OVERFLOW;
        if (status & 0x10 != 0) r |= FP_TRAP_UNDERFLOW;
        if (status & 0x20 != 0) r |= FP_TRAP_INEXACT;
    } else if (builtin.cpu.arch == .aarch64) {
        // ARM64 FPSR: IOC=0, DZC=1, OFC=2, UFC=3, IXC=4
        if (status & 0x01 != 0) r |= FP_TRAP_INVALID_OPERATION;
        if (status & 0x02 != 0) r |= FP_TRAP_ZERO_DIVIDE;
        if (status & 0x04 != 0) r |= FP_TRAP_OVERFLOW;
        if (status & 0x08 != 0) r |= FP_TRAP_UNDERFLOW;
        if (status & 0x10 != 0) r |= FP_TRAP_INEXACT;
    } else {
        r = status & 0x1F;
    }
    return r;
}

// Signal handler implementations
// These correspond to the C++ handlers in vm/os-unix.cpp

// Platform-specific siginfo_t type - use std.posix.siginfo_t on all platforms
const SiginfoType = std.posix.siginfo_t;

// Memory signal handler (SIGSEGV, SIGBUS, SIGTRAP)
// This handles both safepoint checks and actual memory errors
fn memorySignalHandler(_: std.posix.SIG, siginfo: *const SiginfoType, ucontext_ptr: ?*anyopaque) callconv(.c) void {
    const vm = g_current_vm orelse std.process.abort();
    const ucontext = ucontext_ptr orelse std.process.abort();

    // Get fault address - structure varies by platform
    const fault_addr: Cell = if (builtin.os.tag == .linux)
        @intFromPtr(siginfo.fields.sigfault.addr)
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
    const sp_ptr = getStackPointer(ucontext);
    dispatchSignal(vm, sp_ptr, pc_ptr, @intFromPtr(&memory_signal_handler_impl));
}

// Floating point exception handler (SIGFPE)
fn fpeSignalHandler(sig: std.posix.SIG, siginfo: *const SiginfoType, ucontext_ptr: ?*anyopaque) callconv(.c) void {
    const vm = g_current_vm orelse std.process.abort();
    const ucontext = ucontext_ptr orelse std.process.abort();

    vm.signal_number = @intFromEnum(sig);
    vm.signal_fpu_status = processFPUStatus(getFPUStatus(ucontext));
    clearFPUStatus(ucontext);

    const sp_ptr = getStackPointer(ucontext);
    const pc_ptr = getProgramCounter(ucontext);

    // Check if it's integer division (FPE_INTDIV=1 or FPE_INTOVF=2)
    const FPE_INTDIV: c_int = 1;
    const FPE_INTOVF: c_int = 2;
    const si_code = siginfo.code;
    const handler = if (si_code == FPE_INTDIV or si_code == FPE_INTOVF)
        @intFromPtr(&synchronous_signal_handler_impl)
    else
        @intFromPtr(&fp_signal_handler_impl);

    dispatchSignal(vm, sp_ptr, pc_ptr, handler);
}

// Synchronous signal handler (SIGILL, etc.)
fn synchronousSignalHandler(sig: std.posix.SIG, _: *const SiginfoType, ucontext_ptr: ?*anyopaque) callconv(.c) void {
    if (vm_mod.g_fatal_erroring_p) return;

    const vm = g_current_vm orelse {
        fatalError("Foreign thread received signal", @intFromEnum(sig));
    };

    vm.signal_number = @intFromEnum(sig);

    const ucontext = ucontext_ptr orelse std.process.abort();
    const sp_ptr = getStackPointer(ucontext);
    const pc_ptr = getProgramCounter(ucontext);

    dispatchSignal(vm, sp_ptr, pc_ptr, @intFromPtr(&synchronous_signal_handler_impl));
}

// FEP (Factor Error Protocol) signal handler for SIGINT (Ctrl-C)
// This enters the low-level debugger instead of just enqueuing the signal
// Based on vm/os-unix.cpp fep_signal_handler
fn fepSignalHandler(sig: std.posix.SIG, _: *const SiginfoType, _: ?*anyopaque) callconv(.c) void {
    if (vm_mod.g_fatal_erroring_p) return;

    const vm = g_current_vm orelse {
        fatalError("Foreign thread received signal", @intFromEnum(sig));
    };

    // Best-effort: signal handler context, mprotect failure is non-recoverable
    safepoints.enqueueFep(vm) catch return;

    // Also enqueue the signal to the signal pipe for async processing
    enqueueSignal(vm, @intCast(@intFromEnum(sig)));
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
    enqueueSignal(vm, @intCast(@intFromEnum(sig)));
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

// Store fault info for signal handler - matches C++ set_memory_protection_error
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

// Dispatch signal to Factor code
// Based on vm/cpu-x86.cpp dispatch_signal_handler
pub fn dispatchSignal(vm: *vm_mod.FactorVM, sp: *Cell, pc: *Cell, handler: Cell) void {
    const ctx = vm.vm_asm.ctx;

    const code_heap = vm.code orelse {
        fatalError("Signal without code heap", 0);
    };

    // Check if we're in Factor code and have a valid stack
    const in_code_seg = code_heap.code_start <= pc.* and
        pc.* < (code_heap.code_start + code_heap.code_size);
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

// Dispatch resumable signal (fault in Factor code with good stack)
// Based on vm/cpu-x86.cpp dispatch_resumable_signal
fn dispatchResumableSignal(vm: *vm_mod.FactorVM, sp: *Cell, pc: *Cell, handler: Cell) void {
    const offset = sp.* % 16;

    vm.vm_asm.signal_handler_addr = handler;

    // True stack frames are always 16-byte aligned.
    // Leaf procedures without stack frames are misaligned by sizeof(Cell).
    var delta: Cell = 0;
    var index: usize = 0;

    if (offset == 0) {
        delta = @sizeOf(Cell);
        index = @intFromEnum(objects.SpecialObject.signal_handler_word);
    } else if (offset == 16 - @sizeOf(Cell)) {
        // Make a fake frame for the leaf procedure
        delta = 16 + @sizeOf(Cell);
        index = @intFromEnum(objects.SpecialObject.leaf_signal_handler_word);
    } else {
        fatalError("Invalid stack alignment in signal", offset);
    }

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

    // Update callstack_top (matches C++ dispatch_resumable_signal)
    const ctx = vm.vm_asm.ctx;
    ctx.callstack_top = sp.*;
}

// Dispatch non-resumable signal (fault outside Factor code)
// Based on vm/cpu-x86.cpp dispatch_non_resumable_signal
//
// This function modifies the ucontext's SP and PC, then RETURNS.
// When sigreturn restores the modified context, execution continues
// at the handler address on the main stack (not signal stack).
fn dispatchNonResumableSignal(vm: *vm_mod.FactorVM, sp: *Cell, pc: *Cell, handler: Cell, limit: Cell) void {
    const ctx = vm.vm_asm.ctx;

    const code_heap = vm.code orelse {
        fatalError("Signal without code heap", 0);
    };

    // Use the last saved callstack pointer instead of the current one
    var frame_top = ctx.callstack_top;
    const seg_start = ctx.callstack_seg.?.start;

    if (frame_top < seg_start) {
        // Callstack pointer is outside bounds, try to recover by stepping one frame
        const fault_pc = vm.signal_fault_pc;
        if (code_heap.codeBlockForAddress(fault_pc)) |block| {
            const frame_size = block.stackFrameSizeForAddress(fault_pc);
            frame_top += frame_size;
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
    sp.* = frame_top;
    pc.* = handler;
}

// Signal handler implementation functions (called from Factor code)

fn initHandlerAddress() void {
    // No-op - address is passed through inline assembly input
}

// Memory signal handler implementation
// Based on vm/errors.cpp memory_signal_handler_impl
//
// This function raises a Factor-level error that Factor's error handling can catch,
// matching the C++ VM behavior. The unwind_native_frames word will use longjmp-like
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

// FP signal handler implementation
pub fn fp_signal_handler_impl() callconv(.c) void {
    const vm = g_current_vm orelse {
        fatalError("FP signal handler without VM", 0);
    };

    generalError(vm, .fp_trap, tagFixnum(vm.signal_fpu_status), layouts.false_object);
}

// Synchronous signal handler implementation
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
// Based on vm/errors.cpp factor_vm::general_error()
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
    const error_handler_quot = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.error_handler_quot)];

    if (!vm.current_gc_p and error_handler_quot != layouts.false_object) {
        // Root arg1 and arg2 against GC - allotUninitializedArray can trigger GC
        var rooted_arg1 = arg1;
        var rooted_arg2 = arg2;
        vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch @panic("OOM");
        vm.data_roots.appendAssumeCapacity(&rooted_arg1);
        defer _ = vm.data_roots.pop();
        vm.data_roots.appendAssumeCapacity(&rooted_arg2);
        defer _ = vm.data_roots.pop();

        // Allocate error object: 4-element array with [KERNEL_ERROR, error_type, arg1, arg2]
        const error_array = vm.allotUninitializedArray(4) orelse {
            fatalError("Out of memory allocating error object", @intFromEnum(error_type));
        };

        // Fill in the error array elements (use rooted values in case GC moved them)
        const arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(error_array));
        const arr_data = arr.data();
        arr_data[0] = tagFixnum(KERNEL_ERROR);
        arr_data[1] = tagFixnum(@intFromEnum(error_type));
        arr_data[2] = rooted_arg1;
        arr_data[3] = rooted_arg2;

        // Push error object to datastack
        ctx.push(error_array);

        // Clear data roots (we're about to unwind, so root references become invalid)
        vm.data_roots.clearRetainingCapacity();
        vm.code_roots.clearRetainingCapacity();

        // Unwind to Factor's error handler
        unwindNativeFrames(vm, error_handler_quot, ctx.callstack_top);
    } else {
        // Error during GC or before error handler is set - fatal error
        std.debug.print("You have triggered a bug in Factor. Please report.\n", .{});
        std.debug.print("error: {}\n", .{error_type});
        std.debug.print("arg 1: 0x{x}\n", .{arg1});
        std.debug.print("arg 2: 0x{x}\n", .{arg2});
        fatalError("Error before handler initialized or during GC", @intFromEnum(error_type));
    }
}

// Call the unwind-native-frames word to unwind C stack and jump to Factor error handler
// Based on vm/entry_points.cpp factor_vm::unwind_native_frames()
fn unwindNativeFrames(vm: *vm_mod.FactorVM, quot: Cell, to: Cell) noreturn {
    // Get the unwind_native_frames_word from special objects
    const unwind_word_cell = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.unwind_native_frames_word)];

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
    } else if (comptime builtin.cpu.arch == .aarch64) {
        // ARM64: x16 (IP0 scratch) holds entry to avoid conflicts with x19-x22.
        asm volatile (
            \\mov sp, x1
            \\mov x19, x2
            \\ldr x20, [x19]
            \\ldr x21, [x20, #0x10]
            \\ldr x22, [x20, #0x18]
            \\br x16
            :
            : [vm_asm] "{x2}" (vm_asm_ptr),
              [entry] "{x16}" (quot_entry),
              [quot_in] "{x0}" (quot),
              [to_in] "{x1}" (to),
        );
    } else @compileError("Unsupported architecture for unwindNativeFrames");

    // If we get here, something went wrong - the unwind word should never return
    std.process.abort();
}

// Helper functions - use layouts.tagFixnum for consistency
fn tagFixnum(n: anytype) Cell {
    return layouts.tagFixnum(@intCast(n));
}

fn fatalError(msg: []const u8, value: Cell) noreturn {
    std.debug.print("fatal_error: {s}: 0x{x}\n", .{ msg, value });
    // Use _exit to avoid atexit handlers and re-triggering signal handlers
    std.c._exit(1);
}

fn fatalErrorInFatalError() noreturn {
    std.debug.print("fatal_error in fatal_error!\n", .{});
    std.c._exit(1);
}

// Initialize signal handlers
pub fn initSignals(vm: *vm_mod.FactorVM) !void {
    setCurrentVM(vm);

    // Initialize handler addresses for naked wrappers
    initHandlerAddress();

    // Create signal pipe for async signal delivery (uses io.zig helper)
    try io.initSignalPipe(vm);

    // On macOS, try to initialize Mach exception handling
    if (builtin.os.tag == .macos) {
        const mach_signal = @import("mach_signal.zig");
        try mach_signal.machInitialize();
    }

    // Allocate alternate signal stack
    vm.signal_callstack_seg = try @import("segments.zig").Segment.init(vm.callstack_size, false);

    var signal_stack = std.posix.stack_t{
        .sp = @ptrFromInt(vm.signal_callstack_seg.?.start),
        .flags = 0,
        .size = @intCast(vm.signal_callstack_seg.?.size),
    };
    try std.posix.sigaltstack(&signal_stack, null);

    // Set up signal handlers using Zig std.posix API
    // On macOS, install both Unix signal handlers and Mach exceptions
    // (matches the C++ VM behavior).
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

    // Async signals (SIGTERM, SIGCHLD)
    {
        const act = std.posix.Sigaction{
            .handler = .{ .sigaction = enqueueSignalHandler },
            .mask = std.posix.sigemptyset(),
            .flags = (std.c.SA.SIGINFO | std.c.SA.ONSTACK),
        };
        sigactionInt(std.c.SIG.TERM, &act, null);
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
    const act = std.posix.Sigaction{
        .handler = .{ .handler = std.c.SIG.DFL },
        .mask = std.posix.sigemptyset(),
        .flags = 0,
    };
    sigactionInt(std.c.SIG.INT, &act, null);
}

// Re-register SIGINT handler for safepoint-based Ctrl-C (used when leaving factorbug)
pub fn handleCtrlC() void {
    const act = std.posix.Sigaction{
        .handler = .{ .sigaction = fepSignalHandler },
        .mask = std.posix.sigemptyset(),
        .flags = (std.c.SA.SIGINFO | std.c.SA.ONSTACK),
    };
    sigactionInt(std.c.SIG.INT, &act, null);
}

// Cleanup signal handlers
pub fn deinitSignals(vm: *vm_mod.FactorVM) void {
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
