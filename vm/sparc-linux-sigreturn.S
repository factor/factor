/* Copyright (C) 2026 Doug Coleman. BSD license. */
.text
#ifdef __arch64__
#define LOAD ldx
#define CELL 8
#else
#define LOAD ld
#define CELL 4
#endif
.align 4
.global sparc_rt_sigreturn
.type sparc_rt_sigreturn,#function
sparc_rt_sigreturn:
/* Flush current windows before replacing SP. Linux restores the original
 * saved PC and NPC independently, including a taken branch's delay slot. */
#ifdef __arch64__
  flushw
  sub %o0, 2047, %sp
#else
  ta 3
  mov %o0, %sp
#endif
/* Supply the interrupted locals/inputs as well as the kernel's globals/
 * outputs. This also avoids depending on an emulator invalidating windows
 * at sigreturn. The cloned ss is the original kernel-saved window. */
  LOAD [%o0 + 0*CELL], %l0
  LOAD [%o0 + 1*CELL], %l1
  LOAD [%o0 + 2*CELL], %l2
  LOAD [%o0 + 3*CELL], %l3
  LOAD [%o0 + 4*CELL], %l4
  LOAD [%o0 + 5*CELL], %l5
  LOAD [%o0 + 6*CELL], %l6
  LOAD [%o0 + 7*CELL], %l7
  LOAD [%o0 + 8*CELL], %i0
  LOAD [%o0 + 9*CELL], %i1
  LOAD [%o0 + 10*CELL], %i2
  LOAD [%o0 + 11*CELL], %i3
  LOAD [%o0 + 12*CELL], %i4
  LOAD [%o0 + 13*CELL], %i5
  LOAD [%o0 + 14*CELL], %i6
  LOAD [%o0 + 15*CELL], %i7
  mov 101, %g1
#ifdef __arch64__
  ta 0x6d
#else
  ta 0x10
#endif
  unimp 0
.size sparc_rt_sigreturn,.-sparc_rt_sigreturn
.section .note.GNU-stack,"",@progbits
