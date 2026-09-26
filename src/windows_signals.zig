// Windows exception, console and sampling notifications.
const std = @import("std");
const builtin = @import("builtin");
const win = @import("platform.zig").win;
const signals = @import("signals.zig");
const safepoints = @import("safepoints.zig");
const vm_mod = @import("vm.zig");

var handler: ?*anyopaque = null;
var owner: ?*vm_mod.FactorVM = null;
var owner_thread: win.HANDLE = null;
var sampling_thread: ?std.Thread = null;
var sampling_stop: win.HANDLE = null;
var owner_lock: @import("mutex.zig").SpinMutex = .{};

fn pc(context: *win.CONTEXT) *usize {
    return if (builtin.cpu.arch == .aarch64) &context.Pc else &context.Rip;
}

fn sp(context: *win.CONTEXT) *usize {
    return if (builtin.cpu.arch == .aarch64) &context.Sp else &context.Rsp;
}

fn exceptionHandler(info: [*c]win.EXCEPTION_POINTERS) callconv(.winapi) win.LONG {
    const vm = signals.getCurrentVM() orelse return win.EXCEPTION_CONTINUE_SEARCH;
    if (vm_mod.g_fatal_erroring_p) return win.EXCEPTION_CONTINUE_SEARCH;
    const record = info.*.ExceptionRecord.*;
    const context = info.*.ContextRecord;
    if (record.ExceptionFlags & win.EXCEPTION_NONCONTINUABLE != 0) return win.EXCEPTION_CONTINUE_SEARCH;
    const target = switch (record.ExceptionCode) {
        win.EXCEPTION_ACCESS_VIOLATION, win.EXCEPTION_GUARD_PAGE, win.EXCEPTION_STACK_OVERFLOW => blk: {
            const addr = if (record.ExceptionCode == win.EXCEPTION_STACK_OVERFLOW)
                vm.vm_asm.ctx.callstack_seg.?.start - 1
            else if (record.NumberParameters >= 2)
                record.ExceptionInformation[1]
            else
                return win.EXCEPTION_CONTINUE_SEARCH;
            signals.setMemoryProtectionError(vm, addr, pc(context).*);
            break :blk @intFromPtr(&signals.memory_signal_handler_impl);
        },
        win.EXCEPTION_FLT_DENORMAL_OPERAND, win.EXCEPTION_FLT_DIVIDE_BY_ZERO, win.EXCEPTION_FLT_INEXACT_RESULT, win.EXCEPTION_FLT_INVALID_OPERATION, win.EXCEPTION_FLT_OVERFLOW, win.EXCEPTION_FLT_STACK_CHECK, win.EXCEPTION_FLT_UNDERFLOW => blk: {
            if (builtin.cpu.arch == .aarch64) {
                vm.signal_fpu_status = signals.processFPUStatus(context.*.Fpsr);
                context.*.Fpsr = 0;
            } else {
                vm.signal_fpu_status = signals.processFPUStatus(context.*.MxCsr);
                context.*.MxCsr &= ~@as(u32, 0x3f);
            }
            break :blk @intFromPtr(&signals.fp_signal_handler_impl);
        },
        win.EXCEPTION_ILLEGAL_INSTRUCTION, win.EXCEPTION_INT_DIVIDE_BY_ZERO, win.EXCEPTION_INT_OVERFLOW => blk: {
            vm.signal_number = record.ExceptionCode;
            break :blk @intFromPtr(&signals.synchronous_signal_handler_impl);
        },
        else => return win.EXCEPTION_CONTINUE_SEARCH,
    };
    signals.dispatchSignal(vm, sp(context), pc(context), target);
    return win.EXCEPTION_CONTINUE_EXECUTION;
}

fn ctrlHandler(event: win.DWORD) callconv(.winapi) win.BOOL {
    if (event != win.CTRL_C_EVENT and event != win.CTRL_BREAK_EVENT) return 0;
    owner_lock.lock();
    defer owner_lock.unlock();
    const vm = owner orelse return 0;
    safepoints.enqueueFep(vm) catch return 0;
    _ = win.CancelSynchronousIo(owner_thread);
    return 1;
}

pub fn handleCtrlC() void {
    _ = win.SetConsoleCtrlHandler(ctrlHandler, 1);
}

pub fn ignoreCtrlC() void {
    _ = win.SetConsoleCtrlHandler(ctrlHandler, 0);
}

pub fn init(vm: *vm_mod.FactorVM) !void {
    owner_lock.lock();
    defer owner_lock.unlock();
    if (owner != null) return error.WindowsSignalOwnerExists;
    if (win.DuplicateHandle(win.GetCurrentProcess(), win.GetCurrentThread(), win.GetCurrentProcess(), &owner_thread, 0, 0, win.DUPLICATE_SAME_ACCESS) == 0)
        return error.DuplicateHandleFailed;
    errdefer _ = win.CloseHandle(owner_thread);
    handler = win.AddVectoredExceptionHandler(1, exceptionHandler) orelse return error.ExceptionHandlerFailed;
    owner = vm;
    handleCtrlC();
}

pub fn deinit(vm: *vm_mod.FactorVM) void {
    if (owner != vm) return;
    stopSampling();
    ignoreCtrlC();
    owner_lock.lock();
    defer owner_lock.unlock();
    if (handler) |h| _ = win.RemoveVectoredExceptionHandler(h);
    _ = win.CloseHandle(owner_thread);
    handler = null;
    owner = null;
    owner_thread = null;
}

// The JIT's Windows exception tables use EXCEPTION_DISPOSITION (0/1),
// whereas the vectored handler above uses EXCEPTION_CONTINUE_* (-1/0).
pub fn exception_handler(record: [*c]win.EXCEPTION_RECORD, _: ?*anyopaque, context: [*c]win.CONTEXT, _: ?*anyopaque) callconv(.c) c_int {
    var info: win.EXCEPTION_POINTERS = .{ .ExceptionRecord = record, .ContextRecord = context };
    return if (exceptionHandler(&info) == win.EXCEPTION_CONTINUE_EXECUTION) 0 else 1;
}

fn sampleLoop(vm: *vm_mod.FactorVM, interval: u32) void {
    while (win.WaitForSingleObject(sampling_stop, interval) == win.WAIT_TIMEOUT) {
        if (win.SuspendThread(owner_thread) == 0xffffffff) continue;
        defer _ = win.ResumeThread(owner_thread);
        var context: win.CONTEXT = std.mem.zeroes(win.CONTEXT);
        context.ContextFlags = win.CONTEXT_CONTROL;
        if (win.GetThreadContext(owner_thread, &context) != 0)
            safepoints.enqueueSamples(vm, 1, pc(&context).*, false) catch {};
    }
}

pub fn startSampling(vm: *vm_mod.FactorVM, rate: usize) !void {
    sampling_stop = win.CreateEventW(null, 1, 0, null) orelse return error.CreateEventFailed;
    errdefer _ = win.CloseHandle(sampling_stop);
    sampling_thread = try std.Thread.spawn(.{}, sampleLoop, .{ vm, @as(u32, @intCast(@max(1, 1000 / rate))) });
}

pub fn stopSampling() void {
    if (sampling_thread) |thread| {
        _ = win.SetEvent(sampling_stop);
        thread.join();
        _ = win.CloseHandle(sampling_stop);
        sampling_thread = null;
        sampling_stop = null;
    }
}
