! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private
locals.backend math.private namespaces slots.private
strings.private ;
IN: bootstrap.arm

big-endian off

[
] CALLBACK-STUB jit-define

[
] JIT-PUSH-LITERAL jit-define

[
] JIT-WORD-CALL jit-define

[
] JIT-IF jit-define

[
] JIT-DIP jit-define

[
] JIT-2DIP jit-define

[
] JIT-3DIP jit-define

[
] JIT-EXECUTE jit-define

[
] JIT-PROLOG jit-define

[
] JIT-EPILOG jit-define

[
] JIT-RETURN jit-define


! ! ! Polymorphic inline caches
! The PIC stubs are not permitted to touch pic-tail-reg.

! Load a value from a stack position
[
] PIC-LOAD jit-define

[
] PIC-TAG jit-define


[
] PIC-TUPLE jit-define

[
] PIC-CHECK-TAG jit-define

[
] PIC-HIT jit-define

[
] MEGA-LOOKUP jit-define


{
    ! ## Fixnums

    ! ### Add
    { fixnum+fast [
    ] }

    ! ### Bit stuff
    { fixnum-bitand [ 
    ] }
    { fixnum-bitnot [
    ] }
    { fixnum-bitor [
    ] }
    { fixnum-bitxor [
    ] }
    { fixnum-shift-fast [
    ] }

    ! ### Comparisons
    { both-fixnums? [
    ] }
    { eq? [
    ] }
    { fixnum> [
    ] }
    { fixnum>= [
    ] }
    { fixnum< [
    ] }
    { fixnum<= [
    ] }

    ! ### Div/mod
    { fixnum-mod [
    ] }
    { fixnum/i-fast [
    ] }
    { fixnum/mod-fast [
    ] }

    ! ### Mul
    { fixnum*fast [
    ] }

    ! ### Sub
    { fixnum-fast [
    ] }

    ! ## Locals
    { drop-locals [
    ] }
    { get-local [
    ] }
    { load-local [
    ] }

    ! ## Objects
    { slot [
    ] }
    { string-nth-fast [
    ] }
    { tag [
    ] }

    ! ## Shufflers

    ! ### Drops
    { drop [ ] } ! ds-reg bootstrap-cell SUB ] }
    { 2drop [ ] } ! ds-reg 2 bootstrap-cells SUB ] }
    { 3drop [ ] } ! ds-reg 3 bootstrap-cells SUB ] }
    { 4drop [ ] } ! ds-reg 4 bootstrap-cells SUB ] }

    ! ### Dups
    { dup [
    ] }
    { 2dup [
    ] }
    { 3dup [
    ] }
    { 4dup [
    ] }
    { dupd [
    ] }

    ! ### Misc shufflers
    { over [
    ] }
    { pick [
    ] }

    ! ### Nips
    { nip [
    ] }
    { 2nip [
    ] }

    ! ### Swaps
    { -rot [
    ] }
    { rot [
    ] }
    { swap [
    ] }
    { swapd [
    ] }

    ! ## Signal handling
    { leaf-signal-handler [
    ] }
    { signal-handler [
    ] }


} define-sub-primitives


! [ "bootstrap.arm" forget-vocab ] with-compilation-unit