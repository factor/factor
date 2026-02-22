// callstack.zig - Callstack capture and iteration for continuations
//
// This module implements:
// - Callstack capture (save current callstack to a Factor callstack object)
// - Callstack iteration (walk frames in a callstack)
// - Primitives for callstack manipulation

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

// ARM64-specific frame pointer handling
// On ARM64, the frame pointer chain uses absolute addresses in the live callstack,
// but we need to convert them to relative offsets when saving to a callstack object
// (so the callstack can be moved in memory). We convert back when restoring.

// Convert relative offset back to absolute frame pointer (ARM64 only)
// This is used when restoring a callstack from a saved callstack object
fn derelativizeFramePointer(frame_top: Cell, base_addr: Cell) void {
    if (builtin.cpu.arch != .aarch64) return;

    const saved_fp_ptr: *Cell = @ptrFromInt(frame_top);
    const offset = saved_fp_ptr.*;

    // Convert relative offset back to absolute address based on the new base
    saved_fp_ptr.* = base_addr + offset;
}

// Helper for iterating a saved callstack object
// The iterator is called for each frame with: (frame_top, size, code_block, return_addr)
pub fn iterateCallstackObject(vm: *FactorVM, callstack: *const layouts.Callstack, comptime Iterator: type, iterator: *Iterator) void {
    const frame_length = layouts.untagFixnum(callstack.length);
    var frame_offset: Cell = 0;

    const code = vm.code orelse return;

    if (builtin.cpu.arch == .aarch64) {
        // ARM64: saved callstack has relative offsets in FP slots
        // frame_top[0] = relative offset to next frame (converted from absolute FP)
        // frame_top[8] = return address (FRAME_RETURN_ADDRESS)
        // Matches C++ iterate_callstack_object (ARM64 path)
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
        // x86-64: frames laid out sequentially, return address at offset 0
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

// Helper for iterating the live callstack in a context
// The iterator is called for each frame with: (frame_top, size, code_block, return_addr)
pub fn iterateCallstack(vm: *FactorVM, ctx: *const contexts.Context, comptime Iterator: type, iterator: *Iterator) void {
    var top = ctx.callstack_top;
    const bottom = ctx.callstack_bottom;

    const code = vm.code orelse return;

    if (builtin.cpu.arch == .aarch64) {
        // ARM64: walk the frame pointer chain
        // top[0] = saved frame pointer (x29) - absolute address pointing to previous frame
        // top[8] = return address (x30)
        // Matches C++ iterate_callstack (ARM64 path)
        while (top < bottom) {
            const ret_addr = @as(*const Cell, @ptrFromInt(top + FRAME_RETURN_ADDRESS)).*;
            if (ret_addr == 0) break;

            const block = code.codeBlockForAddress(ret_addr) orelse break;

            // C++: cell size = *(cell*)top - top;
            const next_frame = @as(*const Cell, @ptrFromInt(top)).*;
            const frame_size = next_frame -| top;

            iterator.call(top, frame_size, block, ret_addr);

            // Follow the FP chain: top = *(cell*)top
            top = next_frame;
        }
    } else {
        // x86-64: walk from top to bottom using frame sizes
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

// Capture the live callstack into a callstack object
// This is used by the continuation implementation
// On ARM64, we need to convert absolute frame pointers to relative offsets
pub fn captureCallstack(vm: *FactorVM, ctx: *const contexts.Context) ?Cell {
    // Skip the top 2 frames (this primitive and its caller) - see C++ implementation
    // We'll implement second_from_top_stack_frame logic inline
    var top = ctx.callstack_top;
    const bottom = ctx.callstack_bottom;

    // Skip 2 frames if possible
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

    // Calculate size of callstack to capture
    const size: i64 = @as(i64, @intCast(bottom)) - @as(i64, @intCast(top));
    if (size < 0) return null;
    const size_bytes: usize = @intCast(size);

    // Allocate callstack object
    const cs_size = @sizeOf(layouts.Callstack) + size_bytes;
    const tagged = vm.allotObject(.callstack, cs_size) orelse return null;
    const cs: *layouts.Callstack = @ptrFromInt(layouts.UNTAG(tagged));

    cs.length = layouts.tagFixnum(@intCast(size_bytes));

    // Copy callstack data
    const src: [*]const u8 = @ptrFromInt(top);
    const dst = cs.data();
    @memcpy(dst[0..size_bytes], src[0..size_bytes]);

    // ARM64-specific: convert absolute frame pointers to relative offsets
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

// Primitive: callstack->array
// ( callstack -- array )
// Convert a callstack object to an array of stack frame info
// Each frame produces 3 elements: [executing, executing-quot, scan]
pub export fn primitive_callstack_to_array(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const cs_cell = vm.peek();

    vm.checkTag(cs_cell, .callstack);

    const callstack: *const layouts.Callstack = @ptrFromInt(layouts.UNTAG(cs_cell));

    // Collect frames into a growable array
    // We need to build an array dynamically, so we'll use a temporary stack-based buffer
    // then allocate the final array
    var frame_data: [256]Cell = undefined; // Max 256/3 = ~85 frames
    var frame_count: usize = 0;

    const FrameAccumulator = struct {
        data: []Cell,
        count: *usize,
        vm_ref: *@import("vm.zig").FactorVM,

        pub fn call(self: *@This(), _: Cell, _: Cell, block: *const CodeBlock, addr: Cell) void {
            // Get the owner (word or quotation)
            const owner = block.owner;

            // Get the owner quotation - matches C++ code_block::owner_quot()
            // For UNOPTIMIZED blocks owned by a word: return word->def (the quotation)
            // For OPTIMIZED blocks: return owner as-is (the word itself)
            const owner_quot = if (block.blockType() != .optimized and
                layouts.hasTag(owner, .word))
            blk: {
                const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(owner));
                break :blk word.def;
            } else owner;

            // Calculate scan value using block.scan() which calls quotCodeOffsetToScan
            // Matches C++: owner->scan(this, addr)
            const scan = block.scan(self.vm_ref, addr);

            // Add to array: [owner, owner_quot, scan]
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

    // Allocate result array, triggering GC if needed
    const array_size = @sizeOf(layouts.Array) + frame_count * @sizeOf(Cell);
    const tagged = vm.allotObject(.array, array_size) orelse {
        vm.memoryError();
    };
    const arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(tagged));
    arr.capacity = layouts.tagFixnum(@intCast(frame_count));

    // Copy frame data to array
    const arr_data = arr.data();
    @memcpy(arr_data[0..frame_count], frame_data[0..frame_count]);

    vm.replace(tagged);
}

// Primitive: callstack-bounds
// ( -- start end )
// Push the callstack segment bounds as aliens
pub export fn primitive_callstack_bounds(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm.vm_asm.ctx;
    if (ctx.callstack_seg) |seg| {
        // Root start_alien - second allotAlien can trigger GC
        var start_alien = vm.allotAlien(layouts.false_object, seg.start);
        vm.data_roots.append(vm.allocator, &start_alien) catch {
            vm.push(layouts.false_object);
            vm.push(layouts.false_object);
            return;
        };
        defer _ = vm.data_roots.pop();
        const end_alien = vm.allotAlien(layouts.false_object, seg.end);
        vm.push(start_alien);
        vm.push(end_alien);
        return;
    }
    vm.push(layouts.false_object);
    vm.push(layouts.false_object);
}
