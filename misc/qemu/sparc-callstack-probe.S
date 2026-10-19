#ifdef __arch64__
#define CELL 8
#define FRAME 176
#define STORE stx
#define LOAD ldx
#define BIAS 2047
.register %g2,#scratch
.register %g3,#scratch
#else
#define CELL 4
#define FRAME 96
#define STORE st
#define LOAD ld
#define BIAS 0
#endif
.text
.align 4
.global run_context
run_context:
 save %sp,-FRAME,%sp
 mov %g2,%l0
 mov %g3,%l1
 mov %g4,%l2
 mov %g5,%l3
 mov %i2,%g4
 clr %g3
 mov %i0,%g2
 LOAD [%i0],%o0
 LOAD [%g4],%g5
 add %sp,BIAS,%o1
 STORE %o1,[%g5+CELL]
 jmpl %i1,%o7
 nop
.global return_from_callstack
return_from_callstack:
 mov %g2,%i0
 mov %l0,%g2
 mov %l1,%g3
 mov %l2,%g4
 mov %l3,%g5
 ret
 restore
.global callstack_middle_return
callstack_middle_return:
 ret
 restore
/* Linux test shim: verify encoded slots, then normalize ALL copied frames
 * before Linux kernel window fills. This proves the emitted cookie loop;
 * actual OpenBSD kernel encoding/decoding is tested by native BSD probes. */
.global restore_encoded_test_windows
restore_encoded_test_windows:
#ifdef __arch64__
 setx factor_sparc_window_cookie,%o4,%o5
#else
 set factor_sparc_window_cookie,%o5
#endif
 LOAD [%o5],%o5
 mov %o0,%o3
 LOAD [%g5+CELL],%o2
 clr %g1
.Lcookie_loop:
 LOAD [%o3+15*CELL],%o4
 andcc %o4,3,%g0
#ifdef __arch64__
 bne %xcc,.Lencoded
#else
 bne .Lencoded
#endif
 nop
 mov -100,%g1
.Lencoded:
 add %g1,1,%g1
 xor %o4,%o5,%o4
 STORE %o4,[%o3+15*CELL]
 LOAD [%o3+14*CELL],%o3
 add %o3,BIAS,%o3
 cmp %o3,%o2
#ifdef __arch64__
 bne %xcc,.Lcookie_loop
#else
 bne .Lcookie_loop
#endif
 nop
#ifdef __arch64__
 setx cookie_frame_count,%o3,%o4
#else
 set cookie_frame_count,%o4
#endif
 st %g1,[%o4]
#ifdef __arch64__
 setx sparc_restore_window,%o3,%o4
#else
 set sparc_restore_window,%o4
#endif
 jmp %o4
 nop
.section .note.GNU-stack,"",@progbits
