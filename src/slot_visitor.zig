const std = @import("std");
const builtin = @import("builtin");
const callstack_lookup = @import("callstack_lookup.zig");
const code_blocks = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const code_heap_mod = @import("code_heap.zig");
const data_heap_mod = @import("data_heap.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const spill_slots = @import("spill_slots.zig");
const Cell = layouts.Cell;
const Object = layouts.Object;

fn visitInfoForFixup(comptime Fixup: type, fixup: *Fixup, address: Cell) layouts.ObjectVisitInfo {
    const obj: *Object = @ptrFromInt(address);

    return switch (obj.getType()) {
        .tuple => blk: {
            const tuple: *layouts.Tuple = @ptrFromInt(address);
            const layout_addr = if (@hasDecl(Fixup, "resolveTupleLayout"))
                fixup.resolveTupleLayout(tuple.layout)
            else
                layouts.followForwardingPointers(tuple.layout);
            std.debug.assert((layout_addr & 7) == 0);
            const layout: *layouts.TupleLayout = @ptrFromInt(layout_addr);
            const tuple_size = layouts.untagFixnumUnsigned(layout.size);
            break :blk .{
                .type = .tuple,
                .slot_count = 1 + tuple_size,
                .size = layouts.alignCell(@sizeOf(layouts.Tuple) + tuple_size * @sizeOf(Cell), layouts.data_alignment),
            };
        },
        else => layouts.objectVisitInfoFromAddress(address),
    };
}

pub fn visitDataObjectSlots(comptime Fixup: type, fixup: *Fixup, address: Cell) Cell {
    const obj: *Object = @ptrFromInt(address);
    if (obj.isFree()) return 0;

    const info = visitInfoForFixup(Fixup, fixup, address);
    if (info.size == 0) return 0;

    switch (info.type) {
        .callstack => {
            if (@hasDecl(Fixup, "visitCallstackObject")) {
                const cs: *layouts.Callstack = @ptrFromInt(address);
                fixup.visitCallstackObject(cs);
            }
            return info.size;
        },
        .fixnum, .f => return 0,
        else => {},
    }

    if (info.slot_count > 0) {
        if (@hasDecl(Fixup, "ensureSlotCapacity")) fixup.ensureSlotCapacity(info.slot_count);
        const slots: [*]Cell = @ptrFromInt(address + @sizeOf(Cell));
        for (0..info.slot_count) |i| {
            fixup.visitSlot(&slots[i]);
        }
    }

    switch (info.type) {
        .quotation => {
            if (@hasDecl(Fixup, "visitEntryPoint")) {
                const quot: *layouts.Quotation = @ptrFromInt(address);
                fixup.visitEntryPoint(quot.entry_point);
            }
        },
        .word => {
            if (@hasDecl(Fixup, "visitEntryPoint")) {
                const word_obj: *layouts.Word = @ptrFromInt(address);
                fixup.visitEntryPoint(word_obj.entry_point);
            }
        },
        .alien => {
            const alien: *layouts.Alien = @ptrFromInt(address);
            alien.updateAddress();
        },
        else => {},
    }

    return info.size;
}

pub const CopyingDestination = struct {
    const Self = @This();

    source_start: Cell = 0,
    source_end: Cell = 0,
    bump_here: ?*Cell = null,
    bump_end: Cell = 0,
    bump_object_start: *@import("object_start_map.zig").ObjectStartMap = undefined,
    allocation_failed: bool = false,

    source2_start: Cell = 0,
    source2_end: Cell = 0,
    source3_start: Cell = 0,
    source3_end: Cell = 0,
    source4_start: Cell = 0,
    source4_end: Cell = 0,
    // Promotion target: where survivors are copied when bump_here is null (no
    // semispace finger). A typed field, not a fn-pointer, so the copy hot path
    // has no indirect calls.
    tenured_target: ?*data_heap_mod.TenuredSpace = null,
    // Cheney worklist: copied objects pushed here for later slot scanning.
    // null for bump/semispace collectors (which use a finger) and for the
    // full-mark copy path (which drains via its own mark phase).
    mark_stack: ?*std.ArrayList(Cell) = null,
    mark_stack_allocator: std.mem.Allocator = undefined,
    code_heap: ?*code_heap_mod.CodeHeap = null,

    pub fn allocate(self: *CopyingDestination, size: Cell) ?Cell {
        if (self.bump_here) |here_ptr| {
            const h = here_ptr.*;
            const aligned_size = layouts.alignCell(size, layouts.data_alignment);
            if (h + aligned_size > self.bump_end) {
                return null;
            }
            here_ptr.* = h + aligned_size;
            self.bump_object_start.recordObjectStart(h);
            return h;
        }
        if (self.tenured_target) |space| return space.allocate(size);
        return null;
    }

    fn inSourceGeneration(self: *const CopyingDestination, addr: Cell) bool {
        if (addr >= self.source_start and addr < self.source_end) return true;
        if (self.source2_end != 0) {
            if (addr >= self.source2_start and addr < self.source2_end) return true;
            if (self.source3_end != 0) {
                if (addr >= self.source3_start and addr < self.source3_end) return true;
                if (self.source4_end != 0 and addr >= self.source4_start and addr < self.source4_end) return true;
            }
        }
        return false;
    }

    pub fn copy(self: *CopyingDestination, old_addr: Cell) Cell {
        const original_untagged = layouts.UNTAG(old_addr);

        if (!self.inSourceGeneration(original_untagged)) {
            return old_addr;
        }

        return copyInSourceGeneration(self, old_addr, original_untagged);
    }

    noinline fn copyInSourceGeneration(
        self: *CopyingDestination,
        old_addr: Cell,
        original_untagged: Cell,
    ) Cell {
        var obj: *Object = @ptrFromInt(original_untagged);

        var untagged = original_untagged;
        if (obj.isForwardingPointer()) {
            while (obj.isForwardingPointer()) {
                obj = obj.forwardingPointer();
            }
            untagged = @intFromPtr(obj);

            if (!self.inSourceGeneration(untagged)) {
                return untagged | layouts.TAG(old_addr);
            }
        }

        const size = layouts.objectVisitInfoFromAddress(untagged).size;

        const new_addr = self.allocate(size) orelse {
            self.allocation_failed = true;
            return old_addr;
        };

        if (new_addr != untagged) {
            const src: [*]u8 = @ptrFromInt(untagged);
            const dst: [*]u8 = @ptrFromInt(new_addr);
            @memcpy(dst[0..size], src[0..size]);
        } else {
            return old_addr;
        }

        obj.forwardTo(@ptrFromInt(new_addr));

        // Cheney worklist push: queue the copied object for later slot scanning.
        if (self.mark_stack) |ms| {
            ms.append(self.mark_stack_allocator, new_addr) catch @panic("Mark stack overflow");
        }

        return new_addr | layouts.TAG(old_addr);
    }
};

pub const CopyFixup = struct {
    destination: *CopyingDestination,

    pub fn visitSlot(self: *@This(), slot: *Cell) void {
        const value = slot.*;
        if (!layouts.isImmediate(value)) {
            const new_value = self.destination.copy(value);
            if (new_value != value) slot.* = new_value;
        }
    }

    pub fn visitCallstackObject(self: *@This(), stack: *layouts.Callstack) void {
        const code_heap = self.destination.code_heap orelse return;
        visitCallstackObjectRoots(CopyFixup, self, code_heap, stack);
    }
};

pub fn traceAndCopyReturnSize(address: Cell, destination: *CopyingDestination) Cell {
    var fixup = CopyFixup{ .destination = destination };
    return visitDataObjectSlots(CopyFixup, &fixup, address);
}

/// Walk a *callstack object's* frames and apply `fixup.visitSlot(*Cell)` to
/// every spilled object pointer. If `Fixup` declares `visitCodeBlockOwner`, it
/// is also called for each frame's owning code block (the full/mark collector
/// needs this to keep the block live across a code-heap sweep; the copying
/// collector does not and omits the method). Callstack objects store frames
/// relative to the object body; on arm64 the relative frame size is at slot 0
/// and the return address at +8, on x86-64 the return address is at +0. Shared
/// by the copying and full-mark collectors so this frame convention — and the
/// GC-safety of promoting spilled referents — lives in exactly one place.
pub fn visitCallstackObjectRoots(
    comptime Fixup: type,
    fixup: *Fixup,
    code_heap: *code_heap_mod.CodeHeap,
    stack: *layouts.Callstack,
) void {
    var lookup = callstack_lookup.Lookup.init(code_heap) orelse return;
    const frame_length = layouts.untagFixnumUnsigned(stack.length);
    if (frame_length == 0) return;

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;
    const is_arm64 = builtin.cpu.arch == .aarch64;
    var frame_offset: Cell = 0;

    while (frame_offset < frame_length) {
        const frame_top = stack.frameTopAt(frame_offset);

        // arm64 callstack objects store the (relative) frame size at slot 0 and
        // the return address at +8; x86-64 stores the return address at +0.
        const arm_frame_size: Cell = if (is_arm64) @as(*const Cell, @ptrFromInt(frame_top)).* else 0;
        if (is_arm64 and (arm_frame_size == 0 or frame_offset + arm_frame_size > frame_length)) break;

        const addr = @as(*const Cell, @ptrFromInt(frame_top + contexts.FRAME_RETURN_ADDRESS)).*;
        if (addr == 0) break;

        const owner = lookup.ownerForAddressUnsafe(addr) orelse {
            frame_offset += if (is_arm64) arm_frame_size else LEAF_FRAME_SIZE;
            continue;
        };

        const advance = if (is_arm64) arm_frame_size else owner.stackFrameSizeForAddress(addr);

        if (comptime @hasDecl(Fixup, "visitCodeBlockOwner")) {
            fixup.visitCodeBlockOwner(owner);
        }

        if (owner.blockGcInfo()) |gc_info| {
            const return_address_offset: u32 = @intCast(owner.offset(addr));
            if (lookup.callsiteIndex(gc_info, return_address_offset)) |callsite| {
                // A frame's spilled roots number at most frame_size/cell. Fixups
                // that push assume-capacity (the full-mark collector) must have
                // room reserved first, since visitDataObjectSlots does not
                // pre-ensure capacity for callstack objects the way it does for
                // ordinary slot loops.
                if (comptime @hasDecl(Fixup, "ensureSlotCapacity")) {
                    fixup.ensureSlotCapacity(advance / @sizeOf(Cell));
                }
                const stack_pointer: [*]Cell = @ptrFromInt(frame_top);
                const Visit = struct {
                    fn slot(slot_ptr: *Cell, fx: *Fixup) void {
                        fx.visitSlot(slot_ptr);
                    }
                };
                spill_slots.visit(*Fixup, stack_pointer, gc_info, callsite, fixup, Visit.slot);
            }
        }

        frame_offset += advance;
    }
}

/// Walk the live native callstack of a context (between `callstack_top` and
/// `callstack_bottom`) and apply `fixup.visitSlot(*Cell)` to every spilled
/// object pointer. This is the exact arm64-aware frame walk used by the GC's
/// visitCallstack, factored out so non-GC root scanners (primitive_become)
/// reuse one validated implementation instead of re-deriving the frame
/// conventions. The caller must pass the context's *saved* callstack pointers
/// (valid after a GC/safepoint save) and a live code heap.
pub fn visitLiveCallstackRoots(
    comptime Fixup: type,
    fixup: *Fixup,
    code_heap: *code_heap_mod.CodeHeap,
    callstack_top: Cell,
    callstack_bottom: Cell,
) void {
    var lookup = callstack_lookup.Lookup.init(code_heap) orelse return;

    var top = callstack_top;
    const bottom = callstack_bottom;
    if (top == 0 or bottom == 0 or top >= bottom) return;

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;
    const is_arm64 = builtin.cpu.arch == .aarch64;

    while (top < bottom) {
        // Return address: frame_top+0 on x86-64, frame_top+8 on arm64.
        const addr = @as(*const Cell, @ptrFromInt(top + contexts.FRAME_RETURN_ADDRESS)).*;
        if (addr == 0) break;

        // arm64 frames are chained: *(top) is the predecessor frame top.
        const next_top: Cell = if (is_arm64) @as(*const Cell, @ptrFromInt(top)).* else 0;

        const owner = lookup.ownerForAddressUnsafe(addr) orelse {
            if (is_arm64) {
                if (next_top <= top) break;
                top = next_top;
            } else {
                top += LEAF_FRAME_SIZE;
            }
            continue;
        };

        // Full-mark GC needs the frame's code block kept live (return addresses
        // alone are not heap roots). Optional so become/copy paths can omit it.
        if (comptime @hasDecl(Fixup, "visitCodeBlockOwner")) {
            fixup.visitCodeBlockOwner(owner);
        }

        if (owner.blockGcInfo()) |gc_info| {
            const return_address_offset: u32 = @intCast(owner.offset(addr));
            if (lookup.callsiteIndex(gc_info, return_address_offset)) |callsite| {
                const stack_pointer: [*]Cell = @ptrFromInt(top);
                const Visit = struct {
                    fn slot(slot_ptr: *Cell, fx: *Fixup) void {
                        fx.visitSlot(slot_ptr);
                    }
                };
                spill_slots.visit(*Fixup, stack_pointer, gc_info, callsite, fixup, Visit.slot);
            }
        } else {
            lookup.cached_gc_info = null;
            lookup.cached_callsite_index = null;
        }

        if (is_arm64) {
            if (next_top <= top) break;
            top = next_top;
        } else {
            top += callstack_lookup.Lookup.frameSizeFromAddress(owner, addr);
        }
    }
}

// Get size of object for iteration purposes
pub fn objectSize(address: Cell) Cell {
    return layouts.objectVisitInfoFromAddress(address).size;
}

// Iterate over all objects in a memory range
pub const ObjectIterator = struct {
    current: Cell,
    end: Cell,

    const Self = @This();

    pub fn init(start: Cell, end: Cell) Self {
        return Self{
            .current = start,
            .end = end,
        };
    }

    pub fn next(self: *Self) ?Cell {
        while (self.current < self.end) {
            const addr = self.current;
            const header: Cell = @as(*const Cell, @ptrFromInt(addr)).*;

            if (header & 1 == 1) {
                // Free block - size encoded in header for both regular
                // free blocks and gap blocks (< min_block_size).
                const size = header & ~@as(Cell, 7);
                if (size == 0) return null;
                self.current += size;
                continue;
            }

            if (header == 0) return null;
            const size = objectSize(addr);
            if (size == 0) return null;
            self.current += size;
            return addr;
        }
        return null;
    }
};
