! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.arm.assembler
cpu.arm.assembler.opcodes generic.single.private
kernel kernel.private layouts locals.backend
math math.private memory namespaces sequences slots.private
strings.private threads.private vocabs ;
IN: bootstrap.assembler.arm

8 \ cell set

: ds-reg ( -- reg ) X5 ;
: rs-reg ( -- reg ) X6 ;

! caller-saved registers X9-X15
! callee-saved registers X19-X29
: temp0 ( -- reg ) X9 ;
: temp1 ( -- reg ) X10 ;
: temp2 ( -- reg ) X11 ;
: temp3 ( -- reg ) X12 ;


[
] JIT-SAFEPOINT jit-define

[
] JIT-PRIMITIVE jit-define

[
] JIT-WORD-JUMP jit-define

[
] PIC-CHECK-TUPLE jit-define

[
] CALLBACK-STUB jit-define

[
] JIT-PUSH-LITERAL jit-define

[
] JIT-WORD-CALL jit-define

[
] JIT-IF jit-define

: jit->r ( -- )
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post ;

: jit-r> ( -- )
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post ;

: jit-2>r ( -- )
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post ;

: jit-2r> ( -- )
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post ;

: jit-3>r ( -- )
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post ;

: jit-3r> ( -- )
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post ;

[
    ! jit->r
    ! 0 CALL f rc-relative rel-word
    ! jit-r>
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
    { drop [ ] } ! ds-reg SUBi64 ] } ! ds-reg bootstrap-cell SUB ] }
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
