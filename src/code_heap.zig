// code_heap.zig - Code heap management
// Manages the JIT-compiled code heap: allocation, block tracking,
// remembered sets for GC, scan flags, and mark bits.

const std = @import("std");
const builtin = @import("builtin");

const code_blocks_mod = @import("code_blocks.zig");
const free_list = @import("free_list.zig");
const layouts = @import("layouts.zig");
const mark_bits = @import("mark_bits.zig");
const segments = @import("segments.zig");
const write_barrier = @import("write_barrier.zig");

const Cell = layouts.Cell;
const CodeBlock = code_blocks_mod.CodeBlock;
const LiteralRelocationSite = code_blocks_mod.LiteralRelocationSite;

pub const CodeHeap = struct {
    seg: ?*segments.Segment,
    free_list: ?*free_list.FreeListAllocator = null, // typed allocator for JIT
    safepoint_page: Cell,
    // Code heap address range (for callstack walking)
    code_start: Cell = 0,
    code_size: Cell = 0,
    // Source of truth for live code block addresses (kept sorted).
    all_blocks_sorted: std.ArrayList(Cell) = .{},
    // Memory allocator used for code heap metadata (mark bits, hash maps, etc.)
    allocator: ?std.mem.Allocator = null,
    // Remembered sets for GC - track code blocks that may reference young objects
    remembered_sets: write_barrier.CodeHeapRememberedSets,
    // Scan flags for code heap GC (skip blocks without literals/code pointers)
    scan_literals: ?std.DynamicBitSet = null,
    scan_code_ptrs: ?std.DynamicBitSet = null,
    // Uninitialized blocks: code blocks allocated but not yet relocated.
    // Maps block address -> literals Cell for deferred initialization.
    // Matches C++ code_heap::uninitialized_blocks map.
    uninitialized_blocks: std.AutoHashMapUnmanaged(Cell, Cell) = .{},
    // Scratch map reused during compaction to avoid repeated allocations.
    uninitialized_blocks_scratch: std.AutoHashMapUnmanaged(Cell, Cell) = .{},
    // Cached literal relocation operands for each code block.
    literal_sites: std.AutoHashMapUnmanaged(Cell, std.ArrayListUnmanaged(LiteralRelocationSite)) = .{},
    // Mark bits for code heap full GC (mirrors C++ code->allocator->state)
    marks: ?*mark_bits.MarkBits = null,

    const Self = @This();

    pub fn allocate(self: *Self, size: Cell) ?*CodeBlock {
        const alloc = self.free_list orelse return null;
        const aligned_size = layouts.alignCell(size, layouts.data_alignment);
        if (alloc.allocate(aligned_size)) |addr| {
            const block: *CodeBlock = @ptrFromInt(addr);
            // Add to all_blocks for codeBlockForAddress to find
            self.addToAllBlocks(addr);
            return block;
        }
        return null;
    }

    fn addToAllBlocks(self: *Self, block_addr: Cell) void {
        const al = self.allocator orelse return;
        const pos = std.sort.lowerBound(Cell, self.all_blocks_sorted.items, block_addr, layouts.orderCell);
        if (pos < self.all_blocks_sorted.items.len and self.all_blocks_sorted.items[pos] == block_addr) return;
        self.all_blocks_sorted.insert(al, pos, block_addr) catch @panic("OOM");
    }

    pub fn occupiedSpace(self: *const Self) Cell {
        if (self.free_list) |alloc| {
            return alloc.size - alloc.free_space;
        }
        return self.code_size; // If no allocator, assume all space is occupied
    }

    /// Returns the byte extent from code_start to the end of the last occupied
    /// block. Unlike occupiedSpace() (which sums non-free bytes), this accounts
    /// for free blocks interleaved among occupied ones. Needed by save-image
    /// because the Zig VM does not compact the code heap.
    pub fn codeHeapExtent(self: *const Self) Cell {
        const end = self.code_start + self.code_size;
        var current = self.code_start;
        var last_occupied_end: Cell = self.code_start;

        while (current < end) {
            const block: *const CodeBlock = @ptrFromInt(current);
            const block_size = block.size();
            if (block_size == 0) break;
            if (!block.isFree()) {
                last_occupied_end = current + block_size;
            }
            current += block_size;
        }
        return last_occupied_end - self.code_start;
    }

    pub fn writeBarrier(self: *Self, compiled: *CodeBlock) !void {
        try self.remembered_sets.ensureInitialized(self.code_start, self.code_size);
        try self.remembered_sets.writeBarrier(compiled);
    }

    fn ensureScanFlags(self: *Self, al: std.mem.Allocator) !void {
        if (self.scan_literals != null and self.scan_code_ptrs != null) return;
        const bit_count: usize = @intCast(self.code_size / layouts.data_alignment);
        self.scan_literals = try std.DynamicBitSet.initEmpty(al, bit_count);
        self.scan_code_ptrs = try std.DynamicBitSet.initEmpty(al, bit_count);
    }

    fn blockIndex(self: *const Self, block: *CodeBlock) usize {
        return @intCast((@intFromPtr(block) - self.code_start) / layouts.data_alignment);
    }

    fn blockIndexFromAddress(self: *const Self, block_addr: Cell) usize {
        return @intCast((block_addr - self.code_start) / layouts.data_alignment);
    }

    pub fn updateScanFlags(self: *Self, al: std.mem.Allocator, block: *CodeBlock) void {
        // Graceful degradation: without scan flags, all blocks are scanned (slower but correct)
        self.ensureScanFlags(al) catch return;
        const flags = code_blocks_mod.scanRelocationFlags(block);
        const idx = self.blockIndex(block);
        if (self.scan_literals) |*set| {
            if (flags.has_literals) set.set(idx) else set.unset(idx);
        }
        if (self.scan_code_ptrs) |*set| {
            if (flags.has_code_ptrs) set.set(idx) else set.unset(idx);
        }
    }

    pub fn updateLiteralSites(self: *Self, al: std.mem.Allocator, block: *CodeBlock) void {
        var sites = std.ArrayListUnmanaged(LiteralRelocationSite){};
        code_blocks_mod.collectLiteralRelocationSites(block, &sites, al) catch return;

        const block_addr = @intFromPtr(block);
        if (self.literal_sites.fetchRemove(block_addr)) |entry| {
            var old_sites = entry.value;
            old_sites.deinit(al);
        }

        if (sites.items.len == 0) {
            sites.deinit(al);
            return;
        }

        self.literal_sites.put(al, block_addr, sites) catch {
            sites.deinit(al);
        };
    }

    fn removeLiteralSites(self: *Self, block_addr: Cell) void {
        const al = self.allocator orelse return;
        if (self.literal_sites.fetchRemove(block_addr)) |entry| {
            var old_sites = entry.value;
            old_sites.deinit(al);
        }
    }

    fn clearLiteralSites(self: *Self) void {
        const al = self.allocator orelse return;
        var iter = self.literal_sites.valueIterator();
        while (iter.next()) |sites| {
            var list = sites.*;
            list.deinit(al);
        }
        self.literal_sites.clearRetainingCapacity();
    }

    pub fn rebuildLiteralSites(self: *Self, al: std.mem.Allocator) void {
        self.clearLiteralSites();
        for (self.all_blocks_sorted.items) |block_addr| {
            const block: *CodeBlock = @ptrFromInt(block_addr);
            if (!block.isFree()) {
                self.updateLiteralSites(al, block);
            }
        }
    }

    pub fn literalSitesForBlock(self: *const Self, block: *const CodeBlock) ?[]const LiteralRelocationSite {
        if (self.literal_sites.getPtr(@intFromPtr(block))) |sites| return sites.items;
        return null;
    }

    pub fn putUninitializedBlock(self: *Self, al: std.mem.Allocator, block_addr: Cell, literals_cell: Cell) !void {
        try self.uninitialized_blocks.put(al, block_addr, literals_cell);
    }

    pub fn removeUninitializedBlock(self: *Self, block_addr: Cell) bool {
        return self.uninitialized_blocks.remove(block_addr);
    }

    pub fn clearUninitializedBlocks(self: *Self) void {
        self.uninitialized_blocks.clearRetainingCapacity();
    }

    pub fn isBlockUninitialized(self: *const Self, block: *const CodeBlock) bool {
        return self.isUninitializedAddress(@intFromPtr(block));
    }

    pub fn isUninitializedAddress(self: *const Self, block_addr: Cell) bool {
        return self.uninitialized_blocks.contains(block_addr);
    }

    pub fn removeScanFlags(self: *Self, block: *CodeBlock) void {
        if (self.scan_literals == null or self.scan_code_ptrs == null) return;
        const idx = self.blockIndex(block);
        if (self.scan_literals) |*set| set.unset(idx);
        if (self.scan_code_ptrs) |*set| set.unset(idx);
    }

    pub fn removeScanFlagsByAddress(self: *Self, block_addr: Cell) void {
        if (self.scan_literals == null or self.scan_code_ptrs == null) return;
        const idx = self.blockIndexFromAddress(block_addr);
        if (self.scan_literals) |*set| set.unset(idx);
        if (self.scan_code_ptrs) |*set| set.unset(idx);
    }

    pub fn removeLiteralSitesByAddress(self: *Self, block_addr: Cell) void {
        self.removeLiteralSites(block_addr);
    }

    pub fn clearScanFlags(self: *Self) void {
        if (self.scan_literals) |*set| set.unmanaged.unsetAll();
        if (self.scan_code_ptrs) |*set| set.unmanaged.unsetAll();
    }

    pub fn blockHasLiterals(self: *const Self, block: *CodeBlock) bool {
        if (self.scan_literals) |set| return set.isSet(self.blockIndex(block));
        return true;
    }

    pub fn blockHasCodePointers(self: *const Self, block: *CodeBlock) bool {
        if (self.scan_code_ptrs) |set| return set.isSet(self.blockIndex(block));
        return true;
    }

    pub fn clearRememberedSets(self: *Self) void {
        self.remembered_sets.clear();
    }

    pub fn free(self: *Self, block: *CodeBlock) void {
        self.remembered_sets.removeCodeBlock(block);
        self.removeScanFlags(block);
        const block_addr = @intFromPtr(block);
        _ = self.removeUninitializedBlock(block_addr);
        self.removeLiteralSites(block_addr);
        self.removeFromAllBlocks(@intFromPtr(block));

        const size = block.size();
        block.markFree(size);
        if (self.free_list) |alloc| {
            alloc.free(@intFromPtr(block), size);
        }
    }

    fn removeFromAllBlocks(self: *Self, block_addr: Cell) void {
        // Incremental sorted remove: O(log n) search + O(n) shift
        const items = self.all_blocks_sorted.items;
        const pos = std.sort.lowerBound(Cell, items, block_addr, layouts.orderCell);
        if (pos < items.len and items[pos] == block_addr) {
            _ = self.all_blocks_sorted.orderedRemove(pos);
        }
    }

    // Batch remove addresses from all_blocks_sorted.
    pub fn batchRemoveFromAllBlocks(self: *Self, removes: []const Cell) void {
        if (removes.len == 0) return;

        // Fast path: when removes are sorted, remove in-place with one linear merge.
        // Falls back to individual removes when input order is arbitrary.
        if (!isNonDecreasing(removes)) {
            for (removes) |addr| {
                self.removeFromAllBlocks(addr);
            }
            return;
        }

        const items = self.all_blocks_sorted.items;
        var write_idx: usize = 0;
        var remove_idx: usize = 0;

        for (items) |addr| {
            while (remove_idx < removes.len and removes[remove_idx] < addr) : (remove_idx += 1) {}

            if (remove_idx < removes.len and removes[remove_idx] == addr) {
                // Skip duplicate remove entries for the same address.
                const removed_addr = addr;
                while (remove_idx < removes.len and removes[remove_idx] == removed_addr) : (remove_idx += 1) {}
                continue;
            }

            items[write_idx] = addr;
            write_idx += 1;
        }

        self.all_blocks_sorted.items.len = write_idx;
    }

    // Free a code block without removing from all_blocks.
    // Used for batch freeing where all_blocks is updated separately.
    pub fn freeBlockOnly(self: *Self, block: *CodeBlock) void {
        self.remembered_sets.removeCodeBlock(block);
        self.removeScanFlags(block);
        const block_addr = @intFromPtr(block);
        _ = self.removeUninitializedBlock(block_addr);
        self.removeLiteralSites(block_addr);
        const size = block.size();
        block.markFree(size);
        if (self.free_list) |alloc| {
            alloc.free(@intFromPtr(block), size);
        }
    }

    pub fn codeBlockForAddress(self: *Self, address: Cell) ?*CodeBlock {
        const blocks = self.all_blocks_sorted.items;
        if (blocks.len == 0) return null;

        // upperBound returns first block > address, so -1 is the block containing address
        const ub = std.sort.upperBound(Cell, blocks, address, layouts.orderCell);
        if (ub == 0) return null;

        const block: *CodeBlock = @ptrFromInt(blocks[ub - 1]);
        const block_end = blocks[ub - 1] + block.size();
        if (address >= block_end) return null;

        return block;
    }

    // Get the predecessor frame (caller's frame) given the current frame top
    pub fn framePredecessor(self: *Self, frame_top: Cell) Cell {
        if (builtin.cpu.arch == .aarch64) {
            // ARM64: frame_top[0] contains the saved frame pointer (x29)
            // which points directly to the previous frame
            return @as(*const Cell, @ptrFromInt(frame_top)).*;
        } else {
            // x86-64: FRAME_RETURN_ADDRESS = 0, so return address is at frame_top
            // We compute the next frame by adding the frame size
            const FRAME_RETURN_ADDRESS: Cell = 0;
            const addr = @as(*const Cell, @ptrFromInt(frame_top + FRAME_RETURN_ADDRESS)).*;
            const block = self.codeBlockForAddress(addr) orelse {
                // Can't find code block - return minimum frame size
                return frame_top + CodeBlock.LEAF_FRAME_SIZE;
            };
            const frame_size = block.stackFrameSizeForAddress(addr);
            return frame_top + frame_size;
        }
    }

    // Verify that all live code blocks in the heap are present in all_blocks_sorted.
    // Catches missed inserts/removes or stale entries.
    pub fn verifyAllBlocksSet(self: *const Self) void {
        if (comptime builtin.mode != .Debug) return;
        if (self.code_start == 0 or self.code_size == 0) return;

        const code_end = self.code_start + self.code_size;
        var idx: usize = 0;
        var current = self.code_start;

        while (current < code_end) {
            const block: *const CodeBlock = @ptrFromInt(current);
            const block_size = codeBlockSize(current);
            if (block_size == 0) break;

            if (!block.isFree()) {
                std.debug.assert(idx < self.all_blocks_sorted.items.len);
                std.debug.assert(self.all_blocks_sorted.items[idx] == current);
                idx += 1;
            }
            current += block_size;
        }

        std.debug.assert(idx == self.all_blocks_sorted.items.len);
        if (self.all_blocks_sorted.items.len > 1) {
            for (1..self.all_blocks_sorted.items.len) |i| {
                std.debug.assert(self.all_blocks_sorted.items[i - 1] < self.all_blocks_sorted.items[i]);
            }
        }
    }

    // Initialize all_blocks_sorted by scanning the code heap.
    // This must be called after image loading/fixup
    pub fn initializeAllBlocksSet(self: *Self) !void {
        if (self.code_start == 0 or self.code_size == 0) return;

        const alloc = self.allocator orelse return;

        // First pass: count non-free blocks
        var count: usize = 0;
        var current = self.code_start;
        const code_end = self.code_start + self.code_size;

        while (current < code_end) {
            const block_size = codeBlockSize(current);
            if (block_size == 0) break;
            const block: *const CodeBlock = @ptrFromInt(current);
            if (!block.isFree()) {
                count += 1;
            }
            current += block_size;
        }

        // Rebuild sorted array.
        self.all_blocks_sorted.clearRetainingCapacity();
        try self.all_blocks_sorted.ensureTotalCapacity(alloc, count);
        self.clearLiteralSites();

        // Second pass: populate. Iteration order is ascending address, so
        // all_blocks_sorted is naturally sorted without a separate sort call.
        current = self.code_start;
        while (current < code_end) {
            const block_size = codeBlockSize(current);
            if (block_size == 0) break;
            const block: *const CodeBlock = @ptrFromInt(current);
            if (!block.isFree()) {
                self.all_blocks_sorted.appendAssumeCapacity(current);
            }
            current += block_size;
        }

        self.verifyAllBlocksSet();
    }

    pub fn rebuildScanFlags(self: *Self, al: std.mem.Allocator) void {
        self.rebuildLiteralSites(al);
        self.ensureScanFlags(al) catch return;
        self.clearScanFlags();
        for (self.all_blocks_sorted.items) |block_addr| {
            const block: *CodeBlock = @ptrFromInt(block_addr);
            if (!block.isFree()) {
                self.updateScanFlags(al, block);
            }
        }
    }

    pub fn ensureMarks(self: *Self, al: std.mem.Allocator) !void {
        if (self.marks != null) return;
        if (self.code_start == 0 or self.code_size == 0) return;
        const marks = try al.create(mark_bits.MarkBits);
        errdefer al.destroy(marks);
        marks.* = try mark_bits.MarkBits.init(al, self.code_start, self.code_size);
        self.marks = marks;
        self.allocator = al;
    }

    pub fn clearMarks(self: *Self) void {
        if (self.marks) |marks| {
            marks.clearMarks();
        }
    }

    pub fn deinit(self: *Self) void {
        const alloc = self.allocator orelse return;
        self.all_blocks_sorted.deinit(alloc);
        self.uninitialized_blocks.deinit(alloc);
        self.uninitialized_blocks_scratch.deinit(alloc);
        self.clearLiteralSites();
        self.literal_sites.deinit(alloc);
        // Deinit remembered sets and scan flags
        self.remembered_sets.deinit();
        if (self.scan_literals) |*set| {
            set.deinit();
            self.scan_literals = null;
        }
        if (self.scan_code_ptrs) |*set| {
            set.deinit();
            self.scan_code_ptrs = null;
        }
        if (self.marks) |marks| {
            marks.deinit();
            if (self.allocator) |gc_alloc| {
                gc_alloc.destroy(marks);
            }
            self.marks = null;
        }
    }

    pub fn blockSizeAt(self: *const Self, addr: Cell) Cell {
        _ = self;
        return codeBlockSize(addr);
    }
};

// Compute block size at address, handling both code-block and free-list layouts.
// FreeListAllocator encodes size in the header (header = size | 1).
fn codeBlockSize(addr: Cell) Cell {
    const block: *const CodeBlock = @ptrFromInt(addr);
    if (!block.isFree()) {
        return block.size();
    }
    var size = block.size();
    if (size == 0) {
        // For free blocks, read size from header (FreeBlock encodes size in header)
        const free_block: *const free_list.FreeBlock = @ptrFromInt(addr);
        size = free_block.size();
    }
    return size;
}

inline fn isNonDecreasing(values: []const Cell) bool {
    if (values.len < 2) return true;
    for (1..values.len) |i| {
        if (values[i] < values[i - 1]) return false;
    }
    return true;
}
