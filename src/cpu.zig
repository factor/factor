// cpu.zig - Architecture detection and instruction encoding for JIT
// References:
// - vm/cpu-x86.hpp (C++ VM x86_64 support)
// - vm/cpu-arm.64.hpp (C++ VM ARM64 support)

const std = @import("std");
const builtin = @import("builtin");

pub const Arch = enum {
    x86,
    x86_64,
    aarch64,
    unsupported,

    pub fn current() Arch {
        return switch (builtin.cpu.arch) {
            .x86 => .x86,
            .x86_64 => .x86_64,
            .aarch64 => .aarch64,
            else => .unsupported,
        };
    }

    /// True for any x86 family (32-bit or 64-bit).
    /// Matches C++ FACTOR_X86 which is defined for both i386 and x86_64.
    pub fn isX86Family(arch: Arch) bool {
        return arch == .x86 or arch == .x86_64;
    }
};

pub const X86Instruction = struct {
    pub const CALL_OPCODE: u8 = 0xe8;
    pub const JMP_OPCODE: u8 = 0xe9;

    pub fn encodeCall(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), rel_offset: i32) !void {
        try buffer.append(allocator, CALL_OPCODE);
        const bytes: [4]u8 = @bitCast(std.mem.nativeTo(i32, rel_offset, .little));
        try buffer.appendSlice(allocator, &bytes);
    }

    pub fn encodeJump(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), rel_offset: i32) !void {
        try buffer.append(allocator, JMP_OPCODE);
        const bytes: [4]u8 = @bitCast(std.mem.nativeTo(i32, rel_offset, .little));
        try buffer.appendSlice(allocator, &bytes);
    }
};

pub const ARM64Instruction = struct {
    pub const JMP_OPCODE: u32 = 0xd61f0120; // BR X9

    fn emitU32(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), value: u32) !void {
        const bytes: [4]u8 = @bitCast(std.mem.nativeTo(u32, value, .little));
        try buffer.appendSlice(allocator, &bytes);
    }

    pub fn encodeCall(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), offset: i32) !void {
        // BL format: 1 | 00101 | imm26
        const imm26: u32 = @bitCast(@as(i32, @divExact(offset, 4)) & 0x03ffffff);
        const insn: u32 = (0b1 << 31) | (0b00101 << 26) | imm26;
        try emitU32(allocator, buffer, insn);
    }

    pub fn encodeJump(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), offset: i32) !void {
        // B format: 0 | 00101 | imm26
        const imm26: u32 = @bitCast(@as(i32, @divExact(offset, 4)) & 0x03ffffff);
        const insn: u32 = (0b0 << 31) | (0b00101 << 26) | imm26;
        try emitU32(allocator, buffer, insn);
    }
};
