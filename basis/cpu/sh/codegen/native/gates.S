.text
.p2align 2
.global sh_gate_probe
.type sh_gate_probe,@function
sh_gate_probe:
  mov.l r12,@-r15
  mov.l r14,@-r15
  sts.l pr,@-r15
  mov r4,r12
  mov.l .Lsentinel,r14
  mov #5,r4
  mov #7,r5
  mov.l .Lanswer,r1
  mov.l .Lgate,r0
  jsr @r0
  nop
  mov.l .Lsentinel,r1
  cmp/eq r1,r14
  bt .Lreturn
  mov #0,r0
.Lreturn:
  lds.l @r15+,pr
  mov.l @r15+,r14
  rts
  mov.l @r15+,r12
.p2align 2
.Lsentinel: .long 0x12345678
.Lanswer: .long sh_native_answer
.Lgate: .long trampoline
.size sh_gate_probe,.-sh_gate_probe

.global sh_stack_gate_probe
.type sh_stack_gate_probe,@function
sh_stack_gate_probe:
  mov.l r12,@-r15
  mov.l r14,@-r15
  sts.l pr,@-r15
  mov r4,r12
  add #-32,r15
  mov.l .Lsentinel2,r14
  mov #13,r0
  mov.l r0,@r15
  mov #17,r0
  mov.l r0,@(4,r15)
  mov #5,r4
  mov #7,r5
  mov #9,r6
  mov #11,r7
  mov r15,r3
  add #16,r3
  mov.l .Lsix,r1
  mov.l .Lgate2,r0
  jsr @r0
  nop
  mov.l .Lsentinel2,r1
  cmp/eq r1,r14
  bt .Lreturn2
  mov #0,r0
.Lreturn2:
  add #32,r15
  lds.l @r15+,pr
  mov.l @r15+,r14
  rts
  mov.l @r15+,r12
.p2align 2
.Lsentinel2: .long 0x12345678
.Lsix: .long sh_native_six
.Lgate2: .long trampoline2
.size sh_stack_gate_probe,.-sh_stack_gate_probe
.global sh_pair_gate_probe
.type sh_pair_gate_probe,@function
sh_pair_gate_probe:
  mov.l r12,@-r15
  mov.l r14,@-r15
  sts.l pr,@-r15
  mov r4,r12
  mov.l .Lpairsentinel,r14
  mov #5,r4
  mov #7,r5
  mov.l .Lpairanswer,r1
  mov.l .Lpairgate,r0
  jsr @r0
  nop
  mov.l .Lpairsentinel,r7
  cmp/eq r7,r14
  bt .Lpairreturn
  mov #0,r0
.Lpairreturn:
  lds.l @r15+,pr
  mov.l @r15+,r14
  rts
  mov.l @r15+,r12
.p2align 2
.Lpairsentinel: .long 0x12345678
.Lpairanswer: .long sh_native_pair
.Lpairgate: .long trampoline
.size sh_pair_gate_probe,.-sh_pair_gate_probe


.section .note.GNU-stack,"",@progbits
