// primitives/misc.zig - Miscellaneous primitives
// exit, nano-count, sleep, size, ctrl-break

const std = @import("std");
const builtin = @import("builtin");

const layouts = @import("../layouts.zig");
const math = @import("../fixnum.zig");
const slot_visitor = @import("../slot_visitor.zig");
const vm_mod = @import("../vm.zig");

const Cell = layouts.Cell;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

// --- Exit ---

pub export fn primitive_exit(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( n -- )
    const top = vm.pop();
    if (!layouts.hasTag(top, .fixnum)) {
        std.c._exit(254);
    }
    const code = layouts.untagFixnum(top);
    // Use _exit instead of exit to avoid waiting for threads
    std.c._exit(@intCast(code));
}

// --- Nano Count ---

fn machTicksToNanos(ticks: u64, numer: u64, denom: u64) u64 {
    return ticks / denom * numer + ticks % denom * numer / denom;
}

test "mach tick conversion keeps the fractional part of the timebase ratio" {
    try std.testing.expectEqual(@as(u64, 1_000_000_000), machTicksToNanos(24_000_000, 125, 3));
    try std.testing.expectEqual(@as(u64, 41), machTicksToNanos(1, 125, 3));
    try std.testing.expectEqual(@as(u64, 123_456_789), machTicksToNanos(123_456_789, 1, 1));
}

pub fn nanoCountMonotonic() u64 {
    // macOS: mach_absolute_time() scaled to nanoseconds
    // Linux: clock_gettime(CLOCK_MONOTONIC)
    if (comptime builtin.os.tag == .macos) {
        const mach = struct {
            extern "c" fn mach_absolute_time() u64;
            extern "c" fn mach_timebase_info(info: *MachTimebaseInfo) c_int;
            const MachTimebaseInfo = extern struct {
                numer: u32,
                denom: u32,
            };
            var timebase: MachTimebaseInfo = .{ .numer = 0, .denom = 0 };
        };
        if (mach.timebase.denom == 0) {
            if (mach.mach_timebase_info(&mach.timebase) != 0) @panic("mach_timebase_info failed");
        }
        return machTicksToNanos(mach.mach_absolute_time(), mach.timebase.numer, mach.timebase.denom);
    } else {
        // Linux/generic: use CLOCK_MONOTONIC via C library
        var ts: std.c.timespec = undefined;
        if (std.c.clock_gettime(.MONOTONIC, &ts) != 0) return 0;
        return @as(u64, @intCast(ts.sec)) * 1_000_000_000 + @as(u64, @intCast(ts.nsec));
    }
}

pub export fn primitive_nano_count(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( -- n )
    const now_u = nanoCountMonotonic();
    // Track monotonicity
    if (now_u < vm.last_nano_count) {
        vm.push(math.fromUnsignedCell(vm, vm.last_nano_count));
    } else {
        vm.last_nano_count = now_u;
        vm.push(math.fromUnsignedCell(vm, now_u));
    }
}

// --- Sleep ---

pub export fn primitive_sleep(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( nanos -- )
    const nanos = layouts.untagFixnum(vm.pop());
    const secs = @divFloor(nanos, 1_000_000_000);
    const nsecs = @mod(nanos, 1_000_000_000);
    const ts = std.c.timespec{ .sec = @intCast(secs), .nsec = @intCast(nsecs) };
    _ = std.c.nanosleep(&ts, null);
}

// --- Size ---

pub export fn primitive_size(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    // ( obj -- n )
    const obj = vm.pop();
    if (layouts.isImmediate(obj)) {
        vm.push(layouts.tagFixnum(0));
    } else {
        // Use the canonical object-size computation the GC walks the heap with
        // (layouts.objectVisitInfoFromAddress). The old per-type switch here
        // fell through to a bare Object header for tuple/bignum/callstack,
        // reporting ~16 bytes for every tuple and bignum. Matches C++
        // object_size -> object::size (vm/objects.cpp).
        const size = slot_visitor.objectSize(layouts.UNTAG(obj));
        vm.push(layouts.tagFixnum(@intCast(size)));
    }
}

// --- Stub / Ctrl-Break ---

pub export fn primitive_stub(_: *VMAssemblyFields) callconv(.c) void {
    std.process.exit(1);
}

pub export fn primitive_enable_ctrl_break(vm_asm: *VMAssemblyFields) callconv(.c) void {
    // Matches C++ os-unix.cpp: a Ctrl-Break/SIGINT then raises a catchable
    // interrupt error (see safepoints.handleSafepoint) instead of entering FEP.
    vm_asm.getVM().stop_on_ctrl_break = true;
}

pub export fn primitive_disable_ctrl_break(vm_asm: *VMAssemblyFields) callconv(.c) void {
    vm_asm.getVM().stop_on_ctrl_break = false;
}
