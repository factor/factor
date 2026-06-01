// jit_protect.zig - JIT write protection for ARM64 macOS
//
// On Apple Silicon, MAP_JIT memory is either writable or executable,
// never both simultaneously. Use jitWritable() before modifying JIT
// code and jitExecutable() when done, matching the C++ VM's
// JIT_WRITABLE / JIT_EXECUTABLE macros.

const std = @import("std");
const builtin = @import("builtin");

pub const is_arm64_macos = builtin.cpu.arch == .aarch64 and
    (builtin.os.tag == .macos or builtin.os.tag == .ios);

const pthread_jit_write_protect_np = if (is_arm64_macos) struct {
    extern "c" fn pthread_jit_write_protect_np(enabled: c_int) void;
}.pthread_jit_write_protect_np else undefined;

threadlocal var writable_depth: usize = 0;
threadlocal var current_mode: enum { executable, writable } = .executable;

pub const Scope = struct {
    pub fn init() Scope {
        jitWritable();
        return .{};
    }

    pub fn deinit(_: *Scope) void {
        jitExecutable();
    }
};

/// Make JIT code pages writable (not executable). Call before modifying code.
pub inline fn jitWritable() void {
    if (is_arm64_macos) {
        if (current_mode != .writable) {
            pthread_jit_write_protect_np(0);
            current_mode = .writable;
        }
        writable_depth += 1;
    }
}

/// Make JIT code pages executable (not writable). Call after modifying code.
pub inline fn jitExecutable() void {
    if (is_arm64_macos) {
        std.debug.assert(writable_depth > 0);
        writable_depth -= 1;
        if (writable_depth == 0 and current_mode != .executable) {
            pthread_jit_write_protect_np(1);
            current_mode = .executable;
        }
    }
}

/// Ensure JIT code pages are executable when entering Factor from C.
pub inline fn ensureExecutable() void {
    if (is_arm64_macos and current_mode != .executable) {
        pthread_jit_write_protect_np(1);
        current_mode = .executable;
    }
}

/// Reset W^X bookkeeping after a non-local unwind (unwind_native_frames) that
/// abandons every C stack frame between the fault and Factor's error handler.
///
/// Those abandoned frames' `defer scope.deinit()` calls never run, so any
/// jit_protect.Scope open at fault time (inlineCacheMiss / lazyJitCompile / GC)
/// would leak its `writable_depth` increment forever. A leaked depth desyncs
/// all later Scope nesting: jitExecutable() then never reaches depth 0, so it
/// never flips the code heap back to executable, and the next Factor code we
/// run faults executing writable pages (ERROR_MEMORY at a code address) — an
/// error-handler recursion that ends in `die`.
///
/// Factor JIT code only ever runs with depth 0 (scopes live solely inside VM C
/// functions), so the unwind target's correct state is depth 0 + executable.
/// This is why the reset belongs HERE and not in ensureExecutable(): cToFactor
/// also calls ensureExecutable() but may have a still-live caller Scope (e.g. a
/// callback invoked mid-GC), whose depth must be preserved.
pub inline fn resetForUnwind() void {
    if (is_arm64_macos) {
        writable_depth = 0;
        if (current_mode != .executable) {
            pthread_jit_write_protect_np(1);
            current_mode = .executable;
        }
    }
}
