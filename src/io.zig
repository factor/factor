const std = @import("std");
const builtin = @import("builtin");

const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;

// C library function declarations
extern "c" fn fgetc(stream: *std.c.FILE) c_int;
extern "c" fn fputc(c: c_int, stream: *std.c.FILE) c_int;
extern "c" fn ftell(stream: *std.c.FILE) c_long;
extern "c" fn _ftelli64(stream: *std.c.FILE) i64;
extern "c" fn _fseeki64(stream: *std.c.FILE, offset: i64, whence: c_int) c_int;
extern "c" fn fflush(stream: *std.c.FILE) c_int;
extern "c" fn feof(stream: *std.c.FILE) c_int;
extern "c" fn ferror(stream: *std.c.FILE) c_int;
extern "c" fn clearerr(stream: *std.c.FILE) void;
extern "c" fn fseek(stream: *std.c.FILE, offset: c_long, whence: c_int) c_int;

// C constants
const EOF: c_int = -1;

// Error type for I/O operations
pub const IOError = error{
    ReadError,
    WriteError,
    PipeError,
    FcntlError,
    CloseError,
    OpenError,
    SeekError,
    FlushError,
    EINTR,
    EAGAIN,
    UnexpectedEOF,
};

// C constants for fcntl/errno
const EINTR = @intFromEnum(std.posix.E.INTR);
const EAGAIN = @intFromEnum(std.posix.E.AGAIN);
const F_GETFD: c_int = 1;
const F_SETFD: c_int = 2;
const F_GETFL: c_int = 3;
const F_SETFL: c_int = 4;
const FD_CLOEXEC: c_int = 1;
const O_NONBLOCK_C: c_int = if (builtin.os.tag == .macos) 0x0004 else 0x800;

// Create a pipe pair with close-on-exec flags set
// Returns [read_fd, write_fd]
fn makePipe() ![2]i32 {
    var filedes: [2]c_int = undefined;
    if (std.c.pipe(&filedes) < 0) {
        return error.PipeError;
    }

    const read_fd = filedes[0];
    const write_fd = filedes[1];

    // Set close-on-exec on both ends
    if (std.c.fcntl(read_fd, F_SETFD, FD_CLOEXEC) < 0) {
        _ = std.c.close(read_fd);
        _ = std.c.close(write_fd);
        return error.FcntlError;
    }
    if (std.c.fcntl(write_fd, F_SETFD, FD_CLOEXEC) < 0) {
        _ = std.c.close(read_fd);
        _ = std.c.close(write_fd);
        return error.FcntlError;
    }

    return .{ read_fd, write_fd };
}

// Set file descriptor to non-blocking mode
fn setNonblocking(fd: i32) !void {
    const flags = std.c.fcntl(fd, F_GETFL);
    if (flags < 0) return error.FcntlError;
    if (std.c.fcntl(fd, F_SETFL, flags | O_NONBLOCK_C) < 0) return error.FcntlError;
}

// Initialize signal pipe for async signal delivery
// This creates a pipe that signal handlers can write to, and Factor's
// event loop can poll/select on to receive async signals safely
pub fn initSignalPipe(vm: *vm_mod.FactorVM) !void {
    const fds = try makePipe();
    errdefer {
        _ = std.c.close(fds[0]);
        _ = std.c.close(fds[1]);
    }

    // Publish descriptors only once setup has succeeded.
    try setNonblocking(fds[1]);
    vm.signal_pipe_input = fds[0];
    vm.signal_pipe_output = fds[1];

    // Store input pipe fd in special objects so Factor code can poll it
    vm.setSpecialObject(objects.SpecialObject.signal_pipe, layouts.tagFixnum(vm.signal_pipe_input));
}

// Clean up signal pipe
pub fn deinitSignalPipe(vm: *vm_mod.FactorVM) void {
    if (vm.signal_pipe_input != -1) {
        _ = std.c.close(vm.signal_pipe_input);
        vm.signal_pipe_input = -1;
    }
    if (vm.signal_pipe_output != -1) {
        _ = std.c.close(vm.signal_pipe_output);
        vm.signal_pipe_output = -1;
    }
}

// Safe fopen - retries on EINTR
pub fn safeFopen(path: [*:0]const u8, mode: [*:0]const u8) !*std.c.FILE {
    while (true) {
        const file = std.c.fopen(path, mode);
        if (file) |f| {
            return f;
        }

        // Check errno
        const err = std.c._errno().*;
        if (err == @intFromEnum(std.posix.E.INTR)) {
            continue; // Retry on EINTR
        }

        return error.OpenError;
    }
}

// Safe fclose - only closes once, tolerates EINTR
pub fn safeFclose(file: *std.c.FILE) !void {
    const result = std.c.fclose(file);
    if (result != 0) {
        const err = std.c._errno().*;
        if (err != @intFromEnum(std.posix.E.INTR)) {
            return error.CloseError;
        }
    }
}

// Safe fgetc - retries on EINTR
pub fn safeFgetc(file: *std.c.FILE) !i32 {
    while (true) {
        const c = fgetc(file);
        if (c == EOF) {
            if (feof(file) != 0) {
                return EOF;
            }

            const err = std.c._errno().*;
            if (err != @intFromEnum(std.posix.E.INTR)) {
                return error.ReadError;
            }
            clearerr(file);
            // Retry on EINTR
            continue;
        }
        return c;
    }
}

// Safe fread - retries on EINTR until all items read
pub fn safeFread(ptr: *anyopaque, size: usize, nitems: usize, stream: *std.c.FILE) !usize {
    if (size == 0 or nitems == 0) return 0;
    var items_read: usize = 0;

    while (items_read < nitems) {
        const items_remaining = nitems - items_read;
        const offset = items_read * size;
        const dest: [*]u8 = @ptrCast(ptr);

        const ret = std.c.fread(dest + offset, size, items_remaining, stream);
        if (ret == 0) {
            if (feof(stream) != 0) {
                return items_read;
            }

            const err = std.c._errno().*;
            if (err != @intFromEnum(std.posix.E.INTR)) {
                return error.ReadError;
            }
            clearerr(stream);
            // Retry on EINTR
            continue;
        }
        if (ferror(stream) != 0 and std.c._errno().* == EINTR) clearerr(stream);
        items_read += ret;
    }

    return items_read;
}

// Safe fputc - retries on EINTR
pub fn safeFputc(c: i32, file: *std.c.FILE) !void {
    while (true) {
        const result = fputc(c, file);
        if (result != EOF) {
            return;
        }

        const err = std.c._errno().*;
        if (err != @intFromEnum(std.posix.E.INTR)) {
            return error.WriteError;
        }
        clearerr(file);
        // Retry on EINTR
    }
}

// Safe fwrite - retries on EINTR until all items written
pub fn safeFwrite(ptr: *const anyopaque, size: usize, nitems: usize, stream: *std.c.FILE) !usize {
    if (size == 0 or nitems == 0) return 0;
    var items_written: usize = 0;

    while (items_written < nitems) {
        const items_remaining = nitems - items_written;
        const offset = items_written * size;
        const src: [*]const u8 = @ptrCast(ptr);

        const ret = std.c.fwrite(src + offset, size, items_remaining, stream);
        if (ret == 0) {
            const err = std.c._errno().*;
            if (err != @intFromEnum(std.posix.E.INTR)) {
                return error.WriteError;
            }
            clearerr(stream);
            // Retry on EINTR
            continue;
        }
        if (ferror(stream) != 0 and std.c._errno().* == EINTR) clearerr(stream);
        items_written += ret;
    }

    return items_written;
}

// Safe ftell - retries on EINTR
pub fn safeFtell(stream: *std.c.FILE) !i64 {
    while (true) {
        const offset = if (builtin.os.tag == .windows) _ftelli64(stream) else ftell(stream);
        if (offset != -1) {
            return offset;
        }

        const err = std.c._errno().*;
        if (err != @intFromEnum(std.posix.E.INTR)) {
            return error.SeekError;
        }
        // Retry on EINTR
    }
}

// Safe fseek - retries on EINTR
pub fn safeFseek(stream: *std.c.FILE, offset: i64, whence: i32) !void {
    // Convert Factor whence (0, 1, 2) to C SEEK_* constants
    const c_whence: c_int = switch (whence) {
        0 => std.c.SEEK.SET,
        1 => std.c.SEEK.CUR,
        2 => std.c.SEEK.END,
        else => {
            setErrno(@intFromEnum(std.posix.E.INVAL));
            return error.SeekError;
        },
    };

    while (true) {
        const result = if (builtin.os.tag == .windows) _fseeki64(stream, offset, c_whence) else fseek(stream, offset, c_whence);
        if (result == 0) {
            return;
        }

        const err = std.c._errno().*;
        if (err != @intFromEnum(std.posix.E.INTR)) {
            return error.SeekError;
        }
        // Retry on EINTR
    }
}

// Safe fflush - retries on EINTR
pub fn safeFflush(stream: *std.c.FILE) !void {
    while (true) {
        const result = fflush(stream);
        if (result == 0) {
            return;
        }

        const err = std.c._errno().*;
        if (err != @intFromEnum(std.posix.E.INTR)) {
            return error.FlushError;
        }
        // Retry on EINTR
    }
}

// Clear error and EOF indicators on a stream
pub fn safeClearerr(stream: *std.c.FILE) void {
    clearerr(stream);
}

// Get current errno value
pub fn getErrno() i32 {
    return std.c._errno().*;
}

// Set errno value
pub fn setErrno(err: i32) void {
    std.c._errno().* = err;
}

// Initialize I/O subsystem
// Called once at VM startup
pub fn initIO(vm: *vm_mod.FactorVM) !void {
    // Initialize signal pipe for async signal delivery
    try initSignalPipe(vm);
}

// Shutdown I/O subsystem
pub fn deinitIO(vm: *vm_mod.FactorVM) void {
    deinitSignalPipe(vm);
}

test "stdio positioning supports offsets beyond signed 32 bits" {
    const C = struct {
        extern "c" fn tmpfile() ?*std.c.FILE;
    };
    const file = C.tmpfile() orelse return error.OpenError;
    defer safeFclose(file) catch {};
    const offset: i64 = 0x80000010;
    // Seeking alone does not allocate a multi-gigabyte file.
    try safeFseek(file, offset, 0);
    try std.testing.expectEqual(offset, try safeFtell(file));
    try safeFseek(file, -16, 1);
    try std.testing.expectEqual(offset - 16, try safeFtell(file));
    try safeFseek(file, 0, 2);
    try std.testing.expectEqual(@as(i64, 0), try safeFtell(file));
}

test "zero-sized stdio operations and invalid seek origin" {
    const C = struct {
        extern "c" fn tmpfile() ?*std.c.FILE;
    };
    const file = C.tmpfile() orelse return error.OpenError;
    defer safeFclose(file) catch {};
    var byte: u8 = 42;
    setErrno(0);
    try std.testing.expectEqual(@as(usize, 0), try safeFread(&byte, 0, 1, file));
    try std.testing.expectEqual(@as(usize, 0), try safeFwrite(&byte, 0, 1, file));
    try std.testing.expectError(error.SeekError, safeFseek(file, 0, 3));
    try std.testing.expectEqual(@as(i32, @intFromEnum(std.posix.E.INVAL)), getErrno());
}
