/* Native ABI harness for a downward Factor stack separate from upward r30.
 * Signature: gate_probe(value, plabel, context*, factor_sp), r26..r23.
 * The production register contract uses r16=context, r18=Factor frame.
 */
.text
.align 4
.globl hppa_gate_probe
.type hppa_gate_probe,@function
hppa_gate_probe:
 stw %r2,-20(%r30)
 ldo 128(%r30),%r30
 stw %r16,-120(%r30)
 stw %r18,-116(%r30)
 stw %r19,-112(%r30)
 copy %r24,%r16
 copy %r23,%r18
 copy %r25,%r22
 b,l trampoline,%r2
 nop
 ldw -112(%r30),%r19
 ldw -116(%r30),%r18
 ldw -120(%r30),%r16
 ldw -148(%r30),%r2
 bv %r0(%r2)
 ldo -128(%r30),%r30
.size hppa_gate_probe,.-hppa_gate_probe

.globl hppa_gate_probe2
.type hppa_gate_probe2,@function
hppa_gate_probe2:
 stw %r2,-20(%r30)
 ldo 128(%r30),%r30
 stw %r16,-120(%r30)
 stw %r18,-116(%r30)
 stw %r19,-112(%r30)
 copy %r24,%r16
 copy %r23,%r18
 copy %r25,%r22
 b,l trampoline2,%r2
 nop
 ldw -112(%r30),%r19
 ldw -116(%r30),%r18
 ldw -120(%r30),%r16
 ldw -148(%r30),%r2
 bv %r0(%r2)
 ldo -128(%r30),%r30
.size hppa_gate_probe2,.-hppa_gate_probe2

.section .note.GNU-stack,"",@progbits
