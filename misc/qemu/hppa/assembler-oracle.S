.text
 add %r4,%r5,%r6
 sub %r4,%r5,%r6
 and %r4,%r5,%r6
 or %r4,%r5,%r6
 xor %r4,%r5,%r6
 copy %r4,%r6
 ldi -42,%r6
 ldo -42(%r5),%r6
 ldil L%0x12345678,%r6
 ldo R%0x12345678(%r6),%r6
 ldw -42(%r5),%r6
 stw %r6,-42(%r5)
 ldb -42(%r5),%r6
 stb %r6,-42(%r5)
 ldh -42(%r5),%r6
 sth %r6,-42(%r5)
 bv %r0(%r6)
 ble 0(%sr4,%r6)
 copy %r31,%r2
 nop
 cmpb,= %r4,%r5,.+16
 nop
 cmpb,<> %r4,%r5,.+16
 nop
 cmpb,< %r4,%r5,.+16
 nop
 cmpb,>= %r4,%r5,.+16
 nop
 cmpb,<< %r4,%r5,.+16
 nop
 cmpb,>>= %r4,%r5,.+16
 nop
 b .+16
 nop
 bl .+16,%r2
 nop
 extru %r4,31,27,%r6
 extrs %r4,31,27,%r6
 zdep %r4,26,27,%r6
 mtsar %r4
 vshd %r0,%r4,%r6
 vextru %r4,32,%r6
 vextrs %r4,32,%r6
 zvdep %r4,32,%r6
 fadd,dbl %fr4,%fr5,%fr6
 fsub,dbl %fr4,%fr5,%fr6
 fmpy,dbl %fr4,%fr5,%fr6
 fdiv,dbl %fr4,%fr5,%fr6
 fcpy,dbl %fr4,%fr6
 fldd -8(%r5),%fr6
 fstd %fr6,-8(%r5)
 fldw -8(%r5),%fr6L
 fstw %fr6L,-8(%r5)
 fldw -8(%r5),%fr6R
 fstw %fr6R,-8(%r5)
 fcnvxf,sgl,dbl %fr4L,%fr6
 fcnvfxt,dbl,sgl %fr4,%fr6L
 fcnvff,sgl,dbl %fr4L,%fr6
 fcnvff,dbl,sgl %fr4,%fr6L
 xmpyu %fr4L,%fr5L,%fr6
 fabs,dbl %fr4,%fr6
 fcmp,dbl,= %fr4,%fr5
 ftest
 extru %r4,26,27,%r6
 extrs %r4,26,27,%r6
 mtsp %r6,%sr0
zvdep %r4,32,%r6
vextrs %r4,32,%r6
vextru %r4,32,%r6
zvdep %r5,17,%r7
vextrs %r5,17,%r7
vextru %r5,17,%r7
mfctl %sar,%r4
mfctl %sar,%r20
