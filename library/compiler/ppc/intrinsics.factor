! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: assembler kernel kernel-internals math math-internals
namespaces sequences ;

: untag ( dest src -- ) 0 0 31 tag-bits - RLWINM ;

: tag-fixnum ( src dest -- ) tag-bits SLWI ;

: untag-fixnum ( src dest -- ) tag-bits SRAWI ;

\ tag [
    "in" operand dup tag-mask ANDI
    "in" operand dup tag-fixnum
] H{
    { +input { { f "in" } } }
    { +output { "in" } }
} define-intrinsic

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

: define-binary-op ( word op -- )
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
    first2 define-binary-op
] each

\ fixnum-bitnot [
    "x" operand dup NOT
    "x" operand dup untag
] H{
    { +input { { f "x" } } }
    { +output { "x" } }
} define-intrinsic

: define-binary-jump ( word op -- )
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
    first2 define-binary-jump
] each

! M: %type generate-node ( vop -- )
!     drop
!     <label> "f" set
!     <label> "end" set
!     ! Get the tag
!     0 input-operand 1 scratch tag-mask ANDI
!     ! Tag the tag
!     1 scratch 0 scratch tag-fixnum
!     ! Compare with object tag number (3).
!     0 1 scratch object-tag CMPI
!     ! Jump if the object doesn't store type info in its header
!     "end" get BNE
!     ! It does store type info in its header
!     ! Is the pointer itself equal to 3? Then its F_TYPE (9).
!     0 0 input-operand object-tag CMPI
!     "f" get BEQ
!     ! The pointer is not equal to 3. Load the object header.
!     0 scratch 0 input-operand object-tag neg LWZ
!     0 scratch dup untag
!     "end" get B
!     "f" get save-xt
!     ! The pointer is equal to 3. Load F_TYPE (9).
!     f type tag-bits shift 0 scratch LI
!     "end" get save-xt
!     0 output-operand 0 scratch MR ;
! 
! : generate-set-slot ( size quot -- )
!     >r >r
!     ! turn tagged fixnum slot # into an offset, multiple of 4
!     2 input-operand dup tag-bits r> - SRAWI
!     ! compute slot address in 1st input
!     2 input-operand dup 1 input-operand ADD
!     ! store new slot value
!     0 input-operand 2 input-operand r> call ; inline
! 
! M: %set-slot generate-node ( vop -- )
!     drop cell log2 [ 0 STW ] generate-set-slot ;
! 
! M: %write-barrier generate-node ( vop -- )
!     #! Mark the card pointed to by vreg.
!     drop
!     0 input-operand dup card-bits SRAWI
!     0 input-operand dup 16 ADD
!     0 scratch 0 input-operand 0 LBZ
!     0 scratch dup card-mark ORI
!     0 scratch 0 input-operand 0 STB ;
! 
! : simple-overflow ( inv word -- )
!     >r >r
!     <label> "end" set
!     "end" get BNO
!     >3-vop< r> execute
!     0 input-operand dup untag-fixnum
!     1 input-operand dup untag-fixnum
!     >3-vop< r> execute
!     "s48_long_to_bignum" f compile-c-call
!     ! An untagged pointer to the bignum is now in r3; tag it
!     0 output-operand dup bignum-tag ORI
!     "end" get save-xt ; inline
! 
! M: %fixnum+ generate-node ( vop -- )
!     drop 0 MTXER >3-vop< ADDO. \ SUBF \ ADD simple-overflow ;
! 
! M: %fixnum- generate-node ( vop -- )
!     drop 0 MTXER >3-vop< SUBFO. \ ADD \ SUBF simple-overflow ;
! 
! M: %fixnum* generate-node ( vop -- )
!     #! Note that this assumes the output will be in r3.
!     drop
!     <label> "end" set
!     1 input-operand dup untag-fixnum
!     0 MTXER
!     0 scratch 0 input-operand 1 input-operand MULLWO.
!     "end" get BNO
!     1 scratch 0 input-operand 1 input-operand MULHW
!     4 1 scratch MR
!     3 0 scratch MR
!     "s48_fixnum_pair_to_bignum" f compile-c-call
!     ! now we have to shift it by three bits to remove the second
!     ! tag
!     tag-bits neg 4 LI
!     "s48_bignum_arithmetic_shift" f compile-c-call
!     ! An untagged pointer to the bignum is now in r3; tag it
!     0 output-operand 0 scratch bignum-tag ORI
!     "end" get save-xt
!     0 output-operand 0 scratch MR ;
! 
! : generate-fixnum/i
!     #! This VOP is funny. If there is an overflow, it falls
!     #! through to the end, and the result is in 0 output-operand.
!     #! Otherwise it jumps to the "no-overflow" label and the
!     #! result is in 0 scratch.
!     0 scratch 1 input-operand 0 input-operand DIVW
!     ! if the result is greater than the most positive fixnum,
!     ! which can only ever happen if we do
!     ! most-negative-fixnum -1 /i, then the result is a bignum.
!     <label> "end" set
!     <label> "no-overflow" set
!     most-positive-fixnum 1 scratch LOAD
!     0 scratch 0 1 scratch CMP
!     "no-overflow" get BLE
!     most-negative-fixnum neg 3 LOAD
!     "s48_long_to_bignum" f compile-c-call
!     3 dup bignum-tag ORI ;
! 
! M: %fixnum/i generate-node ( vop -- )
!     #! This has specific vreg requirements.
!     drop
!     generate-fixnum/i
!     "end" get B
!     "no-overflow" get save-xt
!     0 scratch 0 output-operand tag-fixnum
!     "end" get save-xt ;
! 
! : generate-fixnum-mod
!     #! PowerPC doesn't have a MOD instruction; so we compute
!     #! x-(x/y)*y. Puts the result in 1 scratch.
!     1 scratch 0 scratch 0 input-operand MULLW
!     1 scratch 1 scratch 1 input-operand SUBF ;
! 
! M: %fixnum-mod generate-node ( vop -- )
!     drop
!     ! divide in2 by in1, store result in out1
!     0 scratch 1 input-operand 0 input-operand DIVW
!     generate-fixnum-mod
!     0 output-operand 1 scratch MR ;
! 
! M: %fixnum/mod generate-node ( vop -- )
!     #! This has specific vreg requirements. Note: if there's an
!     #! overflow, (most-negative-fixnum 1 /mod) the modulus is
!     #! always zero.
!     drop
!     generate-fixnum/i
!     0 0 output-operand LI
!     "end" get B
!     "no-overflow" get save-xt
!     generate-fixnum-mod
!     0 scratch 1 output-operand tag-fixnum
!     0 output-operand 1 scratch MR
!     "end" get save-xt ;
