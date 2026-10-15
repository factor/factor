/* HPPA32 native call gates. r22=plabel, r16=context, r18=Factor frame.
 * Native r30 grows upward; Factor linked frames grow downward independently.
 * GCC's $$dyncall installs descriptor r19 and branches through the code field.
 */
.text
.align 4
.globl trampoline
.hidden trampoline
.type trampoline,@function
trampoline:
 ldo 64(%r30),%r30
 b,l .Lgate,%r0
 nop
.size trampoline,.-trampoline
.globl trampoline2
.hidden trampoline2
.type trampoline2,@function
trampoline2:
 /* FFI caller already allocated its native argument frame. */
 copy %r18,%r1
 ldo -16(%r18),%r18
 stw %r1,0(%r18)
 stw %r2,4(%r18)
 stw %r19,8(%r18)
 stw %r18,0(%r16)
 b,l $$dyncall,%r31
 copy %r31,%r2
 ldw 8(%r18),%r19
 ldw 4(%r18),%r2
 bv %r0(%r2)
 ldw 0(%r18),%r18
.size trampoline2,.-trampoline2
.Lgate:
 copy %r18,%r1
 ldo -16(%r18),%r18
 stw %r1,0(%r18)
 stw %r2,4(%r18)
 stw %r19,8(%r18)
 stw %r18,0(%r16)
 b,l $$dyncall,%r31
 copy %r31,%r2
 ldw 8(%r18),%r19
 ldw 4(%r18),%r2
 ldw 0(%r18),%r18
 bv %r0(%r2)
 ldo -64(%r30),%r30
.section .note.GNU-stack,"",@progbits
