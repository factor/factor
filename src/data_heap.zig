// data_heap.zig - Data heap management with generational GC
// Ported from vm/data_heap.hpp and vm/data_heap.cpp
//
// Memory layout (high to low addresses):
// [tenured space][aging space][aging semispace][nursery]
//
// The heap consists of:
// - Nursery: bump allocator, collected by copying to aging
// - Aging: semispace collector, objects that survive nursery GC
// - Aging semispace: target space for aging collection
// - Tenured: free-list allocator, long-lived objects

const std = @import("std");
const layouts = @import("layouts.zig");
const vm = @import("vm.zig");
const bump_allocator = @import("bump_allocator.zig");
const free_list = @import("free_list.zig");
const mark_bits = @import("mark_bits.zig");
const object_start_map = @import("object_start_map.zig");
const segments = @import("segments.zig");
const Cell = layouts.Cell;

// Generation identifiers
pub const Generation = enum(u2) {
    nursery = 0,
    aging = 1,
    tenured = 2,
};

// Aging space - semispace collector
pub const AgingSpace = struct {
    start: Cell,
    end: Cell,
    size: Cell,
    here: Cell,
    object_start: object_start_map.ObjectStartMap,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, start: Cell, size: Cell) !Self {
        // Align start to data_alignment (16 bytes). All object addresses must
        // be 16-byte aligned because the forwarding pointer mechanism uses
        // UNTAG (clears bottom 4 bits) to recover addresses.
        const aligned_start = layouts.alignCell(start, layouts.data_alignment);
        const effective_size = (start + size) - aligned_start;
        return Self{
            .start = aligned_start,
            .end = start + size,
            .size = size,
            .here = aligned_start,
            .object_start = try object_start_map.ObjectStartMap.init(allocator, aligned_start, effective_size),
        };
    }

    pub fn deinit(self: *Self) void {
        self.object_start.deinit();
    }

    pub fn reset(self: *Self) void {
        self.here = self.start;
        self.object_start.clear();
    }

    pub fn allocate(self: *Self, size: Cell) ?Cell {
        // Align both 'here' and size to data_alignment (16 bytes).
        // Objects MUST be 16-byte aligned because the forwarding pointer
        // mechanism uses UNTAG (clears bottom 4 bits) to recover addresses.
        const aligned_here = layouts.alignCell(self.here, layouts.data_alignment);
        const aligned_size = layouts.alignCell(size, layouts.data_alignment);
        if (aligned_here + aligned_size > self.end) {
            return null;
        }
        self.here = aligned_here + aligned_size;
        std.debug.assert(aligned_here % layouts.data_alignment == 0);
        std.debug.assert(self.here <= self.end);
        // Record object start for card-based scanning
        self.object_start.recordObjectStart(aligned_here);
        return aligned_here;
    }

    pub fn usedBytes(self: *const Self) Cell {
        return self.here - self.start;
    }

    pub fn freeBytes(self: *const Self) Cell {
        return self.end - self.here;
    }

    pub inline fn contains(self: *const Self, addr: Cell) bool {
        return addr >= self.start and addr < self.end;
    }
};

// Tenured space - free-list allocator with mark bits
pub const TenuredSpace = struct {
    start: Cell,
    end: Cell,
    size: Cell,
    free_list: free_list.FreeListAllocator,
    marks: mark_bits.MarkBits,
    object_start: object_start_map.ObjectStartMap,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, start: Cell, size: Cell) !Self {
        return Self{
            .start = start,
            .end = start + size,
            .size = size,
            .free_list = free_list.FreeListAllocator.init(allocator, start, size),
            .marks = try mark_bits.MarkBits.init(allocator, start, size),
            .object_start = try object_start_map.ObjectStartMap.init(allocator, start, size),
        };
    }

    pub fn deinit(self: *Self) void {
        self.free_list.deinit();
        self.marks.deinit();
        self.object_start.deinit();
    }

    pub fn allocate(self: *Self, size: Cell) ?Cell {
        const addr = self.free_list.allocate(size);
        if (addr) |a| {
            self.object_start.recordAllocation(a);
        }
        return addr;
    }

    pub inline fn contains(self: *const Self, addr: Cell) bool {
        return addr >= self.start and addr < self.end;
    }

    pub fn usedBytes(self: *const Self) Cell {
        return self.free_list.allocatedBytes();
    }

    pub fn freeBytes(self: *const Self) Cell {
        return self.free_list.freeBytes();
    }

    pub fn isMarked(self: *const Self, addr: Cell) bool {
        return self.marks.isMarked(addr);
    }

    pub fn clearMarks(self: *Self) void {
        self.marks.clearMarks();
    }
};

// Complete data heap structure
pub const DataHeap = struct {
    // Memory segment for entire heap
    segment: segments.Segment,

    // Generation spaces
    nursery: bump_allocator.BumpAllocator,
    aging: AgingSpace,
    aging_semispace: AgingSpace,
    tenured: TenuredSpace,

    // Card and deck tables for write barrier
    cards: object_start_map.CardTable,
    decks: object_start_map.DeckTable,

    // Configuration
    young_size: Cell,
    aging_size: Cell,
    tenured_size: Cell,

    // Statistics
    nursery_collections: Cell,
    aging_collections: Cell,
    full_collections: Cell,

    // Memory allocator
    allocator: std.mem.Allocator,

    const Self = @This();

    // Default sizes
    pub const default_young_size: Cell = 4 * 1024 * 1024; // 4MB
    pub const default_aging_size: Cell = 16 * 1024 * 1024; // 16MB
    pub const default_tenured_size: Cell = 128 * 1024 * 1024; // 128MB

    pub fn init(
        allocator: std.mem.Allocator,
        young_size: Cell,
        aging_size: Cell,
        tenured_size: Cell,
    ) !*Self {
        const self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        // Align generation sizes up to card_size so adjacent generations never
        // share a card. Without this, a boundary card is processed by both the
        // tenured and aging card scans: the tenured scan clears the nursery bit
        // (unmask=0x80) leaving 0x40, then the aging scan skips the card
        // (mask=0x80 doesn't match 0x40), leaving stale nursery pointers.
        const card_align = @as(Cell, vm.card_size);
        const tenured_sz = (tenured_size + card_align - 1) & ~(card_align - 1);
        const aging_sz = (aging_size + card_align - 1) & ~(card_align - 1);

        // Calculate total size
        const total_size = young_size + aging_sz * 2 + tenured_sz;

        // Allocate the segment
        self.segment = try segments.Segment.init(total_size, false);
        errdefer self.segment.deinit();

        // Layout: [tenured][aging][aging_semispace][nursery]
        const tenured_start = self.segment.start;
        const aging_start = tenured_start + tenured_sz;
        const aging_semi_start = aging_start + aging_sz;
        const nursery_start = layouts.alignCell(aging_semi_start + aging_sz, layouts.data_alignment);

        // Initialize spaces (using aligned sizes)
        self.tenured = try TenuredSpace.init(allocator, tenured_start, tenured_sz);
        errdefer self.tenured.deinit();

        self.aging = try AgingSpace.init(allocator, aging_start, aging_sz);
        errdefer self.aging.deinit();
        self.aging_semispace = try AgingSpace.init(allocator, aging_semi_start, aging_sz);
        errdefer self.aging_semispace.deinit();
        self.nursery = bump_allocator.BumpAllocator{
            .start = nursery_start,
            .here = nursery_start,
            .end = nursery_start + young_size,
            .size = young_size,
        };

        // Initialize card/deck tables for entire heap
        // Use segment.size (page-aligned) instead of total_size to cover the full segment
        self.cards = try object_start_map.CardTable.init(allocator, self.segment.start, self.segment.size);
        errdefer self.cards.deinit();

        self.decks = try object_start_map.DeckTable.init(allocator, self.segment.start, self.segment.size);
        errdefer self.decks.deinit();

        self.young_size = young_size;
        self.aging_size = aging_sz;
        self.tenured_size = tenured_sz;
        self.nursery_collections = 0;
        self.aging_collections = 0;
        self.full_collections = 0;
        self.allocator = allocator;

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.tenured.deinit();
        self.aging.deinit();
        self.aging_semispace.deinit();
        self.cards.deinit();
        self.decks.deinit();
        self.segment.deinit();
        self.allocator.destroy(self);
    }

    pub fn allocateNursery(self: *Self, size: Cell) ?Cell {
        if (!self.nursery.canAllot(size)) return null;
        return self.nursery.allocate(size);
    }

    pub fn allocateAging(self: *Self, size: Cell) ?Cell {
        return self.aging.allocate(size);
    }

    pub fn allocateTenured(self: *Self, size: Cell) ?Cell {
        return self.tenured.allocate(size);
    }

    // Determine which generation an address belongs to
    pub fn addressGeneration(self: *const Self, addr: Cell) ?Generation {
        if (addr >= self.nursery.start and addr < self.nursery.end) {
            return .nursery;
        }
        if (addr >= self.aging.start and addr < self.aging.end) {
            return .aging;
        }
        if (addr >= self.aging_semispace.start and addr < self.aging_semispace.end) {
            return .aging;
        }
        if (addr >= self.tenured.start and addr < self.tenured.end) {
            return .tenured;
        }
        return null;
    }

    pub fn inYoungGeneration(self: *const Self, addr: Cell) bool {
        if (self.addressGeneration(addr)) |gen| {
            return gen == .nursery or gen == .aging;
        }
        return false;
    }

    pub inline fn contains(self: *const Self, addr: Cell) bool {
        return addr >= self.segment.start and addr < self.segment.end;
    }

    pub fn resetNursery(self: *Self) void {
        self.nursery.reset();
    }

    pub fn swapAgingSpaces(self: *Self) void {
        const tmp = self.aging;
        self.aging = self.aging_semispace;
        self.aging_semispace = tmp;
        self.aging_semispace.reset(); // Also clears object_start map
    }

    pub fn totalUsedBytes(self: *const Self) Cell {
        return self.nursery.usedBytes() + self.aging.usedBytes() + self.tenured.usedBytes();
    }

    pub fn usedBytes(self: *const Self) Cell {
        return self.totalUsedBytes();
    }

    pub fn totalFreeBytes(self: *const Self) Cell {
        return self.nursery.freeBytes() + self.aging.freeBytes() + self.tenured.freeBytes();
    }

    pub fn totalBytes(self: *const Self) Cell {
        return self.segment.size;
    }

    // Write barrier support
    pub fn writeBarrier(self: *Self, slot_addr: Cell) void {
        if (slot_addr < self.segment.start or slot_addr >= self.segment.end) {
            return;
        }
        self.cards.markCard(slot_addr);
        self.decks.markDeck(slot_addr);
    }

    pub fn clearCards(self: *Self, start: Cell, end: Cell) void {
        // Skip if range is outside the segment (e.g., aging allocated separately)
        if (start >= self.segment.end or end <= self.segment.start) {
            return;
        }

        // Clamp to segment bounds
        const clamped_start = @max(start, self.segment.start);
        const clamped_end = @min(end, self.segment.end);

        const start_card = (clamped_start - self.segment.start) / vm.card_size;
        const end_card = (clamped_end - self.segment.start + vm.card_size - 1) / vm.card_size;

        // Also clamp to card count
        const card_count = self.cards.cardCount();
        const safe_end_card = @min(end_card, card_count);

        if (start_card < safe_end_card) {
            @memset(self.cards.cards[start_card..safe_end_card], 0);
        }
    }

    pub fn clearDecks(self: *Self, start: Cell, end: Cell) void {
        // Skip if range is outside the segment (e.g., aging allocated separately)
        if (start >= self.segment.end or end <= self.segment.start) {
            return;
        }

        // Clamp to segment bounds
        const clamped_start = @max(start, self.segment.start);
        const clamped_end = @min(end, self.segment.end);

        const start_deck = (clamped_start - self.segment.start) / vm.deck_size;
        const end_deck = (clamped_end - self.segment.start + vm.deck_size - 1) / vm.deck_size;

        const deck_count = self.decks.deckCount();
        const safe_end_deck = @min(end_deck, deck_count);

        if (start_deck < safe_end_deck) {
            @memset(self.decks.decks[start_deck..safe_end_deck], 0);
        }
    }

    // Calculate high water mark - the minimum free space needed in tenured
    // This is the size of nursery + aging, which is the maximum amount that
    // could be promoted to tenured in a single collection
    pub fn highWaterMark(self: *const Self) Cell {
        return self.young_size + self.aging_size;
    }

    // Check if tenured space has high fragmentation
    // High fragmentation means the largest free block is smaller than the high water mark,
    // which would prevent a full collection from succeeding
    pub fn isHighFragmentation(self: *const Self) bool {
        return self.tenured.free_list.largestFreeBlock() <= self.highWaterMark();
    }

    // Check if tenured space has low memory
    // Low memory means total free space is less than the high water mark
    pub fn isLowMemory(self: *const Self) bool {
        return self.tenured.free_list.free_space <= self.highWaterMark();
    }

    // Add method to reset aging (needed by GC)
    pub fn resetAging(self: *Self) void {
        self.aging.reset();
        self.clearCards(self.aging.start, self.aging.end);
        self.clearDecks(self.aging.start, self.aging.end);
    }

    // Grow the heap - creates a new larger heap
    // The nursery must be empty when calling this
    // Returns a new DataHeap with doubled tenured size plus requested bytes
    pub fn grow(self: *const Self, requested_bytes: Cell) !*Self {
        return self.growWithSizes(requested_bytes, self.young_size, self.aging_size);
    }

    // Grow the heap with explicit young/aging sizes (adaptive sizing support).
    // Tenured size is still doubled plus requested bytes, matching C++ behavior.
    pub fn growWithSizes(self: *const Self, requested_bytes: Cell, young_size: Cell, aging_size: Cell) !*Self {
        // Calculate new tenured size - double current plus requested bytes
        const new_tenured_size = layouts.alignCell(2 * self.tenured_size + requested_bytes, layouts.data_alignment);

        return DataHeap.init(
            self.allocator,
            young_size,
            aging_size,
            new_tenured_size,
        );
    }
};

// Tests
test "data_heap basic allocation" {
    const allocator = std.testing.allocator;

    const heap = try DataHeap.init(
        allocator,
        4096, // Small nursery for testing
        4096, // Small aging
        8192, // Small tenured
    );
    defer heap.deinit();

    // Allocate in nursery
    const obj1 = heap.allocateNursery(64);
    try std.testing.expect(obj1 != null);
    try std.testing.expectEqual(Generation.nursery, heap.addressGeneration(obj1.?).?);

    // Allocate in aging
    const obj2 = heap.allocateAging(64);
    try std.testing.expect(obj2 != null);
    try std.testing.expectEqual(Generation.aging, heap.addressGeneration(obj2.?).?);

    // Allocate in tenured
    const obj3 = heap.allocateTenured(64);
    try std.testing.expect(obj3 != null);
    try std.testing.expectEqual(Generation.tenured, heap.addressGeneration(obj3.?).?);
}

test "data_heap generations" {
    const allocator = std.testing.allocator;

    const heap = try DataHeap.init(allocator, 4096, 4096, 8192);
    defer heap.deinit();

    // Check generation identification
    try std.testing.expect(heap.inYoungGeneration(heap.nursery.start));
    try std.testing.expect(heap.inYoungGeneration(heap.aging.start));
    try std.testing.expect(!heap.inYoungGeneration(heap.tenured.start));

    // Check contains
    try std.testing.expect(heap.contains(heap.nursery.start));
    try std.testing.expect(heap.contains(heap.tenured.start));
    try std.testing.expect(!heap.contains(0));
}

test "data_heap swap_aging" {
    const allocator = std.testing.allocator;

    const heap = try DataHeap.init(allocator, 4096, 4096, 8192);
    defer heap.deinit();

    const original_aging_start = heap.aging.start;
    const original_semi_start = heap.aging_semispace.start;

    // Allocate something in aging
    _ = heap.allocateAging(64);
    try std.testing.expect(heap.aging.usedBytes() > 0);

    // Swap
    heap.swapAgingSpaces();

    // Spaces should be swapped
    try std.testing.expectEqual(original_semi_start, heap.aging.start);
    try std.testing.expectEqual(original_aging_start, heap.aging_semispace.start);

    // New aging (old semispace) should be reset
    try std.testing.expectEqual(@as(Cell, 0), heap.aging_semispace.usedBytes());
}
