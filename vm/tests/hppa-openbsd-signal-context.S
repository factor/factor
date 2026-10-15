/* Native register markers verify the kernel's actual saved-register ordering.
 * Keep r18/r19 independent of C register allocation and restore the caller.
 */
.text
.align 4
.globl hppa_signal_register_fault
.hidden hppa_signal_register_fault
.type hppa_signal_register_fault,@function
hppa_signal_register_fault:
 stw %r2,-20(%r30)
 ldo 64(%r30),%r30
 stw %r18,-64(%r30)
 stw %r19,-60(%r30)
 ldil L%0x12345678,%r18
 ldo R%0x12345678(%r18),%r18
 ldil L%0x23456789,%r19
 ldo R%0x23456789(%r19),%r19
 ldw 0(%r26),%r28
 stw %r18,0(%r25)
 stw %r19,4(%r25)
 ldw -64(%r30),%r18
 ldw -60(%r30),%r19
 ldw -84(%r30),%r2
 bv %r0(%r2)
 ldo -64(%r30),%r30
.size hppa_signal_register_fault,.-hppa_signal_register_fault
.section .note.GNU-stack,"",@progbits
