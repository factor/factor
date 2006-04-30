! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien assembler kernel kernel-internals math
math-internals namespaces sequences ;

\ tag [
    "in" operand tag-mask AND
    "in" operand tag-bits SHL
] H{
    { +input { { f "in" } } }
    { +output { "in" } }
} define-intrinsic

\ type [
    #! Intrinstic version of type primitive.
    <label> "header" set
    <label> "f" set
    <label> "end" set
    ! Make a copy
    "x" operand "obj" operand MOV
    ! Get the tag
    "obj" operand tag-mask AND
    ! Compare with object tag number (3).
    "obj" operand object-tag CMP
    ! Jump if the object doesn't store type info in its header
    "header" get JE
    ! It doesn't store type info in its header
    "obj" operand tag-bits SHL
    "end" get JMP
    "header" get save-xt
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    "x" operand object-tag CMP
    "f" get JE
    ! The pointer is not equal to 3. Load the object header.
    "obj" operand "x" operand object-tag neg [+] MOV
    ! Mask off header tag, making a fixnum.
    "obj" operand object-tag XOR
    "end" get JMP
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    "obj" operand f type tag-bits shift MOV
    "end" get save-xt
] H{
    { +input { { f "obj" } } }
    { +scratch { { f "x" } { f "y" } } }
    { +output { "obj" } }
} define-intrinsic

: untag ( reg -- ) tag-mask bitnot AND ;

\ slot [
    "obj" operand untag
    ! turn tagged fixnum slot # into an offset, multiple of 4
    "n" operand fixnum>slot@
    ! compute slot address
    "obj" operand "n" operand ADD
    ! load slot value
    "obj" operand dup [] MOV
] H{
    { +input { { f "obj" } { f "n" } } }
    { +output { "obj" } }
    { +clobber { "n" } }
} define-intrinsic

: card-offset 1 getenv ; inline

: generate-write-barrier ( -- )
    #! Mark the card pointed to by vreg.
    "obj" operand card-bits SHR
    "obj" operand card-offset ADD rel-absolute-cell rel-cards
    "obj" operand [] card-mark OR ;

\ set-slot [
    "obj" operand untag
    ! turn tagged fixnum slot # into an offset
    "slot" operand fixnum>slot@
    ! compute slot address
    "obj" operand "slot" operand ADD
    ! store new slot value
    "obj" operand [] "val" operand MOV
    generate-write-barrier
] H{
    { +input { { f "val" } { f "obj" } { f "slot" } } }
    { +scratch { { f "x" } } }
    { +clobber { "obj" } }
} define-intrinsic

\ char-slot [
    EBX PUSH
    "n" operand 2 SHR
    EBX dup XOR
    EBX "n" operand ADD
    BX "obj" operand string-offset [+] MOV
    EBX tag-bits SHL
    "obj" operand EBX MOV
    EBX POP
] H{
    { +input { { f "n" } { f "obj" } } }
    { +output { "obj" } }
    { +clobber { "n" } }
} define-intrinsic

\ set-char-slot [
    "obj" operand untag
    EBX PUSH
    "val" operand tag-bits SHR
    "slot" operand 2 SHR
    "obj" operand "slot" operand ADD
    EBX "val" operand MOV
    "obj" operand string-offset [+] BX MOV
    EBX POP
] H{
    { +input { { f "val" } { f "slot" } { f "obj" } } }
    { +clobber { "obj" } }
} define-intrinsic

: define-binary-op ( word op -- )
    [ [ "x" operand "y" operand ] % , ] [ ] make H{
        { +input { { f "x" } { f "y" } } }
        { +output { "x" } }
    } define-intrinsic ;

{
    { fixnum+fast ADD }
    { fixnum-fast SUB }
    { fixnum-bitand AND }
    { fixnum-bitor OR }
    { fixnum-bitxor XOR }
} [
    first2 define-binary-op
] each

\ fixnum-bitnot [
    "x" operand NOT
    "x" operand tag-mask XOR
] H{
    { +input { { f "x" } } }
    { +output { "x" } }
} define-intrinsic

! This has specific register requirements. Inputs are in
! ECX and EAX, and the result is in EDX.
\ fixnum-mod [
    prepare-division
    "x" operand IDIV
] H{
    { +input { { 0 "x" } { 2 "y" } } }
    { +output { "x" } }
} define-intrinsic

! : literal-overflow ( -- dest src )
!     #! Called if the src operand is a literal.
!     #! Untag the dest operand.
!     dest/src over tag-bits SAR tag-bits neg shift ;
! 
! : computed-overflow ( -- dest src )
!     #! Called if the src operand is a register.
!     #! Untag both operands.
!     dest/src 2dup tag-bits SAR tag-bits SAR ;
! 
! : simple-overflow ( inverse word -- )
!     #! If the previous arithmetic operation overflowed, then we
!     #! turn the result into a bignum and leave it in EAX.
!     <label> "end" set
!     "end" get JNO
!     ! There was an overflow. Recompute the original operand.
!     >r >r dest/src r> execute
!     0 input integer? [ literal-overflow ] [ computed-overflow ] if
!     ! Compute a result, this time it will fit.
!     r> execute
!     ! Create a bignum.
!     "s48_long_to_bignum" f 0 output-operand
!     1array compile-c-call*
!     ! An untagged pointer to the bignum is now in EAX; tag it
!     T{ int-regs } return-reg bignum-tag OR
!     "end" get save-xt ; inline
! 
! M: %fixnum+ generate-node ( vop -- )
!     drop dest/src ADD  \ SUB \ ADD simple-overflow ;
! 
! M: %fixnum- generate-node ( vop -- )
!     drop dest/src SUB  \ ADD \ SUB simple-overflow ;
! 
! M: %fixnum* generate-node ( vop -- )
!     drop
!     ! both inputs are tagged, so one of them needs to have its
!     ! tag removed.
!     1 input-operand tag-bits SAR
!     0 input-operand IMUL
!     <label> "end" set
!     "end" get JNO
!     "s48_fixnum_pair_to_bignum" f
!     1 input-operand remainder-reg 2array compile-c-call*
!     ! now we have to shift it by three bits to remove the second
!     ! tag
!     "s48_bignum_arithmetic_shift" f
!     1 input-operand tag-bits neg 2array compile-c-call*
!     ! an untagged pointer to the bignum is now in EAX; tag it
!     T{ int-regs } return-reg bignum-tag OR
!     "end" get save-xt ;
! 
! : generate-fixnum/mod
!     #! The same code is used for %fixnum/i and %fixnum/mod.
!     #! This has specific register requirements. Inputs are in
!     #! ECX and EAX, and the result is in EDX.
!     <label> "end" set
!     prepare-division
!     0 input-operand IDIV
!     ! Make a copy since following shift is destructive
!     0 input-operand 1 input-operand MOV
!     ! Tag the value, since division cancelled tags from both
!     ! inputs
!     1 input-operand tag-bits SHL
!     ! Did it overflow?
!     "end" get JNO
!     ! There was an overflow, so make ECX into a bignum. we must
!     ! save EDX since its volatile.
!     remainder-reg PUSH
!     "s48_long_to_bignum" f
!     0 input-operand 1array compile-c-call*
!     ! An untagged pointer to the bignum is now in EAX; tag it
!     T{ int-regs } return-reg bignum-tag OR
!     ! the remainder is now in EDX
!     remainder-reg POP
!     "end" get save-xt ;
! 
! M: %fixnum/i generate-node drop generate-fixnum/mod ;
! 
! M: %fixnum/mod generate-node drop generate-fixnum/mod ;

: define-binary-jump ( word op -- )
    [
        [ end-basic-block "x" operand "y" operand CMP ] % ,
    ] [ ] make H{
        { +input { { f "x" } { f "y" } } }
    } define-if-intrinsic ;

{
    { fixnum< JL }
    { fixnum<= JLE }
    { fixnum> JG }
    { fixnum>= JGE }
    { eq? JE }
} [
    first2 define-binary-jump
] each

: %userenv ( -- )
    "x" operand "userenv" f dlsym MOV
    rel-absolute-cell rel-userenv
    "n" operand 1 SHR
    "n" operand "x" operand ADD ;

\ getenv [
    %userenv  "n" operand dup [] MOV
] H{
    { +input { { f "n" } } }
    { +scratch { { f "x" } } }
    { +output { "n" } }
} define-intrinsic

\ setenv [
    %userenv  "n" operand [] "val" operand MOV
] H{
    { +input { { f "val" } { f "n" } } }
    { +scratch { { f "x" } } }
    { +clobber { "n" } }
} define-intrinsic
