const builtin = @import("builtin");
// Native call gates preserve Factor's linked frame chain. The JIT places
// the target in IP0 and an alternate frame pointer in IP1 for stack arguments.
// Naked functions have no compiler-generated prologue or epilogue.

fn genericTrampoline() callconv(.naked) void {
    if (builtin.cpu.arch == .s390x) {
        asm volatile (
            \\lgr %r0,%r15
            \\aghi %r15,-176
            \\stg %r0,0(%r15)
            \\stg %r12,160(%r15)
            \\stg %r14,168(%r15)
            \\lay %r12,160(%r15)
            \\stg %r12,0(%r8)
            \\basr %r14,%r1
            \\lg %r14,168(%r15)
            \\lg %r12,160(%r15)
            \\aghi %r15,176
            \\br %r14
        );
    } else if (builtin.cpu.arch == .riscv64) {
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
    } else if (builtin.cpu.arch == .mips or builtin.cpu.arch == .mipsel) {
        asm volatile (
            \\.set push
            \\.set noreorder
            \\.set noat
            \\addiu $sp, $sp, -32
            \\sw $fp, 16($sp)
            \\sw $ra, 20($sp)
            \\sw $gp, 24($sp)
            \\addiu $fp, $sp, 16
            \\sw $fp, 0($s3)
            \\jalr $ra, $t9
            \\nop
            \\lw $gp, 24($sp)
            \\lw $ra, 20($sp)
            \\lw $fp, 16($sp)
            \\jr $ra
            \\addiu $sp, $sp, 32
            \\.set pop
        );
    } else if ((builtin.cpu.arch == .mips64 or builtin.cpu.arch == .mips64el) and @sizeOf(usize) == 8) {
        asm volatile (
            \\.set push
            \\.set noreorder
            \\.set noat
            \\daddiu $sp, $sp, -32
            \\sd $fp, 16($sp)
            \\sd $ra, 24($sp)
            \\sd $gp, 0($sp)
            \\daddiu $fp, $sp, 16
            \\sd $fp, 0($s3)
            \\jalr $ra, $t9
            \\nop
            \\ld $gp, 0($sp)
            \\ld $ra, 24($sp)
            \\ld $fp, 16($sp)
            \\jr $ra
            \\daddiu $sp, $sp, 32
            \\.set pop
        );
    } else if (builtin.cpu.arch == .arm) {
        asm volatile (
            \\sub sp, sp, #16
            \\str r11, [sp]
            \\str lr, [sp, #4]
            \\mov r11, sp
            \\str r11, [r8]
            \\blx r12
            \\ldr r11, [sp]
            \\ldr lr, [sp, #4]
            \\add sp, sp, #16
            \\bx lr
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

fn genericTrampoline2() callconv(.naked) void {
    if (builtin.cpu.arch == .s390x) {
        asm volatile (
            \\stg %r12,0(%r8)
            \\lgr %r12,%r0
            \\lg %r0,0(%r8)
            \\stg %r0,0(%r12)
            \\stg %r14,8(%r12)
            \\stg %r12,0(%r8)
            \\basr %r14,%r1
            \\lg %r14,8(%r12)
            \\lg %r12,0(%r12)
            \\br %r14
        );
    } else if (builtin.cpu.arch == .riscv64) {
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
    } else if (builtin.cpu.arch == .mips or builtin.cpu.arch == .mipsel) {
        asm volatile (
            \\.set push
            \\.set noreorder
            \\.set noat
            \\sw $fp, 0($t8)
            \\sw $ra, 4($t8)
            \\sw $gp, 8($t8)
            \\move $fp, $t8
            \\sw $fp, 0($s3)
            \\jalr $ra, $t9
            \\nop
            \\lw $gp, 8($fp)
            \\lw $ra, 4($fp)
            \\lw $fp, 0($fp)
            \\jr $ra
            \\nop
            \\.set pop
        );
    } else if ((builtin.cpu.arch == .mips64 or builtin.cpu.arch == .mips64el) and @sizeOf(usize) == 8) {
        asm volatile (
            \\.set push
            \\.set noreorder
            \\.set noat
            \\sd $fp, 0($t8)
            \\sd $ra, 8($t8)
            \\sd $gp, 16($t8)
            \\move $fp, $t8
            \\sd $fp, 0($s3)
            \\jalr $ra, $t9
            \\nop
            \\ld $gp, 16($fp)
            \\ld $ra, 8($fp)
            \\ld $fp, 0($fp)
            \\jr $ra
            \\nop
            \\.set pop
        );
    } else if (builtin.cpu.arch == .arm) {
        asm volatile (
            \\str r11, [r4]
            \\str lr, [r4, #4]
            \\mov r11, r4
            \\str r11, [r8]
            \\blx r12
            \\ldr lr, [r11, #4]
            \\ldr r11, [r11]
            \\bx lr
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

const Assembly = struct {
    extern fn trampoline() callconv(.c) void;
    extern fn trampoline2() callconv(.c) void;
};
const assembly_trampolines = builtin.cpu.arch == .sparc or builtin.cpu.arch == .sparc64 or builtin.cpu.arch == .loongarch64;
pub const trampoline = if (assembly_trampolines) Assembly.trampoline else genericTrampoline;
pub const trampoline2 = if (assembly_trampolines) Assembly.trampoline2 else genericTrampoline2;
