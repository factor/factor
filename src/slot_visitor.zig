const std = @import("std");
const callstack_lookup = @import("callstack_lookup.zig");
const code_blocks = @import("code_blocks.zig");
const code_heap_mod = @import("code_heap.zig");
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
    allocateFn: ?*const fn (*CopyingDestination, Cell) ?Cell = null,
    postCopyFn: ?*const fn (*CopyingDestination, Cell) void = null,
    ptr: *anyopaque = undefined,
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
        return self.allocateFn.?(self, size);
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

        if (self.postCopyFn) |postCopy| {
            postCopy(self, new_addr);
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
        visitCallstackObjectSlotsForCopy(stack, self.destination);
    }
};

pub fn traceAndCopyReturnSize(address: Cell, destination: *CopyingDestination) Cell {
    var fixup = CopyFixup{ .destination = destination };
    return visitDataObjectSlots(CopyFixup, &fixup, address);
}

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

        const owner = lookup.ownerForAddressUnsafe(addr) orelse {
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
