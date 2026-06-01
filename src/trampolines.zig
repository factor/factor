// arm64 call-gate trampolines (was src/trampolines_arm64.S, now inlined as
// naked functions). Entered via `BLR` from JIT code with the target in X16
// (IP0), an alternate frame pointer in X17 (IP1), and the context in X20 (CTX);
// each saves the callstack top (FP) into [CTX], calls the target, and returns.
//
// These are referenced only by arm64 code paths via `&trampoline` /
// `&trampoline2`, all behind `if (builtin.cpu.arch == .aarch64)`. They are
// `pub fn` (not `export`), so on non-arm64 targets they're never referenced and
// never analyzed — the arm64-only asm is therefore not compiled there.
//
// naked => no prologue/epilogue: the inline asm IS the entire function body.

pub fn trampoline() callconv(.naked) void {
    asm volatile (
        \\stp x29, x30, [sp, #-16]!
        \\mov x29, sp
        \\str x29, [x20]
        \\blr x16
        \\ldp x29, x30, [sp], #16
        \\ret
    );
}

pub fn trampoline2() callconv(.naked) void {
    asm volatile (
        \\stp x29, x30, [x17]
        \\mov x29, x17
        \\str x29, [x20]
        \\blr x16
        \\ldp x29, x30, [x29]
        \\ret
    );
}
