// OS services shared by the VM's image loader, memory manager and FFI.
const std = @import("std");
const builtin = @import("builtin");
pub const windows = builtin.os.tag == .windows;
pub const win = if (windows) @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", "1");
    @cInclude("windows.h");
    @cInclude("io.h");
}) else struct {};

pub const PROT = if (windows) struct { READ: bool = false, WRITE: bool = false, EXEC: bool = false } else std.c.PROT;
pub const MAP = if (windows) struct {
    TYPE: enum { PRIVATE } = .PRIVATE,
    ANONYMOUS: bool = false,
    FIXED: bool = false,
    JIT: bool = false,
} else std.c.MAP;
pub const MAP_FAILED = std.c.MAP_FAILED;

fn protection(prot: PROT) u32 {
    if (prot.EXEC) return if (prot.WRITE) win.PAGE_EXECUTE_READWRITE else win.PAGE_EXECUTE_READ;
    if (prot.WRITE) return win.PAGE_READWRITE;
    return if (prot.READ) win.PAGE_READONLY else win.PAGE_NOACCESS;
}

pub fn mmap(address: ?*anyopaque, len: usize, prot: PROT, flags: MAP, fd: c_int, offset: i64) *anyopaque {
    if (!windows) return std.c.mmap(@alignCast(address), len, prot, flags, fd, offset);
    std.debug.assert(flags.ANONYMOUS and fd == -1 and offset == 0);
    return win.VirtualAlloc(address, len, win.MEM_RESERVE | win.MEM_COMMIT, protection(prot)) orelse MAP_FAILED;
}

pub fn munmap(address: *anyopaque, len: usize) c_int {
    if (!windows) return std.c.munmap(@alignCast(address), len);
    return if (win.VirtualFree(address, 0, win.MEM_RELEASE) != 0) 0 else -1;
}

pub fn mprotect(address: *align(std.heap.page_size_min) anyopaque, len: usize, prot: PROT) c_int {
    if (!windows) return std.c.mprotect(address, len, prot);
    var previous: win.DWORD = undefined;
    return if (win.VirtualProtect(address, len, protection(prot), &previous) != 0) 0 else -1;
}

pub const RTLD = if (windows) struct { LAZY: bool = false, GLOBAL: bool = false } else std.c.RTLD;

// Factor supplies native encoded paths: UTF-16 on Windows, UTF-8 on Unix.
pub fn dlopen(path: ?[*:0]const u8, flags: RTLD) ?*anyopaque {
    if (!windows) return std.c.dlopen(path, flags);
    return if (path) |p| win.LoadLibraryW(@ptrCast(@alignCast(p))) else win.GetModuleHandleW(null);
}

pub fn dlsym(handle: ?*anyopaque, name: [*:0]const u8) ?*anyopaque {
    if (!windows) return std.c.dlsym(handle, name);
    const module: win.HMODULE = if (handle) |h| @ptrCast(@alignCast(h)) else win.GetModuleHandleW(null);
    return @ptrCast(@constCast(win.GetProcAddress(module, name)));
}

pub fn dlclose(handle: *anyopaque) c_int {
    if (!windows) return std.c.dlclose(handle);
    return if (win.FreeLibrary(@ptrCast(@alignCast(handle))) != 0) 0 else -1;
}

pub fn isatty(fd: c_int) c_int {
    return if (windows) win._isatty(fd) else std.c.isatty(fd);
}

pub fn read(fd: c_int, buffer: [*]u8, len: usize) isize {
    return if (windows) win._read(fd, buffer, @intCast(@min(len, std.math.maxInt(c_int)))) else std.c.read(fd, buffer, len);
}

test "anonymous memory can be protected and released" {
    const size = std.heap.page_size_min;
    const memory = mmap(null, size, .{ .READ = true, .WRITE = true }, .{ .TYPE = .PRIVATE, .ANONYMOUS = true }, -1, 0);
    try std.testing.expect(memory != MAP_FAILED);
    defer _ = munmap(memory, size);
    const ptr: *align(std.heap.page_size_min) u8 = @ptrCast(@alignCast(memory));
    ptr.* = 42;
    try std.testing.expectEqual(@as(c_int, 0), mprotect(ptr, size, .{}));
    try std.testing.expectEqual(@as(c_int, 0), mprotect(ptr, size, .{ .READ = true, .WRITE = true }));
    try std.testing.expectEqual(@as(u8, 42), ptr.*);
}
