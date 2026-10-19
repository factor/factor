.LEVEL 1.1
.text
.align 4
.globl hppa_bootstrap_execute
.type hppa_bootstrap_execute,@function
hppa_bootstrap_execute:
 stw %r2,-20(%r30)
 ldo 128(%r30),%r30
 stw %r3,-112(%r30)
 stw %r4,-108(%r30)
 stw %r5,-104(%r30)
 stw %r6,-100(%r30)
 stw %r7,-96(%r30)
 stw %r8,-92(%r30)
 stw %r9,-88(%r30)
 stw %r10,-84(%r30)
 stw %r11,-80(%r30)
 stw %r12,-76(%r30)
 stw %r13,-72(%r30)
 stw %r14,-68(%r30)
 stw %r15,-64(%r30)
 stw %r16,-60(%r30)
 stw %r17,-56(%r30)
 stw %r18,-52(%r30)
 stw %r19,-48(%r30)
 copy %r26,%r22
 copy %r25,%r15
 copy %r24,%r16
 copy %r23,%r18
 copy %r0,%r14
 copy %r0,%r17
 ldil L'trampoline,%r12
 ldo R'trampoline(%r12),%r12
 ble 0(%sr4,%r22)
 copy %r31,%r2
 copy %r15,%r28
 ldw -112(%r30),%r3
 ldw -108(%r30),%r4
 ldw -104(%r30),%r5
 ldw -100(%r30),%r6
 ldw -96(%r30),%r7
 ldw -92(%r30),%r8
 ldw -88(%r30),%r9
 ldw -84(%r30),%r10
 ldw -80(%r30),%r11
 ldw -76(%r30),%r12
 ldw -72(%r30),%r13
 ldw -68(%r30),%r14
 ldw -64(%r30),%r15
 ldw -60(%r30),%r16
 ldw -56(%r30),%r17
 ldw -52(%r30),%r18
 ldw -48(%r30),%r19
 ldw -148(%r30),%r2
 bv %r0(%r2)
 ldo -128(%r30),%r30
.size hppa_bootstrap_execute,.-hppa_bootstrap_execute
.section .note.GNU-stack,"",@progbits
.text
.align 4
.globl hppa_mock_factor_entry
.hidden hppa_mock_factor_entry
.type hppa_mock_factor_entry,@function
hppa_mock_factor_entry:
 ldi 999,%r3
 ldi 998,%r4
 ldi 997,%r5
 ldi 996,%r6
 ldi 995,%r7
 stw %r26,0(%r15)
 ldw 16(%r16),%r1
 ldw -292(%r1),%r20
 comb,<> %r20,%r26,.Lcallback_bad
 nop
 ldw -296(%r1),%r20
 comb,<> %r20,%r25,.Lcallback_bad
 nop
 ldw -300(%r1),%r20
 comb,<> %r20,%r24,.Lcallback_bad
 nop
 ldw -304(%r1),%r20
 comb,<> %r20,%r23,.Lcallback_bad
 nop
 ldw -84(%r1),%r20
 comb,<> %r20,%r26,.Lcallback_bad
 nop
 ldw -80(%r1),%r20
 comb,<> %r20,%r25,.Lcallback_bad
 nop
 ldw -76(%r1),%r20
 comb,<> %r20,%r24,.Lcallback_bad
 nop
 ldw -72(%r1),%r20
 comb,<> %r20,%r23,.Lcallback_bad
 nop
 bv %r0(%r2)
 ldi 42,%r28
.Lcallback_bad:
 bv %r0(%r2)
 ldi -1,%r28
.size hppa_mock_factor_entry,.-hppa_mock_factor_entry
.globl hppa_mock_factor_float
.hidden hppa_mock_factor_float
.type hppa_mock_factor_float,@function
hppa_mock_factor_float:
 ldw 16(%r16),%r1
 ldo -56(%r1),%r1
 fldds 0(%r1),%fr4
 fcmp,dbl,= %fr4,%fr5
 ftest
 b .Lfloat_bad
 nop
 ldw 16(%r16),%r1
 ldo -40(%r1),%r1
 fldds 0(%r1),%fr4
 fcmp,dbl,= %fr4,%fr7
 ftest
 b .Lfloat_bad
 nop
 fadd,dbl %fr5,%fr7,%fr4
 bv %r0(%r2)
 nop
.Lfloat_bad:
 bv %r0(%r2)
 fsub,dbl %fr5,%fr5,%fr4
.size hppa_mock_factor_float,.-hppa_mock_factor_float
