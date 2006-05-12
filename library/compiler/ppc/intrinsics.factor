! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien assembler kernel kernel-internals math
math-internals namespaces sequences words ;

: untag ( dest src -- ) 0 0 31 tag-bits - RLWINM ;

: tag-fixnum ( src dest -- ) tag-bits SLWI ;

: untag-fixnum ( src dest -- ) tag-bits SRAWI ;

: generate-slot ( size quot -- )
    >r >r
    ! turn tagged fixnum slot # into an offset, multiple of 4
    "n" operand dup tag-bits r> - SRAWI
    ! compute slot address
    "obj" operand dup "n" operand ADD
    ! load slot value
    "obj" operand dup r> call ; inline

\ slot [
    "obj" operand dup untag
    cell log2 [ 0 LWZ ] generate-slot
] H{
    { +input { { f "obj" } { f "n" } } }
    { +output { "obj" } }
} define-intrinsic

\ char-slot [
    1 [ string-offset LHZ ] generate-slot
    "obj" operand dup tag-fixnum
] H{
    { +input { { f "n" } { f "obj" } } }
    { +output { "obj" } }
} define-intrinsic

: generate-set-slot ( size quot -- )
    >r >r
    ! turn tagged fixnum slot # into an offset, multiple of 4
    "slot" operand dup tag-bits r> - SRAWI
    ! compute slot address in 1st input
    "slot" operand dup "obj" operand ADD
    ! store new slot value
    "val" operand "slot" operand r> call ; inline

: generate-write-barrier ( -- )
    #! Mark the card pointed to by vreg.
    "obj" operand dup card-bits SRAWI
    "obj" operand dup 16 ADD
    "x" operand "obj" operand 0 LBZ
    "x" operand dup card-mark ORI
    "x" operand "obj" operand 0 STB ;

\ set-slot [
    "obj" operand dup untag
    cell log2 [ 0 STW ] generate-set-slot generate-write-barrier
] H{
    { +input { { f "val" } { f "obj" } { f "slot" } } }
    { +scratch { { f "x" } } }
    { +clobber { "obj" "slot" } }
} define-intrinsic

\ set-char-slot [
    ! untag the new value in 0th input
    "val" operand dup untag-fixnum
    1 [ string-offset STH ] generate-set-slot
] H{
    { +input { { f "val" } { f "slot" } { f "obj" } } }
    { +scratch { { f "x" } } }
    { +clobber { "val" "slot" "obj" } }
} define-intrinsic

: define-fixnum-op ( word op -- )
    [ [ "x" operand "y" operand "x" operand ] % , ] [ ] make H{
        { +input { { f "x" } { f "y" } } }
        { +output { "x" } }
    } define-intrinsic ;

{
    { fixnum+fast ADD }
    { fixnum-fast SUBF }
    { fixnum-bitand AND }
    { fixnum-bitor OR }
    { fixnum-bitxor XOR }
} [
    first2 define-fixnum-op
] each

: generate-fixnum-mod
    #! PowerPC doesn't have a MOD instruction; so we compute
    #! x-(x/y)*y. Puts the result in "s" operand.
    "s" operand "r" operand "y" operand MULLW
    "s" operand "s" operand "x" operand SUBF ;

\ fixnum-mod [
    ! divide x by y, store result in x
    "r" operand "x" operand "y" operand DIVW
    generate-fixnum-mod
] H{
    { +input { { f "x" } { f "y" } } }
    { +scratch { { f "r" } { f "s" } } }
    { +output { "s" } }
} define-intrinsic

\ fixnum-bitnot [
    "x" operand dup NOT
    "x" operand dup untag
] H{
    { +input { { f "x" } } }
    { +output { "x" } }
} define-intrinsic

: define-fixnum-jump ( word op -- )
    [
        [ end-basic-block "x" operand 0 "y" operand CMP ] % ,
     ] [ ] make H{ { +input { { f "x" } { f "y" } } } }
    define-if-intrinsic ;

{
    { fixnum< BLT }
    { fixnum<= BLE }
    { fixnum> BGT }
    { fixnum>= BGE }
    { eq? BEQ }
} [
    first2 define-fixnum-jump
] each

: simple-overflow ( word -- )
    >r
    <label> "end" set
    "end" get BNO
    { "x" "y" } [ operand ] map prune [ dup untag-fixnum ] each
    3 "y" operand "x" operand r> execute
    "s48_long_to_bignum" f %alien-invoke
    ! An untagged pointer to the bignum is now in r3; tag it
    3 "r" operand bignum-tag ORI
    "end" get save-xt ; inline

\ fixnum+ [
    finalize-contents
    0 MTXER
    "r" operand "y" operand "x" operand ADDO.
    \ ADD simple-overflow
] H{
    { +input { { f "x" } { f "y" } } }
    { +scratch { { f "r" } } }
    { +output { "r" } }
    { +clobber { "x" "y" } }
} define-intrinsic

\ fixnum- [
    finalize-contents
    0 MTXER
    "r" operand "y" operand "x" operand SUBFO.
    \ SUBF simple-overflow
] H{
    { +input { { f "x" } { f "y" } } }
    { +scratch { { f "r" } } }
    { +output { "r" } }
    { +clobber { "x" "y" } }
} define-intrinsic

\ fixnum* [
    finalize-contents
    <label> "end" set
    "r" operand "x" operand untag-fixnum
    0 MTXER
    12 "y" operand "r" operand MULLWO.
    "end" get BNO
    4 "y" operand "r" operand MULHW
    3 12 MR
    "s48_fixnum_pair_to_bignum" f %alien-invoke
    ! now we have to shift it by three bits to remove the second
    ! tag
    tag-bits neg 4 LI
    "s48_bignum_arithmetic_shift" f %alien-invoke
    ! An untagged pointer to the bignum is now in r3; tag it
    3 12 bignum-tag ORI
    "end" get save-xt
    "s" operand 12 MR
] H{
    { +input { { f "x" } { f "y" } } }
    { +scratch { { f "r" } { f "s" } } }
    { +output { "s" } }
    { +clobber { "x" "y" } }
} define-intrinsic

: generate-fixnum/i
    #! This VOP is funny. If there is an overflow, it falls
    #! through to the end, and the result is in "x" operand.
    #! Otherwise it jumps to the "no-overflow" label and the
    #! result is in "r" operand.
    <label> "end" set
    <label> "no-overflow" set
    "r" operand "x" operand "y" operand DIVW
    ! if the result is greater than the most positive fixnum,
    ! which can only ever happen if we do
    ! most-negative-fixnum -1 /i, then the result is a bignum.
    most-positive-fixnum "s" operand LOAD
    "r" operand 0 "s" operand CMP
    "no-overflow" get BLE
    most-negative-fixnum neg 3 LOAD
    "s48_long_to_bignum" f %alien-invoke
    "x" operand 3 bignum-tag ORI ;

\ fixnum/i [
    finalize-contents
    generate-fixnum/i
    "end" get B
    "no-overflow" get save-xt
    "r" operand "x" operand tag-fixnum
    "end" get save-xt
] H{
    { +input { { f "x" } { f "y" } } }
    { +scratch { { f "r" } { f "s" } } }
    { +output { "x" } }
    { +clobber { "y" } }
} define-intrinsic

\ fixnum/mod [
    finalize-contents
    generate-fixnum/i
    0 "s" operand LI
    "end" get B
    "no-overflow" get save-xt
    generate-fixnum-mod
    "r" operand "x" operand tag-fixnum
    "end" get save-xt
] H{
    { +input { { f "x" } { f "y" } } }
    { +scratch { { f "r" } { f "s" } } }
    { +output { "x" "s" } }
    { +clobber { "y" } }
} define-intrinsic

: define-float-op ( word op -- )
    [ [ "x" operand "x" operand "y" operand ] % , ] [ ] make H{
        { +input { { float "x" } { float "y" } } }
        { +output { "x" } }
    } define-intrinsic ;

{
    { float+ FADD }
    { float- FSUB }
    { float* FMUL }
    { float/f FDIV }
} [
    first2 define-float-op
] each

: define-float-jump ( word op -- )
    [
        [ end-basic-block "x" operand 0 "y" operand FCMPU ] % ,
     ] [ ] make H{ { +input { { float "x" } { float "y" } } } }
    define-if-intrinsic ;

{
    { float< BLT }
    { float<= BLE }
    { float> BGT }
    { float>= BGE }
    { float= BEQ }
} [
    first2 define-float-jump
] each

\ tag [
    "in" operand "out" operand tag-mask ANDI
    "out" operand dup tag-fixnum
] H{
    { +input { { f "in" } } }
    { +scratch { { f "out" } } }
    { +output { "out" } }
} define-intrinsic

\ type [
    <label> "f" set
    <label> "end" set
    ! Get the tag
    "obj" operand "y" operand tag-mask ANDI
    ! Tag the tag
    "y" operand "x" operand tag-fixnum
    ! Compare with object tag number (3).
    0 "y" operand object-tag CMPI
    ! Jump if the object doesn't store type info in its header
    "end" get BNE
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    0 "obj" operand object-tag CMPI
    "f" get BEQ
    ! The pointer is not equal to 3. Load the object header.
    "x" operand "obj" operand object-tag neg LWZ
    "x" operand dup untag
    "end" get B
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    f type tag-bits shift "x" operand LI
    "end" get save-xt
] H{
    { +input { { f "obj" } } }
    { +scratch { { f "x" } { f "y" } } }
    { +output { "x" } }
} define-intrinsic

: userenv ( reg -- )
    #! Load the userenv pointer in a register.
    "userenv" f dlsym swap LOAD32 0 rel-2/2 rel-userenv ;

\ getenv [
    "n" operand dup 1 SRAWI
    "x" operand userenv
    "x" operand "n" operand "x" operand ADD
    "x" operand dup 0 LWZ
] H{
    { +input { { f "n" } } }
    { +scratch { { f "x" } } }
    { +output { "x" } }
    { +clobber { "n" } }
} define-intrinsic

\ setenv [
    "n" operand dup 1 SRAWI
    "x" operand userenv
    "x" operand "n" operand "x" operand ADD
    "val" operand "x" operand 0 STW
] H{
    { +input { { f "val" } { f "n" } } }
    { +scratch { { f "x" } } }
    { +clobber { "n" } }
} define-intrinsic
