// mach_signal.zig - Mach exception handling for macOS
// Implements Mach exception port handling for Factor VM
// Based on vm/mach_signal.cpp from the C++ VM
//
// On macOS, hardware exceptions (SIGSEGV, SIGILL, etc.) are better handled via
// Mach exceptions for more reliable behavior. This replaces Unix signal handling
// on macOS with a Mach exception port and handler thread.

const std = @import("std");
const builtin = @import("builtin");

const contexts = @import("contexts.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const safepoints = @import("safepoints.zig");
const signals = @import("signals.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;

// Only compile this module on macOS
comptime {
    if (builtin.os.tag != .macos) {
        @compileError("mach_signal.zig is only for macOS");
    }
}

// Mach kernel types, constants, and functions from system headers
const c = @cImport({
    @cInclude("mach/mach.h");
    @cInclude("mach/exception_types.h");
    @cInclude("pthread.h");
});

const mach_port_t = c.mach_port_t;
const kern_return_t = c.kern_return_t;
const exception_type_t = c.exception_type_t;
const exception_data_type_t = c.exception_data_type_t;
const mach_msg_type_number_t = c.mach_msg_type_number_t;
const exception_mask_t = c.exception_mask_t;
const exception_behavior_t = c.exception_behavior_t;
const thread_state_flavor_t = c.thread_state_flavor_t;
const mach_msg_header_t = c.mach_msg_header_t;
const mach_msg_body_t = c.mach_msg_body_t;

const KERN_SUCCESS = c.KERN_SUCCESS;
const KERN_FAILURE = c.KERN_FAILURE;
const EXC_BAD_ACCESS = c.EXC_BAD_ACCESS;
const EXC_BAD_INSTRUCTION = c.EXC_BAD_INSTRUCTION;
const EXC_ARITHMETIC = c.EXC_ARITHMETIC;
const EXC_MASK_BAD_ACCESS = c.EXC_MASK_BAD_ACCESS;
const EXC_MASK_BAD_INSTRUCTION = c.EXC_MASK_BAD_INSTRUCTION;
const EXC_MASK_ARITHMETIC = c.EXC_MASK_ARITHMETIC;
const EXCEPTION_DEFAULT = c.EXCEPTION_DEFAULT;
const MACHINE_THREAD_STATE = c.MACHINE_THREAD_STATE;
const MACH_MSG_TYPE_MAKE_SEND = c.MACH_MSG_TYPE_MAKE_SEND;
const MACH_PORT_RIGHT_RECEIVE = c.MACH_PORT_RIGHT_RECEIVE;
const MACH_RCV_MSG = c.MACH_RCV_MSG;
const MACH_RCV_LARGE = c.MACH_RCV_LARGE;
const MACH_SEND_MSG = c.MACH_SEND_MSG;
const MACH_MSG_TIMEOUT_NONE = c.MACH_MSG_TIMEOUT_NONE;
const MACH_PORT_NULL = c.MACH_PORT_NULL;

// Architecture-specific state types and accessors.
// Thread/exception state structs and flavor constants come from @cImport.
// Float state structs are defined manually because Zig's C translator
// demotes them to opaque (complex nested __darwin_mmst_reg fields).
const ArchState = if (builtin.cpu.arch == .x86_64)
    struct {
        const exception_state_t = c.__darwin_x86_exception_state64;
        const thread_state_t = c.__darwin_x86_thread_state64;

        // Manual: @cImport makes this opaque due to nested struct types
        const float_state_t = extern struct {
            __fpu_reserved: [2]c_int,
            __fpu_fcw: u16,
            __fpu_fsw: u16,
            __fpu_ftw: u8,
            __fpu_rsrv1: u8,
            __fpu_fop: u16,
            __fpu_ip: u32,
            __fpu_cs: u16,
            __fpu_rsrv2: u16,
            __fpu_dp: u32,
            __fpu_ds: u16,
            __fpu_rsrv3: u16,
            __fpu_mxcsr: u32,
            __fpu_mxcsrmask: u32,
            __fpu_stmm0: [16]u8,
            __fpu_stmm1: [16]u8,
            __fpu_stmm2: [16]u8,
            __fpu_stmm3: [16]u8,
            __fpu_stmm4: [16]u8,
            __fpu_stmm5: [16]u8,
            __fpu_stmm6: [16]u8,
            __fpu_stmm7: [16]u8,
            __fpu_xmm0: [16]u8,
            __fpu_xmm1: [16]u8,
            __fpu_xmm2: [16]u8,
            __fpu_xmm3: [16]u8,
            __fpu_xmm4: [16]u8,
            __fpu_xmm5: [16]u8,
            __fpu_xmm6: [16]u8,
            __fpu_xmm7: [16]u8,
            __fpu_xmm8: [16]u8,
            __fpu_xmm9: [16]u8,
            __fpu_xmm10: [16]u8,
            __fpu_xmm11: [16]u8,
            __fpu_xmm12: [16]u8,
            __fpu_xmm13: [16]u8,
            __fpu_xmm14: [16]u8,
            __fpu_xmm15: [16]u8,
            __fpu_rsrv4: [96]u8,
            __fpu_reserved1: c_int,
        };

        const EXC_STATE_FLAVOR = c.x86_EXCEPTION_STATE64;
        const EXC_STATE_COUNT = c.x86_EXCEPTION_STATE64_COUNT;
        const THREAD_STATE_FLAVOR = c.x86_THREAD_STATE64;
        const THREAD_STATE_COUNT = c.x86_THREAD_STATE64_COUNT;
        const FLOAT_STATE_FLAVOR = c.x86_FLOAT_STATE64;
        const FLOAT_STATE_COUNT: mach_msg_type_number_t = @sizeOf(float_state_t) / @sizeOf(c_uint);

        const EXC_INTEGER_DIV: exception_data_type_t = c.EXC_I386_DIV;

        fn getFaultAddr(exc_state: *const exception_state_t) u64 {
            return exc_state.__faultvaddr;
        }

        fn getPC(thread_state: *const thread_state_t) u64 {
            return thread_state.__rip;
        }

        fn setPC(thread_state: *thread_state_t, pc: u64) void {
            thread_state.__rip = pc;
        }

        fn getSP(thread_state: *const thread_state_t) u64 {
            return thread_state.__rsp;
        }

        fn setR12(thread_state: *thread_state_t, val: u64) void {
            thread_state.__r12 = val;
        }

        fn setR13(thread_state: *thread_state_t, val: u64) void {
            thread_state.__r13 = val;
        }

        fn setR14(thread_state: *thread_state_t, val: u64) void {
            thread_state.__r14 = val;
        }

        fn setR15(thread_state: *thread_state_t, val: u64) void {
            thread_state.__r15 = val;
        }

        fn setRDI(thread_state: *thread_state_t, val: u64) void {
            thread_state.__rdi = val;
        }

        fn setRSI(thread_state: *thread_state_t, val: u64) void {
            thread_state.__rsi = val;
        }

        fn setSP(thread_state: *thread_state_t, sp: u64) void {
            thread_state.__rsp = sp;
        }

        fn getFPUStatus(float_state: *const float_state_t) u32 {
            const x87sw = float_state.__fpu_fsw;
            return float_state.__fpu_mxcsr | x87sw;
        }

        fn clearFPUStatus(float_state: *float_state_t) void {
            float_state.__fpu_mxcsr &= 0xffffffc0;
            float_state.__fpu_fsw = 0;
        }
    }
else if (builtin.cpu.arch == .aarch64)
    struct {
        const exception_state_t = c.__darwin_arm_exception_state64;
        const thread_state_t = c.__darwin_arm_thread_state64;

        // Manual: @cImport makes NEON state opaque due to __darwin_arm_neon_state128
        const float_state_t = extern struct {
            __v: [32][16]u8, // 128-bit SIMD registers
            __fpsr: u32,
            __fpcr: u32,
        };

        const EXC_STATE_FLAVOR = c.ARM_EXCEPTION_STATE64;
        const EXC_STATE_COUNT = c.ARM_EXCEPTION_STATE64_COUNT;
        const THREAD_STATE_FLAVOR = c.ARM_THREAD_STATE64;
        const THREAD_STATE_COUNT = c.ARM_THREAD_STATE64_COUNT;
        const FLOAT_STATE_FLAVOR = c.ARM_NEON_STATE64;
        const FLOAT_STATE_COUNT: mach_msg_type_number_t = @sizeOf(float_state_t) / @sizeOf(c_uint);

        const EXC_INTEGER_DIV: exception_data_type_t = 0x0200; // EXC_ARM_FP_DZ

        fn getFaultAddr(exc_state: *const exception_state_t) u64 {
            return exc_state.__far;
        }

        fn getPC(thread_state: *const thread_state_t) u64 {
            return thread_state.__pc;
        }

        fn setPC(thread_state: *thread_state_t, pc: u64) void {
            thread_state.__pc = pc;
        }

        fn getSP(thread_state: *const thread_state_t) u64 {
            return thread_state.__sp;
        }

        fn setSP(thread_state: *thread_state_t, sp: u64) void {
            thread_state.__sp = sp;
        }

        fn setX0(thread_state: *thread_state_t, val: u64) void {
            thread_state.__x[0] = val;
        }

        fn setX1(thread_state: *thread_state_t, val: u64) void {
            thread_state.__x[1] = val;
        }

        fn getFPUStatus(float_state: *const float_state_t) u32 {
            return float_state.__fpsr;
        }

        fn clearFPUStatus(float_state: *float_state_t) void {
            float_state.__fpsr = 0;
        }
    }
else
    @compileError("Unsupported architecture for Mach exception handling");

// Import type aliases for cleaner code
const ExceptionState = ArchState.exception_state_t;
const ThreadState = ArchState.thread_state_t;
const FloatState = ArchState.float_state_t;

// Exception port (global variable, set by mach_initialize)
var our_exception_port: mach_port_t = MACH_PORT_NULL;

// Mach API functions from @cImport
const mach_task_self = c.mach_task_self;
const mach_port_allocate = c.mach_port_allocate;
const mach_port_insert_right = c.mach_port_insert_right;
const task_set_exception_ports = c.task_set_exception_ports;
const thread_get_state = c.thread_get_state;
const thread_set_state = c.thread_set_state;
const mach_msg = c.mach_msg;
// Keep as extern: @cImport's pthread_t is a different opaque type than std.c.pthread_t
extern "c" fn pthread_from_mach_thread_np(thread: mach_port_t) std.c.pthread_t;

// exc_server is generated by mig (Mach Interface Generator) from exc.defs
// It unmarshals the exception message and calls catch_exception_raise
extern "c" fn exc_server(request: *mach_msg_header_t, reply: *mach_msg_header_t) c_int;

// Call the VM's fault handler to modify thread state
// Based on factor_vm::call_fault_handler in mach_signal.cpp
//
// For memory exceptions, we directly set up the Factor error handler by:
// 1. Allocating the error object and pushing to datastack
// 2. Setting all Factor registers (R12, R13, R14, R15) in thread state
// 3. Setting PC to error handler quotation's entry point
// 4. Setting SP to callstack_top
// This bypasses the unwind word which has issues under Rosetta.
fn callFaultHandler(
    vm: *vm_mod.FactorVM,
    exception: exception_type_t,
    code: exception_data_type_t,
    exc_state: *ExceptionState,
    thread_state: *ThreadState,
    float_state: *FloatState,
) void {
    const fault_addr = ArchState.getFaultAddr(exc_state);
    const fault_pc = ArchState.getPC(thread_state);

    if (exception == EXC_BAD_ACCESS) {
        if (safepoints.isSafepoint(vm, fault_addr)) {
            // Safepoint hit: handle directly in Mach handler thread.
            // The faulted thread is suspended, so we can safely disarm the
            // safepoint page and handle profiler/FEP without redirecting
            // through the signal handler word. The thread resumes at its
            // original faulted PC, which re-executes the safepoint touch
            // on the now-unprotected page.
            safepoints.disarmSafepoint(vm) catch {};

            if (safepoints.safepoint_fep_p.load(.monotonic)) {
                // FEP (debugger interrupt) needs to run on the faulted thread
                // because it enters an interactive debugger loop. Dispatch
                // through the signal handler word.
                signals.setMemoryProtectionError(vm, fault_addr, fault_pc);
                var sp = ArchState.getSP(thread_state);
                var pc = ArchState.getPC(thread_state);
                signals.dispatchSignal(vm, @ptrCast(&sp), @ptrCast(&pc), @intFromPtr(&signals.memory_signal_handler_impl));
                ArchState.setSP(thread_state, sp);
                ArchState.setPC(thread_state, pc);
            } else if (safepoints.sampling_profiler_p.load(.monotonic)) {
                // Profiler safepoint: record sample directly.
                // The faulted thread's callstack is frozen and walkable.
                safepoints.recordSampleFromMach(vm, fault_pc, ArchState.getSP(thread_state));
            }
            // Thread state is not modified (except for FEP case above).
            // Thread resumes at faulted PC; page is now writable.
        } else if (handleMemoryErrorDirect(vm, fault_addr, fault_pc, thread_state)) {
            // Handled directly
        } else {
            signals.setMemoryProtectionError(vm, fault_addr, fault_pc);
            var sp = ArchState.getSP(thread_state);
            var pc = ArchState.getPC(thread_state);
            signals.dispatchSignal(vm, @ptrCast(&sp), @ptrCast(&pc), @intFromPtr(&signals.memory_signal_handler_impl));
            ArchState.setSP(thread_state, sp);
            ArchState.setPC(thread_state, pc);
        }
    } else if (exception == EXC_ARITHMETIC and code != ArchState.EXC_INTEGER_DIV) {
        // Floating point exception
        vm.signal_fpu_status = signals.processFPUStatus(ArchState.getFPUStatus(float_state));
        ArchState.clearFPUStatus(float_state);
        var sp = ArchState.getSP(thread_state);
        var pc = ArchState.getPC(thread_state);
        signals.dispatchSignal(vm, @ptrCast(&sp), @ptrCast(&pc), @intFromPtr(&signals.fp_signal_handler_impl));
        ArchState.setSP(thread_state, sp);
        ArchState.setPC(thread_state, pc);
    } else {
        // Other synchronous exceptions
        vm.signal_number = switch (exception) {
            EXC_ARITHMETIC => @intFromEnum(std.c.SIG.FPE),
            EXC_BAD_INSTRUCTION => @intFromEnum(std.c.SIG.ILL),
            else => @intFromEnum(std.c.SIG.ABRT),
        };
        var sp = ArchState.getSP(thread_state);
        var pc = ArchState.getPC(thread_state);
        signals.dispatchSignal(vm, @ptrCast(&sp), @ptrCast(&pc), @intFromPtr(&signals.synchronous_signal_handler_impl));
        ArchState.setSP(thread_state, sp);
        ArchState.setPC(thread_state, pc);
    }
}

// Handle memory error directly by jumping to the unwind word.
// Sets up RDI=quotation, RSI=target_sp, PC=unwind_word_entry so the
// faulting thread resumes in JIT-compiled Factor code, bypassing any
// Zig function on the redirected stack. This is critical under Rosetta 2
// which cannot resume Zig-compiled code after a synchronous exception.
// Returns true if successful, false if fallback to dispatchSignal is needed.
fn handleMemoryErrorDirect(vm: *vm_mod.FactorVM, fault_addr: Cell, fault_pc: Cell, thread_state: *ThreadState) bool {
    const ctx = vm.vm_asm.ctx;

    const error_handler_quot = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.error_handler_quot)];
    if (error_handler_quot == layouts.false_object) return false;
    if (vm.current_gc_p) return false;

    const unwind_word_cell = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.unwind_native_frames_word)];
    if (!layouts.hasTag(unwind_word_cell, .word)) return false;

    const error_type = ctx.addressToError(fault_addr);

    // Callstack underflow is extremely rare; let the dispatchSignal path handle it.
    if (error_type == .callstack_underflow) return false;

    const is_callstack_overflow = (error_type == .callstack_overflow);

    // Set faulting flag (unwind word will clear this)
    vm.vm_asm.faulting_p = true;

    // Fix stacks
    ctx.fixStacks();
    vm.gc_off = false;

    // Determine target SP. For callstack overflow, callstack_top is near the
    // guard page so we walk frames upward past stack_reserved to find a safe SP.
    // This replicates the logic from dispatchNonResumableSignal in signals.zig.
    var target_sp = ctx.callstack_top;

    if (is_callstack_overflow) {
        const code_heap = vm.code orelse return false;
        const seg = ctx.callstack_seg orelse return false;
        const seg_start = seg.start;
        const cs_limit = seg_start + contexts.stack_reserved;
        var frame_top = ctx.callstack_top;

        if (frame_top < seg_start) {
            if (code_heap.codeBlockForAddress(fault_pc)) |block| {
                frame_top += block.stackFrameSizeForAddress(fault_pc);
            }
        }

        if (frame_top >= seg_start) {
            var iteration: usize = 0;
            while (frame_top < ctx.callstack_bottom and frame_top < cs_limit) {
                frame_top = code_heap.framePredecessor(frame_top);
                iteration += 1;
                if (iteration > 10000) break;
            }
        }

        ctx.callstack_top = frame_top;
        target_sp = frame_top;
    }

    // Allocate error array [KERNEL_ERROR, error_type, arg1, false]
    const error_array = vm.allotUninitializedArray(4) orelse return false;

    const arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(error_array));
    const arr_data = arr.data();
    arr_data[0] = layouts.tagFixnum(signals.KERNEL_ERROR);
    arr_data[1] = layouts.tagFixnum(@intFromEnum(error_type));
    arr_data[2] = if (is_callstack_overflow)
        layouts.false_object
    else if (fault_addr <= @as(Cell, @bitCast(@as(layouts.Fixnum, std.math.maxInt(layouts.Fixnum) >> @intCast(layouts.tag_bits)))))
        layouts.tagFixnum(@intCast(fault_addr))
    else
        layouts.tagFixnum(0);
    arr_data[3] = layouts.false_object;

    // Push error to datastack (in memory)
    ctx.push(error_array);

    // Get unwind word entry point
    const unwind_word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(unwind_word_cell));
    const unwind_entry = unwind_word.entry_point;

    // Set up arguments for unwind word and jump to it
    // The unwind word expects: RDI = quotation, RSI = callstack_top
    // It will then: set RSP=RSI, load R12/R14/R15 from ctx, clear faulting_p, JMP to quotation
    if (builtin.cpu.arch == .x86_64) {
        ArchState.setRDI(thread_state, error_handler_quot);
        ArchState.setRSI(thread_state, target_sp);
        ArchState.setPC(thread_state, unwind_entry);
    } else if (builtin.cpu.arch == .aarch64) {
        ArchState.setX0(thread_state, error_handler_quot);
        ArchState.setX1(thread_state, target_sp);
        ArchState.setPC(thread_state, unwind_entry);
    }

    // Clear roots (unwind word will clear faulting_p)
    vm.data_roots.clearRetainingCapacity();
    vm.code_roots.clearRetainingCapacity();

    return true;
}

// Additional exception handler variants (required by exc_server but not used)
// These are part of the MIG-generated interface but we only use catch_exception_raise
export fn catch_exception_raise_state(
    _: mach_port_t,
    _: exception_type_t,
    _: [*c]exception_data_type_t,
    _: mach_msg_type_number_t,
    _: *thread_state_flavor_t,
    _: *anyopaque,
    _: mach_msg_type_number_t,
    _: *anyopaque,
    _: *mach_msg_type_number_t,
) callconv(.c) kern_return_t {
    return KERN_FAILURE;
}

export fn catch_exception_raise_state_identity(
    _: mach_port_t,
    _: mach_port_t,
    _: mach_port_t,
    _: exception_type_t,
    _: [*c]exception_data_type_t,
    _: mach_msg_type_number_t,
    _: *thread_state_flavor_t,
    _: *anyopaque,
    _: mach_msg_type_number_t,
    _: *anyopaque,
    _: *mach_msg_type_number_t,
) callconv(.c) kern_return_t {
    return KERN_FAILURE;
}

// Mach exception handler callback
// This is called by exc_server when an exception message is received
// Based on catch_exception_raise in mach_signal.cpp
export fn catch_exception_raise(
    _: mach_port_t,
    thread: mach_port_t,
    task: mach_port_t,
    exception: exception_type_t,
    code: [*c]exception_data_type_t,
    _: mach_msg_type_number_t,
) callconv(.c) kern_return_t {
    // Ignore exceptions from child processes (macOS 10.6+)
    if (task != mach_task_self()) return KERN_FAILURE;

    // Get exception state (fault address, etc.)
    var exc_state: ExceptionState = undefined;
    var exc_state_count: mach_msg_type_number_t = ArchState.EXC_STATE_COUNT;
    if (thread_get_state(
        thread,
        ArchState.EXC_STATE_FLAVOR,
        @ptrCast(&exc_state),
        &exc_state_count,
    ) != KERN_SUCCESS) return KERN_FAILURE;

    // Get thread state (registers)
    var thread_state: ThreadState = undefined;
    var thread_state_count: mach_msg_type_number_t = ArchState.THREAD_STATE_COUNT;
    if (thread_get_state(
        thread,
        ArchState.THREAD_STATE_FLAVOR,
        @ptrCast(&thread_state),
        &thread_state_count,
    ) != KERN_SUCCESS) return KERN_FAILURE;

    // Get float state (FPU registers)
    var float_state: FloatState = undefined;
    var float_state_count: mach_msg_type_number_t = ArchState.FLOAT_STATE_COUNT;
    if (thread_get_state(
        thread,
        ArchState.FLOAT_STATE_FLAVOR,
        @ptrCast(&float_state),
        &float_state_count,
    ) != KERN_SUCCESS) return KERN_FAILURE;

    // Look up the VM instance for this thread
    const pthread_id = pthread_from_mach_thread_np(thread);
    const vm = signals.getVmForThread(pthread_id) orelse return KERN_FAILURE;

    // Call the fault handler to modify thread state
    callFaultHandler(vm, exception, code[0], &exc_state, &thread_state, &float_state);

    // Set the modified float state
    if (thread_set_state(
        thread,
        ArchState.FLOAT_STATE_FLAVOR,
        @ptrCast(&float_state),
        float_state_count,
    ) != KERN_SUCCESS) return KERN_FAILURE;

    // Set the modified thread state (PC and SP changed)
    if (thread_set_state(
        thread,
        ArchState.THREAD_STATE_FLAVOR,
        @ptrCast(&thread_state),
        thread_state_count,
    ) != KERN_SUCCESS) return KERN_FAILURE;

    return KERN_SUCCESS;
}

// Mach exception handler thread function
// This thread receives exception messages and dispatches them
// Based on mach_exception_thread in mach_signal.cpp
fn machExceptionThread(_: ?*anyopaque) callconv(.c) ?*anyopaque {
    // Message buffers (contain private kernel data, we just forward them)
    const MsgBuffer = extern struct {
        head: mach_msg_header_t,
        body: mach_msg_body_t,
        data: [1024]u8,
    };

    const ReplyBuffer = extern struct {
        head: mach_msg_header_t,
        data: [1024]u8,
    };

    while (true) {
        var msg: MsgBuffer = undefined;
        var reply: ReplyBuffer = undefined;

        // Wait for exception message
        const rcv_result = mach_msg(
            &msg.head,
            MACH_RCV_MSG | MACH_RCV_LARGE,
            0,
            @sizeOf(MsgBuffer),
            our_exception_port,
            MACH_MSG_TIMEOUT_NONE,
            MACH_PORT_NULL,
        );

        if (rcv_result != KERN_SUCCESS) {
            std.process.abort();
        }

        // Handle the exception (calls catch_exception_raise)
        _ = exc_server(&msg.head, &reply.head);

        // Send the reply
        const send_result = mach_msg(
            &reply.head,
            MACH_SEND_MSG,
            reply.head.msgh_size,
            0,
            MACH_PORT_NULL,
            MACH_MSG_TIMEOUT_NONE,
            MACH_PORT_NULL,
        );

        if (send_result != KERN_SUCCESS) {
            std.process.abort();
        }
    }

    return null;
}

// Detect if we're running under Rosetta (x86_64 emulation on Apple Silicon)
pub fn isRunningUnderRosetta() bool {
    var ret: c_int = 0;
    var size: usize = @sizeOf(c_int);
    const result = std.c.sysctlbyname(
        "sysctl.proc_translated",
        @ptrCast(&ret),
        &size,
        null,
        0,
    );
    if (result == -1) return false;
    return ret == 1;
}

// Global flag set when running under Rosetta - Mach exceptions don't work properly
pub var g_running_under_rosetta: bool = false;

// Initialize Mach exception handling
// Based on mach_initialize in mach_signal.cpp
pub fn machInitialize() !void {
    // Force the linker to include catch_exception_raise and friends.
    // exc_server (from libsystem_kernel) calls these by symbol name at runtime.
    // Without explicit references, the Zig linker dead-strips them.
    forceExportExcHandlers();

    // Detect Rosetta for informational purposes
    g_running_under_rosetta = isRunningUnderRosetta();

    const self = mach_task_self();

    // Allocate exception port
    if (mach_port_allocate(self, MACH_PORT_RIGHT_RECEIVE, &our_exception_port) != KERN_SUCCESS) {
        return error.MachPortAllocateFailed;
    }

    // Insert send right
    if (mach_port_insert_right(
        self,
        our_exception_port,
        our_exception_port,
        MACH_MSG_TYPE_MAKE_SEND,
    ) != KERN_SUCCESS) {
        return error.MachPortInsertRightFailed;
    }

    // Exception mask (what we want to catch)
    const mask = EXC_MASK_BAD_ACCESS | EXC_MASK_BAD_INSTRUCTION | EXC_MASK_ARITHMETIC;

    // Create exception handler thread
    var thread: std.c.pthread_t = undefined;
    const result = std.c.pthread_create(&thread, null, machExceptionThread, null);
    if (result != .SUCCESS) {
        return error.ThreadCreateFailed;
    }

    // Detach thread so it runs independently
    _ = std.c.pthread_detach(thread);

    // Set exception ports for the task
    if (task_set_exception_ports(
        self,
        mask,
        our_exception_port,
        EXCEPTION_DEFAULT,
        MACHINE_THREAD_STATE,
    ) != KERN_SUCCESS) {
        return error.TaskSetExceptionPortsFailed;
    }
}

// Force the linker to retain catch_exception_raise, catch_exception_raise_state,
// and catch_exception_raise_state_identity. These are called at runtime by
// exc_server (in libsystem_kernel) via symbol lookup, so they must be exported.
fn forceExportExcHandlers() void {
    const refs: [3]*const anyopaque = .{
        @ptrCast(&catch_exception_raise),
        @ptrCast(&catch_exception_raise_state),
        @ptrCast(&catch_exception_raise_state_identity),
    };
    for (refs) |r| {
        std.mem.doNotOptimizeAway(r);
    }
}
