const std = @import("std");
const builtin = @import("builtin");

const code_blocks = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const layouts = @import("layouts.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const CodeBlock = code_blocks.CodeBlock;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

const FRAME_RETURN_ADDRESS = contexts.FRAME_RETURN_ADDRESS;

fn derelativizeFramePointer(frame_top: Cell, base_addr: Cell) void {
    if (builtin.cpu.arch != .aarch64) return;

    const saved_fp_ptr: *Cell = @ptrFromInt(frame_top);
    const offset = saved_fp_ptr.*;

    saved_fp_ptr.* = base_addr + offset;
}

pub fn iterateCallstackObject(vm: *FactorVM, callstack: *const layouts.Callstack, comptime Iterator: type, iterator: *Iterator) void {
    const frame_length = layouts.untagFixnum(callstack.length);
    var frame_offset: Cell = 0;

    const code = vm.code orelse return;

    if (builtin.cpu.arch == .aarch64) {
        while (frame_offset < frame_length) {
            const frame_top = callstack.frameTopAt(frame_offset);
            const frame_size = @as(*const Cell, @ptrFromInt(frame_top)).*;

            if (frame_size == 0 or frame_offset + frame_size > frame_length) break;

            const ret_addr = @as(*const Cell, @ptrFromInt(frame_top + FRAME_RETURN_ADDRESS)).*;
            const block = code.codeBlockForAddress(ret_addr) orelse break;

            iterator.call(frame_top, frame_size, block, ret_addr);

            frame_offset += frame_size;
        }
    } else {
        while (frame_offset < frame_length) {
            const frame_top = callstack.frameTopAt(frame_offset);
            const ret_addr = @as(*const Cell, @ptrFromInt(frame_top + FRAME_RETURN_ADDRESS)).*;

            const block = code.codeBlockForAddress(ret_addr) orelse break;
            const frame_size = block.stackFrameSizeForAddress(ret_addr);

            iterator.call(frame_top + FRAME_RETURN_ADDRESS, frame_size - FRAME_RETURN_ADDRESS, block, ret_addr);

            frame_offset += frame_size;
        }
    }
}

pub fn iterateCallstack(vm: *FactorVM, ctx: *const contexts.Context, comptime Iterator: type, iterator: *Iterator) void {
    var top = ctx.callstack_top;
    const bottom = ctx.callstack_bottom;

    const code = vm.code orelse return;

    if (builtin.cpu.arch == .aarch64) {
        while (top < bottom) {
            const ret_addr = @as(*const Cell, @ptrFromInt(top + FRAME_RETURN_ADDRESS)).*;
            if (ret_addr == 0) break;

            const block = code.codeBlockForAddress(ret_addr) orelse break;

            const next_frame = @as(*const Cell, @ptrFromInt(top)).*;
            const frame_size = next_frame -| top;

            iterator.call(top, frame_size, block, ret_addr);

            top = next_frame;
        }
    } else {
        while (top < bottom) {
            const ret_addr = @as(*const Cell, @ptrFromInt(top + FRAME_RETURN_ADDRESS)).*;
            if (ret_addr == 0) break;

            const block = code.codeBlockForAddress(ret_addr) orelse break;
            const frame_size = block.stackFrameSizeForAddress(ret_addr);

            iterator.call(top + FRAME_RETURN_ADDRESS, frame_size - FRAME_RETURN_ADDRESS, block, ret_addr);

            top += frame_size;
        }
    }
}

pub fn captureCallstack(vm: *FactorVM, ctx: *const contexts.Context) ?Cell {
    var top = ctx.callstack_top;
    const bottom = ctx.callstack_bottom;

    const code = vm.code orelse @panic("code heap not initialized");
    var frames_skipped: usize = 0;
    while (frames_skipped < 2 and top < bottom) {
        if (builtin.cpu.arch == .aarch64) {
            const next_frame = @as(*const Cell, @ptrFromInt(top)).*;
            if (next_frame >= bottom or next_frame == 0) break;
            top = next_frame;
        } else {
            const ret_addr = @as(*const Cell, @ptrFromInt(top + FRAME_RETURN_ADDRESS)).*;
            if (ret_addr == 0) break;
            const block = code.codeBlockForAddress(ret_addr) orelse break;
            const frame_size = block.stackFrameSizeForAddress(ret_addr);
            top += frame_size;
        }
        frames_skipped += 1;
    }

    const size: i64 = @as(i64, @intCast(bottom)) - @as(i64, @intCast(top));
    if (size < 0) return null;
    const size_bytes: usize = @intCast(size);

    // Allocate callstack object
    const cs_size = @sizeOf(layouts.Callstack) + size_bytes;
    const tagged = vm.allotObject(.callstack, cs_size) orelse return null;
    const cs: *layouts.Callstack = @ptrFromInt(layouts.UNTAG(tagged));

    cs.length = layouts.tagFixnum(@intCast(size_bytes));

    const src: [*]const u8 = @ptrFromInt(top);
    const dst = cs.data();
    @memcpy(dst[0..size_bytes], src[0..size_bytes]);

    if (builtin.cpu.arch == .aarch64) {
        var scan_top = top;
        var scan_dst = cs.top();
        while (scan_top < bottom) {
            const saved_fp = @as(*const Cell, @ptrFromInt(scan_top)).*;
            if (saved_fp > scan_top) {
                const dst_ptr: *Cell = @ptrFromInt(scan_dst);
                dst_ptr.* = saved_fp - scan_top;
                scan_top = saved_fp;
                scan_dst += dst_ptr.*;
            } else {
                break;
            }
        }
    }

    return tagged;
}

pub export fn primitive_callstack_to_array(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const cs_cell = vm.peek();

    vm.checkTag(cs_cell, .callstack);

    const callstack: *const layouts.Callstack = @ptrFromInt(layouts.UNTAG(cs_cell));

    var frame_data: [256]Cell = undefined; // Max 256/3 = ~85 frames
    var frame_count: usize = 0;

    const FrameAccumulator = struct {
        data: []Cell,
        count: *usize,
        vm_ref: *@import("vm.zig").FactorVM,

        pub fn call(self: *@This(), _: Cell, _: Cell, block: *const CodeBlock, addr: Cell) void {
            const owner = block.owner;

            const owner_quot = if (block.blockType() != .optimized and
                layouts.hasTag(owner, .word))
            blk: {
                const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(owner));
                break :blk word.def;
            } else owner;

            const scan = block.scan(self.vm_ref, addr);

            if (self.count.* + 3 <= self.data.len) {
                self.data[self.count.*] = owner;
                self.data[self.count.* + 1] = owner_quot;
                self.data[self.count.* + 2] = scan;
                self.count.* += 3;
            }
        }
    };

    var accumulator = FrameAccumulator{
        .data = &frame_data,
        .count = &frame_count,
        .vm_ref = vm,
    };

    iterateCallstackObject(vm, callstack, FrameAccumulator, &accumulator);

    const tagged = vm.allotUninitializedArray(frame_count) orelse {
        vm.memoryError();
    };
    const arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(tagged));
    const arr_data = arr.data();
    @memcpy(arr_data[0..frame_count], frame_data[0..frame_count]);

    vm.replace(tagged);
}

pub export fn primitive_callstack_bounds(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm.vm_asm.ctx;
    if (ctx.callstack_seg) |seg| {
        var start_alien = vm.allotAlien(layouts.false_object, seg.start);
        vm.data_roots.appendAssumeCapacity(&start_alien);
        defer _ = vm.data_roots.pop();
        const end_alien = vm.allotAlien(layouts.false_object, seg.end);
        vm.push(start_alien);
        vm.push(end_alien);
        return;
    }
    vm.push(layouts.false_object);
    vm.push(layouts.false_object);
}
