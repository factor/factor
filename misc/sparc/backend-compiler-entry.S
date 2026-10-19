/* Every Factor callee must preserve its caller's local/input window. */
#ifdef __arch64__
.register %g2,#scratch
.register %g3,#scratch
#endif
#ifdef __arch64__
#define STORE stx
#define LOAD ldx
#define CELL 8
#define BIAS 2047
#else
#define STORE st
#define LOAD ld
#define CELL 4
#define BIAS 0
#endif
.text
.macro INIT_WINDOW reg,value,slot
 mov \value,\reg
 STORE \reg,[%sp+BIAS+\slot*CELL]
.endm
.macro CHECK_WINDOW reg,slot
 LOAD [%sp+BIAS+\slot*CELL],%o4
 cmp \reg,%o4
 bne 1f
  nop
.endm
.align 4
.global sparc_compiler_enter
.type sparc_compiler_enter,#function
sparc_compiler_enter:
#ifdef __arch64__
 save %sp,-176,%sp
#else
 save %sp,-96,%sp
#endif
 mov %i1,%g2
 mov %i2,%g3
 mov %i3,%g4
 mov %i0,%g1
 INIT_WINDOW %l0,101,0
 INIT_WINDOW %l1,102,1
 INIT_WINDOW %l2,103,2
 INIT_WINDOW %l3,104,3
 INIT_WINDOW %l4,105,4
 INIT_WINDOW %l5,106,5
 INIT_WINDOW %l6,107,6
 INIT_WINDOW %l7,108,7
 INIT_WINDOW %i0,109,8
 INIT_WINDOW %i1,110,9
 INIT_WINDOW %i2,111,10
 INIT_WINDOW %i3,112,11
 INIT_WINDOW %i4,113,12
 INIT_WINDOW %i5,114,13
 jmpl %g1,%o7
  nop
 CHECK_WINDOW %l0,0
 CHECK_WINDOW %l1,1
 CHECK_WINDOW %l2,2
 CHECK_WINDOW %l3,3
 CHECK_WINDOW %l4,4
 CHECK_WINDOW %l5,5
 CHECK_WINDOW %l6,6
 CHECK_WINDOW %l7,7
 CHECK_WINDOW %i0,8
 CHECK_WINDOW %i1,9
 CHECK_WINDOW %i2,10
 CHECK_WINDOW %i3,11
 CHECK_WINDOW %i4,12
 CHECK_WINDOW %i5,13
 clr %i0
 ret
  restore
1:
 mov 1,%i0
 ret
  restore
.size sparc_compiler_enter,.-sparc_compiler_enter
.section .note.GNU-stack,"",@progbits
