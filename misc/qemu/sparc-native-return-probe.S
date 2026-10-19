/* Copyright (C) 2026 Doug Coleman. BSD license. */
.register %g2,#scratch
.register %g3,#scratch
.text
.global run_native_return
.type run_native_return,#function
run_native_return:
 save %sp,-176,%sp
 mov %g2,%l0
 mov %g3,%l1
 mov %g4,%l2
 mov %g5,%l3
 mov %i0,%g4
 ldx [%i0],%g5
 ldx [%g5+16],%g2
 ldx [%g5+24],%g3
 jmpl %i1,%o7
  nop
 cmp %g4,%i0
 bne,pn %xcc,1f
  nop
 ldx [%i0],%l4
 cmp %g5,%l4
 bne,pn %xcc,1f
  nop
 ldx [%l4+16],%l5
 cmp %g2,%l5
 bne,pn %xcc,1f
  nop
 ldx [%l4+24],%l5
 cmp %g3,%l5
 bne,pn %xcc,1f
  nop
 std %f0,[%i2]
 mov %o0,%i0
 mov %o1,%i1
 ba 2f
  nop
1:
 clr %i0
 clr %i1
2:
 mov %l0,%g2
 mov %l1,%g3
 mov %l2,%g4
 mov %l3,%g5
 ret
  restore
.size run_native_return,.-run_native_return
.section .note.GNU-stack,"",@progbits
