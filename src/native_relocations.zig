//! CPU dispatch for the image format's two native relocation slots.
//! Architecture is explicit so independent fixtures can exercise every ABI.
const std = @import("std");
const mips = @import("mips.zig");
const powerpc = @import("powerpc.zig");
const sparc = @import("sparc.zig");
const loongarch = @import("loongarch.zig");
const s390x = @import("s390x.zig");
const Arch = std.Target.Cpu.Arch;

pub fn supported(comptime arch: Arch) bool {
    return switch (arch) {
        .mips, .mipsel, .mips64, .mips64el, .powerpc, .powerpcle, .powerpc64, .powerpc64le, .sparc, .sparc64, .s390x, .loongarch64 => true,
        else => false,
    };
}
fn wide(comptime arch: Arch) bool {
    return switch (arch) {
        .mips64, .mips64el, .powerpc64, .powerpc64le, .sparc64, .s390x, .loongarch64 => true,
        else => false,
    };
}
fn signedDifference(comptime arch: Arch, value: u64, base: usize) i64 {
    const delta = value -% @as(u64, base);
    return if (wide(arch)) @bitCast(delta) else @as(i32, @bitCast(@as(u32, @truncate(delta))));
}
fn word(pointer: usize) *align(1) u32 {
    return @ptrFromInt(pointer);
}
fn signedBits(value: i64) u64 {
    return @bitCast(value);
}

pub fn load(comptime arch: Arch, slot: u1, pointer: usize, relative_to: usize) u64 {
    switch (arch) {
        .mips, .mipsel, .mips64, .mips64el => {
            if (slot == 1) return signedBits(@as(i16, @bitCast(@as(u16, @truncate(word(pointer - 4).*)))));
            return if (wide(arch)) mips.loadLiteral64(@ptrFromInt(pointer - 28)) else mips.loadLiteral32(@ptrFromInt(pointer - 8));
        },
        .powerpc, .powerpcle, .powerpc64, .powerpc64le => {
            const instruction = word(pointer - 4).*;
            if (slot == 1) {
                if ((instruction >> 26 != 16 and instruction >> 26 != 18) or instruction & 2 != 0)
                    @panic("Invalid relative PowerPC branch template");
                return @as(u64, relative_to) -% 4 +% signedBits(powerpc.branchDisplacement(instruction));
            }
            if (instruction >> 26 == 24)
                return if (wide(arch)) powerpc.loadLiteral64(@ptrFromInt(pointer - 20)) else powerpc.loadLiteral32(@ptrFromInt(pointer - 8));
            return signedBits(powerpc.loadDisplacement(instruction));
        },
        .sparc, .sparc64 => {
            if (slot == 1) return if (wide(arch)) sparc.loadSet64(@ptrFromInt(pointer - 24)) else sparc.loadSet32(@ptrFromInt(pointer - 8));
            return @as(u64, relative_to) -% 4 +% signedBits(sparc.branchDisplacement(@ptrFromInt(pointer - 4)));
        },
        .loongarch64 => {
            if (slot == 1) return loongarch.loadLiteral(@ptrFromInt(pointer - 32));
            return @as(u64, relative_to) -% 8 +% signedBits(loongarch.pairDisplacement(@ptrFromInt(pointer - 8)));
        },
        .s390x => {
            if (slot == 1) return s390x.loadImmediate(@ptrFromInt(pointer - 12));
            return @as(u64, relative_to) -% 6 +% signedBits(s390x.branchDisplacement(@ptrFromInt(pointer - 6)));
        },
        else => @panic("Native relocation class is unsupported on this CPU"),
    }
}

pub fn store(comptime arch: Arch, slot: u1, pointer: usize, value: u64) void {
    switch (arch) {
        .mips, .mipsel, .mips64, .mips64el => {
            if (slot == 1) {
                const immediate: i64 = if (wide(arch)) @bitCast(value) else @as(i32, @bitCast(@as(u32, @truncate(value))));
                if (immediate < -32768 or immediate > 32767) @panic("MIPS instruction immediate out of range");
                const p = word(pointer - 4);
                p.* = (p.* & 0xffff0000) | (@as(u32, @truncate(value)) & 0xffff);
            } else if (wide(arch)) mips.storeLiteral64(@ptrFromInt(pointer - 28), value) else mips.storeLiteral32(@ptrFromInt(pointer - 8), @truncate(value));
        },
        .powerpc, .powerpcle, .powerpc64, .powerpc64le => {
            const p = word(pointer - 4);
            if (slot == 1) {
                if ((p.* >> 26 != 16 and p.* >> 26 != 18) or p.* & 2 != 0) @panic("Invalid relative PowerPC branch template");
                const delta = signedDifference(arch, value, pointer - 4);
                const limit: i64 = if (p.* >> 26 == 16) 32768 else 33554432;
                if (delta & 3 != 0 or delta < -limit or delta >= limit) @panic("PowerPC branch displacement out of range");
                powerpc.storeBranch(p, delta);
            } else if (p.* >> 26 == 24) {
                if (wide(arch)) powerpc.storeLiteral64(@ptrFromInt(pointer - 20), value) else powerpc.storeLiteral32(@ptrFromInt(pointer - 8), @truncate(value));
            } else {
                const immediate = signedDifference(arch, value, 0);
                if (immediate < -32768 or immediate > 32767 or (p.* >> 26 >= 58 and immediate & 3 != 0))
                    @panic("PowerPC instruction displacement out of range");
                powerpc.storeDisplacement(p, immediate);
            }
        },
        .sparc, .sparc64 => {
            if (slot == 1) {
                if (wide(arch)) sparc.storeSet64(@ptrFromInt(pointer - 24), value) else sparc.storeSet32(@ptrFromInt(pointer - 8), @truncate(value));
            } else {
                const bytes: [*]u8 = @ptrFromInt(pointer - 4);
                const delta = signedDifference(arch, value, pointer - 4);
                const bits = sparc.branchBits(bytes);
                const limit: i64 = @as(i64, 1) << @intCast(bits + 1);
                if (delta & 3 != 0 or delta < -limit or delta >= limit) @panic("SPARC branch displacement out of range");
                sparc.storeBranch(bytes, delta);
            }
        },
        .loongarch64 => {
            if (slot == 1) loongarch.storeLiteral(@ptrFromInt(pointer - 32), value)
            else loongarch.storePair(@ptrFromInt(pointer - 8), signedDifference(arch,value,pointer - 8));
        },
        .s390x => {
            if (slot == 1) s390x.storeImmediate(@ptrFromInt(pointer - 12), value) else {
                const delta = signedDifference(arch, value, pointer - 6);
                if (delta & 1 != 0 or delta < -4294967296 or delta > 4294967294) @panic("System z branch displacement out of range");
                s390x.storeBranch(@ptrFromInt(pointer - 6), delta);
            }
        },
        else => @panic("Native relocation class is unsupported on this CPU"),
    }
}

test "native class dispatch preserves independent literal bytes and PC bases" {
    // The same class slots deliberately have distinct per-CPU meanings.
    var z = [_]u8{ 0xc0, 0xe5, 0, 0, 0, 0 };
    const z_end = @intFromPtr(&z) + z.len;
    store(.s390x, 0, z_end, @intFromPtr(&z) + 10);
    try std.testing.expectEqualSlices(u8, &.{ 0xc0, 0xe5, 0, 0, 0, 5 }, &z);
    try std.testing.expectEqual(@as(u64, 1010), load(.s390x, 0, z_end, 1006));
    var imm = [_]u8{ 0xc0, 0x28, 0, 0, 0, 0, 0xc0, 0x29, 0, 0, 0, 0 };
    const imm_end = @intFromPtr(&imm) + imm.len;
    store(.s390x, 1, imm_end, 0xfedcba9876543210);
    try std.testing.expectEqualSlices(u8, &.{ 0xc0, 0x28, 0xfe, 0xdc, 0xba, 0x98, 0xc0, 0x29, 0x76, 0x54, 0x32, 0x10 }, &imm);
    try std.testing.expectEqual(@as(u64, 0xfedcba9876543210), load(.s390x, 1, imm_end, 0));
    var m32 = [_]u32{ 0x3c020000, 0x34420000 };
    const m32_end = @intFromPtr(&m32) + 8;
    store(.mips, 0, m32_end, 0xfedcba98);
    try std.testing.expectEqual(@as(u32, 0x3c02fedc), m32[0]);
    try std.testing.expectEqual(@as(u32, 0x3442ba98), m32[1]);
    try std.testing.expectEqual(@as(u64, 0xfedcba98), load(.mips, 0, m32_end, 0));
    var mi: u32 = 0x8c820000;
    store(.mips64, 1, @intFromPtr(&mi) + 4, signedBits(-32768));
    try std.testing.expectEqual(@as(u32, 0x8c828000), mi);
    try std.testing.expectEqual(signedBits(-32768), load(.mips64, 1, @intFromPtr(&mi) + 4, 0));
    var pb: u32 = 0x48000001;
    store(.powerpc64, 1, @intFromPtr(&pb) + 4, @intFromPtr(&pb) - 4);
    try std.testing.expectEqual(@as(u32, 0x4bfffffd), pb);
    try std.testing.expectEqual(@as(u64, 996), load(.powerpc64, 1, @intFromPtr(&pb) + 4, 1004));
    var pl = [_]u32{ 0x3c600000, 0x60630000 };
    store(.powerpc, 0, @intFromPtr(&pl) + 8, 0x87654321);
    try std.testing.expectEqual(@as(u32, 0x3c608765), pl[0]);
    try std.testing.expectEqual(@as(u32, 0x60634321), pl[1]);
    var sb = [_]u8{ 0x40, 0, 0, 0 };
    store(.sparc64, 0, @intFromPtr(&sb) + 4, @intFromPtr(&sb) - 4);
    try std.testing.expectEqualSlices(u8, &.{ 0x7f, 0xff, 0xff, 0xff }, &sb);
    try std.testing.expectEqual(@as(u64, 996), load(.sparc64, 0, @intFromPtr(&sb) + 4, 1004));
    try std.testing.expect(!supported(.x86_64));
    try std.testing.expect(!supported(.m68k));
}

pub fn isTocOperand(comptime arch: Arch, pointer: usize) bool {
    if (arch != .powerpc64) return false;
    const instruction = word(pointer - 4).*;
    return instruction >> 26 == 24 and (instruction >> 21) & 31 == 2;
}

pub fn descriptorAddress(comptime elf_v1: bool, raw: usize, toc: bool) usize {
    if (!elf_v1) return raw;
    const descriptor: *align(1) const [3]usize = @ptrFromInt(raw);
    return descriptor[if (toc) @as(usize, 1) else 0];
}

test "ELFv1 entry and TOC loads share raw descriptors without changing type bits" {
    var toc: u32 = 0x60420000;
    var code: u32 = 0x618c0000;
    const descriptor = [_]usize{ 0x12345678, 0x87654321, 0 };
    const raw = @intFromPtr(&descriptor);
    try std.testing.expect(isTocOperand(.powerpc64, @intFromPtr(&toc) + 4));
    try std.testing.expect(!isTocOperand(.powerpc64, @intFromPtr(&code) + 4));
    try std.testing.expect(!isTocOperand(.powerpc64le, 0));
    try std.testing.expectEqual(@as(usize, 0x87654321), descriptorAddress(true, raw, true));
    try std.testing.expectEqual(@as(usize, 0x12345678), descriptorAddress(true, raw, false));
    try std.testing.expectEqual(raw, descriptorAddress(false, raw, true));
}
