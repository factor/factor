//! FreeBSD 14/15 signal context ABI, from sys/{x86,arm,arm64,riscv}/include/ucontext.h.
//! sigset_t occupies 16 bytes and the embedded mcontext begins at offset 16.
const builtin = @import("builtin");
const std = @import("std");
const Cell = usize;
fn bytes(context: *anyopaque) [*]u8 { return @ptrCast(context); }
pub fn programCounter(context: *anyopaque) *Cell {
    const offset: usize = switch (builtin.cpu.arch) { .x86_64 => 16 + 20 * 8, .x86 => 16 + 15 * 4, .arm => 16 + 15 * 4, .aarch64 => 16 + 32 * 8, .riscv64 => 16 + 31 * 8, else => unreachable };
    return @ptrCast(@alignCast(bytes(context) + offset));
}
pub fn stackPointer(context: *anyopaque) *Cell {
    const offset: usize = switch (builtin.cpu.arch) { .x86_64 => 16 + 23 * 8, .x86 => 16 + 18 * 4, .arm => 16 + 13 * 4, .aarch64 => 16 + 31 * 8, .riscv64 => 16 + 8, else => unreachable };
    return @ptrCast(@alignCast(bytes(context) + offset));
}
fn fpBase() usize { return if (builtin.cpu.arch == .x86_64) 16 + 224 else 16 + 96; }
fn fpFormat(mc: [*]u8) u32 {
    const offset: usize = if (builtin.cpu.arch == .x86_64) 224 else 100;
    return std.mem.readInt(u32, mc[offset..][0..4], .little);
}
fn armFp(context: *anyopaque) ?[*]u8 {
    const mc = bytes(context);
    if (std.mem.readInt(u32, mc[84..][0..4], .little) < 264) return null;
    const address = std.mem.readInt(u32, mc[88..][0..4], .little);
    return if (address == 0) null else @ptrFromInt(address);
}
pub fn status(context: *anyopaque) u32 {
    const mc = bytes(context);
    if (builtin.cpu.arch == .arm) {
        const fp = armFp(context) orelse return 0;
        return std.mem.readInt(u32, fp[256..][0..4], .little);
    }
    // gpregs occupy 33 cells; fp_x reserves 32 pairs of 64-bit cells.
    if (builtin.cpu.arch == .riscv64) return @truncate(std.mem.readInt(u64, mc[792..][0..8], .little));
    if (builtin.cpu.arch == .aarch64) return std.mem.readInt(u32, mc[800..][0..4], .little);
    if (builtin.cpu.arch == .x86 and fpFormat(mc) == 0x10001) return std.mem.readInt(u32, mc[fpBase() + 4 ..][0..4], .little);
    if (fpFormat(mc) != 0x10002) return 0;
    // FXSAVE environment: status word at byte 2, MXCSR at byte 24.
    return std.mem.readInt(u16, mc[fpBase() + 2 ..][0..2], .little) | std.mem.readInt(u32, mc[fpBase() + 24 ..][0..4], .little);
}
pub fn clearStatus(context: *anyopaque) void {
    const mc = bytes(context);
    if (builtin.cpu.arch == .arm) {
        const fp = armFp(context) orelse return;
        const fpscr = std.mem.readInt(u32, fp[256..][0..4], .little);
        std.mem.writeInt(u32, fp[256..][0..4], fpscr & ~@as(u32, 0x9f), .little);
        return;
    }
    if (builtin.cpu.arch == .riscv64) {
        const fcsr = std.mem.readInt(u64, mc[792..][0..8], .little);
        std.mem.writeInt(u64, mc[792..][0..8], fcsr & ~@as(u64, 0x1f), .little);
        return;
    }
    if (builtin.cpu.arch == .aarch64) { std.mem.writeInt(u32, mc[800..][0..4], 0, .little); return; }
    if (builtin.cpu.arch == .x86 and fpFormat(mc) == 0x10001) { std.mem.writeInt(u32, mc[fpBase() + 4 ..][0..4], 0, .little); return; }
    if (fpFormat(mc) != 0x10002) return;
    std.mem.writeInt(u16, mc[fpBase() + 2 ..][0..2], 0, .little);
    const mxcsr = std.mem.readInt(u32, mc[fpBase() + 24 ..][0..4], .little);
    std.mem.writeInt(u32, mc[fpBase() + 24 ..][0..4], mxcsr & 0xffffffc0, .little);
}

// Offsets verified against FreeBSD 14.5 machine/ucontext.h.
test "FreeBSD RV64 signal context preserves registers and FCSR rounding" {
    if (builtin.cpu.arch != .riscv64) return error.SkipZigTest;
    var context: [880]u8 align(16) = @splat(0);
    std.mem.writeInt(u64, context[264..][0..8], 0x12345678, .little);
    std.mem.writeInt(u64, context[24..][0..8], 0x87654320, .little);
    std.mem.writeInt(u64, context[792..][0..8], 0x10000009f, .little);
    try std.testing.expectEqual(@as(Cell, 0x12345678), programCounter(&context).*);
    try std.testing.expectEqual(@as(Cell, 0x87654320), stackPointer(&context).*);
    try std.testing.expectEqual(@as(u32, 0x9f), status(&context));
    programCounter(&context).* = 0xabcdef00;
    stackPointer(&context).* = 0x76543210;
    try std.testing.expectEqual(@as(u64, 0xabcdef00), std.mem.readInt(u64, context[264..][0..8], .little));
    try std.testing.expectEqual(@as(u64, 0x76543210), std.mem.readInt(u64, context[24..][0..8], .little));
    clearStatus(&context);
    try std.testing.expectEqual(@as(u64, 0x100000080), std.mem.readInt(u64, context[792..][0..8], .little));
}

test "FreeBSD ARM32 signal context handles optional VFP state" {
    if (builtin.cpu.arch != .arm) return error.SkipZigTest;
    var context: [256]u8 align(8) = @splat(0);
    var fp: [264]u8 align(8) = @splat(0);
    std.mem.writeInt(u32, context[76..][0..4], 0x12345678, .little);
    std.mem.writeInt(u32, context[68..][0..4], 0x87654320, .little);
    try std.testing.expectEqual(@as(Cell, 0x12345678), programCounter(&context).*);
    try std.testing.expectEqual(@as(Cell, 0x87654320), stackPointer(&context).*);
    try std.testing.expectEqual(@as(u32, 0), status(&context));
    clearStatus(&context);
    std.mem.writeInt(u32, context[84..][0..4], 264, .little);
    std.mem.writeInt(u32, context[88..][0..4], @intFromPtr(&fp), .little);
    std.mem.writeInt(u32, fp[256..][0..4], 0x100009f, .little);
    try std.testing.expectEqual(@as(u32, 0x100009f), status(&context));
    clearStatus(&context);
    try std.testing.expectEqual(@as(u32, 0x1000000), std.mem.readInt(u32, fp[256..][0..4], .little));
}
