// mark_bits.zig - Bitmap for GC mark phase tracking
// Ported from vm/mark_bits.hpp

const std = @import("std");
const layouts = @import("layouts.zig");
const Cell = layouts.Cell;

// Mark bits are stored at data_alignment (16-byte) granularity
// Each bit represents whether a 16-byte aligned block is part of a live object
pub const mark_bits_granularity: Cell = @bitSizeOf(Cell); // 64 bits per Cell on 64-bit

pub const MarkBits = struct {
    allocator: std.mem.Allocator,
    start: Cell,
    size: Cell,
    bits_size: Cell,
    marked: []Cell,
    forwarding: []Cell,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, start: Cell, size: Cell) !Self {
        const bits_needed = size / layouts.data_alignment;
        const cells_needed = (bits_needed + mark_bits_granularity - 1) / mark_bits_granularity;

        const marked = try allocator.alloc(Cell, cells_needed);
        @memset(marked, 0);

        const forwarding = try allocator.alloc(Cell, cells_needed);
        @memset(forwarding, 0);

        return Self{
            .allocator = allocator,
            .start = start,
            .size = size,
            .bits_size = cells_needed,
            .marked = marked,
            .forwarding = forwarding,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.marked);
        self.allocator.free(self.forwarding);
        self.marked = &[_]Cell{};
        self.forwarding = &[_]Cell{};
    }

    pub fn clearMarks(self: *Self) void {
        @memset(self.marked, 0);
    }

    pub inline fn addressToBitIndex(self: *const Self, address: Cell) ?struct { cell_index: usize, bit_index: u6 } {
        if (address < self.start or address >= self.start + self.size) {
            return null;
        }

        const offset = (address - self.start) / layouts.data_alignment;
        const cell_index = offset / mark_bits_granularity;
        const bit_index: u6 = @truncate(offset % mark_bits_granularity);

        return .{ .cell_index = cell_index, .bit_index = bit_index };
    }

    // Mark all bits covering [address, address + data_size)
    // This matches the C++ VM: mark bits track entire live object ranges.
    pub inline fn setMarked(self: *Self, address: Cell, data_size: Cell) void {
        if (address < self.start or address >= self.start + self.size) {
            return;
        }

        const start_line = (address - self.start) / layouts.data_alignment;
        self.setMarkedFromLine(address, data_size, start_line);
    }

    // Set mark bits given pre-computed start_line, avoiding redundant
    // address-to-line recomputation when caller already has it.
    inline fn setMarkedFromLine(self: *Self, address: Cell, data_size: Cell, start_line: Cell) void {
        const total_lines = self.size / layouts.data_alignment;
        const raw_end_line = (address + data_size - self.start) / layouts.data_alignment;
        const end_line = @min(raw_end_line, total_lines);

        const start_cell = start_line / mark_bits_granularity;
        const start_bit: u6 = @truncate(start_line % mark_bits_granularity);
        const end_cell = end_line / mark_bits_granularity;
        const end_bit: u6 = @truncate(end_line % mark_bits_granularity);

        const start_mask: Cell = (@as(Cell, 1) << start_bit) - 1;
        const end_mask: Cell = (@as(Cell, 1) << end_bit) - 1;

        if (start_cell == end_cell) {
            self.marked[start_cell] |= start_mask ^ end_mask;
        } else {
            self.marked[start_cell] |= ~start_mask;

            var index = start_cell + 1;
            while (index < end_cell) : (index += 1) {
                self.marked[index] = ~@as(Cell, 0);
            }

            if (end_mask != 0 and end_cell < self.bits_size) {
                self.marked[end_cell] |= end_mask;
            }
        }
    }

    // Mark the start bit of an object. Returns true if this was the
    // first time the object was seen. Non-atomic: GC is single-threaded
    // (stop-the-world), matching C++ which uses plain |=.
    pub inline fn tryMarkStart(self: *Self, address: Cell, data_size: Cell) bool {
        const idx = self.addressToBitIndex(address) orelse return false;
        const mask: Cell = (@as(Cell, 1) << idx.bit_index);
        const prev = self.marked[idx.cell_index];
        if ((prev & mask) != 0) {
            return false;
        }
        self.marked[idx.cell_index] = prev | mask;
        // Reuse already-computed line index instead of recomputing from address
        const start_line = idx.cell_index * mark_bits_granularity + idx.bit_index;
        self.setMarkedFromLine(address, data_size, start_line);
        return true;
    }

    // Mark ONLY the start bit of an object (no size/range). Returns true
    // if newly marked. Caller MUST later call setMarked(addr, size) to
    // fill the full bit range before sweep. Used by full GC mark to defer
    // size computation to the drain phase.
    pub inline fn tryMarkStartBitOnly(self: *Self, address: Cell) bool {
        const idx = self.addressToBitIndex(address) orelse return false;
        const mask: Cell = (@as(Cell, 1) << idx.bit_index);
        const prev = self.marked[idx.cell_index];
        if ((prev & mask) != 0) return false;
        self.marked[idx.cell_index] = prev | mask;
        return true;
    }

    pub inline fn isMarked(self: *const Self, address: Cell) bool {
        const idx = self.addressToBitIndex(address) orelse return false;
        return (self.marked[idx.cell_index] & (@as(Cell, 1) << idx.bit_index)) != 0;
    }

    // Must be called after marking phase and before compaction
    pub fn computeForwarding(self: *Self) void {
        var accum: Cell = 0;
        for (0..self.bits_size) |index| {
            self.forwarding[index] = accum;
            accum += @popCount(self.marked[index]);
        }
    }

    pub inline fn forwardBlock(self: *const Self, original: Cell) Cell {
        const position = self.addressToBitIndex(original) orelse return original;

        // Inline isMarked check using already-computed position
        if ((self.marked[position.cell_index] & (@as(Cell, 1) << position.bit_index)) == 0) {
            return original;
        }

        const offset = original & (layouts.data_alignment - 1);

        // Get approximate popcount from precomputed forwarding array
        const approx_popcount = self.forwarding[position.cell_index];

        // Add the popcount of bits before our position within this cell
        const mask = (@as(Cell, 1) << position.bit_index) - 1;
        const new_line_number = approx_popcount + @popCount(self.marked[position.cell_index] & mask);

        const new_block = self.lineBlock(new_line_number) + offset;
        return new_block;
    }

    inline fn lineBlock(self: *const Self, line: Cell) Cell {
        return line * layouts.data_alignment + self.start;
    }

    pub inline fn nextMarkedBlockAfter(self: *const Self, original: Cell) Cell {
        const position = self.addressToBitIndex(original) orelse return self.start + self.size;
        var bit_index = position.bit_index;

        var index = position.cell_index;
        while (index < self.bits_size) : (index += 1) {
            const mask = self.marked[index] >> @truncate(bit_index);
            if (mask != 0) {
                const set_bit = @ctz(mask);
                return self.lineBlock(index * mark_bits_granularity + bit_index + set_bit);
            }
            bit_index = 0;
        }

        return self.start + self.size;
    }

    pub inline fn nextUnmarkedBlockAfter(self: *const Self, original: Cell) Cell {
        const position = self.addressToBitIndex(original) orelse return self.start + self.size;
        var bit_index = position.bit_index;

        var index = position.cell_index;
        while (index < self.bits_size) : (index += 1) {
            const mask: i64 = @bitCast(self.marked[index]);
            const shifted_mask = mask >> @truncate(bit_index);
            if (~shifted_mask != 0) {
                const clear_bit = @ctz(~@as(Cell, @bitCast(shifted_mask)));
                return self.lineBlock(index * mark_bits_granularity + bit_index + clear_bit);
            }
            bit_index = 0;
        }

        return self.start + self.size;
    }

    pub inline fn unmarkedBlockSize(self: *const Self, original: Cell) Cell {
        const next_marked = self.nextMarkedBlockAfter(original);
        return next_marked - original;
    }

    pub fn countMarked(self: *const Self) Cell {
        var count: Cell = 0;
        for (self.marked) |cell| {
            count += @popCount(cell);
        }
        return count;
    }
};

// Tests
test "mark_bits basic operations" {
    const allocator = std.testing.allocator;

    const start: Cell = 0x1000;
    const size: Cell = 0x10000; // 64KB

    var mb = try MarkBits.init(allocator, start, size);
    defer mb.deinit();

    try std.testing.expect(!mb.isMarked(start));
    try std.testing.expect(!mb.isMarked(start + 16));
    try std.testing.expect(!mb.isMarked(start + 32));

    mb.setMarked(start, 16);
    mb.setMarked(start + 32, 16);
    mb.setMarked(start + 64, 16);

    try std.testing.expect(mb.isMarked(start));
    try std.testing.expect(!mb.isMarked(start + 16));
    try std.testing.expect(mb.isMarked(start + 32));
    try std.testing.expect(!mb.isMarked(start + 48));
    try std.testing.expect(mb.isMarked(start + 64));

    try std.testing.expectEqual(@as(Cell, 3), mb.countMarked());
}

test "mark_bits compute_forwarding" {
    const allocator = std.testing.allocator;

    const start: Cell = 0x1000;
    const size: Cell = 0x10000;

    var mb = try MarkBits.init(allocator, start, size);
    defer mb.deinit();

    // Mark addresses at offsets 0, 32, 64, 128
    mb.setMarked(start, 16);
    mb.setMarked(start + 32, 16);
    mb.setMarked(start + 64, 16);
    mb.setMarked(start + 128, 16);

    // Compute forwarding addresses
    mb.computeForwarding();

    // Check forwarding addresses - each object slides to eliminate gaps
    try std.testing.expectEqual(start + 0, mb.forwardBlock(start));
    try std.testing.expectEqual(start + 16, mb.forwardBlock(start + 32));
    try std.testing.expectEqual(start + 32, mb.forwardBlock(start + 64));
    try std.testing.expectEqual(start + 48, mb.forwardBlock(start + 128));
}

test "mark_bits next_marked" {
    const allocator = std.testing.allocator;

    const start: Cell = 0x1000;
    const size: Cell = 0x10000;

    var mb = try MarkBits.init(allocator, start, size);
    defer mb.deinit();

    // Mark some addresses
    mb.setMarked(start + 48, 16);
    mb.setMarked(start + 128, 16);
    mb.setMarked(start + 1024, 16);

    // Find next marked from start
    try std.testing.expectEqual(start + 48, mb.nextMarkedBlockAfter(start));
    try std.testing.expectEqual(start + 48, mb.nextMarkedBlockAfter(start + 48));
    try std.testing.expectEqual(start + 128, mb.nextMarkedBlockAfter(start + 64));
    try std.testing.expectEqual(start + 1024, mb.nextMarkedBlockAfter(start + 256));
    try std.testing.expectEqual(start + size, mb.nextMarkedBlockAfter(start + 2048));
}

test "mark_bits clear_all" {
    const allocator = std.testing.allocator;

    const start: Cell = 0x1000;
    const size: Cell = 0x10000;

    var mb = try MarkBits.init(allocator, start, size);
    defer mb.deinit();

    // Mark many addresses
    mb.setMarked(start, 16);
    mb.setMarked(start + 32, 16);
    mb.setMarked(start + 64, 16);
    mb.setMarked(start + 1024, 16);
    mb.setMarked(start + 2048, 16);

    // Each setMarked marks 1 bit (at 16-byte granularity)
    try std.testing.expectEqual(@as(Cell, 5), mb.countMarked());

    // Clear all
    mb.clearMarks();

    try std.testing.expectEqual(@as(Cell, 0), mb.countMarked());
    try std.testing.expect(!mb.isMarked(start));
    try std.testing.expect(!mb.isMarked(start + 32));
}

test "mark_bits unmarked_block_size" {
    const allocator = std.testing.allocator;

    const start: Cell = 0x1000;
    const size: Cell = 0x10000;

    var mb = try MarkBits.init(allocator, start, size);
    defer mb.deinit();

    // Mark objects with gaps
    mb.setMarked(start, 16);
    mb.setMarked(start + 128, 16);

    // The gap between start+16 and start+128 is 112 bytes
    const gap_size = mb.unmarkedBlockSize(start + 16);
    try std.testing.expectEqual(@as(Cell, 112), gap_size);
}
