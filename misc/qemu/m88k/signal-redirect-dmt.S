.text
.align 4
.globl redirect_fault
.globl redirect_resume
redirect_fault:
 or %r2,%r0,42
 or %r3,%r0,0
 ld %r2,%r3,36
redirect_resume:
 jmp %r1
