// free_list.zig - Free list allocator for tenured space
// Ported from vm/free_list.hpp and vm/free_list.cpp
//
// DESIGN: Uses external storage for free block pointers (ArrayLists) like C++.
// This allows FreeBlock to be just 8 bytes (header only), enabling 16-byte minimum blocks.

const std = @import("std");
const layouts = @import("layouts.zig");
const Cell = layouts.Cell;
const Object = layouts.Object;
const Allocator = std.mem.Allocator;

// Free list allocator constants
pub const free_list_count: usize = 32;
pub const block_granularity: Cell = layouts.data_alignment; // 16 bytes
pub const allocation_page_size: Cell = 1024;

// Minimum allocatable block size - matches data_alignment
// This is possible because we store free block pointers externally (not inline)
pub const min_block_size: Cell = block_granularity; // 16 bytes

// Free block header - stored in-place in free memory
// Only 8 bytes! The free list pointers are stored externally in ArrayLists.
pub const FreeBlock = struct {
    const Self = @This();

    header: Cell, // = size | 1 (free bit)

    pub fn init(self: *FreeBlock, block_size: Cell) void {
        std.debug.assert(block_size >= min_block_size);
        self.header = (block_size & ~@as(Cell, 7)) | 1;
    }

    pub fn isFree(self: *const FreeBlock) bool {
        return (self.header & 1) == 1;
    }

    pub fn size(self: *const FreeBlock) Cell {
        const s = self.header & ~@as(Cell, 7);
        std.debug.assert(s > 0);
        return s;
    }
};

// Free list allocator with size-segregated buckets
// Like C++, uses external storage (ArrayLists) for free block pointers
pub const FreeListAllocator = struct {
    // Region of memory managed
    start: Cell,
    end: Cell,
    size: Cell,

    // Size-segregated free lists - external storage for pointers
    // Bucket i contains blocks of size (i+1) * block_granularity
    // Bucket 0: 16 bytes, Bucket 1: 32 bytes, etc.
    // Using ArrayList(Cell) to store block addresses
    small_blocks: [free_list_count]std.ArrayList(Cell),

    // Large blocks (size > free_list_count * block_granularity)
    // Stored as (address, size) pairs, sorted by size descending
    large_blocks: std.ArrayList(LargeBlock),

    free_block_count: Cell,
    free_space: Cell,

    // Bitmask: bit i set iff small_blocks[i] is non-empty.
    // Enables O(1) find-first-non-empty via @ctz instead of
    // scanning 32 ArrayList lengths across scattered cache lines.
    non_empty_mask: u32,

    allocator: Allocator,

    const Self = @This();

    const LargeBlock = struct {
        addr: Cell,
        size: Cell,
    };

    pub fn init(allocator: Allocator, start: Cell, region_size: Cell) Self {
        var self = Self{
            .start = start,
            .end = start + region_size,
            .size = region_size,
            .small_blocks = undefined,
            .large_blocks = .{},
            .free_block_count = 0,
            .free_space = 0,
            .non_empty_mask = 0,
            .allocator = allocator,
        };

        for (&self.small_blocks) |*bucket| {
            bucket.* = .{};
        }

        if (region_size >= min_block_size) {
            self.addFreeBlock(start, region_size);
        }

        return self;
    }

    /// Initialize allocator for image loading - creates a free block AFTER the occupied bytes
    pub fn initForImageLoad(allocator: Allocator, start: Cell, total_size: Cell, occupied: Cell) Self {
        var self = Self{
            .start = start,
            .end = start + total_size,
            .size = total_size,
            .small_blocks = undefined,
            .large_blocks = .{},
            .free_block_count = 0,
            .free_space = 0,
            .non_empty_mask = 0,
            .allocator = allocator,
        };

        for (&self.small_blocks) |*bucket| {
            bucket.* = .{};
        }

        // Create a free block AFTER the occupied data
        const free_start = start + occupied;
        const free_size = total_size - occupied;
        if (free_size >= min_block_size) {
            self.addFreeBlock(free_start, free_size);
        }

        return self;
    }

    pub fn deinit(self: *Self) void {
        for (&self.small_blocks) |*bucket| {
            bucket.deinit(self.allocator);
        }
        self.large_blocks.deinit(self.allocator);
    }

    inline fn sizeToIndex(size: Cell) ?usize {
        if (size < min_block_size) return null;
        const index = (size / block_granularity) - 1;
        if (index < free_list_count) {
            return index;
        }
        return null; // Large block
    }

    pub fn addFreeBlock(self: *Self, address: Cell, block_size: Cell) void {
        if (block_size < min_block_size) {
            return; // Too small to track
        }

        std.debug.assert(address >= self.start and address + block_size <= self.end);

        const block: *FreeBlock = @ptrFromInt(address);
        block.init(block_size);

        self.free_block_count += 1;
        self.free_space += block_size;

        if (sizeToIndex(block_size)) |index| {
            self.small_blocks[index].append(self.allocator, address) catch
                @panic("addFreeBlock: OOM");
            self.non_empty_mask |= @as(u32, 1) << @intCast(index);
        } else {
            // Large block - insert sorted by size ascending (best-fit order).
            // Use binary search for O(log n) position finding.
            const new_block = LargeBlock{ .addr = address, .size = block_size };
            const insert_idx = self.largeBlockInsertionPoint(block_size);
            self.large_blocks.insert(self.allocator, insert_idx, new_block) catch
                @panic("addFreeBlock: OOM");
        }
    }

    // Unsorted variant for sweep: appends without maintaining sort order.
    // Call sortLargeBlocks() after all blocks are added.
    pub fn addFreeBlockUnsorted(self: *Self, address: Cell, block_size: Cell) void {
        if (block_size < min_block_size) return;
        std.debug.assert(address >= self.start and address + block_size <= self.end);

        const block: *FreeBlock = @ptrFromInt(address);
        block.init(block_size);

        self.free_block_count += 1;
        self.free_space += block_size;

        if (sizeToIndex(block_size)) |index| {
            self.small_blocks[index].append(self.allocator, address) catch
                @panic("addFreeBlockUnsorted: OOM");
            self.non_empty_mask |= @as(u32, 1) << @intCast(index);
        } else {
            self.large_blocks.append(self.allocator, .{ .addr = address, .size = block_size }) catch
                @panic("addFreeBlockUnsorted: OOM");
        }
    }

    pub fn sortLargeBlocks(self: *Self) void {
        std.mem.sort(LargeBlock, self.large_blocks.items, {}, struct {
            fn cmp(_: void, a: LargeBlock, b: LargeBlock) bool {
                return a.size < b.size;
            }
        }.cmp);
    }

    fn orderLargeBlockSize(context: Cell, item: LargeBlock) std.math.Order {
        return std.math.order(context, item.size);
    }

    // Find insertion point in large_blocks (sorted ascending by size).
    fn largeBlockInsertionPoint(self: *Self, block_size: Cell) usize {
        return std.sort.lowerBound(LargeBlock, self.large_blocks.items, block_size, orderLargeBlockSize);
    }

    // Find the first large block with size >= requested, or null if none.
    fn findLargeBlock(self: *Self, size: Cell) ?usize {
        const idx = std.sort.lowerBound(LargeBlock, self.large_blocks.items, size, orderLargeBlockSize);
        if (idx < self.large_blocks.items.len) return idx;
        return null;
    }

    // Allocate a block of at least 'size' bytes
    pub fn allocate(self: *Self, requested_size: Cell) ?Cell {
        // Round up to block granularity
        const size = layouts.alignCell(requested_size, block_granularity);

        // Try exact-fit in small blocks (matches C++ find_free_block)
        if (sizeToIndex(size)) |index| {
            if (self.small_blocks[index].items.len == 0) {
                // Page promotion: exact bucket empty. Grab a large block,
                // split into uniform small blocks, populate the bucket.
                // C++ only checks the exact bucket — never steals from
                // larger buckets, which would create odd-sized remainders
                // and cascade into fragmentation.
                const page_size = ((allocation_page_size + size - 1) / size) * size;
                if (self.allocateLargeBlock(page_size)) |page_addr| {
                    const num_blocks = page_size / size;
                    self.small_blocks[index].ensureUnusedCapacity(self.allocator, num_blocks) catch {
                        @panic("allocate: OOM during page promotion");
                    };
                    var offset: Cell = 0;
                    while (offset + size <= page_size) : (offset += size) {
                        const small_addr = page_addr + offset;
                        const small_block: *FreeBlock = @ptrFromInt(small_addr);
                        small_block.init(size);
                        self.free_block_count += 1;
                        self.free_space += size;
                        self.small_blocks[index].appendAssumeCapacity(small_addr);
                    }
                    self.non_empty_mask |= @as(u32, 1) << @intCast(index);
                } else {
                    // Page promotion failed. Try direct large block allocation
                    // as fallback (handles case where large block exists >= size
                    // but < page_size).
                    return self.allocateLargeBlock(size);
                }
            }

            // Pop from exact bucket
            const addr = self.small_blocks[index].pop().?;
            if (self.small_blocks[index].items.len == 0) {
                self.non_empty_mask &= ~(@as(u32, 1) << @intCast(index));
            }
            const block: *FreeBlock = @ptrFromInt(addr);
            const block_size = block.size();

            self.free_block_count -= 1;
            self.free_space -= block_size;

            return self.splitAndReturn(addr, block_size, size);
        }

        // Allocate directly from large blocks
        return self.allocateLargeBlock(size);
    }

    // Find and remove a large block of at least 'size' bytes.
    // Uses binary search (O(log n)) + orderedRemove on sorted ascending list.
    fn allocateLargeBlock(self: *Self, size: Cell) ?Cell {
        const idx = self.findLargeBlock(size) orelse return null;
        const item = self.large_blocks.items[idx];
        _ = self.large_blocks.orderedRemove(idx);

        self.free_block_count -= 1;
        self.free_space -= item.size;

        return self.splitAndReturn(item.addr, item.size, size);
    }

    // Split a block if there's leftover space
    fn splitAndReturn(self: *Self, address: Cell, block_size: Cell, alloc_size: Cell) Cell {
        const remaining = block_size - alloc_size;

        if (remaining >= min_block_size) {
            // Split: add remainder back to free list
            self.addFreeBlock(address + alloc_size, remaining);
        }
        // Note: if remaining > 0 but < min_block_size, we waste those bytes
        // This is rare since allocations are aligned to block_granularity

        // Clear free bit - now allocated (caller will write object header)
        const block: *FreeBlock = @ptrFromInt(address);
        block.header = 0;

        return address;
    }

    // Free a block (add it back to free list)
    pub fn free(self: *Self, address: Cell, block_size: Cell) void {
        self.addFreeBlock(address, block_size);
    }

    pub fn freeBlockCount(self: *const Self) Cell {
        return self.free_block_count;
    }

    pub fn freeBytes(self: *const Self) Cell {
        return self.free_space;
    }

    pub fn allocatedBytes(self: *const Self) Cell {
        return self.size - self.free_space;
    }

    pub fn largestFreeBlock(self: *const Self) Cell {
        // Check large blocks first (sorted ascending by size, largest is last)
        if (self.large_blocks.items.len > 0) {
            return self.large_blocks.items[self.large_blocks.items.len - 1].size;
        }

        // Use bitmask to find highest non-empty bucket in O(1)
        if (self.non_empty_mask != 0) {
            const highest_bit = 31 - @clz(self.non_empty_mask);
            return (@as(Cell, highest_bit) + 1) * block_granularity;
        }

        return 0;
    }

    pub fn canAllot(self: *const Self, size: Cell) bool {
        const min_size = @max(size, allocation_page_size);
        return self.largestFreeBlock() >= min_size;
    }

    // Clear all free lists, resetting to empty state.
    // Must be called before repopulating (sweep, compaction, etc.).
    pub fn reset(self: *Self) void {
        for (&self.small_blocks) |*bucket| {
            bucket.clearRetainingCapacity();
        }
        self.large_blocks.clearRetainingCapacity();
        self.free_block_count = 0;
        self.free_space = 0;
        self.non_empty_mask = 0;
    }

    pub fn initialFreeList(self: *Self, occupied: Cell) void {
        self.reset();

        if (occupied < self.size) {
            const free_start = self.start + occupied;
            const free_size = self.size - occupied;
            if (free_size >= min_block_size) {
                self.addFreeBlock(free_start, free_size);
            }
        }
    }

    // Validate free list (debug-only, O(n) over all free blocks)
    pub fn validateFreeList(self: *const Self) void {
        if (comptime @import("builtin").mode != .Debug) return;
        var total_free: Cell = 0;
        var block_count: Cell = 0;

        for (self.small_blocks, 0..) |bucket, bucket_idx| {
            for (bucket.items) |addr| {
                const block: *const FreeBlock = @ptrFromInt(addr);
                std.debug.assert(block.isFree());
                const expected_size = (bucket_idx + 1) * block_granularity;
                const actual_size = block.size();
                std.debug.assert(actual_size >= expected_size and actual_size < expected_size + block_granularity);
                total_free += actual_size;
                block_count += 1;
            }
        }

        for (self.large_blocks.items) |item| {
            const block: *const FreeBlock = @ptrFromInt(item.addr);
            std.debug.assert(block.isFree());
            std.debug.assert(block.size() == item.size);
            total_free += item.size;
            block_count += 1;
        }

        std.debug.assert(total_free == self.free_space);
        std.debug.assert(block_count == self.free_block_count);
    }
};

// Calculate object size from its header
pub inline fn objectSizeFromHeader(address: Cell) Cell {
    const obj: *Object = @ptrFromInt(address);
    const obj_type = obj.getType();

    return switch (obj_type) {
        .array => blk: {
            const arr: *layouts.Array = @ptrFromInt(address);
            std.debug.assert(layouts.hasTag(arr.capacity, .fixnum));
            const capacity = layouts.untagFixnumUnsigned(arr.capacity);
            break :blk layouts.alignCell(@sizeOf(layouts.Array) + capacity * @sizeOf(Cell), layouts.data_alignment);
        },
        .byte_array => blk: {
            const arr: *layouts.ByteArray = @ptrFromInt(address);
            std.debug.assert(layouts.hasTag(arr.capacity, .fixnum));
            const capacity = layouts.untagFixnumUnsigned(arr.capacity);
            break :blk layouts.alignCell(@sizeOf(layouts.ByteArray) + capacity, layouts.data_alignment);
        },
        .string => blk: {
            const str: *layouts.String = @ptrFromInt(address);
            std.debug.assert(layouts.hasTag(str.length, .fixnum));
            const len = layouts.untagFixnumUnsigned(str.length);
            break :blk layouts.alignCell(@sizeOf(layouts.String) + len, layouts.data_alignment);
        },
        .bignum => blk: {
            const bn: *layouts.Bignum = @ptrFromInt(address);
            std.debug.assert(layouts.hasTag(bn.capacity, .fixnum));
            const capacity = layouts.untagFixnumUnsigned(bn.capacity);
            break :blk layouts.alignCell(@sizeOf(layouts.Bignum) + capacity * @sizeOf(Cell), layouts.data_alignment);
        },
        .tuple => blk: {
            const tuple: *layouts.Tuple = @ptrFromInt(address);
            // Match C++: untag layout, follow forwarding pointers, read size.
            // No defensive bounds checks — wrong sizes cause worse bugs than crashes.
            const layout_addr = layouts.followForwardingPointers(tuple.layout);
            const layout: *layouts.TupleLayout = @ptrFromInt(layout_addr);
            const tuple_size = layouts.untagFixnumUnsigned(layout.size);
            break :blk layouts.alignCell(@sizeOf(layouts.Tuple) + tuple_size * @sizeOf(Cell), layouts.data_alignment);
        },
        .quotation => layouts.alignCell(@sizeOf(layouts.Quotation), layouts.data_alignment),
        .word => layouts.alignCell(@sizeOf(layouts.Word), layouts.data_alignment),
        .wrapper => layouts.alignCell(@sizeOf(layouts.Wrapper), layouts.data_alignment),
        .float => layouts.alignCell(@sizeOf(layouts.BoxedFloat), layouts.data_alignment),
        .alien => layouts.alignCell(@sizeOf(layouts.Alien), layouts.data_alignment),
        .dll => layouts.alignCell(@sizeOf(layouts.Dll), layouts.data_alignment),
        .callstack => blk: {
            const cs: *layouts.Callstack = @ptrFromInt(address);
            std.debug.assert(layouts.hasTag(cs.length, .fixnum));
            const len = layouts.untagFixnumUnsigned(cs.length);
            break :blk layouts.alignCell(@sizeOf(layouts.Callstack) + len, layouts.data_alignment);
        },
        .fixnum, .f => layouts.data_alignment,
    };
}

// Tests
test "free_list basic allocation" {
    const size: Cell = 0x10000;
    const mem = std.testing.allocator.alloc(u8, size) catch return;
    defer std.testing.allocator.free(mem);

    const start: Cell = @intFromPtr(mem.ptr);
    var allocator = FreeListAllocator.init(std.testing.allocator, start, size);
    defer allocator.deinit();

    try std.testing.expectEqual(size, allocator.freeBytes());
    try std.testing.expectEqual(@as(Cell, 1), allocator.freeBlockCount());

    const block1 = allocator.allocate(64);
    try std.testing.expect(block1 != null);

    const block2 = allocator.allocate(128);
    try std.testing.expect(block2 != null);
    try std.testing.expect(block2.? != block1.?);

    try std.testing.expect(allocator.freeBytes() < size);
}

test "free_list 16-byte allocation" {
    const size: Cell = 0x10000;
    const mem = std.testing.allocator.alloc(u8, size) catch return;
    defer std.testing.allocator.free(mem);

    const start: Cell = @intFromPtr(mem.ptr);
    var allocator = FreeListAllocator.init(std.testing.allocator, start, size);
    defer allocator.deinit();

    // Allocate exactly 16 bytes
    const block = allocator.allocate(16);
    try std.testing.expect(block != null);

    // Another 16 bytes
    const block2 = allocator.allocate(16);
    try std.testing.expect(block2 != null);
    try std.testing.expect(block2.? != block.?);
}
