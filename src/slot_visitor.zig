// slot_visitor.zig - Object traversal for GC
// Ported from vm/slot_visitor.hpp
//
// The slot visitor visits all slots (references) in an object.
// This is the core of garbage collection - tracing live objects.

const std = @import("std");
const callstack_lookup = @import("callstack_lookup.zig");
const code_blocks = @import("code_blocks.zig");
const code_heap_mod = @import("code_heap.zig");
const free_list = @import("free_list.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const spill_slots = @import("spill_slots.zig");
const Cell = layouts.Cell;
const Object = layouts.Object;

// Slot visitor callback type
pub const SlotVisitorFn = *const fn (slot: *Cell, ctx: *anyopaque) void;

// Visit all slots in an object at the given address
pub inline fn visitObjectSlots(address: Cell, callback: SlotVisitorFn, ctx: *anyopaque) void {
    const obj: *Object = @ptrFromInt(address);

    if (obj.isFree()) {
        return;
    }

    const obj_type = obj.getType();

    switch (obj_type) {
        .array => {
            const arr: *layouts.Array = @ptrFromInt(address);
            const capacity = layouts.untagFixnumUnsigned(arr.capacity);
            const data = arr.data();
            for (0..capacity) |i| {
                callback(&data[i], ctx);
            }
        },

        .quotation => {
            const quot: *layouts.Quotation = @ptrFromInt(address);
            callback(@ptrCast(&quot.array), ctx);
            callback(@ptrCast(&quot.cached_effect), ctx);
            callback(@ptrCast(&quot.cache_counter), ctx);
            // entry_point is untagged, skip
        },

        .word => {
            const word: *layouts.Word = @ptrFromInt(address);
            callback(@ptrCast(&word.hashcode_field), ctx);
            callback(@ptrCast(&word.name), ctx);
            callback(@ptrCast(&word.vocabulary), ctx);
            callback(@ptrCast(&word.def), ctx);
            callback(@ptrCast(&word.props), ctx);
            callback(@ptrCast(&word.pic_def), ctx);
            callback(@ptrCast(&word.pic_tail_def), ctx);
            callback(@ptrCast(&word.subprimitive), ctx);
            // entry_point is untagged, skip
        },

        .tuple => {
            const tuple: *layouts.Tuple = @ptrFromInt(address);
            callback(@ptrCast(&tuple.layout), ctx);

            // Get tuple size from layout - MUST follow forwarding pointers
            // because the layout object may have been moved by GC
            const layout_addr = layouts.followForwardingPointers(tuple.layout);

            std.debug.assert(layouts.hasTag(tuple.layout, .array));
            std.debug.assert((layout_addr & 7) == 0);

            const layout: *layouts.TupleLayout = @ptrFromInt(layout_addr);
            const size = layouts.untagFixnumUnsigned(layout.size);
            const data = tuple.data();
            for (0..size) |i| {
                callback(&data[i], ctx);
            }
        },

        .wrapper => {
            const wrapper: *layouts.Wrapper = @ptrFromInt(address);
            callback(@ptrCast(&wrapper.object), ctx);
        },

        .string => {
            const str: *layouts.String = @ptrFromInt(address);
            callback(@ptrCast(&str.aux), ctx);
            callback(@ptrCast(&str.hashcode_field), ctx);
            // length is a fixnum (immediate), data is bytes, skip both
        },

        .alien => {
            const alien: *layouts.Alien = @ptrFromInt(address);
            callback(@ptrCast(&alien.base), ctx);
            callback(@ptrCast(&alien.expired), ctx);
            // displacement and address are untagged, skip
        },

        .dll => {
            const dll: *layouts.Dll = @ptrFromInt(address);
            callback(@ptrCast(&dll.path), ctx);
            // handle is untagged, skip
        },

        .callstack => {
            // Callstack contains raw return addresses, not tagged cells
            // No slots to visit
        },

        // Types with only raw data (no slots):
        .bignum => {},
        .byte_array => {},
        .float => {},

        // Immediates should not appear as heap objects:
        .fixnum => {},
        .f => {},
    }
}

// Interface for copying destinations (aging or tenured space).
// Field layout optimized for cache locality: hot fields (source range,
// bump allocator) in first cache line, cold fields after.
pub const CopyingDestination = struct {
    const Self = @This();

    // --- Cache line 1: hot path fields (64 bytes) ---
    // Source range (checked on every copy call)
    source_start: Cell = 0,
    source_end: Cell = 0,
    // Inline bump allocator (used on every allocation for nursery→aging).
    // When bump_here is non-null, allocate() uses fast inline bump path.
    bump_here: ?*Cell = null,
    bump_end: Cell = 0,
    bump_object_start: *@import("object_start_map.zig").ObjectStartMap = undefined,
    // Allocation failure flag
    allocation_failed: bool = false,

    // --- Cache line 2: cold/secondary fields ---
    // Secondary source ranges (only used for aging/tenured/grow paths)
    source2_start: Cell = 0,
    source2_end: Cell = 0,
    source3_start: Cell = 0,
    source3_end: Cell = 0,
    source4_start: Cell = 0,
    source4_end: Cell = 0,
    // Function pointers (only used for tenured/grow paths)
    allocateFn: ?*const fn (*CopyingDestination, Cell) ?Cell = null,
    postCopyFn: ?*const fn (*CopyingDestination, Cell) void = null,
    ptr: *anyopaque = undefined,
    // Code heap pointer for callstack object spill slot visiting
    code_heap: ?*code_heap_mod.CodeHeap = null,

    pub inline fn allocate(self: *CopyingDestination, size: Cell) ?Cell {
        // Fast path: inline bump allocation (aging space)
        // here is always aligned after init/previous allocation, only size needs alignment.
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
        // Slow path: function pointer (tenured free list allocator)
        return self.allocateFn.?(self, size);
    }

    // Check if an address is within the source generation.
    // Uses direct range checks instead of function pointer for performance.
    inline fn inSourceGeneration(self: *const CopyingDestination, addr: Cell) bool {
        // Fast path: primary source range
        if (addr >= self.source_start and addr < self.source_end) return true;
        // Secondary ranges only checked when set
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

        // Only copy objects from the source generation
        if (!self.inSourceGeneration(original_untagged)) {
            return old_addr;
        }

        var obj: *Object = @ptrFromInt(original_untagged);

        // Follow forwarding pointer chain (only check destination when
        // forwarding actually occurred — saves an inSourceGeneration call
        // for the common un-forwarded case)
        var untagged = original_untagged;
        if (obj.isForwardingPointer()) {
            while (obj.isForwardingPointer()) {
                obj = obj.forwardingPointer();
            }
            untagged = @intFromPtr(obj);

            // After following forwarding pointers, if outside source generation,
            // return the forwarded address with original tag bits.
            if (!self.inSourceGeneration(untagged)) {
                return untagged | layouts.TAG(old_addr);
            }
            // NOTE: If we followed forwarding pointers but the result is STILL
            // in the source generation, we must NOT return early. This happens
            // during full GC where source = nursery + aging: a nursery object
            // may have been forwarded to aging by a prior minor GC. The aging
            // copy must still be promoted to tenured.
        }

        const size = free_list.objectSizeFromHeader(untagged);

        // Allocate in destination
        const new_addr = self.allocate(size) orelse {
            self.allocation_failed = true;
            return old_addr;
        };

        // Copy object data
        if (new_addr != untagged) {
            const src: [*]u8 = @ptrFromInt(untagged);
            const dst: [*]u8 = @ptrFromInt(new_addr);
            @memcpy(dst[0..size], src[0..size]);
        } else {
            return old_addr;
        }

        // Set forwarding pointer in old location
        obj.forwardTo(@ptrFromInt(new_addr));

        // Call post-copy hook if present (e.g., to push to mark stack)
        if (self.postCopyFn) |postCopy| {
            postCopy(self, new_addr);
        }

        return new_addr | layouts.TAG(old_addr);
    }
};

// Inline helper: copy a single slot value if it's a heap pointer.
inline fn copySlot(slot: *Cell, destination: *CopyingDestination) void {
    const value = slot.*;
    if (!layouts.isImmediate(value)) {
        const new_value = destination.copy(value);
        if (new_value != value) slot.* = new_value;
    }
}

// Trace an object's slots, copying children. Returns the object's size
// so cheneyAlgorithm can avoid a redundant objectSizeFromHeader call.
// All types are inlined directly to avoid callback indirection.
pub fn traceAndCopyReturnSize(address: Cell, destination: *CopyingDestination) Cell {
    const obj: *Object = @ptrFromInt(address);
    const obj_type = obj.getType();

    switch (obj_type) {
        .array => {
            const arr: *layouts.Array = @ptrFromInt(address);
            const capacity = layouts.untagFixnumUnsigned(arr.capacity);
            const data = arr.data();
            for (0..capacity) |i| {
                copySlot(&data[i], destination);
            }
            return layouts.alignCell(@sizeOf(layouts.Array) + capacity * @sizeOf(Cell), layouts.data_alignment);
        },
        .tuple => {
            const tuple: *layouts.Tuple = @ptrFromInt(address);
            copySlot(@ptrCast(&tuple.layout), destination);
            const layout_addr = layouts.followForwardingPointers(tuple.layout);
            if ((layout_addr & 7) == 0) {
                const layout: *layouts.TupleLayout = @ptrFromInt(layout_addr);
                if (layouts.hasTag(layout.size, .fixnum)) {
                    const size = layouts.untagFixnumUnsigned(layout.size);
                    const data = tuple.data();
                    for (0..size) |i| {
                        copySlot(&data[i], destination);
                    }
                    return layouts.alignCell(@sizeOf(layouts.Tuple) + size * @sizeOf(Cell), layouts.data_alignment);
                }
            }
            return free_list.objectSizeFromHeader(address);
        },
        .quotation => {
            const quot: *layouts.Quotation = @ptrFromInt(address);
            copySlot(@ptrCast(&quot.array), destination);
            copySlot(@ptrCast(&quot.cached_effect), destination);
            copySlot(@ptrCast(&quot.cache_counter), destination);
            return layouts.alignCell(@sizeOf(layouts.Quotation), layouts.data_alignment);
        },
        .word => {
            const word_obj: *layouts.Word = @ptrFromInt(address);
            copySlot(@ptrCast(&word_obj.hashcode_field), destination);
            copySlot(@ptrCast(&word_obj.name), destination);
            copySlot(@ptrCast(&word_obj.vocabulary), destination);
            copySlot(@ptrCast(&word_obj.def), destination);
            copySlot(@ptrCast(&word_obj.props), destination);
            copySlot(@ptrCast(&word_obj.pic_def), destination);
            copySlot(@ptrCast(&word_obj.pic_tail_def), destination);
            copySlot(@ptrCast(&word_obj.subprimitive), destination);
            return layouts.alignCell(@sizeOf(layouts.Word), layouts.data_alignment);
        },
        .wrapper => {
            const wrapper: *layouts.Wrapper = @ptrFromInt(address);
            copySlot(@ptrCast(&wrapper.object), destination);
            return layouts.alignCell(@sizeOf(layouts.Wrapper), layouts.data_alignment);
        },
        .string => {
            const str: *layouts.String = @ptrFromInt(address);
            copySlot(@ptrCast(&str.aux), destination);
            copySlot(@ptrCast(&str.hashcode_field), destination);
            const len = layouts.untagFixnumUnsigned(str.length);
            return layouts.alignCell(@sizeOf(layouts.String) + len, layouts.data_alignment);
        },
        .alien => {
            const alien: *layouts.Alien = @ptrFromInt(address);
            copySlot(@ptrCast(&alien.base), destination);
            copySlot(@ptrCast(&alien.expired), destination);
            alien.updateAddress();
            return layouts.alignCell(@sizeOf(layouts.Alien), layouts.data_alignment);
        },
        .dll => {
            const dll: *layouts.Dll = @ptrFromInt(address);
            copySlot(@ptrCast(&dll.path), destination);
            return layouts.alignCell(@sizeOf(layouts.Dll), layouts.data_alignment);
        },
        .callstack => {
            const stack: *layouts.Callstack = @ptrFromInt(address);
            visitCallstackObjectSlotsForCopy(stack, destination);
            const frame_length = layouts.untagFixnumUnsigned(stack.length);
            return layouts.alignCell(@sizeOf(layouts.Callstack) + frame_length, layouts.data_alignment);
        },
        // Types with only raw data (no slots):
        .bignum => {
            const bn: *layouts.Bignum = @ptrFromInt(address);
            const capacity = layouts.untagFixnumUnsigned(bn.capacity);
            return layouts.alignCell(@sizeOf(layouts.Bignum) + capacity * @sizeOf(Cell), layouts.data_alignment);
        },
        .byte_array => {
            const ba: *layouts.ByteArray = @ptrFromInt(address);
            const capacity = layouts.untagFixnumUnsigned(ba.capacity);
            return layouts.alignCell(@sizeOf(layouts.ByteArray) + capacity, layouts.data_alignment);
        },
        .float => return layouts.alignCell(@sizeOf(layouts.BoxedFloat), layouts.data_alignment),
        // Immediates should not appear as heap objects
        .fixnum, .f => return 0,
    }
}

// Backward-compatible wrapper for callers that don't need the size.
pub fn traceAndCopy(address: Cell, destination: *CopyingDestination) void {
    _ = traceAndCopyReturnSize(address, destination);
}

// Visit spill slots in a callstack OBJECT on the heap and copy referenced
// objects. Mirrors mark.zig markCallstackObject but uses destination.copy()
// instead of marking. Matches C++ visit_callstack_object.
fn visitCallstackObjectSlotsForCopy(stack: *layouts.Callstack, destination: *CopyingDestination) void {
    const code_heap = destination.code_heap orelse return;
    var lookup = callstack_lookup.Lookup.init(code_heap) orelse return;
    const frame_length = layouts.untagFixnumUnsigned(stack.length);
    if (frame_length == 0) return;

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;
    var frame_offset: Cell = 0;

    while (frame_offset < frame_length) {
        const frame_top = stack.frameTopAt(frame_offset);
        const addr_ptr: *const Cell = @ptrFromInt(frame_top);
        const addr = addr_ptr.*;
        if (addr == 0) break;

        const owner = lookup.ownerForAddress(addr) orelse {
            frame_offset += LEAF_FRAME_SIZE;
            continue;
        };

        const frame_size = owner.stackFrameSizeForAddress(addr);

        if (owner.blockGcInfo()) |gc_info| {
            const return_address_offset: u32 = @intCast(owner.offset(addr));
            if (lookup.callsiteIndex(gc_info, return_address_offset)) |callsite| {
                const stack_pointer: [*]Cell = @ptrFromInt(frame_top);
                const Visit = struct {
                    fn slot(slot_ptr: *Cell, dest: *CopyingDestination) void {
                        const value = slot_ptr.*;
                        if (layouts.isImmediate(value)) return;
                        const copied = dest.copy(value);
                        if (copied != value) slot_ptr.* = copied;
                    }
                };
                spill_slots.visit(*CopyingDestination, stack_pointer, gc_info, callsite, destination, Visit.slot);
            }
        }

        frame_offset += frame_size;
    }
}

// Get size of object for iteration purposes
pub fn objectSize(address: Cell) Cell {
    return free_list.objectSizeFromHeader(address);
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
