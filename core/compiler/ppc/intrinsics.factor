! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: alien arrays assembler-ppc kernel kernel-internals math
math-internals namespaces sequences words generic quotations ;

: generate-slot ( size quot -- )
    >r >r
    ! turn tagged fixnum slot # into an offset, multiple of 4
    "n" operand dup tag-bits get r> - SRAWI
    ! compute slot address
    "out" operand dup "n" operand ADD
    ! load slot value
    "out" operand dup r> call ; inline

\ slot {
    ! Slot number is literal
    {
        [
            "obj" operand "out" operand %untag
            "out" operand dup "n" get cells LWZ
        ] H{
            { +input+ { { f "obj" } { [ small-slot? ] "n" } } }
            { +scratch+ { { f "out" } } }
            { +output+ { "out" } }
        }
    }
    ! Slot number in a register
    {
        [
            "obj" operand "out" operand %untag
            cell log2 [ 0 LWZ ] generate-slot
        ] H{
            { +input+ { { f "obj" } { f "n" } } }
            { +scratch+ { { f "out" } } }
            { +output+ { "out" } }
            { +clobber+ { "n" } }
        }
    }
} define-intrinsics

\ char-slot [
    "out" operand "obj" operand MR
    1 [ string-offset LHZ ] generate-slot
    "out" operand dup %tag-fixnum
] H{
    { +input+ { { f "n" } { f "obj" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
    { +clobber+ { "n" } }
} define-intrinsic

: generate-set-slot ( size quot -- )
    >r >r
    ! turn tagged fixnum slot # into an offset, multiple of 4
    "slot" operand dup tag-bits get r> - SRAWI
    ! compute slot address in 1st input
    "slot" operand dup "obj" operand ADD
    ! store new slot value
    "val" operand "slot" operand r> call ; inline

: load-cards-offset ( dest -- )
    "cards_offset" f pick compile-dlsym  dup 0 LWZ ;

: generate-write-barrier ( -- )
    "obj" operand dup card-bits SRWI
    "x" operand load-cards-offset
    "obj" operand dup "x" operand ADD
    "x" operand "obj" operand 0 LBZ
    "x" operand dup card-mark ORI
    "x" operand "obj" operand 0 STB ;

\ set-slot {
    ! Slot number is literal
    {
        [
            "obj" operand dup %untag
            "val" operand "obj" operand "n" get cells STW
            generate-write-barrier
        ] H{
            { +input+ { { f "val" } { f "obj" } { [ small-slot? ] "n" } } }
            { +scratch+ { { f "x" } } }
            { +clobber+ { "obj" } }
        }
    }
    ! Slot number is in a register
    {
        [
            "obj" operand dup %untag
            cell log2 [ 0 STW ] generate-set-slot
            generate-write-barrier
        ] H{
            { +input+ { { f "val" } { f "obj" } { f "slot" } } }
            { +scratch+ { { f "x" } } }
            { +clobber+ { "obj" "slot" } }
        }
    }
} define-intrinsics

\ set-char-slot [
    ! untag the new value in 0th input
    "val" operand dup %untag-fixnum
    1 [ string-offset STH ] generate-set-slot
] H{
    { +input+ { { f "val" } { f "slot" } { f "obj" } } }
    { +scratch+ { { f "x" } } }
    { +clobber+ { "val" "slot" "obj" } }
} define-intrinsic

: fixnum-register-op ( op -- pair )
    [ "out" operand "y" operand "x" operand ] swap add H{
        { +input+ { { f "x" } { f "y" } } }
        { +scratch+ { { f "out" } } }
        { +output+ { "out" } }
    } 2array ;

: fixnum-value-op ( op -- pair )
    [ "out" operand "x" operand "y" operand ] swap add H{
        { +input+ { { f "x" } { [ small-tagged? ] "y" } } }
        { +scratch+ { { f "out" } } }
        { +output+ { "out" } }
    } 2array ;

: define-fixnum-op ( word imm-op reg-op -- )
    >r fixnum-value-op r> fixnum-register-op 2array
    define-intrinsics ;

{
    { fixnum+fast ADDI ADD }
    { fixnum-fast SUBI SUBF }
    { fixnum-bitand ANDI AND }
    { fixnum-bitor ORI OR }
    { fixnum-bitxor XORI XOR }
} [
    first3 define-fixnum-op
] each

\ fixnum*fast {
    {
        [
            "out" operand "x" operand "y" get MULLI
        ] H{
            { +input+ { { f "x" } { [ small-tagged? ] "y" } } }
            { +scratch+ { { f "out" } } }
            { +output+ { "out" } }
        }
    } {
        [
            "out" operand "x" operand %untag-fixnum
            "out" operand "y" operand "out" operand MULLW
        ] H{
            { +input+ { { f "x" } { f "y" } } }
            { +scratch+ { { f "out" } } }
            { +output+ { "out" } }
        }
    }
} define-intrinsics

\ fixnum-shift [
    "out" operand "x" operand "y" get neg SRAWI
    ! Mask off low bits
    "out" operand dup %untag
] H{
    { +input+ { { f "x" } { [ -31 0 between? ] "y" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

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
    { +input+ { { f "x" } { f "y" } } }
    { +scratch+ { { f "r" } { f "s" } } }
    { +output+ { "s" } }
} define-intrinsic

\ fixnum-bitnot [
    "x" operand dup NOT
    "x" operand dup %untag
] H{
    { +input+ { { f "x" } } }
    { +output+ { "x" } }
} define-intrinsic

: fixnum-register-jump ( op -- pair )
    [ "x" operand 0 "y" operand CMP ] swap add
    { { f "x" } { f "y" } } 2array ;

: fixnum-value-jump ( op -- pair )
    [ 0 "x" operand "y" operand CMPI ] swap add
    { { f "x" } { [ small-tagged? ] "y" } } 2array ;

: define-fixnum-jump ( word op -- )
    [ fixnum-value-jump ] keep fixnum-register-jump
    2array define-if-intrinsics ;

{
    { fixnum< BLT }
    { fixnum<= BLE }
    { fixnum> BGT }
    { fixnum>= BGE }
    { eq? BEQ }
} [
    first2 define-fixnum-jump
] each

: %untag-fixnums ( seq -- )
    [ dup %untag-fixnum ] unique-operands ;

: overflow-check ( insn1 insn2 -- )
    [
        >r 0 0 LI
        0 MTXER
        "r" operand "y" operand "x" operand r> execute
        >r
        "end" define-label
        "end" get BNO
        { "x" "y" } %untag-fixnums
        "r" operand "y" operand "x" operand r> execute
        "r" operand %allot-bignum-signed-1
        "end" resolve-label
    ] with-scope ; inline

: overflow-template ( word insn1 insn2 -- )
    [ overflow-check ] curry curry H{
        { +input+ { { f "x" } { f "y" } } }
        { +scratch+ { { f "r" } } }
        { +output+ { "r" } }
        { +clobber+ { "x" "y" } }
    } define-intrinsic ;

\ fixnum+ \ ADD \ ADDO. overflow-template
\ fixnum- \ SUBF \ SUBFO. overflow-template

: generate-fixnum/i
    #! This VOP is funny. If there is an overflow, it falls
    #! through to the end, and the result is in "x" operand.
    #! Otherwise it jumps to the "no-overflow" label and the
    #! result is in "r" operand.
    "end" define-label
    "no-overflow" define-label
    "r" operand "x" operand "y" operand DIVW
    ! if the result is greater than the most positive fixnum,
    ! which can only ever happen if we do
    ! most-negative-fixnum -1 /i, then the result is a bignum.
    most-positive-fixnum "s" operand LOAD
    "r" operand 0 "s" operand CMP
    "no-overflow" get BLE
    most-negative-fixnum neg "x" operand LOAD
    "x" operand %allot-bignum-signed-1 ;

\ fixnum/i [
    generate-fixnum/i
    "end" get B
    "no-overflow" resolve-label
    "r" operand "x" operand %tag-fixnum
    "end" resolve-label
] H{
    { +input+ { { f "x" } { f "y" } } }
    { +scratch+ { { f "r" } { f "s" } } }
    { +output+ { "x" } }
    { +clobber+ { "y" } }
} define-intrinsic

\ fixnum/mod [
    generate-fixnum/i
    0 "s" operand LI
    "end" get B
    "no-overflow" resolve-label
    generate-fixnum-mod
    "r" operand "x" operand %tag-fixnum
    "end" resolve-label
] H{
    { +input+ { { f "x" } { f "y" } } }
    { +scratch+ { { f "r" } { f "s" } } }
    { +output+ { "x" "s" } }
    { +clobber+ { "y" } }
} define-intrinsic

\ fixnum>bignum [
    "x" operand dup %untag-fixnum
    "x" operand %allot-bignum-signed-1
] H{
    { +input+ { { f "x" } } }
    { +output+ { "x" } }
} define-intrinsic

\ bignum>fixnum [
    "nonzero" define-label
    "positive" define-label
    "end" define-label
    "x" operand dup %untag
    "y" operand "x" operand cell LWZ
     ! if the length is 1, its just the sign and nothing else,
     ! so output 0
    0 "y" operand 1 v>operand CMPI
    "nonzero" get BNE
    0 "y" operand LI
    "end" get B
    "nonzero" resolve-label
    ! load the value
    "y" operand "x" operand 3 cells LWZ
    ! load the sign
    "x" operand "x" operand 2 cells LWZ
    ! is the sign negative?
    0 "x" operand 0 CMPI
    "positive" get BEQ
    "y" operand dup -1 MULI
    "positive" resolve-label
    "y" operand dup %tag-fixnum
    "end" resolve-label
] H{
    { +input+ { { f "x" } } }
    { +scratch+ { { f "y" } } }
    { +clobber+ { "x" } }
    { +output+ { "y" } }
} define-intrinsic

: define-float-op ( word op -- )
    [ "x" operand "x" operand "y" operand ] swap add H{
        { +input+ { { float "x" } { float "y" } } }
        { +output+ { "x" } }
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
    [ "x" operand 0 "y" operand FCMPU ] swap add
    { { float "x" } { float "y" } } define-if-intrinsic ;

{
    { float< BLT }
    { float<= BLE }
    { float> BGT }
    { float>= BGE }
    { float= BEQ }
} [
    first2 define-float-jump
] each

\ float>fixnum [
    "scratch" operand "in" operand FCTIWZ
    "scratch" operand 1 0 param@ STFD
    "out" operand 1 cell param@ LWZ
    "out" operand dup %tag-fixnum
] H{
    { +input+ { { float "in" } } }
    { +scratch+ { { float "scratch" } { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ tag [
    "out" operand "in" operand tag-mask get ANDI
    "out" operand dup %tag-fixnum
] H{
    { +input+ { { f "in" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ type [
    "f" define-label
    "end" define-label
    ! Get the tag
    "y" operand "obj" operand tag-mask get ANDI
    ! Tag the tag
    "y" operand "x" operand %tag-fixnum
    ! Compare with object tag number (3).
    0 "y" operand object tag-number CMPI
    ! Jump if the object doesn't store type info in its header
    "end" get BNE
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    0 "obj" operand object tag-number CMPI
    "f" get BEQ
    ! The pointer is not equal to 3. Load the object header.
    "x" operand "obj" operand object tag-number neg LWZ
    "x" operand dup %untag
    "end" get B
    "f" resolve-label
    ! The pointer is equal to 3. Load F_TYPE (9).
    f type v>operand "x" operand LI
    "end" resolve-label
] H{
    { +input+ { { f "obj" } } }
    { +scratch+ { { f "x" } { f "y" } } }
    { +output+ { "x" } }
} define-intrinsic

: userenv ( reg -- )
    #! Load the userenv pointer in a register.
    "userenv" f rot compile-dlsym ;

\ getenv [
    "n" operand dup 1 SRAWI
    "x" operand userenv
    "x" operand "n" operand "x" operand ADD
    "x" operand dup 0 LWZ
] H{
    { +input+ { { f "n" } } }
    { +scratch+ { { f "x" } } }
    { +output+ { "x" } }
    { +clobber+ { "n" } }
} define-intrinsic

\ setenv [
    "n" operand dup 1 SRAWI
    "x" operand userenv
    "x" operand "n" operand "x" operand ADD
    "val" operand "x" operand 0 STW
] H{
    { +input+ { { f "val" } { f "n" } } }
    { +scratch+ { { f "x" } } }
    { +clobber+ { "n" } }
} define-intrinsic

\ <tuple> [
    "tuple" operand "class" operand "n" get %allot-tuple
] H{
    { +input+ { { f "class" } { [ inline-array? ] "n" } } }
    { +scratch+ { { f "tuple" } } }
    { +output+ { "tuple" } }
} define-intrinsic

\ <array> [
    "array" operand "initial" operand "n" get %allot-array
] H{
    { +input+ { { [ inline-array? ] "n" } { f "initial" } } }
    { +scratch+ { { f "array" } } }
    { +output+ { "array" } }
} define-intrinsic
