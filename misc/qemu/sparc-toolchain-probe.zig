// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
// Standalone Zig/C++ interoperability probe, not a Factor VM test.
export fn probe_add(a: usize, b: usize) usize { return a + b; }
export fn probe_fp(a: f64, b: f64) f64 { return a + b; }

const sparc = @import("sparc");
export fn probe_relocation(value: u64) u32 {
    var bytes: [24]u8 = undefined;
    const words = [_]u32{ 0x03000000, 0x82106000, 0x83287020, 0x11000000, 0x90122000, 0x90120001 };
    for (words, 0..) |word, i| sparc.storeInstruction(bytes[0..].ptr + i * 4, word);
    sparc.storeSet64(&bytes, value);
    sparc.flushInstructionCache(@intFromPtr(&bytes), bytes.len);
    if (sparc.loadSet64(&bytes) != value) return 1;
    if (sparc.loadInstruction(bytes[8..].ptr) != words[2]) return 2;
    if (sparc.loadInstruction(bytes[20..].ptr) != words[5]) return 3;
    inline for (.{ 19, 22, 30 }) |width| {
        const limit: i64 = @as(i64, 1) << (width + 1);
        const offsets = [_]i64{ -limit, -4, 0, 4, limit - 4 };
        for (offsets) |offset| {
            sparc.storeInstruction(&bytes, 0x40000000);
            sparc.storeDisplacement(&bytes, offset, width);
            if (sparc.displacement(&bytes, width) != offset) return 4;
        }
    }
    return 0;
}

export fn probe_signal_offsets(pc: usize, sp: usize, npc: usize) u32 {
    const Context = if (@sizeOf(usize) == 8) sparc.LinuxContext64 else sparc.LinuxContext32;
    const expected_sp = @offsetOf(Context, "regs") + 14 * @sizeOf(usize);
    return if (pc == @offsetOf(Context, "pc") and sp == expected_sp and npc == @offsetOf(Context, "npc")) 0 else 1;
}
export fn probe_redirect(raw: *anyopaque, target: usize) void {
    const Context = if (@sizeOf(usize) == 8) sparc.LinuxContext64 else sparc.LinuxContext32;
    const context: *Context = @ptrCast(@alignCast(raw));
    sparc.redirectSignal(context, target);
}

export fn probe_frames() u32 {
    const F = sparc.Frame(usize);
    var frames: [64]usize = @splat(0);
    const first = @intFromPtr(&frames[0]);
    const second = @intFromPtr(&frames[32]);
    frames[14] = F.rawStack(second);
    frames[15] = 0x12340;
    frames[20] = 0xdead; // Callee spill slots must not be scanned for caller PC.
    frames[52] = 0xcafe; // Caller spill slot20 corresponds to saved i7 caller PC.
    if (F.parent(first) != second) return 1;
    if (@as(*const usize, @ptrFromInt(F.parent(first) + 20 * @sizeOf(usize))).* != 0xcafe) return 8;
    if (F.codeAddress(first) != 0x12348) return 2;
    F.setCodeAddress(first, 0x23458);
    if (frames[15] != 0x23450 or F.codeAddress(first) != 0x23458) return 3;
    // A movable captured callstack stores relative, unbiased links at i6.
    var captured: [64]usize = frames;
    captured[14] = F.parent(first) - first;
    if (captured[14] != 32 * @sizeOf(usize)) return 4;
    const moved = @intFromPtr(&captured[0]);
    captured[14] = F.rawStack(moved + captured[14]);
    if (F.parent(moved) != @intFromPtr(&captured[32])) return 5;
    if (F.codeAddress(moved) != 0x23458) return 6;
    F.setCodeAddress(moved, 0);
    if (F.codeAddress(moved) != 0) return 7;
    return 0;
}

const rt = @import("sparc_runtime");
export fn probe_runtime(seed: usize) u32 {
    if (rt.__udivti3(@as(u128, 340282366920938463463374607431768211455) +% seed, 3) != 113427455640312821154458202477256070485 or rt.__umodti3(@as(u128, 340282366920938463463374607431768211455) +% seed, 3) != 0) return 1;
    if (rt.__udivti3(@as(u128, 170141183460469231731687303715884105745) +% seed, 18446744073709551619) != 9223372036854775806 or rt.__umodti3(@as(u128, 170141183460469231731687303715884105745) +% seed, 18446744073709551619) != 9223372036854775831) return 1;
    if (rt.__udivti3(@as(u128, 340282366920938463463374607431768211455) +% seed, 170141183460469231731687303715884105729) != 1 or rt.__umodti3(@as(u128, 340282366920938463463374607431768211455) +% seed, 170141183460469231731687303715884105729) != 170141183460469231731687303715884105726) return 1;
    if (rt.__udivti3(@as(u128, 18446744073709551616) +% seed, 17) != 1085102592571150095 or rt.__umodti3(@as(u128, 18446744073709551616) +% seed, 17) != 1) return 1;
    if (rt.__divti3(-170141183460469231731687303715884105727, 3) != -56713727820156410577229101238628035242) return 2;
    if (rt.__modti3(-17, 5) != -2) return 3;
    if (rt.__fixdfti(123456789.875 + @as(f64, @floatFromInt(seed))) != 123456789 or rt.__fixdfti(-0.875) != 0) return 4;
    if (rt.__fixdfti(0x1p100) != 1267650600228229401496703205376) return 5;
    return 0;
}

export fn probe_native_word() u32 {
    const bytes = [_]u8{0x4f,0,0,0x18};
    return @import("std").mem.readInt(u32, &bytes, @import("builtin").cpu.arch.endian());
}

export fn probe_callsites(seed: usize) u32 {
    const S = sparc.CallSite(usize);
    var bytes: [32]u8 = undefined;
    const base = @intFromPtr(&bytes);
    sparc.storeInstruction(&bytes, 0x40000000);
    if (!S.valid(base + 8) or S.tail(base + 8)) return 1;
    _ = S.patch(base + 8, base + seed + 16) catch return 2;
    if (S.target(base + 8) != base + seed + 16) return 3;
    const n: usize = if (@sizeOf(usize) == 8) 32 else 16;
    const words = [_]u32{0x2f000000,0xae15e000,0xaf2df020,0x03000000,0x82106000,0x82104017};
    if (@sizeOf(usize) == 8) {
        for (words, 0..) |word, i| sparc.storeInstruction(bytes[0..].ptr + i * 4, word);
    } else {
        sparc.storeInstruction(&bytes, 0x03000000);
        sparc.storeInstruction(bytes[4..].ptr, 0x82106000);
    }
    sparc.storeInstruction(bytes[n-8..].ptr, 0x81c06000);
    sparc.storeInstruction(bytes[n-4..].ptr, 0x01000000);
    if (!S.valid(base + n) or !S.tail(base + n)) return 4;
    _ = S.patch(base + n, base + seed + 64) catch return 5;
    if (S.target(base + n) != base + seed + 64) return 6;
    sparc.storeInstruction(bytes[n-8..].ptr, 0x9fc06000);
    if (!S.valid(base + n) or S.tail(base + n)) return 7;
    _ = S.patch(base + n, base + seed + 96) catch return 8;
    if (S.target(base + n) != base + seed + 96) return 9;
    return 0;
}
