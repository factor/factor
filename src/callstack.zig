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
    const frame_length = if (comptime contexts.powerpc_frames)
        @as(Cell, @intCast(layouts.untagFixnum(@as(*const layouts.Callstack, @ptrFromInt(layouts.UNTAG(cs_cell.*))).length)))
    else
        layouts.untagFixnum(@as(*const layouts.Callstack, @ptrFromInt(layouts.UNTAG(cs_cell.*))).length);
    var frame_offset: Cell = 0;

    if ((builtin.cpu.arch == .arm or builtin.cpu.arch == .powerpc or builtin.cpu.arch == .powerpc64 or builtin.cpu.arch == .powerpc64le or builtin.cpu.arch == .aarch64 or (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .loongarch64) or contexts.mips_frames or builtin.cpu.arch == .s390x or builtin.cpu.arch == .riscv32 or contexts.sparc_frames)) {
        while (frame_offset < frame_length) {
            const callstack: *const layouts.Callstack = @ptrFromInt(layouts.UNTAG(cs_cell.*));
            const frame_top = callstack.frameTopAt(frame_offset);
            const frame_size = contexts.capturedFrameSize(frame_top);

            if (frame_size == 0 or frame_offset + frame_size > frame_length) break;

            const ret_addr = contexts.frameReturnAddress(frame_top);
            const block = code.codeBlockForAddress(ret_addr) orelse break;

            const advance = if (comptime contexts.powerpc_frames)
                contexts.capturedFrameAdvance(frame_top, frame_size, frame_length - frame_offset)
            else
                frame_size;
            iterator.call(frame_top, frame_size, block, ret_addr);

            frame_offset += advance;
        }
    } else {
        while (frame_offset < frame_length) {
            const callstack: *const layouts.Callstack = @ptrFromInt(layouts.UNTAG(cs_cell.*));
            const frame_top = callstack.frameTopAt(frame_offset);
            const ret_addr = contexts.frameReturnAddress(frame_top);

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

    if ((builtin.cpu.arch == .arm or builtin.cpu.arch == .powerpc or builtin.cpu.arch == .powerpc64 or builtin.cpu.arch == .powerpc64le or builtin.cpu.arch == .aarch64 or (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .loongarch64) or contexts.mips_frames or builtin.cpu.arch == .s390x or builtin.cpu.arch == .riscv32 or contexts.sparc_frames)) {
        while (top < bottom) {
            const ret_addr = contexts.frameReturnAddress(top);
            if (ret_addr == 0) break;

            const block = code.codeBlockForAddress(ret_addr) orelse break;

            const parent = contexts.frameParent(top);
            const frame_size = parent -| top;
            const next_frame = contexts.liveFrameNext(top, parent, bottom);

            iterator.call(top, frame_size, block, ret_addr);

            top = next_frame;
        }
    } else {
        while (top < bottom) {
            const ret_addr = contexts.frameReturnAddress(top);
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

test "System z live and saved callstacks follow frame links past spills" {
    if (builtin.cpu.arch != .s390x) return error.SkipZigTest;
    var block: CodeBlock align(16) = undefined;
    block.initialize(.optimized, 64, 16);
    const address = block.entryPoint() + 8;
    var blocks = [_]Cell{@intFromPtr(&block)};
    var heap: @import("code_heap.zig").CodeHeap = undefined;
    heap.all_blocks_sorted = .empty;
    heap.all_blocks_sorted.items = &blocks;
    heap.all_blocks_sorted.capacity = 1;
    heap.pending_blocks = .empty;
    var vm: FactorVM = undefined;
    vm.code = &heap;
    const Accumulator = struct {
        count: usize = 0,
        sizes: [2]Cell = @splat(0),
        fn call(self: *@This(), _: Cell, size: Cell, _: *CodeBlock, _: Cell) void {
            if (self.count < self.sizes.len) self.sizes[self.count] = size;
            self.count += 1;
        }
    };
    var live: [6]Cell align(16) = .{ 0, address, 0xdeadbeef, 0xfeedface, 0, address };
    live[0] = @intFromPtr(&live) + 32;
    live[4] = @intFromPtr(&live) + 48;
    var context: contexts.Context = undefined;
    context.callstack_top = @intFromPtr(&live);
    context.callstack_bottom = @intFromPtr(&live) + 48;
    var live_result: Accumulator = .{};
    iterateCallstack(&vm, &context, Accumulator, &live_result);
    try std.testing.expectEqual(@as(usize, 2), live_result.count);
    try std.testing.expectEqualSlices(Cell, &.{32, 16}, &live_result.sizes);
    var saved: [8]Cell align(16) = .{ 0, layouts.tagFixnum(48), 32, address, 0xdeadbeef, 0xfeedface, 16, address };
    var saved_cell = @intFromPtr(&saved) | @backingInt(layouts.TypeTag.callstack);
    var saved_result: Accumulator = .{};
    iterateCallstackObject(&vm, &saved_cell, Accumulator, &saved_result);
    try std.testing.expectEqual(@as(usize, 2), saved_result.count);
    try std.testing.expectEqualSlices(Cell, &.{32, 16}, &saved_result.sizes);
}
