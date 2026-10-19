.text
.align 4
.globl hppa_fault
.type hppa_fault,@function
hppa_fault:
 ldw 0(%r0),%r28
 ldi -1,%r28
 bv %r0(%r2)
 nop
.size hppa_fault,.-hppa_fault
.globl hppa_resume
hppa_resume:
 ldi 42,%r28
 bv %r0(%r2)
 nop
.section .note.GNU-stack,"",@progbits
