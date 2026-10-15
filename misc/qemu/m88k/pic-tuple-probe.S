.text
.globl pic_tuple_call
pic_tuple_call:
 subu %r31,%r31,16
 st %r1,%r31,0
 st %r19,%r31,4
 jsr %r3
 ld %r19,%r31,4
 ld %r1,%r31,0
 addu %r31,%r31,16
 jmp %r1

/* OpenBSD native cache synchronization, same sequence used by native-code.S. */
.globl m88k_cache_sync
m88k_cache_sync:
 tb0 0,%r0,451
 jmp %r1
