// bump_allocator.zig - Simple bump allocator for nursery
// offset of 'here' and 'end' is hardcoded in compiler backends

const std = @import("std");
const layouts = @import("layouts.zig");
const Cell = layouts.Cell;
const Object = layouts.Object;

// Bump allocator struct - field layout is critical for assembly compatibility
// The fields here, start, end, size must be in this exact order
pub const BumpAllocator = extern struct {
    const Self = @This();

    // Current allocation pointer - offset hardcoded in compiler backends
    here: Cell,
    start: Cell,
    // End of allocation region - offset hardcoded in compiler backends
    end: Cell,
    size: Cell,

    pub fn init(size: Cell, start_addr: Cell) BumpAllocator {
        const aligned_start = layouts.alignCell(start_addr, layouts.data_alignment);
        return BumpAllocator{
            .here = aligned_start,
            .start = aligned_start,
            .end = start_addr + size,
            .size = start_addr + size - aligned_start,
        };
    }

    pub fn contains(self: *const BumpAllocator, obj: *Object) bool {
        const addr = @intFromPtr(obj);
        return addr >= self.start and addr < self.end;
    }

    pub fn flush(self: *BumpAllocator) void {
        self.here = self.start;
        // In debug mode, fill with pattern to catch stale references
        if (std.debug.runtime_safety) {
            const ptr: [*]u8 = @ptrFromInt(self.start);
            @memset(ptr[0..self.size], 0xBA);
        }
    }

    pub fn canAllot(self: *const BumpAllocator, size: Cell) bool {
        return self.here + layouts.alignCell(size, layouts.data_alignment) <= self.end;
    }

    // Match C++ bump_allocator::allot(): here is always aligned after init/reset,
    // so only the size needs alignment. Caller (ensureNurserySpace) already
    // checked bounds, so no redundant check needed.
    pub inline fn allocate(self: *BumpAllocator, size: Cell) Cell {
        const h = self.here;
        self.here = h + layouts.alignCell(size, layouts.data_alignment);
        return h;
    }

    pub fn reset(self: *BumpAllocator) void {
        self.here = self.start;
    }

    pub fn usedBytes(self: *const BumpAllocator) Cell {
        return self.here - self.start;
    }

    pub fn freeBytes(self: *const BumpAllocator) Cell {
        return self.end - self.here;
    }
};

// Compile-time verification of struct layout
comptime {
    // Verify field order matches C++ - critical for assembly compatibility
    std.debug.assert(@offsetOf(BumpAllocator, "here") == 0 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(BumpAllocator, "start") == 1 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(BumpAllocator, "end") == 2 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(BumpAllocator, "size") == 3 * @sizeOf(Cell));
    std.debug.assert(@sizeOf(BumpAllocator) == 4 * @sizeOf(Cell));
}
