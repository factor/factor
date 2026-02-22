// primitives/misc.zig - Miscellaneous primitives
// exit, nano-count, sleep, size, stub, ctrl-break

const std = @import("std");
const builtin = @import("builtin");

const layouts = @import("../layouts.zig");
const math = @import("../fixnum.zig");
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

pub fn nanoCountMonotonic() u64 {
    // Use monotonic clock matching C++ VM:
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
            var scaling_factor: u64 = 0;
        };
        if (mach.scaling_factor == 0) {
            var info: mach.MachTimebaseInfo = undefined;
            _ = mach.mach_timebase_info(&info);
            mach.scaling_factor = @as(u64, info.numer) / @as(u64, info.denom);
        }
        return mach.mach_absolute_time() * mach.scaling_factor;
    } else {
        // Linux/generic: use CLOCK_MONOTONIC
        var ts: std.posix.timespec = undefined;
        std.posix.clock_gettime(.MONOTONIC, &ts) catch return 0;
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
        // Get object size based on type
        const obj_ptr: *const layouts.Object = @ptrFromInt(layouts.UNTAG(obj));
        const type_tag = obj_ptr.getType();
        const base_size: Cell = switch (type_tag) {
            .array => blk: {
                const arr: *const layouts.Array = @ptrCast(obj_ptr);
                break :blk layouts.arraySize(layouts.Array, @intCast(layouts.untagFixnumUnsigned(arr.capacity)));
            },
            .byte_array => blk: {
                const ba: *const layouts.ByteArray = @ptrCast(obj_ptr);
                break :blk layouts.arraySize(layouts.ByteArray, @intCast(layouts.untagFixnumUnsigned(ba.capacity)));
            },
            .string => blk: {
                const str: *const layouts.String = @ptrCast(obj_ptr);
                break :blk layouts.stringSize(@intCast(layouts.untagFixnumUnsigned(str.length)));
            },
            .word => @sizeOf(layouts.Word),
            .quotation => @sizeOf(layouts.Quotation),
            .wrapper => @sizeOf(layouts.Wrapper),
            .float => @sizeOf(layouts.BoxedFloat),
            .alien => @sizeOf(layouts.Alien),
            .dll => @sizeOf(layouts.Dll),
            else => @sizeOf(layouts.Object),
        };
        const size = layouts.alignCell(base_size, layouts.data_alignment);
        vm.push(layouts.tagFixnum(@intCast(size)));
    }
}

// --- Stub / Ctrl-Break ---

pub export fn primitive_stub(_: *VMAssemblyFields) callconv(.c) void {
    std.process.exit(1);
}

pub export fn primitive_enable_ctrl_break(_: *VMAssemblyFields) callconv(.c) void {}

pub export fn primitive_disable_ctrl_break(_: *VMAssemblyFields) callconv(.c) void {}
