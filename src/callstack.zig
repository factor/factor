const std = @import("std");
const builtin = @import("builtin");

const code_blocks = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const growable = @import("growable.zig");
const layouts = @import("layouts.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const CodeBlock = code_blocks.CodeBlock;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

const FRAME_RETURN_ADDRESS = contexts.FRAME_RETURN_ADDRESS;

/// Iterate a callstack *object's* frames. `cs_cell` must be a GC root the
/// caller keeps live (e.g. pushed on data_roots): `iterator.call` may allocate
/// and trigger a GC that moves the callstack object, so the callstack base is
/// re-derived from `cs_cell` every iteration rather than captured once.
pub fn iterateCallstackObject(vm: *FactorVM, cs_cell: *Cell, comptime Iterator: type, iterator: *Iterator) void {
    const code = vm.code orelse return;
    // Length is an immutable fixnum, so reading it once (as a number) is safe
    // even though the object may move.
    const frame_length = layouts.untagFixnum(@as(*const layouts.Callstack, @ptrFromInt(layouts.UNTAG(cs_cell.*))).length);
    var frame_offset: Cell = 0;

    if (builtin.cpu.arch == .aarch64) {
        while (frame_offset < frame_length) {
            const callstack: *const layouts.Callstack = @ptrFromInt(layouts.UNTAG(cs_cell.*));
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
            const callstack: *const layouts.Callstack = @ptrFromInt(layouts.UNTAG(cs_cell.*));
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

pub export fn primitive_callstack_to_array(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();

    var cs_cell = vm.peek();
    vm.checkTag(cs_cell, .callstack);

    // Root the callstack object: block.scan() below can JIT-compile a quotation
    // and trigger a GC that moves it, and the frame walk dereferences it every
    // iteration (matches C++ data_root<callstack>).
    std.debug.assert(vm.data_roots.items.len < vm.data_roots.capacity);
    vm.data_roots.appendAssumeCapacity(&cs_cell);
    defer _ = vm.data_roots.pop();

    // Accumulate into a rooted, growable Factor array. The old fixed 256-cell
    // Zig buffer silently truncated callstacks past ~85 frames and held tagged
    // pointers that a GC inside scan() could invalidate before they were copied
    // into the result (matches C++ growable_array frames).
    var frames = growable.GrowableArray.init(vm, 8) orelse vm.memoryError();
    std.debug.assert(vm.data_roots.items.len < vm.data_roots.capacity);
    vm.data_roots.appendAssumeCapacity(&frames.elements);
    defer _ = vm.data_roots.pop();

    const FrameAccumulator = struct {
        frames: *growable.GrowableArray,
        vm_ref: *FactorVM,

        pub fn call(self: *@This(), _: Cell, _: Cell, block: *const CodeBlock, addr: Cell) void {
            var owner = block.owner;
            var owner_quot = if (block.blockType() != .optimized and
                layouts.hasTag(owner, .word))
            blk: {
                const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(owner));
                break :blk word.def;
            } else owner;

            // scan() may GC (it can JIT-compile the frame's quotation), so root
            // owner and owner_quot across it before reading scan (C++ wraps each
            // in a data_root). scan itself is a fixnum (immediate).
            const vm_ref = self.vm_ref;
            std.debug.assert(vm_ref.data_roots.items.len + 2 <= vm_ref.data_roots.capacity);
            vm_ref.data_roots.appendAssumeCapacity(&owner);
            vm_ref.data_roots.appendAssumeCapacity(&owner_quot);
            defer {
                _ = vm_ref.data_roots.pop();
                _ = vm_ref.data_roots.pop();
            }

            const scan = block.scan(vm_ref, addr);

            // add() may GC; owner/owner_quot stay rooted above, scan is immediate.
            if (!self.frames.add(owner)) vm_ref.memoryError();
            if (!self.frames.add(owner_quot)) vm_ref.memoryError();
            if (!self.frames.add(scan)) vm_ref.memoryError();
        }
    };

    var accumulator = FrameAccumulator{ .frames = &frames, .vm_ref = vm };
    iterateCallstackObject(vm, &cs_cell, FrameAccumulator, &accumulator);

    if (!frames.trim()) vm.memoryError();
    vm.replace(frames.toArray());
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
