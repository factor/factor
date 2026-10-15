// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
const std = @import("std");

// Shared Unix templates decode saved return addresses with this cookie.
// Linux register windows store plain addresses; OpenBSD uses StackGhost.
pub export var factor_sparc_window_cookie: usize = 0;

// Linux has no authenticated signal windows to retire before replacing a callstack.
pub export fn factor_sparc_prepare_callstack(vm: ?*anyopaque) callconv(.c) void {
    _ = vm;
}

// Instructions are big-endian even when a cross-image builder is little-endian.
pub fn loadInstruction(p: [*]const u8) u32 {
    return (@as(u32, p[0]) << 24) | (@as(u32, p[1]) << 16) |
        (@as(u32, p[2]) << 8) | p[3];
}
pub fn storeInstruction(p: [*]u8, value: u32) void {
    p[0] = @truncate(value >> 24);
    p[1] = @truncate(value >> 16);
    p[2] = @truncate(value >> 8);
    p[3] = @truncate(value);
}
pub fn signedField(value: u32, comptime width: u5) i64 {
    comptime std.debug.assert(width > 0 and width <= 30);
    const mask = (@as(u32, 1) << width) - 1;
    const bits = value & mask;
    return if (bits & (@as(u32, 1) << (width - 1)) != 0)
        @as(i64, bits) - (@as(i64, 1) << width)
    else
        bits;
}
pub fn displacement(p: [*]const u8, comptime width: u5) i64 {
    return signedField(loadInstruction(p), width) * 4;
}
pub fn storeDisplacement(p: [*]u8, value: i64, comptime width: u5) void {
    comptime std.debug.assert(width > 0 and width <= 30);
    const limit = @as(i64, 1) << (@as(u6, width) + 1);
    std.debug.assert(value >= -limit and value < limit and value & 3 == 0);
    const mask = (@as(u32, 1) << width) - 1;
    const bits: u32 = @truncate(@as(u64, @bitCast(@divExact(value, 4))));
    storeInstruction(p, (loadInstruction(p) & ~mask) | (bits & mask));
}

pub fn branchWidth(instruction: u32) ?u5 {
    const op = instruction >> 30;
    if (op == 1) return 30; // CALL
    if (op != 0) return null;
    return switch ((instruction >> 22) & 7) {
        2, 6 => 22, // Bicc, FBfcc
        1, 5 => 19, // BPcc, FBPfcc
        else => null, // BPr has a noncontiguous displacement; reject it.
    };
}
pub fn branchBits(p: [*]const u8) u5 {
    return branchWidth(loadInstruction(p)) orelse @panic("Unsupported SPARC branch instruction");
}
pub fn branchDisplacement(p: [*]const u8) i64 {
    return switch (branchWidth(loadInstruction(p)) orelse @panic("Unsupported SPARC branch instruction")) {
        30 => displacement(p, 30),
        22 => displacement(p, 22),
        19 => displacement(p, 19),
        else => unreachable,
    };
}
pub fn storeBranch(p: [*]u8, value: i64) void {
    switch (branchWidth(loadInstruction(p)) orelse @panic("Unsupported SPARC branch instruction")) {
        30 => storeDisplacement(p, value, 30),
        22 => storeDisplacement(p, value, 22),
        19 => storeDisplacement(p, value, 19),
        else => unreachable,
    }
}

// SET32: SETHI rd,high22; OR rd,low10,rd.
pub fn loadSet32(p: [*]const u8) u32 {
    return ((loadInstruction(p) & 0x3fffff) << 10) | (loadInstruction(p + 4) & 0x3ff);
}
pub fn storeSet32(p: [*]u8, value: u32) void {
    storeInstruction(p, (loadInstruction(p) & ~@as(u32, 0x3fffff)) | (value >> 10));
    storeInstruction(p + 4, (loadInstruction(p + 4) & ~@as(u32, 0x3ff)) | (value & 0x3ff));
}
// SET64: SET32 scratch,high32; SLLX scratch,32,scratch;
// SET32 rd,low32; OR rd,scratch,rd (six instructions).
pub fn loadSet64(p: [*]const u8) u64 {
    return (@as(u64, loadSet32(p)) << 32) | loadSet32(p + 12);
}
pub fn storeSet64(p: [*]u8, value: u64) void {
    storeSet32(p, @truncate(value >> 32));
    storeSet32(p + 12, @truncate(value));
}

test "SPARC instruction relocation boundaries and unaligned big-endian bytes" {
    var bytes: [26]u8 = @splat(0x55);
    const p: [*]u8 = bytes[1..].ptr;
    const words = [_]u32{ 0x03000000, 0x82106000, 0x83287020, 0x11000000, 0x90122000, 0x90120001 };
    for (words, 0..) |word, i| storeInstruction(p + i * 4, word);
    const values = [_]u64{ 0, 1, 0xffffffff, 0x100000000, 0x8000000000000000, 0xfedcba9876543210, 0xffffffffffffffff };
    for (values) |value| {
        storeSet64(p, value);
        try std.testing.expectEqual(value, loadSet64(p));
        try std.testing.expectEqual(words[2], loadInstruction(p + 8));
        try std.testing.expectEqual(words[5], loadInstruction(p + 20));
        try std.testing.expectEqual(words[0], loadInstruction(p) & 0xffc00000);
        try std.testing.expectEqual(words[3], loadInstruction(p + 12) & 0xffc00000);
        try std.testing.expectEqual(@as(u8, 0x55), bytes[0]);
        try std.testing.expectEqual(@as(u8, 0x55), bytes[25]);
    }
    inline for (.{ 19, 22, 30 }) |width| {
        const limit: i64 = @as(i64, 1) << (width + 1);
        const offsets = [_]i64{ -limit, -4, 0, 4, limit - 4 };
        const base: u32 = if (width == 30) 0x40000000 else if (width == 22) 0x12800000 else 0x12680000;
        for (offsets) |offset| {
            storeInstruction(p, base);
            storeDisplacement(p, offset, width);
            try std.testing.expectEqual(offset, displacement(p, width));
            try std.testing.expectEqual(base, loadInstruction(p) & ~((@as(u32, 1) << width) - 1));
        }
    }
}

test "SPARC branch opcode inference rejects unsupported formats" {
    try std.testing.expectEqual(@as(?u5, 30), branchWidth(0x40000000));
    try std.testing.expectEqual(@as(?u5, 22), branchWidth(0x10800000));
    try std.testing.expectEqual(@as(?u5, 22), branchWidth(0x13800000));
    try std.testing.expectEqual(@as(?u5, 19), branchWidth(0x12680000));
    try std.testing.expectEqual(@as(?u5, 19), branchWidth(0x13780000));
    try std.testing.expectEqual(@as(?u5, null), branchWidth(0x81c3e008));
    try std.testing.expectEqual(@as(?u5, null), branchWidth(0x02c00000));
    try std.testing.expectEqual(@as(?u5, null), branchWidth(0x01000000));
    var instruction: [4]u8 = undefined;
    for ([_]u32{0x40000000,0x10800000,0x13800000,0x12680000,0x13780000}) |opcode| {
        storeInstruction(&instruction, opcode);
        storeBranch(&instruction, -4);
        try std.testing.expectEqual(@as(i64,-4), branchDisplacement(&instruction));
    }
}

/// Linux SPARC passes a sigcontext, rather than libc's ucontext_t, to
/// SA_SIGINFO handlers. Keep both layouts available for host-side ABI tests.
pub const LinuxContext32 = extern struct {
    psr: u32,
    pc: u32,
    npc: u32,
    y: u32,
    regs: [16]u32,
};
pub const LinuxFpu64 = extern struct {
    regs: [64]u32,
    fsr: u64,
    gsr: u64,
    fprs: u64,
};
pub const LinuxContext64 = extern struct {
    info: [128]u8,
    regs: [16]u64,
    tstate: u64,
    pc: u64,
    npc: u64,
    y: u32,
    fprs: u32,
    fpu: ?*LinuxFpu64,
};

/// Register windows save i6/i7 in slots 14/15. Saved links contain raw,
/// biased SP values; saved i7 names the call instruction, not its successor.
pub fn Frame(comptime Word: type) type {
    return struct {
        pub const bias: Word = if (@sizeOf(Word) == 8) 2047 else 0;
        pub const chain_offset = 14 * @sizeOf(Word);
        pub const return_offset = 15 * @sizeOf(Word);
        pub const minimum_size = if (@sizeOf(Word) == 8) 176 else 96;
        pub fn physicalStack(raw: Word) Word { return raw +% bias; }
        pub fn rawStack(physical: Word) Word { return physical -% bias; }
        pub fn returnAddress(saved: Word) Word { return saved +% 8; }
        pub fn savedReturn(address: Word) Word { return address -% 8; }
        pub fn parent(top: Word) Word {
            return physicalStack(@as(*const Word, @ptrFromInt(top + chain_offset)).*);
        }
        pub fn codeAddress(top: Word) Word {
            const saved = @as(*const Word, @ptrFromInt(top + return_offset)).*;
            return if (saved == 0) 0 else returnAddress(saved);
        }
        pub fn setCodeAddress(top: Word, address: Word) void {
            @as(*Word, @ptrFromInt(top + return_offset)).* = if (address == 0) 0 else savedReturn(address);
        }
    };
}

pub fn redirectSignal(context: anytype, target: @TypeOf(context.pc)) void {
    context.pc = target;
    context.npc = target +% 4;
}

test "SPARC Linux signal ABI and register window frame addresses" {
    try std.testing.expectEqual(@as(usize, 4), @offsetOf(LinuxContext32, "pc"));
    try std.testing.expectEqual(@as(usize, 72), @offsetOf(LinuxContext32, "regs") + 14 * 4);
    try std.testing.expectEqual(@as(usize, 264), @offsetOf(LinuxContext64, "pc"));
    try std.testing.expectEqual(@as(usize, 240), @offsetOf(LinuxContext64, "regs") + 14 * 8);
    try std.testing.expectEqual(@as(usize, 288), @offsetOf(LinuxContext64, "fpu"));
    inline for (.{ u32, u64 }) |Word| {
        const F = Frame(Word);
        try std.testing.expectEqual(@as(Word, 0x10000), F.physicalStack(F.rawStack(0x10000)));
        try std.testing.expectEqual(@as(Word, 0x12348), F.returnAddress(F.savedReturn(0x12348)));
    }
    var c32 = std.mem.zeroes(LinuxContext32);
    redirectSignal(&c32, 0x12340);
    try std.testing.expectEqual(@as(u32, 0x12344), c32.npc);
    var c64 = std.mem.zeroes(LinuxContext64);
    redirectSignal(&c64, 0x1000012340);
    try std.testing.expectEqual(@as(u64, 0x1000012344), c64.npc);
}

/// Flush each instruction-cache line touched by patched generated code.
/// SPARC FLUSH addresses an eight-byte instruction block on both ABIs.
pub fn flushInstructionCache(start: usize, size: usize) void {
    if (size == 0) return;
    var address = start & ~@as(usize, 7);
    const last = (start + size - 1) & ~@as(usize, 7);
    while (true) {
        asm volatile ("flush %[address]" :: [address] "r" (address) : .{ .memory = true });
        if (address == last) break;
        address += 8;
    }
}

pub fn patchBranch(address: [*]u8, delta: i64) !void {
    const instruction = loadInstruction(address);
    const width: u5 = if (instruction >> 30 == 1) 30 else if (instruction >> 30 == 0)
        switch ((instruction >> 22) & 7) { 2, 6 => 22, 1, 5 => 19, else => return error.UnsupportedArchitecture }
        else return error.UnsupportedArchitecture;
    const limit = @as(i64, 1) << (@as(u6, width) + 1);
    if (delta & 3 != 0 or delta < -limit or delta >= limit) return error.JumpOutOfRange;
    switch (width) {
        19 => storeDisplacement(address, delta, 19),
        22 => storeDisplacement(address, delta, 22),
        30 => storeDisplacement(address, delta, 30),
        else => unreachable,
    }
}

test "SPARC JIT branch patch recognizes integer floating and predicted formats" {
    var bytes: [4]u8 = undefined;
    inline for (.{ .{ 0x40000000, 30 }, .{ 0x10800000, 22 }, .{ 0x11800000, 22 }, .{ 0x10680000, 19 }, .{ 0x11680000, 19 } }) |entry| {
        const width = entry[1];
        const limit: i64 = @as(i64, 1) << (width + 1);
        for ([_]i64{ -limit, -4, 0, 4, limit - 4 }) |delta| {
            storeInstruction(&bytes, entry[0]);
            try patchBranch(&bytes, delta);
            try std.testing.expectEqual(delta, displacement(&bytes, width));
        }
        try std.testing.expectError(error.JumpOutOfRange, patchBranch(&bytes, limit));
        try std.testing.expectError(error.JumpOutOfRange, patchBranch(&bytes, 2));
    }
    storeInstruction(&bytes, 0x01000000); // NOP/SETHI is not a branch.
    try std.testing.expectError(error.UnsupportedArchitecture, patchBranch(&bytes, 0));
}
pub fn CallSite(comptime Word: type) type {
    return struct {
        fn instruction(ra: Word) u32 { return loadInstruction(@ptrFromInt(ra - 8)); }
        pub fn valid(ra: Word) bool {
            const word = instruction(ra);
            return word >> 30 == 1 or (word & 0xffc00000) == 0x10800000 or (word == 0x81c06000 or word == 0x9fc06000);
        }
        pub fn tail(ra: Word) bool {
            const word = instruction(ra);
            return word >> 30 == 0 or word == 0x81c06000;
        }
        pub fn target(ra: Word) Word {
            const word = instruction(ra);
            if (word == 0x81c06000 or word == 0x9fc06000)
                return if (@sizeOf(Word) == 8) @intCast(loadSet64(@ptrFromInt(ra - 32))) else loadSet32(@ptrFromInt(ra - 16));
            const delta = if (word >> 30 == 1) displacement(@ptrFromInt(ra - 8), 30) else displacement(@ptrFromInt(ra - 8), 22);
            return (ra -% 8) +% @as(Word, @truncate(@as(u64, @bitCast(delta))));
        }
        pub fn patch(ra: Word, destination: Word) !Word {
            if (instruction(ra) == 0x81c06000 or instruction(ra) == 0x9fc06000) {
                const size: Word = if (@sizeOf(Word) == 8) 32 else 16;
                if (@sizeOf(Word) == 8) storeSet64(@ptrFromInt(ra - size), destination)
                else storeSet32(@ptrFromInt(ra - size), destination);
                return size;
            }
            try patchBranch(@ptrFromInt(ra - 8), @as(i64, @intCast(destination)) - @as(i64, @intCast(ra - 8)));
            return 8;
        }
    };
}

pub const PendingSignal = struct {
    saved: [2048]u8 align(16) = undefined,
    owner: ?*anyopaque = null,
    frame: usize = 0,
    active: bool = false,
};

pub fn trapStatus(fsr: u32) u32 {
    const exceptions = (fsr | (fsr >> 5)) & 31;
    return ((exceptions & 16) >> 4) | ((exceptions & 8) >> 2) |
        (exceptions & 4) | ((exceptions & 2) << 2) | ((exceptions & 1) << 4);
}
