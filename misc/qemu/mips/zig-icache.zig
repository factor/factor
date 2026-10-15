const cache = @import("icache");
export fn factor_mips_flush(start: usize, size: usize) void {
    cache.flushICache(start, size);
}
