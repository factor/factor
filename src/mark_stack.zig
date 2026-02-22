// mark_stack.zig - Chunked mark stack for GC

const std = @import("std");
const layouts = @import("layouts.zig");
const Cell = layouts.Cell;

pub const MarkStack = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    blocks: std.ArrayList([]Cell) = .empty,
    top: usize = 0,

    pub const block_len: usize = 4096;

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{ .allocator = allocator };
    }

    pub fn deinit(self: *Self) void {
        for (self.blocks.items) |blk| {
            self.allocator.free(blk);
        }
        self.blocks.deinit(self.allocator);
        self.top = 0;
    }

    pub fn clearRetainingCapacity(self: *Self) void {
        self.top = 0;
    }

    pub fn len(self: *const Self) usize {
        return self.top;
    }

    pub fn capacity(self: *const Self) usize {
        return self.blocks.items.len * block_len;
    }

    pub fn append(self: *Self, value: Cell) !void {
        const idx = self.top;
        const block_index = idx / block_len;
        const offset = idx % block_len;

        if (block_index >= self.blocks.items.len) {
            const blk = try self.allocator.alloc(Cell, block_len);
            errdefer self.allocator.free(blk);
            try self.blocks.append(self.allocator, blk);
        }

        self.blocks.items[block_index][offset] = value;
        self.top += 1;
    }

    pub fn pop(self: *Self) ?Cell {
        if (self.top == 0) return null;
        self.top -= 1;
        const idx = self.top;
        const block_index = idx / block_len;
        const offset = idx % block_len;
        return self.blocks.items[block_index][offset];
    }
};
