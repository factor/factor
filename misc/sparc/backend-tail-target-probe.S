#ifdef __arch64__
#define FRAME 512
#else
#define FRAME 256
#endif
.text
.align 4
.global run_tail
run_tail:
 save %sp,-FRAME,%sp
 mov 123,%l7
 mov 0x123,%o4
 jmpl %i0,%o7
 nop
#ifdef __arch64__
 stx %o0,[%i1]
#else
 st %o0,[%i1]
#endif
 mov %l7,%i0
 ret
 restore
.global tail_target
tail_target:
 mov %o4,%o0
 retl
 nop
.section .note.GNU-stack,"",@progbits
