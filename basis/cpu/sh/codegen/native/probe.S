! Emitted code is copied to a private mapping before its call target is patched.
.section .rodata
.p2align 2
.global sh_probe_start,sh_probe_end
.global literal_probe,alias_sub_probe,shift_probe,call_probe,float_probe,float_load_probe
sh_probe_start:
literal_probe:
.incbin "artifacts/literal.bin"
.p2align 2
alias_sub_probe:
.incbin "artifacts/alias-sub.bin"
.p2align 2
shift_probe:
.incbin "artifacts/shift.bin"
.p2align 2
call_probe:
.incbin "artifacts/call.bin"
.p2align 2
float_probe:
.incbin "artifacts/float.bin"
.p2align 2
float_load_probe:
.incbin "artifacts/float-load.bin"
.p2align 2
.global multiply_overflow_probe
multiply_overflow_probe:
.incbin "artifacts/multiply-overflow.bin"
.p2align 2
.global backward_loop_probe
backward_loop_probe:
.incbin "artifacts/backward-loop.bin"
.p2align 2
.global linked_epilog_probe
linked_epilog_probe:
.incbin "artifacts/linked-epilog.bin"
.p2align 2
.global shift_source_probe
shift_source_probe:
.incbin "artifacts/shift-source.bin"
.p2align 2
.global shift_scratch_probe
shift_scratch_probe:
.incbin "artifacts/shift-scratch.bin"
.p2align 2
.global write_barrier_probe
write_barrier_probe:
.incbin "artifacts/write-barrier.bin"
sh_probe_end:
.text
.p2align 2
.global sh_epilog_probe
.type sh_epilog_probe,@function
sh_epilog_probe:
  mov.l r14,@-r15
  sts.l pr,@-r15
  mov r15,r6
  add #-16,r15
  mov.l r14,@r15
  mov.l .Lresume_address,r0
  mov.l r0,@(4,r15)
  mov #-1,r14
  jmp @r4
  nop
.Lresume:
  cmp/eq r6,r15
  bf .Lbad_stack
  mov #1,r0
  bra .Lrestore
  nop
.Lbad_stack:
  mov #0,r0
.Lrestore:
  lds.l @r15+,pr
  rts
  mov.l @r15+,r14
.p2align 2
.Lresume_address: .long .Lresume
.size sh_epilog_probe,.-sh_epilog_probe
.section .note.GNU-stack,"",@progbits
