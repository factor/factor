const std = @import("std");
const builtin = @import("builtin");

pub const Arch = enum {
    x86,
    x86_64,
    aarch64,
    arm,
    riscv64,
    loongarch64,
    riscv32,
    s390x,
    sparc,
    sparc64,
    powerpc,
    powerpc64,
    powerpc64le,
    mips,
    mipsel,
    mips64,
    mips64el,
    unsupported,

    pub fn current() Arch {
        return switch (builtin.cpu.arch) {
            .x86 => .x86,
            .x86_64 => .x86_64,
            .aarch64 => .aarch64,
            .arm => .arm,
            .riscv64 => .riscv64,
            .loongarch64 => .loongarch64,
            .riscv32 => .riscv32,
            .s390x => .s390x,
            .sparc => .sparc,
            .sparc64 => .sparc64,
            .powerpc => .powerpc,
            .powerpc64 => .powerpc64,
            .powerpc64le => .powerpc64le,
            .mips => .mips,
            .mipsel => .mipsel,
            .mips64 => .mips64,
            .mips64el => .mips64el,
            else => .unsupported,
        };
    }

    /// True for any x86 family (32-bit or 64-bit).
    pub fn isX86Family(arch: Arch) bool {
        return arch == .x86 or arch == .x86_64;
    }
};

pub const X86Instruction = struct {
    pub const CALL_OPCODE: u8 = 0xe8;
    pub const JMP_OPCODE: u8 = 0xe9;

    pub fn encodeCall(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), rel_offset: i32) !void {
        try buffer.append(allocator, CALL_OPCODE);
        var bytes: [4]u8 = undefined;
        std.mem.writeInt(i32, &bytes, rel_offset, .little);
        try buffer.appendSlice(allocator, &bytes);
    }

    pub fn encodeJump(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), rel_offset: i32) !void {
        try buffer.append(allocator, JMP_OPCODE);
        var bytes: [4]u8 = undefined;
        std.mem.writeInt(i32, &bytes, rel_offset, .little);
        try buffer.appendSlice(allocator, &bytes);
    }
};

pub const ARM64Instruction = struct {
    pub const JMP_OPCODE: u32 = 0xd61f0120; // BR X9

    fn emitU32(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), value: u32) !void {
        var bytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &bytes, value, .little);
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

test "instruction encoders emit little-endian bytes on every host" {
    var bytes: std.ArrayList(u8) = .empty;
    defer bytes.deinit(std.testing.allocator);
    try X86Instruction.encodeCall(std.testing.allocator, &bytes, 0x12345678);
    try X86Instruction.encodeJump(std.testing.allocator, &bytes, -4);
    try ARM64Instruction.encodeCall(std.testing.allocator, &bytes, 4);
    try ARM64Instruction.encodeJump(std.testing.allocator, &bytes, -4);
    try std.testing.expectEqualSlices(u8, &.{
        0xe8, 0x78, 0x56, 0x34, 0x12,
        0xe9, 0xfc, 0xff, 0xff, 0xff,
        0x01, 0x00, 0x00, 0x94, 0xff,
        0xff, 0xff, 0x17,
    }, bytes.items);
}
