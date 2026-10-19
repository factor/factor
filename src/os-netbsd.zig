const std = @import("std");
const builtin = @import("builtin");
const Cell = @import("layouts.zig").Cell;

// NetBSD's _ksiginfo reason union contains uint64_t syscall arguments.
// On ARM32 and PowerPC32 its native alignment is eight, while Zig's
// std.c.netbsd._ksiginfo explicitly lowers it to pointer alignment.
const NativeSiginfoPrefix = extern struct {
    signo: c_int,
    code: c_int,
    errno: c_int,
    reason: extern union {
        fault: extern struct { addr: *allowzero anyopaque },
        syscall_args: [8]u64,
    },
};

pub fn faultAddress(info: *const std.posix.siginfo_t) Cell {
    if (builtin.cpu.arch == .powerpc or builtin.cpu.arch == .arm) {
        const native: *const NativeSiginfoPrefix = @ptrCast(@alignCast(info));
        return @intFromPtr(native.reason.fault.addr);
    }
    return @intFromPtr(info.info.reason.fault.addr);
}

// NetBSD 11 sys/ucontext.h and machine/mcontext.h ABI.
pub const Context = extern struct {
    flags: c_uint,
    link: ?*anyopaque,
    mask: [4]u32,
    stack: std.c.stack_t,
    mcontext: MContext,
    machine_pad: if (builtin.cpu.arch == .arm) [1]u32 else [0]u8,
};
const MContext = if (builtin.cpu.arch == .riscv64) extern struct {
    regs: [32]u64,
    fp: [33]u64,
    spare: [7]u64,
} else if (builtin.cpu.arch == .aarch64) extern struct {
    regs: [35]u64,
    fp: [512]u8 align(16),
    fpcr: u32,
    fpsr: u32,
    spare: [8]u64,
} else if (builtin.cpu.arch == .arm) extern struct {
    regs: [17]u32,
    fp: extern struct { fpscr: u32, regs: [32]u64, fpsid: u32 },
    tls: u32,
    user_tpid: u32,
} else if (builtin.cpu.arch == .powerpc) extern struct {
    regs: [39]u32,
    fp: extern struct { regs: [32]f64, fpscr: u32, valid: u32 },
    vector: [528]u8 align(16),
} else if (builtin.cpu.arch == .x86_64) extern struct {
    regs: [26]u64,
    tls: u64,
    fp: [512]u8 align(8),
} else extern struct {
    regs: [19]u32,
    fp: [644]u8,
    tls: u32,
};

pub fn programCounter(ucontext_ptr: *anyopaque) *Cell {
    const context: *Context = @ptrCast(@alignCast(ucontext_ptr));
    return @ptrCast(&context.mcontext.regs[if (builtin.cpu.arch == .riscv64) 31 else if (builtin.cpu.arch == .aarch64) 32 else if (builtin.cpu.arch == .arm) 15 else if (builtin.cpu.arch == .powerpc) 34 else if (builtin.cpu.arch == .x86_64) 21 else 14]);
}

pub fn stackPointer(ucontext_ptr: *anyopaque) *Cell {
    const context: *Context = @ptrCast(@alignCast(ucontext_ptr));
    return @ptrCast(&context.mcontext.regs[if (builtin.cpu.arch == .riscv64) 1 else if (builtin.cpu.arch == .aarch64) 31 else if (builtin.cpu.arch == .arm) 13 else if (builtin.cpu.arch == .powerpc) 1 else if (builtin.cpu.arch == .x86_64) 24 else 17]);
}

pub fn fpuStatus(ucontext_ptr: *anyopaque) u32 {
    const context: *Context = @ptrCast(@alignCast(ucontext_ptr));
    if (builtin.cpu.arch == .riscv64) return @truncate(context.mcontext.fp[32]);
    if (builtin.cpu.arch == .aarch64) return context.mcontext.fpsr;
    if (builtin.cpu.arch == .arm) return if (context.flags & 0x10000 != 0) context.mcontext.fp.fpscr else 0;
    if (builtin.cpu.arch == .powerpc) return context.mcontext.fp.fpscr;
    const fp = &context.mcontext.fp;
    if (builtin.cpu.arch == .x86 and context.flags & 0x20 == 0) return std.mem.readInt(u16, fp[4..][0..2], .little);
    return std.mem.readInt(u16, fp[2..][0..2], .little) | std.mem.readInt(u32, fp[24..][0..4], .little);
}

pub fn clearFpuStatus(ucontext_ptr: *anyopaque) void {
    const context: *Context = @ptrCast(@alignCast(ucontext_ptr));
    if (builtin.cpu.arch == .riscv64) {
        context.mcontext.fp[32] &= ~@as(u64, 0x1f);
    } else if (builtin.cpu.arch == .aarch64) {
        context.mcontext.fpsr = 0;
    } else if (builtin.cpu.arch == .arm) {
        if (context.flags & 0x10000 != 0) context.mcontext.fp.fpscr &= ~@as(u32, 0x9f);
    } else if (builtin.cpu.arch == .powerpc) {
        context.mcontext.fp.fpscr &= 0x0007f8ff;
    } else {
        const fp = &context.mcontext.fp;
        if (builtin.cpu.arch == .x86 and context.flags & 0x20 == 0) {
            std.mem.writeInt(u16, fp[4..][0..2], 0, .little);
            return;
        }
        std.mem.writeInt(u16, fp[2..][0..2], 0, .little);
        const mxcsr = std.mem.readInt(u32, fp[24..][0..4], .little);
        std.mem.writeInt(u32, fp[24..][0..4], mxcsr & 0xffffffc0, .little);
    }
    return;
}

test "NetBSD RISC-V native signal context layout" {
    if (builtin.os.tag != .netbsd or builtin.cpu.arch != .riscv64) return error.SkipZigTest;
    try std.testing.expectEqual(@as(usize, 632), @sizeOf(Context));
    try std.testing.expectEqual(@as(usize, 56), @offsetOf(Context, "mcontext"));
    try std.testing.expectEqual(@as(usize, 256), @offsetOf(MContext, "fp"));
    var context = std.mem.zeroes(Context);
    context.mcontext.regs[31] = 0x1234;
    context.mcontext.regs[1] = 0x5678;
    context.mcontext.fp[32] = 0x7f;
    try std.testing.expectEqual(@as(Cell, 0x1234), programCounter(&context).*);
    try std.testing.expectEqual(@as(Cell, 0x5678), stackPointer(&context).*);
    clearFpuStatus(&context);
    try std.testing.expectEqual(@as(u64, 0x60), context.mcontext.fp[32]);
}

test "NetBSD ARM32 native signal context layout" {
    if (builtin.os.tag != .netbsd or builtin.cpu.arch != .arm) return error.SkipZigTest;
    try std.testing.expectEqual(@as(usize, 400), @sizeOf(Context));
    try std.testing.expectEqual(@as(usize, 40), @offsetOf(Context, "mcontext"));
    try std.testing.expectEqual(@as(usize, 72), @offsetOf(MContext, "fp"));
    var context = std.mem.zeroes(Context);
    context.mcontext.regs[15] = 0x1234;
    context.mcontext.regs[13] = 0x5678;
    context.flags = 0x10000;
    context.mcontext.fp.fpscr = 0x0080009f;
    try std.testing.expectEqual(@as(Cell, 0x1234), programCounter(&context).*);
    try std.testing.expectEqual(@as(Cell, 0x5678), stackPointer(&context).*);
    try std.testing.expectEqual(@as(u32, 0x0080009f), fpuStatus(&context));
    clearFpuStatus(&context);
    try std.testing.expectEqual(@as(u32, 0x00800000), context.mcontext.fp.fpscr);
    context.flags = 0;
    context.mcontext.fp.fpscr = 0xffffffff;
    try std.testing.expectEqual(@as(u32, 0), fpuStatus(&context));
    clearFpuStatus(&context);
    try std.testing.expectEqual(@as(u32, 0xffffffff), context.mcontext.fp.fpscr);
}
