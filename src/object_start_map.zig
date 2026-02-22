// object_start_map.zig - Maps card addresses to object start addresses
// Ported from vm/object_start_map.hpp and vm/object_start_map.cpp
//
// The object start map enables finding the object containing any address.
// For each card (256 bytes), we store the offset to the start of the first
// object that begins in or before that card.

const std = @import("std");
const layouts = @import("layouts.zig");
const vm = @import("vm.zig");
const mark_bits = @import("mark_bits.zig");
const Cell = layouts.Cell;

// Map stores offsets at card granularity
// Each entry is the offset (in bytes) from the card start to the object start
// A value of 0xFF means "look at the previous card"
pub const invalid_offset: u8 = 0xFF;

pub const ObjectStartMap = struct {
    start: Cell,
    size: Cell,
    entries: []u8,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, start: Cell, size: Cell) !Self {
        const card_count = (size + vm.card_size - 1) / vm.card_size;
        const entries = try allocator.alloc(u8, card_count);

        // Initialize all entries to invalid
        @memset(entries, invalid_offset);

        return Self{
            .start = start,
            .size = size,
            .entries = entries,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.entries);
        self.entries = &[_]u8{};
    }

    inline fn addressToCard(self: *const Self, address: Cell) usize {
        std.debug.assert(address >= self.start);
        std.debug.assert(address < self.start + self.size);
        return (address - self.start) / vm.card_size;
    }

    inline fn cardToAddress(self: *const Self, card_index: usize) Cell {
        return self.start + card_index * vm.card_size;
    }

    pub inline fn recordObjectStart(self: *Self, address: Cell) void {
        std.debug.assert((address & 0xF) == 0); // Objects must be 16-byte aligned

        const card_index = self.addressToCard(address);
        const card_start = self.cardToAddress(card_index);
        const offset = address - card_start;

        // Only update if this is the first object in the card, or if it's earlier
        if (self.entries[card_index] == invalid_offset or offset < self.entries[card_index]) {
            self.entries[card_index] = @truncate(offset);
        }
    }

    pub fn recordAllocation(self: *Self, address: Cell) void {
        self.recordObjectStart(address);
    }

    pub fn clear(self: *Self) void {
        @memset(self.entries, invalid_offset);
    }

    // Find the first object at or after the start of a card
    // Used when scanning cards for write barrier
    pub fn findFirstObjectInCard(self: *const Self, card_index: usize) ?Cell {
        if (card_index >= self.entries.len) {
            return null;
        }

        // If this card has a valid offset, use it
        if (self.entries[card_index] != invalid_offset) {
            return self.cardToAddress(card_index) + self.entries[card_index];
        }

        // Otherwise, walk back to find the object spanning into this card
        var idx = card_index;
        while (idx > 0) {
            idx -= 1;
            if (self.entries[idx] != invalid_offset) {
                var object_addr = self.cardToAddress(idx) + self.entries[idx];
                const card_start = self.cardToAddress(card_index);

                // Walk forward to find object in or spanning into the card
                while (object_addr < card_start + vm.card_size) {
                    const size = @import("free_list.zig").objectSizeFromHeader(object_addr);
                    if (object_addr + size > card_start) {
                        return object_addr;
                    }
                    object_addr += size;

                    if (object_addr >= self.start + self.size) {
                        return null;
                    }
                }

                return null;
            }
        }

        return null;
    }

    // Find the object containing the start of this card.
    // Matches C++ object_start_map::find_object_containing_card() which
    // starts from card_index-1 and walks back to find objects that span
    // into the target card. This is critical for write barrier correctness:
    // the write barrier marks the card containing the SLOT address, but the
    // object header may be in a previous card.
    pub fn findObjectContainingCard(self: *const Self, card_index: usize) ?Cell {
        if (card_index >= self.entries.len) {
            return null;
        }
        // C++: if (card_index == 0) return start;
        if (card_index == 0) return self.start;

        // C++: card_index--; then walk back to find valid entry
        var idx = card_index - 1;
        while (self.entries[idx] == invalid_offset) {
            if (idx == 0) return self.start;
            idx -= 1;
        }
        const result = self.cardToAddress(idx) + self.entries[idx];

        std.debug.assert((result & 0xF) == 0); // result must be 16-byte aligned

        return result;
    }

    // Update after compaction - rebuild the map from scratch
    pub fn rebuild(self: *Self, start: Cell, end: Cell) void {
        self.clear();

        var current = start;
        while (current < end) {
            self.recordObjectStart(current);
            const size = @import("free_list.zig").objectSizeFromHeader(current);
            if (size == 0) break;
            current += size;
        }
    }

    // Update card offsets after sweep using mark bits.
    // Matches C++ object_start_map::update_for_sweep.
    pub fn updateForSweep(self: *Self, marks: *const mark_bits.MarkBits) void {
        const is_64 = @sizeOf(Cell) == 8;
        var index: usize = 0;
        while (index < marks.bits_size) : (index += 1) {
            const mask: Cell = marks.marked[index];
            if (mask == 0) {
                if (is_64) {
                    const first = index * 4;
                    if (first < self.entries.len) {
                        const last = @min(first + 4, self.entries.len);
                        @memset(self.entries[first..last], invalid_offset);
                    }
                } else {
                    const first = index * 2;
                    if (first < self.entries.len) {
                        const last = @min(first + 2, self.entries.len);
                        @memset(self.entries[first..last], invalid_offset);
                    }
                }
                continue;
            }
            if (is_64) {
                self.updateCardForSweep(index * 4, @intCast(mask & 0xFFFF));
                self.updateCardForSweep(index * 4 + 1, @intCast((mask >> 16) & 0xFFFF));
                self.updateCardForSweep(index * 4 + 2, @intCast((mask >> 32) & 0xFFFF));
                self.updateCardForSweep(index * 4 + 3, @intCast((mask >> 48) & 0xFFFF));
            } else {
                self.updateCardForSweep(index * 2, @intCast(mask & 0xFFFF));
                self.updateCardForSweep(index * 2 + 1, @intCast((mask >> 16) & 0xFFFF));
            }
        }
    }

    pub fn updateCardForSweep(self: *Self, card_index: usize, mask: u16) void {
        if (card_index >= self.entries.len) return;

        const offset = self.entries[card_index];
        if (offset == invalid_offset) return;

        // Validate existing offset is aligned
        std.debug.assert((offset & 0xF) == 0); // existing offset must be aligned

        var shifted = mask;
        const shift_bits: u4 = @truncate(offset / layouts.data_alignment);
        shifted >>= shift_bits;

        if (shifted == 0) {
            self.entries[card_index] = invalid_offset;
        } else {
            const bit = rightmostSetBit(shifted);
            const new_offset: u16 = @intCast(@as(u16, offset) + bit * @as(u16, layouts.data_alignment));
            self.entries[card_index] = @truncate(new_offset);
        }
    }

    fn rightmostSetBit(mask: u16) u16 {
        return @intCast(@ctz(mask));
    }
};

// Tracks which cards have been written to (dirty)
// Used alongside object start map for write barrier
pub const CardTable = struct {
    start: Cell,
    size: Cell,
    cards: []u8,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, start: Cell, size: Cell) !Self {
        const card_count = (size + vm.card_size - 1) / vm.card_size;
        const cards = try allocator.alloc(u8, card_count);
        @memset(cards, 0);

        return Self{
            .start = start,
            .size = size,
            .cards = cards,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.cards);
        self.cards = &[_]u8{};
    }

    inline fn addressToCard(self: *const Self, address: Cell) usize {
        return (address - self.start) / vm.card_size;
    }

    pub fn markCard(self: *Self, address: Cell) void {
        const card = self.addressToCard(address);
        self.cards[card] = vm.card_mark_mask;
    }

    pub fn isCardDirty(self: *const Self, card_index: usize) bool {
        return (self.cards[card_index] & vm.card_mark_mask) != 0;
    }

    pub fn clearCard(self: *Self, card_index: usize) void {
        self.cards[card_index] = 0;
    }

    pub fn clearAll(self: *Self) void {
        @memset(self.cards, 0);
    }

    pub fn cardCount(self: *const Self) usize {
        return self.cards.len;
    }
};

// Deck table - coarse-grained tracking
// Each deck covers deck_size (256KB) bytes
pub const DeckTable = struct {
    start: Cell,
    size: Cell,
    decks: []u8,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, start: Cell, size: Cell) !Self {
        const deck_count = (size + vm.deck_size - 1) / vm.deck_size;
        const decks = try allocator.alloc(u8, deck_count);
        @memset(decks, 0);

        return Self{
            .start = start,
            .size = size,
            .decks = decks,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.decks);
        self.decks = &[_]u8{};
    }

    inline fn addressToDeck(self: *const Self, address: Cell) usize {
        return (address - self.start) / vm.deck_size;
    }

    pub fn markDeck(self: *Self, address: Cell) void {
        const deck = self.addressToDeck(address);
        self.decks[deck] = vm.card_mark_mask;
    }

    pub fn isDeckDirty(self: *const Self, deck_index: usize) bool {
        return (self.decks[deck_index] & vm.card_mark_mask) != 0;
    }

    pub fn clearDeck(self: *Self, deck_index: usize) void {
        self.decks[deck_index] = 0;
    }

    pub fn clearAll(self: *Self) void {
        @memset(self.decks, 0);
    }

    pub fn deckCount(self: *const Self) usize {
        return self.decks.len;
    }

    pub fn firstCardInDeck(deck_index: usize) usize {
        return deck_index * (vm.deck_size / vm.card_size);
    }

    pub fn lastCardInDeck(deck_index: usize) usize {
        return (deck_index + 1) * (vm.deck_size / vm.card_size) - 1;
    }
};

// Tests
test "object_start_map basic operations" {
    const allocator = std.testing.allocator;

    const start: Cell = 0x10000;
    const size: Cell = 0x10000; // 64KB

    var osm = try ObjectStartMap.init(allocator, start, size);
    defer osm.deinit();

    // Record some object starts (all 16-byte aligned)
    osm.recordObjectStart(start);
    osm.recordObjectStart(start + 96);
    osm.recordObjectStart(start + 304);

    // Check entries were recorded
    // Card 0 should have offset 0 (object at start of card)
    try std.testing.expectEqual(@as(u8, 0), osm.entries[0]);
}

test "object_start_map multiple objects in card" {
    const allocator = std.testing.allocator;

    const start: Cell = 0x10000;
    const size: Cell = 0x10000;

    var osm = try ObjectStartMap.init(allocator, start, size);
    defer osm.deinit();

    // Multiple objects in same card - earliest one wins
    osm.recordObjectStart(start + 48);
    osm.recordObjectStart(start + 16);
    osm.recordObjectStart(start + 96);

    try std.testing.expectEqual(@as(u8, 16), osm.entries[0]);
}

test "card_table operations" {
    const allocator = std.testing.allocator;

    const start: Cell = 0x10000;
    const size: Cell = 0x10000;

    var ct = try CardTable.init(allocator, start, size);
    defer ct.deinit();

    // Initially clean
    try std.testing.expect(!ct.isCardDirty(0));
    try std.testing.expect(!ct.isCardDirty(1));

    // Mark some cards
    ct.markCard(start);
    ct.markCard(start + vm.card_size * 5);

    try std.testing.expect(ct.isCardDirty(0));
    try std.testing.expect(!ct.isCardDirty(1));
    try std.testing.expect(ct.isCardDirty(5));

    // Clear
    ct.clearCard(0);
    try std.testing.expect(!ct.isCardDirty(0));
}

test "deck_table operations" {
    const allocator = std.testing.allocator;

    const start: Cell = 0x10000;
    const size: Cell = 0x1000000; // 16MB

    var dt = try DeckTable.init(allocator, start, size);
    defer dt.deinit();

    // Initially clean
    try std.testing.expect(!dt.isDeckDirty(0));

    // Mark a deck
    dt.markDeck(start);
    try std.testing.expect(dt.isDeckDirty(0));

    // Check deck math
    try std.testing.expectEqual(@as(usize, 0), DeckTable.firstCardInDeck(0));
    try std.testing.expectEqual(@as(usize, 1023), DeckTable.lastCardInDeck(0));
}
