// segments.zig - Memory segment management

const std = @import("std");
const builtin = @import("builtin");
const layouts = @import("layouts.zig");
const Cell = layouts.Cell;

// Page size: match C++ VM's getpagesize() behavior.
// On x86_64-macos under Rosetta, getpagesize() returns 4096 even though
// the hardware page size is 16384. We must match C++ to get equivalent
// system call performance characteristics.
pub const page_size: usize = if (builtin.cpu.arch == .x86_64 and builtin.os.tag == .macos)
    4096
else
    std.heap.page_size_min;

// C++ VM allocates: [guard page][usable memory][guard page]
// The start/end fields point to the usable memory region
pub const Segment = struct {
    start: Cell,
    size: Cell,
    end: Cell,

    // Track total allocation for proper cleanup
    alloc_base: Cell,
    alloc_size: Cell,

    // Initialize with optional executable flag
    // Matches C++ segment::segment() in os-unix.cpp
    pub fn init(size_param: Cell, executable: bool) !Segment {
        // Page-align size to ensure guard pages work (mprotect requires page alignment)
        const size = layouts.alignCell(size_param, page_size);

        // Set protection flags based on executable parameter
        const prot: std.c.PROT = if (executable)
            .{ .READ = true, .WRITE = true, .EXEC = true }
        else
            .{ .READ = true, .WRITE = true };

        // Allocate: [guard page][usable memory][guard page]
        // This matches C++ VM: alloc_size = 2 * pagesize + size
        const alloc_size = 2 * page_size + size;

        // On ARM64 macOS, executable memory requires MAP_JIT flag
        const is_arm64_macos = builtin.cpu.arch == .aarch64 and
            (builtin.os.tag == .macos or builtin.os.tag == .ios);

        const map_flags: std.c.MAP = if (executable and is_arm64_macos)
            .{ .TYPE = .PRIVATE, .ANONYMOUS = true, .JIT = true }
        else
            .{ .TYPE = .PRIVATE, .ANONYMOUS = true };

        const ptr = std.c.mmap(
            null,
            alloc_size,
            prot,
            map_flags,
            -1,
            0,
        );
        if (ptr == std.c.MAP_FAILED) return error.OutOfMemory;

        // On ARM64 macOS with MAP_JIT, need to disable write protection for initial writes
        if (executable and is_arm64_macos) {
            const pthread_jit_write_protect_np = struct {
                extern "c" fn pthread_jit_write_protect_np(enabled: c_int) void;
            }.pthread_jit_write_protect_np;
            pthread_jit_write_protect_np(0); // Disable write protection (allow writes)
        }

        const alloc_base = @intFromPtr(ptr);

        // Usable memory starts after first guard page
        // Matches C++ VM: start = (cell)(array + pagesize)
        const start = alloc_base + page_size;
        const end = start + size;

        var seg = Segment{
            .start = start,
            .size = size,
            .end = end,
            .alloc_base = alloc_base,
            .alloc_size = alloc_size,
        };

        // Lock the guard pages (make them inaccessible)
        // Matches C++ VM: set_border_locked(true)
        // Note: On ARM64 macOS with MAP_JIT, mprotect doesn't work on JIT memory,
        // so we skip guard page setup for executable segments
        if (!(executable and is_arm64_macos)) {
            seg.setBorderLocked(true) catch {
                // Cleanup on failure
                _ = std.c.munmap(@ptrFromInt(alloc_base), alloc_size);
                return error.MprotectFailed;
            };
        }

        return seg;
    }

    pub fn deinit(self: *Segment) void {
        if (self.alloc_size > 0) {
            _ = std.c.munmap(@ptrFromInt(self.alloc_base), self.alloc_size);
        }
        self.start = 0;
        self.size = 0;
        self.end = 0;
        self.alloc_base = 0;
        self.alloc_size = 0;
    }

    pub fn isUnderflow(self: *const Segment, addr: Cell) bool {
        // Matches C++ VM: addr >= (start - getpagesize()) && addr < start
        return addr >= (self.start - page_size) and addr < self.start;
    }

    pub fn isOverflow(self: *const Segment, addr: Cell) bool {
        // Matches C++ VM: addr >= end && addr < (end + getpagesize())
        return addr >= self.end and addr < (self.end + page_size);
    }

    // Check if address is in the usable segment
    pub fn contains(self: *const Segment, addr: Cell) bool {
        return addr >= self.start and addr < self.end;
    }

    // Matches C++ VM: set_border_locked() in segments.hpp
    pub fn setBorderLocked(self: *Segment, locked: bool) !void {
        const prot: std.c.PROT = if (locked)
            .{}
        else
            .{ .READ = true, .WRITE = true };

        // Low guard page
        const lo = self.start - page_size;
        const lo_ptr: *align(std.heap.page_size_min) anyopaque = @ptrFromInt(lo);
        if (std.c.mprotect(lo_ptr, page_size, prot) != 0) return error.MprotectFailed;

        // High guard page
        const hi = self.end;
        const hi_ptr: *align(std.heap.page_size_min) anyopaque = @ptrFromInt(hi);
        if (std.c.mprotect(hi_ptr, page_size, prot) != 0) return error.MprotectFailed;
    }
};
