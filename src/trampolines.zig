const builtin = @import("builtin");

// ARM64 relocation types only; panic on non-ARM64 targets or invocation.
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
