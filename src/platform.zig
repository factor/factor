// OS services shared by the VM's image loader, memory manager and FFI.
const std = @import("std");
const builtin = @import("builtin");
pub const windows = builtin.os.tag == .windows;
pub const win = if (windows) @import("windows_c") else struct {};

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
    if (!windows) {
        var native_prot = prot;
        // NetBSD PaX requires the maximum allowed protection at mapping time.
        if (builtin.os.tag == .netbsd and prot.EXEC) {
            native_prot = @bitCast(@as(u32, @bitCast(prot)) | (@as(u32, @bitCast(prot)) << 3));
        }
        // Zig exposes a 64-bit off_t; GNU 32-bit mmap has a narrower ABI.
        const map = if (std.posix.lfs64_abi) std.c.mmap64 else std.c.mmap;
        return map(@alignCast(address), len, native_prot, flags, fd, offset);
    }
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
const mips_gnu_loader = builtin.os.tag == .linux and builtin.abi.isGnu() and @import("contexts.zig").mips_frames;
const native_loader = struct {
    extern "c" fn dlopen(path: ?[*:0]const u8, flags: c_int) ?*anyopaque;
};

// Factor supplies native encoded paths: UTF-16 on Windows, UTF-8 on Unix.
pub fn dlopen(path: ?[*:0]const u8, flags: RTLD) ?*anyopaque {
    if (mips_gnu_loader) {
        // glibc's MIPS ABI uses GLOBAL=4, NOLOAD=8 and DEEPBIND=16.
        // Zig's generic Linux RTLD representation uses 256, 4 and 8.
        const raw: u32 = @bitCast(flags);
        const native = (raw & ~@as(u32, 0x10c)) |
            @as(u32, if (flags.GLOBAL) 4 else 0) |
            @as(u32, if (flags.NOLOAD) 8 else 0) |
            @as(u32, if (flags.DEEPBIND) 16 else 0);
        return native_loader.dlopen(path, @intCast(native));
    }
    if (!windows) return std.c.dlopen(path, flags);
    return if (path) |p| win.LoadLibraryW(@ptrCast(@alignCast(p))) else win.GetModuleHandleW(null);
}

test "MIPS glibc loads shared objects with native global visibility flags" {
    if (!mips_gnu_loader) return error.SkipZigTest;
    var flags: RTLD = .{};
    flags.LAZY = true;
    flags.GLOBAL = true;
    const handle = dlopen("libm.so.6", flags) orelse return error.TestUnexpectedResult;
    defer _ = dlclose(handle);
    try std.testing.expect(dlsym(handle, "cos") != null);
}

extern fn factor_netbsd_missing_math_symbol(name: [*:0]const u8) ?*anyopaque;

fn netbsdNetworkAliasFor(comptime os: std.Target.Os.Tag, comptime arch: std.Target.Cpu.Arch, comptime endian: std.builtin.Endian, name: []const u8) ?[:0]const u8 {
    if (os != .netbsd or arch != .riscv64 or endian != .little) return null;
    if (std.mem.eql(u8, name, "htons") or std.mem.eql(u8, name, "ntohs")) return "__bswap16";
    if (std.mem.eql(u8, name, "htonl") or std.mem.eql(u8, name, "ntohl")) return "__bswap32";
    return null;
}

test "NetBSD network symbol aliases require RV64 little endian" {
    for ([_][]const u8{ "htons", "ntohs", "htonl", "ntohl" }, 0..) |name, i| {
        try std.testing.expectEqualStrings(if (i < 2) "__bswap16" else "__bswap32", netbsdNetworkAliasFor(.netbsd, .riscv64, .little, name).?);
        try std.testing.expect(netbsdNetworkAliasFor(.linux, .riscv64, .little, name) == null);
        try std.testing.expect(netbsdNetworkAliasFor(.netbsd, .mips64, .little, name) == null);
        try std.testing.expect(netbsdNetworkAliasFor(.netbsd, .riscv64, .big, name) == null);
    }
    try std.testing.expect(netbsdNetworkAliasFor(.netbsd, .riscv64, .little, "malloc") == null);
}

test "NetBSD native network aliases preserve exported symbols and 16/32 bit values" {
    if (windows) return error.SkipZigTest;
    const handle = dlopen(null, .{ .LAZY = true }) orelse return error.TestUnexpectedResult;
    defer _ = dlclose(handle);
    const malloc_native = std.c.dlsym(handle, "malloc") orelse return error.TestUnexpectedResult;
    try std.testing.expectEqual(malloc_native, dlsym(handle, "malloc").?);
    if (builtin.os.tag != .netbsd or builtin.cpu.arch != .riscv64 or builtin.cpu.arch.endian() != .little) return;
    for ([_][*:0]const u8{ "htons", "ntohs" }) |name| {
        const native = std.c.dlsym(handle, name);
        const resolved = dlsym(handle, name) orelse return error.TestUnexpectedResult;
        if (native) |original| try std.testing.expectEqual(original, resolved) else try std.testing.expectEqual(std.c.dlsym(handle, "__bswap16").?, resolved);
        const convert: *const fn (u16) callconv(.c) u16 = @ptrCast(@alignCast(resolved));
        for ([_]u16{ 0, 1, 0x80, 0x8000, 0xffff, 0x1234 }) |value| try std.testing.expectEqual(@byteSwap(value), convert(value));
    }
    for ([_][*:0]const u8{ "htonl", "ntohl" }) |name| {
        const native = std.c.dlsym(handle, name);
        const resolved = dlsym(handle, name) orelse return error.TestUnexpectedResult;
        if (native) |original| try std.testing.expectEqual(original, resolved) else try std.testing.expectEqual(std.c.dlsym(handle, "__bswap32").?, resolved);
        const convert: *const fn (u32) callconv(.c) u32 = @ptrCast(@alignCast(resolved));
        for ([_]u32{ 0, 1, 0x80, 0x80000000, 0xffffffff, 0x12345678 }) |value| try std.testing.expectEqual(@byteSwap(value), convert(value));
    }
}

pub fn dlsym(handle: ?*anyopaque, name: [*:0]const u8) ?*anyopaque {
    if (!windows) {
        const result = std.c.dlsym(handle, name);
        if (result != null) return result;
        if (netbsdNetworkAliasFor(builtin.os.tag, builtin.cpu.arch, builtin.cpu.arch.endian(), std.mem.span(name))) |alias| return std.c.dlsym(handle, alias.ptr);
        if (builtin.os.tag == .netbsd and builtin.cpu.arch == .riscv64) {
            return result orelse factor_netbsd_missing_math_symbol(name);
        }
        return result;
    }
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
