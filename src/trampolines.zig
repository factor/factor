const builtin = @import("builtin");

// Placeholder trampoline implementations.
// These are only needed for ARM64 relocation types and should never be called
// on non-ARM64 targets. If they are invoked, we want a hard failure.
pub fn trampoline() callconv(.C) noreturn {
    if (builtin.cpu.arch != .aarch64) {
        @panic("trampoline called on non-aarch64");
    }
    @panic("trampoline not implemented");
}

pub fn trampoline2() callconv(.C) noreturn {
    if (builtin.cpu.arch != .aarch64) {
        @panic("trampoline2 called on non-aarch64");
    }
    @panic("trampoline2 not implemented");
}
