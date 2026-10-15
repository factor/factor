.text
.align 4
.global sparc_entry_gc_signal
.type sparc_entry_gc_signal,#function
sparc_entry_gc_signal:
#ifdef __arch64__
  ldx [%sp+2047+14*8], %i6
  ldx [%sp+2047+15*8], %i7
#else
  ld [%sp+14*4], %i6
  ld [%sp+15*4], %i7
#endif
  call sparc_entry_gc_collect
   nop
  ba sparc_rt_sigreturn
   nop
.size sparc_entry_gc_signal,.-sparc_entry_gc_signal
.section .note.GNU-stack,"",@progbits
