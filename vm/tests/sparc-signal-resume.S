.text
.align 4
.global sparc_delay_fault
.type sparc_delay_fault,#function
sparc_delay_fault:
#ifdef __arch64__
  save %sp, -176, %sp
#else
  save %sp, -96, %sp
#endif
  sethi %hi(.Lfloating), %g1
  or %g1, %lo(.Lfloating), %g1
  ldd [%g1], %f0
  mov 0x135, %l0
  cmp %l0, %l0
  mov 0, %g1
  ba sparc_original_target
.global sparc_original_delay
sparc_original_delay:
   ld [%g1], %g0
  mov 0, %l0
.global sparc_original_target
sparc_original_target:
  bne .Lbad
   nop
  std %f0, [%i0]
  mov %l0, %i0
  ret
   restore
.global sparc_relocated_delay
sparc_relocated_delay:
  ld [%g1], %g0
  unimp 0
.global sparc_relocated_target
sparc_relocated_target:
  bne .Lbad
   nop
  std %f0, [%i0]
  mov 0x246, %i0
  ret
   restore
.Lbad:
  ret
   restore %g0, 0, %o0
.size sparc_delay_fault,.-sparc_delay_fault
.global sparc_test_signal_entry
.type sparc_test_signal_entry,#function
sparc_test_signal_entry:
#ifdef __arch64__
  ldx [%sp + 2047 + 14*8], %i6
  ldx [%sp + 2047 + 15*8], %i7
#else
  ld [%sp + 14*4], %i6
  ld [%sp + 15*4], %i7
#endif
  call sparc_resume_callback
   nop
  ba sparc_rt_sigreturn
   nop
.size sparc_test_signal_entry,.-sparc_test_signal_entry
.section .rodata
.align 8
.Lfloating:
.double 1.25
.section .note.GNU-stack,"",@progbits
