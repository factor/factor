// write_barrier.zig - Write barriers for generational GC
// Ported from vm/write_barrier.hpp
//
// Write barriers track cross-generational references by marking cards
// when older generation objects point to younger generation objects.
//
// For code heap: we maintain remembered sets of code blocks that may
// reference nursery or aging objects.

const std = @import("std");

const code_blocks = @import("code_blocks.zig");
const layouts = @import("layouts.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const CodeBlock = code_blocks.CodeBlock;

// Card marking constants (from vm/write_barrier.hpp)
pub const card_points_to_nursery: u8 = 0x80;
pub const card_points_to_aging: u8 = 0x40;
pub const card_mark_mask: u8 = card_points_to_nursery | card_points_to_aging;

pub const card_bits: Cell = 8;
pub const card_size: Cell = 1 << card_bits; // 256 bytes
pub const addr_card_mask: Cell = card_size - 1;

pub const deck_bits: Cell = card_bits + 10; // 18 total
pub const deck_size: Cell = 1 << deck_bits; // 256 KB
pub const cards_per_deck: Cell = 1 << 10; // 1024 cards per deck

// Convert address to card index
pub inline fn addrToCard(addr: Cell) Cell {
    return addr >> card_bits;
}

// Convert address to deck index
pub inline fn addrToDeck(addr: Cell) Cell {
    return addr >> deck_bits;
}

// Card table - tracks cross-generational references in data heap
pub const CardTable = struct {
    cards: []u8,
    decks: []u8,
    segment_start: Cell,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, segment_start: Cell, segment_size: Cell) !Self {
        const num_cards = (segment_size + card_size - 1) / card_size;
        const num_decks = (segment_size + deck_size - 1) / deck_size;

        const cards = try allocator.alloc(u8, num_cards);
        errdefer allocator.free(cards);

        const decks = try allocator.alloc(u8, num_decks);
        errdefer allocator.free(decks);

        @memset(cards, 0);
        @memset(decks, 0);

        return Self{
            .cards = cards,
            .decks = decks,
            .segment_start = segment_start,
        };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        allocator.free(self.cards);
        allocator.free(self.decks);
    }

    // Mark a card as dirty
    pub fn markCard(self: *Self, addr: Cell, mark: u8) void {
        if (addr < self.segment_start) return;

        const offset = addr - self.segment_start;
        const card_idx = offset / card_size;
        const deck_idx = offset / deck_size;

        if (card_idx < self.cards.len) {
            self.cards[card_idx] |= mark;
        }

        if (deck_idx < self.decks.len) {
            self.decks[deck_idx] |= mark;
        }
    }

    // Check if card is dirty
    pub fn isCardDirty(self: *const Self, card_idx: usize) bool {
        if (card_idx >= self.cards.len) return false;
        return (self.cards[card_idx] & card_mark_mask) != 0;
    }

    // Clear a card
    pub fn clearCard(self: *Self, card_idx: usize) void {
        if (card_idx < self.cards.len) {
            self.cards[card_idx] = 0;
        }
    }
};

// Code heap remembered sets
// These track which code blocks may reference young generation objects
pub const CodeHeapRememberedSets = struct {
    code_start: Cell = 0,
    code_size: Cell = 0,
    bit_count: usize = 0,
    nursery_count: usize = 0,
    aging_count: usize = 0,
    has_any: bool = false,
    nursery_has_any: bool = false,
    aging_has_any: bool = false,

    // Bitsets keyed by code block start line (data_alignment granularity).
    // Retained for O(1) dedup in writeBarrier and cross-set checks in
    // the .both scan mode.
    points_to_nursery: ?std.DynamicBitSet = null,
    points_to_aging: ?std.DynamicBitSet = null,

    // Dirty lists for O(m) iteration where m = dirty block count.
    // Replaces full bitset scans (750KB+ for 96MB code heap) with
    // compact sequential reads. Stale entries from removeCodeBlock
    // are filtered by isFree() during iteration.
    nursery_dirty_blocks: std.ArrayListUnmanaged(usize) = .{},
    aging_dirty_blocks: std.ArrayListUnmanaged(usize) = .{},

    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{ .allocator = allocator };
    }

    pub fn deinit(self: *Self) void {
        if (self.points_to_nursery) |*set| {
            set.deinit();
            self.points_to_nursery = null;
        }
        if (self.points_to_aging) |*set| {
            set.deinit();
            self.points_to_aging = null;
        }
        self.nursery_dirty_blocks.deinit(self.allocator);
        self.aging_dirty_blocks.deinit(self.allocator);
        self.code_start = 0;
        self.code_size = 0;
        self.bit_count = 0;
        self.nursery_count = 0;
        self.aging_count = 0;
        self.has_any = false;
        self.nursery_has_any = false;
        self.aging_has_any = false;
    }

    pub fn ensureInitialized(self: *Self, code_start: Cell, code_size: Cell) !void {
        if (self.points_to_nursery != null and self.points_to_aging != null) {
            if (self.code_start == code_start and self.code_size == code_size) return;
            // Code heap moved or resized; reinitialize.
            if (self.points_to_nursery) |*set| set.deinit();
            if (self.points_to_aging) |*set| set.deinit();
            self.points_to_nursery = null;
            self.points_to_aging = null;
            self.nursery_dirty_blocks.clearRetainingCapacity();
            self.aging_dirty_blocks.clearRetainingCapacity();
        }

        if (code_start == 0 or code_size == 0) {
            return error.RememberedSetsUninitialized;
        }

        const bit_count: usize = @intCast(code_size / layouts.data_alignment);
        var nursery = try std.DynamicBitSet.initEmpty(self.allocator, bit_count);
        errdefer nursery.deinit();
        const aging = try std.DynamicBitSet.initEmpty(self.allocator, bit_count);
        self.points_to_nursery = nursery;
        self.points_to_aging = aging;
        self.code_start = code_start;
        self.code_size = code_size;
        self.bit_count = bit_count;
        self.nursery_count = 0;
        self.aging_count = 0;
        self.refreshHasAny();
    }

    inline fn blockIndex(self: *const Self, block: *CodeBlock) usize {
        const addr: Cell = @intFromPtr(block);
        return @intCast((addr - self.code_start) / layouts.data_alignment);
    }

    pub fn writeBarrier(self: *Self, compiled: *CodeBlock) !void {
        if (self.points_to_nursery == null or self.points_to_aging == null) {
            return error.RememberedSetsUninitialized;
        }
        const idx = self.blockIndex(compiled);
        if (self.points_to_nursery) |*set| {
            if (!set.isSet(idx)) {
                set.set(idx);
                self.nursery_count += 1;
                try self.nursery_dirty_blocks.append(self.allocator, idx);
            }
        }
        if (self.points_to_aging) |*set| {
            if (!set.isSet(idx)) {
                set.set(idx);
                self.aging_count += 1;
                try self.aging_dirty_blocks.append(self.allocator, idx);
            }
        }
        // writeBarrier only sets bits, so has_any can only go false→true.
        // Skip the count-based refreshHasAny — just set directly.
        self.nursery_has_any = true;
        self.aging_has_any = true;
        self.has_any = true;
    }

    // Clear both remembered sets after GC (aging/tenured/full collections)
    pub fn clear(self: *Self) void {
        if (self.nursery_has_any) {
            if (self.points_to_nursery) |*set| {
                set.unmanaged.unsetAll();
            }
            self.nursery_dirty_blocks.clearRetainingCapacity();
        }
        if (self.aging_has_any) {
            if (self.points_to_aging) |*set| {
                set.unmanaged.unsetAll();
            }
            self.aging_dirty_blocks.clearRetainingCapacity();
        }
        self.nursery_count = 0;
        self.aging_count = 0;
        self.refreshHasAny();
    }

    inline fn refreshHasAny(self: *Self) void {
        self.nursery_has_any = self.nursery_count != 0;
        self.aging_has_any = self.aging_count != 0;
        self.has_any = self.nursery_has_any or self.aging_has_any;
    }

    // Clear only the nursery remembered set (after nursery GC).
    // The aging set is preserved so that code blocks whose references
    // were just promoted from nursery to aging remain tracked for the
    // next aging collection.  Without this, those references become
    // stale when aging space is reclaimed.
    pub fn clearNurseryOnly(self: *Self) void {
        if (self.nursery_has_any) {
            if (self.points_to_nursery) |*set| {
                set.unmanaged.unsetAll();
            }
            self.nursery_dirty_blocks.clearRetainingCapacity();
            self.nursery_count = 0;
        }
        // Keep aging set, but update aggregate flags.
        self.refreshHasAny();
    }

    fn removeDirtyIndex(list: *std.ArrayListUnmanaged(usize), index: usize) void {
        if (list.items.len == 0) return;

        var write_idx: usize = 0;
        for (list.items) |item| {
            if (item == index) continue;
            list.items[write_idx] = item;
            write_idx += 1;
        }
        list.items.len = write_idx;
    }

    // Remove a code block from remembered sets (when it's freed)
    pub fn removeCodeBlock(self: *Self, compiled: *CodeBlock) void {
        if (self.points_to_nursery == null or self.points_to_aging == null) return;
        const idx = self.blockIndex(compiled);
        var changed = false;
        if (self.points_to_nursery) |*set| {
            if (set.isSet(idx)) {
                set.unset(idx);
                std.debug.assert(self.nursery_count != 0);
                self.nursery_count -= 1;
                removeDirtyIndex(&self.nursery_dirty_blocks, idx);
                changed = true;
            }
        }
        if (self.points_to_aging) |*set| {
            if (set.isSet(idx)) {
                set.unset(idx);
                std.debug.assert(self.aging_count != 0);
                self.aging_count -= 1;
                removeDirtyIndex(&self.aging_dirty_blocks, idx);
                changed = true;
            }
        }
        if (changed) self.refreshHasAny();
    }

    pub fn hasAny(self: *const Self) bool {
        return self.has_any;
    }

    // Get dirty block indices for nursery remembered set.
    // O(m) iteration over the dirty list instead of scanning the full bitset.
    pub fn nurseryDirtyBlocks(self: *const Self) []const usize {
        return self.nursery_dirty_blocks.items;
    }

    // Get dirty block indices for aging remembered set.
    pub fn agingDirtyBlocks(self: *const Self) []const usize {
        return self.aging_dirty_blocks.items;
    }
};

// Tests
test "card address conversion" {
    const addr: Cell = 0x1234;
    const card_idx = addrToCard(addr);
    const deck_idx = addrToDeck(addr);

    try std.testing.expect(card_idx == 0x12); // 0x1234 >> 8
    try std.testing.expect(deck_idx == 0); // 0x1234 >> 18
}

test "card table basic operations" {
    const allocator = std.testing.allocator;

    const segment_start: Cell = 0x10000;
    const segment_size: Cell = 1024 * 1024; // 1MB

    var cards = try CardTable.init(allocator, segment_start, segment_size);
    defer cards.deinit(allocator);

    // Mark a card
    const test_addr: Cell = segment_start + 0x500;
    cards.markCard(test_addr, card_points_to_nursery);

    const card_idx = (test_addr - segment_start) / card_size;
    try std.testing.expect(cards.isCardDirty(card_idx));

    // Clear the card
    cards.clearCard(card_idx);
    try std.testing.expect(!cards.isCardDirty(card_idx));
}

test "code heap remembered sets" {
    const allocator = std.testing.allocator;

    var sets = CodeHeapRememberedSets.init(allocator);
    defer sets.deinit();

    const code_size: usize = layouts.data_alignment * 4;
    const buffer = try allocator.alloc(u8, code_size);
    defer allocator.free(buffer);

    const code_start: Cell = @intFromPtr(buffer.ptr);
    try sets.ensureInitialized(code_start, @intCast(code_size));

    const dummy_block: *CodeBlock = @ptrFromInt(code_start);
    dummy_block.header = 0x100; // Non-free, size 256

    // Marking the same block repeatedly should not inflate set counts.
    try sets.writeBarrier(dummy_block);
    try sets.writeBarrier(dummy_block);

    // Verify the block was marked in both sets
    const idx = sets.blockIndex(dummy_block);
    try std.testing.expect(sets.points_to_nursery.?.isSet(idx));
    try std.testing.expect(sets.points_to_aging.?.isSet(idx));
    try std.testing.expectEqual(@as(usize, 1), sets.nurseryDirtyBlocks().len);
    try std.testing.expectEqual(@as(usize, 1), sets.agingDirtyBlocks().len);
    try std.testing.expect(sets.hasAny());
    try std.testing.expect(sets.nursery_has_any);
    try std.testing.expect(sets.aging_has_any);

    sets.removeCodeBlock(dummy_block);

    try std.testing.expect(!sets.points_to_nursery.?.isSet(idx));
    try std.testing.expect(!sets.points_to_aging.?.isSet(idx));
    try std.testing.expectEqual(@as(usize, 0), sets.nurseryDirtyBlocks().len);
    try std.testing.expectEqual(@as(usize, 0), sets.agingDirtyBlocks().len);
    try std.testing.expect(!sets.hasAny());
    try std.testing.expect(!sets.nursery_has_any);
    try std.testing.expect(!sets.aging_has_any);

    // Re-adding after removal should not produce duplicate dirty-list entries.
    try sets.writeBarrier(dummy_block);
    try std.testing.expectEqual(@as(usize, 1), sets.nurseryDirtyBlocks().len);
    try std.testing.expectEqual(@as(usize, 1), sets.agingDirtyBlocks().len);
}
