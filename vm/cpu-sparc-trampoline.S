/* Copyright (C) 2026 Doug Coleman.
 * See https://factorcode.org/license.txt for BSD license. */
#ifdef __arch64__
#define FRAME 176
#define BIAS 2047
#define STORE stx
#define LOAD ldx
#define CELL 8
.register %g2, #scratch
.register %g3, #scratch
#else
#define FRAME 96
#define BIAS 0
#define STORE st
#define LOAD ld
#define CELL 4
#endif
.text
#if defined(__OpenBSD__)
/* A leaf PC thunk keeps the transfer arguments and native results intact. */
.macro OPENBSD_COOKIE
  sethi %hi(_GLOBAL_OFFSET_TABLE_-4), %o4
  call .Lsparc_cookie_pc
   add %o4, %lo(_GLOBAL_OFFSET_TABLE_+4), %o4
  sethi %hi(factor_sparc_window_cookie), %g1
  or %g1, %lo(factor_sparc_window_cookie), %g1
  ldx [%o4 + %g1], %o4
  ldx [%o4], %o4
.endm
.macro DECODE_I7
  andcc %i7, 3, %g0
  bz,pt %xcc, 1f
   nop
  xor %i7, %o4, %i7
1:
.endm
.Lsparc_cookie_pc:
  jmpl %o7 + 8, %g0
   add %o4, %o7, %o4
#endif
.align 4
.global trampoline
.type trampoline,#function
trampoline:
  /* Older ordinary images publish their frame without probing the native
   * reserve. Fault before SAVE while the kernel can spill this window. */
  LOAD [%sp + BIAS - 4096], %g0
  save %sp, -FRAME, %sp
  mov %i0, %o0
  mov %i1, %o1
  mov %i2, %o2
  mov %i3, %o3
  mov %i4, %o4
  mov %i5, %o5
  ba .Lnative_call
   nop
.size trampoline,.-trampoline

/* The optimizer has already SAVE-d an ABI frame and prepared C arguments.
 * Keep that SP so overflow arguments stay at their native ABI offsets.
 * The stable helper owns the C return PC while the Factor heap may move. */
.global trampoline2
.type trampoline2,#function
trampoline2:
  mov %o7, %i7
.Lnative_call:
  mov %g2, %l0
  mov %g3, %l1
  mov %g4, %l2
  mov %g5, %l3
  mov %g1, %l4
  STORE %i6, [%sp + BIAS + 14*CELL]
  STORE %i7, [%sp + BIAS + 15*CELL]
#ifdef __arch64__
  flushw
#else
  ta 3
#endif
  add %sp, BIAS, %l5
  STORE %l5, [%l3]
  jmpl %l4, %o7
   nop
#ifndef __arch64__
  /* GCC structure returns resume at call+12; scalar returns at call+8. */
  nop
#endif
  mov %l0, %g2
  mov %l1, %g3
  mov %l2, %g4
  mov %l3, %g5
  mov %o0, %i0
  mov %o1, %i1
  mov %o2, %i2
  mov %o3, %i3
  LOAD [%sp + BIAS + 15*CELL], %i7
#if defined(__OpenBSD__)
  OPENBSD_COOKIE
  DECODE_I7
#endif
  ret
   restore
.size trampoline2,.-trampoline2

/* Tail transfer to a saved native window. Input o0 is its physical stack
 * address and o1 is the continuation. FLUSHW/ta3 invalidates the old
 * restorable windows so RESTORE in the target uses its saved parent. */
.global sparc_restore_window
.type sparc_restore_window,#function
sparc_restore_window:
#if defined(__OpenBSD__)
  OPENBSD_COOKIE
  andcc %o1, 3, %g0
  bz,pt %xcc, 1f
   sub %o1, 8, %o5
  xor %o5, %o4, %o5
  add %o5, 8, %o1
1:
#endif
#ifdef __arch64__
  flushw
#else
  ta 3
#endif
  sub %o0, BIAS, %sp
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
#if defined(__OpenBSD__)
  DECODE_I7
#endif
  /* A fresh context restores its zeroed physical anchor, then enters a
   * nonreturning root quotation. That quotation's fixed JIT SAVE inherits
   * the native gate's o7. Exclude this entry window from the logical stack
   * at transfer time, keeping both empty-stack pointers equal until the
   * next publication. Suspended windows have a nonzero i6 and are unchanged.
   * Leave SP and the zeroed physical anchor intact for window restoration. */
  cmp %i6, 0
  bne .Lrestore_existing_window
   nop
  LOAD [%g5], %o4
  cmp %o0, %o4
  bne .Lrestore_existing_window
   nop
  LOAD [%g5 + CELL], %o4
  cmp %o0, %o4
  bne .Lrestore_existing_window
   nop
  sub %o0, FRAME, %o4
  STORE %o4, [%g5]
  STORE %o4, [%g5 + CELL]
.Lrestore_existing_window:
  jmpl %o1, %g0
   nop
.size sparc_restore_window,.-sparc_restore_window
.global sparc_signal_enter_window
.type sparc_signal_enter_window,#function
sparc_signal_enter_window:
#if defined(__OpenBSD__)
  mov %g1, %o1
  OPENBSD_COOKIE
#endif
#ifdef __arch64__
  add %sp, 2047, %o0
#else
  mov %sp, %o0
#endif
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
#if defined(__OpenBSD__)
  DECODE_I7
  jmpl %o1, %g0
#else
  jmpl %g1, %g0
#endif
   nop
.size sparc_signal_enter_window,.-sparc_signal_enter_window
#if defined(__OpenBSD__)
/* Preserve the native signal checkpoint before leaving its retained stack. */
.global sparc_openbsd_enter_interrupted_stack
.type sparc_openbsd_enter_interrupted_stack,#function
sparc_openbsd_enter_interrupted_stack:
  save %sp, -176, %sp
  flushw
  sub %i0, 2047, %sp
  add %sp, 192, %i6
  mov %i3, %i7
  mov %i2, %o0
  jmpl %i1, %o7
   nop
  unimp 0
.size sparc_openbsd_enter_interrupted_stack,.-sparc_openbsd_enter_interrupted_stack
#endif
.section .note.GNU-stack,"",@progbits
