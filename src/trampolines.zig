const builtin = @import("builtin");
// Native call gates preserve Factor's linked frame chain. The JIT places
// the target in IP0 and an alternate frame pointer in IP1 for stack arguments.
// Naked functions have no compiler-generated prologue or epilogue.

pub fn trampoline() callconv(.naked) void {
    if (builtin.cpu.arch == .riscv64) {
        asm volatile (
            \\.option push
            \\.option norelax
            \\.option norvc
            \\addi sp, sp, -16
            \\sd s0, 0(sp)
            \\sd ra, 8(sp)
            \\mv s0, sp
            \\sd s0, 0(s3)
            \\jalr ra, t2, 0
            \\ld s0, 0(sp)
            \\ld ra, 8(sp)
            \\addi sp, sp, 16
            \\ret
            \\.option pop
        );
    } else if (builtin.cpu.arch == .riscv32) {
        asm volatile (
            \\.option push
            \\.option norelax
            \\.option norvc
            \\addi sp, sp, -16
            \\sw s0, 0(sp)
            \\sw ra, 4(sp)
            \\mv s0, sp
            \\sw s0, 0(s3)
            \\jalr ra, t2, 0
            \\lw s0, 0(sp)
            \\lw ra, 4(sp)
            \\addi sp, sp, 16
            \\ret
            \\.option pop
        );
    } else {
        asm volatile (
            \\stp x29, x30, [sp, #-16]!
            \\mov x29, sp
            \\str x29, [x20]
            \\blr x16
            \\ldp x29, x30, [sp], #16
            \\ret
        );
    }
}

pub fn trampoline2() callconv(.naked) void {
    if (builtin.cpu.arch == .riscv64) {
        asm volatile (
            \\.option push
            \\.option norelax
            \\.option norvc
            \\sd s0, 0(t3)
            \\sd ra, 8(t3)
            \\mv s0, t3
            \\sd s0, 0(s3)
            \\jalr ra, t2, 0
            \\ld ra, 8(s0)
            \\ld s0, 0(s0)
            \\ret
            \\.option pop
        );
    } else if (builtin.cpu.arch == .riscv32) {
        asm volatile (
            \\.option push
            \\.option norelax
            \\.option norvc
            \\sw s0, 0(t3)
            \\sw ra, 4(t3)
            \\mv s0, t3
            \\sw s0, 0(s3)
            \\jalr ra, t2, 0
            \\lw ra, 4(s0)
            \\lw s0, 0(s0)
            \\ret
            \\.option pop
        );
    } else {
        asm volatile (
            \\stp x29, x30, [x17]
            \\mov x29, x17
            \\str x29, [x20]
            \\blr x16
            \\ldp x29, x30, [x29]
            \\ret
        );
    }
}
