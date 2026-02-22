// icache.zig - Instruction cache flush functionality
//
// ARM platforms require explicit instruction cache flush after modifying code.
// x86/x86-64 has coherent instruction caches, so no flush is needed.
//
// Platform-specific implementations:
// - x86/x86-64: no-op (caches are coherent)
// - Linux ARM64: use cacheflush syscall
// - macOS ARM64: use pthread_jit_write_protect_np + __clear_cache

const std = @import("std");
const builtin = @import("builtin");
const layouts = @import("layouts.zig");

const Cell = layouts.Cell;

/// Flush instruction cache for a memory range
/// This ensures that modified code is visible to the instruction fetch unit
pub fn flushICache(start: Cell, size: Cell) void {
    const end = start + size;

    switch (builtin.cpu.arch) {
        .x86_64, .x86 => {
            // x86/x86-64 has coherent instruction and data caches
            // No explicit flush needed
            return;
        },
        .aarch64 => {
            flushICacheARM64(start, end);
        },
        else => {
            // Unknown architecture - skip flush
            // This may cause issues on platforms with split I/D caches
            return;
        },
    }
}

// ARM64-specific instruction cache flush
fn flushICacheARM64(start: Cell, end: Cell) void {
    switch (builtin.os.tag) {
        .macos, .ios, .tvos, .watchos => {
            flushICacheMacOSARM64(start, end);
        },
        .linux => {
            flushICacheLinuxARM64(start, end);
        },
        else => {
            // Unknown OS - try the GCC builtin
            // This should work on most POSIX systems with GCC/Clang
            const gcc_clear_cache = struct {
                extern "c" fn __clear_cache(start: *const anyopaque, end: *const anyopaque) void;
            }.__clear_cache;

            const start_ptr: *const anyopaque = @ptrFromInt(start);
            const end_ptr: *const anyopaque = @ptrFromInt(end);
            gcc_clear_cache(start_ptr, end_ptr);
        },
    }
}

// macOS ARM64 instruction cache flush
// On Apple Silicon, W^X is enforced via JIT write protection
fn flushICacheMacOSARM64(start: Cell, end: Cell) void {
    // On macOS ARM64, we use sys_icache_invalidate from libSystem
    // This is the Darwin-specific way to flush instruction cache
    const sys_icache_invalidate = struct {
        extern "c" fn sys_icache_invalidate(start: *const anyopaque, size: usize) void;
    }.sys_icache_invalidate;

    const start_ptr: *const anyopaque = @ptrFromInt(start);
    const size = end - start;
    sys_icache_invalidate(start_ptr, size);
}

// Linux ARM64 instruction cache flush
fn flushICacheLinuxARM64(start: Cell, end: Cell) void {
    // Linux ARM64 uses __builtin___clear_cache
    // This is provided by GCC/Clang and generates the appropriate instructions
    // On ARM64, this typically generates:
    //   DC CVAU (data cache clean)
    //   DSB ISH (data synchronization barrier)
    //   IC IVAU (instruction cache invalidate)
    //   DSB ISH
    //   ISB (instruction synchronization barrier)

    const gcc_clear_cache = struct {
        extern "c" fn __clear_cache(start: *const anyopaque, end: *const anyopaque) void;
    }.__clear_cache;

    const start_ptr: *const anyopaque = @ptrFromInt(start);
    const end_ptr: *const anyopaque = @ptrFromInt(end);
    gcc_clear_cache(start_ptr, end_ptr);
}

/// Flush instruction cache for a pointer + size
/// Convenience wrapper for common use case
pub fn flushICachePtr(ptr: *const anyopaque, size: usize) void {
    const start = @intFromPtr(ptr);
    flushICache(start, size);
}

test "icache flush pointer" {
    // Allocate some memory to test flushing
    // We can't test the actual effect, but we can verify it doesn't crash
    const data = [_]u8{ 0x90, 0x90, 0x90, 0x90 }; // NOPs
    flushICachePtr(&data, data.len);

    // Also test the Cell-based version with the same memory
    const addr = @intFromPtr(&data);
    flushICache(addr, data.len);
}
