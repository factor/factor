// callstack_lookup.zig - Shared fast lookup helpers for callstack walking
//
// Centralizes code-block owner and callsite lookup caches used by GC phases.

const std = @import("std");

const code_blocks = @import("code_blocks.zig");
const code_heap_mod = @import("code_heap.zig");
const layouts = @import("layouts.zig");

const Cell = layouts.Cell;

pub const Lookup = struct {
    blocks: []const Cell,
    cached_owner: ?*const code_blocks.CodeBlock = null,
    cached_start: Cell = 0,
    cached_end: Cell = 0,
    cached_gc_info: ?*const code_blocks.GcInfo = null,
    cached_callsite_return_offset: u32 = 0,
    cached_callsite_index: ?u32 = null,

    const Self = @This();

    pub fn init(code_heap: *code_heap_mod.CodeHeap) ?Self {
        const blocks = code_heap.all_blocks_sorted.items;
        if (blocks.len == 0) return null;
        return .{ .blocks = blocks };
    }

    // Returns owner only if address is inside the block extent.
    pub inline fn ownerForAddress(self: *Self, address: Cell) ?*const code_blocks.CodeBlock {
        if (self.cached_owner) |owner| {
            if (address >= self.cached_start and address < self.cached_end) {
                return owner;
            }
        }

        const ub = std.sort.upperBound(Cell, self.blocks, address, layouts.orderCell);
        if (ub == 0) return null;

        const block_start = self.blocks[ub - 1];
        const block: *const code_blocks.CodeBlock = @ptrFromInt(block_start);
        const block_end = block_start + block.size();
        if (address >= block_end) return null;

        self.cached_owner = block;
        self.cached_start = block_start;
        self.cached_end = block_end;
        return block;
    }

    // Returns previous block by address order; caller validates extent if needed.
    pub inline fn ownerForAddressUnsafe(self: *Self, address: Cell) ?*const code_blocks.CodeBlock {
        if (self.cached_owner) |owner| {
            if (address >= self.cached_start and address < self.cached_end) {
                return owner;
            }
        }

        const ub = std.sort.upperBound(Cell, self.blocks, address, layouts.orderCell);
        if (ub == 0) return null;

        const block_start = self.blocks[ub - 1];
        const block: *const code_blocks.CodeBlock = @ptrFromInt(block_start);
        self.cached_owner = block;
        self.cached_start = block_start;
        self.cached_end = block_start + block.size();
        return block;
    }

    // Cached gc_info.returnAddressIndex lookup for repeated PCs in same callsite.
    pub inline fn callsiteIndex(self: *Self, gc_info: *const code_blocks.GcInfo, return_address_offset: u32) ?u32 {
        if (self.cached_gc_info == gc_info and
            self.cached_callsite_return_offset == return_address_offset)
        {
            return self.cached_callsite_index;
        }

        const found = gc_info.returnAddressIndex(return_address_offset);
        self.cached_gc_info = gc_info;
        self.cached_callsite_return_offset = return_address_offset;
        self.cached_callsite_index = found;
        return found;
    }

    pub inline fn frameSizeFromAddress(owner: *const code_blocks.CodeBlock, addr: Cell) Cell {
        const entry_point = owner.entryPoint();
        const delta = if (addr > entry_point) addr - entry_point else 0;
        const natural_frame_size = owner.stackFrameSize();
        if (natural_frame_size > 0 and delta > 0) {
            return natural_frame_size;
        }
        return code_blocks.CodeBlock.LEAF_FRAME_SIZE;
    }
};
