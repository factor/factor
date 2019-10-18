! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: alien arrays assembler-arm kernel kernel-internals math
math-internals namespaces sequences words quotations generic ;

\ slot {
    ! Slot number is literal
    {
        [
            "out" operand "obj" operand %untag
            "out" operand dup "n" get cells <+> LDR
        ] H{
            { +input+ { { f "obj" } { [ small-slot? ] "n" } } }
            { +scratch+ { { f "out" } } }
            { +output+ { "out" } }
        }
    }
    ! Slot number in a register
    {
        [
            "out" operand "obj" operand %untag
            "out" operand dup "n" operand 1 <LSR> <+> LDR
        ] H{
            { +input+ { { f "obj" } { f "n" } } }
            { +scratch+ { { f "out" } } }
            { +output+ { "out" } }
        }
    }
} define-intrinsics

: generate-write-barrier ( -- )
    "cards_offset" f R12 %alien-global
    R12 dup 0 <+> LDR
    "obj" operand R12 "obj" operand card-bits <LSR> ADD
    "x" operand "obj" operand 0 LDRB
    "x" operand dup card-mark ORR
    "x" operand "obj" operand 0 STRB ;

\ set-slot {
    ! Slot number is literal
    {
        [
            "obj" operand dup %untag
            "val" operand "obj" operand "n" get cells <+> STR
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
            "n" operand "obj" operand "n" operand 1 <LSR> ADD
            "val" operand "n" operand 0 STR
            generate-write-barrier
        ] H{
            { +input+ { { f "val" } { f "obj" } { f "n" } } }
            { +scratch+ { { f "x" } } }
            { +clobber+ { "obj" } }
        }
    }
} define-intrinsics

: (%char-slot)
    "out" operand string-offset MOV
    "out" operand dup "n" operand 2 <LSR> ADD ;

\ char-slot [
    (%char-slot)
    "out" operand "obj" operand "out" operand <+> LDRH
    "out" operand dup %tag-fixnum
] H{
    { +input+ { { f "n" } { f "obj" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ set-char-slot [
    "val" operand dup %untag-fixnum
    (%char-slot)
    "val" operand "obj" operand "out" operand <+> STRH
] H{
    { +input+ { { f "val" } { f "n" } { f "obj" } } }
    { +scratch+ { { f "out" } } }
    { +clobber+ { "val" } }
} define-intrinsic

: fixnum-op ( op -- quot )
    [ "out" operand "x" operand "y" operand ] swap add ;

: fixnum-register-op ( op -- pair )
    fixnum-op H{
        { +input+ { { f "x" } { f "y" } } }
        { +scratch+ { { f "out" } } }
        { +output+ { "out" } }
    } 2array ;

: fixnum-value-op ( op -- pair )
    fixnum-op H{
        { +input+ { { f "x" } { [ small-tagged? ] "y" } } }
        { +scratch+ { { f "out" } } }
        { +output+ { "out" } }
    } 2array ;

: define-fixnum-op ( word op -- )
    [ fixnum-value-op ] keep fixnum-register-op 2array
    define-intrinsics ;

{
    { fixnum+fast ADD }
    { fixnum-fast SUB }
    { fixnum-bitand AND }
    { fixnum-bitor ORR }
    { fixnum-bitxor EOR }
} [
    first2 define-fixnum-op
] each

\ fixnum-bitnot [
    "x" operand dup MVN
    "x" operand dup %untag
] H{
    { +input+ { { f "x" } } }
    { +output+ { "x" } }
} define-intrinsic

\ fixnum*fast [
    "out" operand "y" operand %untag-fixnum
    "out" operand "x" operand "out" operand MUL
] H{
    { +input+ { { f "x" } { f "y" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ fixnum-shift [
    "out" operand "x" operand "y" get neg <ASR> MOV
    ! Mask off low bits
    "out" operand dup %untag
] H{
    { +input+ { { f "x" } { [ -31 0 between? ] "y" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

: %untag-fixnums ( seq -- )
    [ dup %untag-fixnum ] unique-operands ;

: overflow-check ( insn -- )
    [
        "end" define-label
        [ "allot-tmp" operand "x" operand "y" operand roll S execute ] keep
        "end" get VC B
        { "x" "y" } %untag-fixnums
        "x" operand "x" operand "y" operand roll execute
        "x" operand %allot-bignum-signed-1
        "end" resolve-label
    ] with-scope ; inline

: overflow-template ( word insn -- )
    [ overflow-check ] curry H{
        { +input+ { { f "x" } { f "y" } } }
        { +scratch+ { { f "allot-tmp" } } }
        { +output+ { "allot-tmp" } }
        { +clobber+ { "x" "y" } }
    } define-intrinsic ;

\ fixnum+ \ ADD overflow-template
\ fixnum- \ SUB overflow-template

\ fixnum>bignum [
    "x" operand dup %untag-fixnum
    "x" operand %allot-bignum-signed-1
] H{
    { +input+ { { f "x" } } }
    { +scratch+ { { f "allot-tmp" } } }
    { +clobber+ { "x" } }
    { +output+ { "allot-tmp" } }
} define-intrinsic

\ bignum>fixnum [
    "end" define-label
    "x" operand dup %untag
    "y" operand "x" operand cell <+> LDR
     ! if the length is 1, its just the sign and nothing else,
     ! so output 0
    "y" operand 1 v>operand CMP
    "y" operand 0 EQ MOV
    "end" get EQ B
    ! load the value
    "y" operand "x" operand 3 cells <+> LDR
    ! load the sign
    "x" operand "x" operand 2 cells <+> LDR
    ! is the sign negative?
    "x" operand 0 CMP
    ! Negate the value
    "y" operand "y" operand 0 NE RSB
    "y" operand dup %tag-fixnum
    "end" resolve-label
] H{
    { +input+ { { f "x" } } }
    { +scratch+ { { f "y" } } }
    { +clobber+ { "x" } }
    { +output+ { "y" } }
} define-intrinsic

: fixnum-jump ( op -- quo )
    [ "x" operand "y" operand CMP ] swap
    1quotation [ B ] 3append ;

: fixnum-register-jump ( op -- pair )
   fixnum-jump { { f "x" } { f "y" } } 2array ;

: fixnum-value-jump ( op -- pair )
    fixnum-jump { { f "x" } { [ small-tagged? ] "y" } } 2array ;

: define-fixnum-jump ( word op -- )
    [ fixnum-value-jump ] keep fixnum-register-jump
    2array define-if-intrinsics ;

{
    { fixnum< LT }
    { fixnum<= LE }
    { fixnum> GT }
    { fixnum>= GE }
    { eq? EQ }
} [
    first2 define-fixnum-jump
] each

\ tag [
    "out" operand "in" operand tag-mask get AND
    "out" operand dup %tag-fixnum
] H{
    { +input+ { { f "in" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ type [
    "end" define-label
    ! Get the tag
    "y" operand "obj" operand tag-mask get AND
    ! Compare with object tag number (3).
    "y" operand object tag-number CMP
    ! Tag the tag if it is not equal to 3
    "x" operand "y" operand NE %tag-fixnum
    ! Jump to end if it is not equal to 3
    "end" get NE B
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    "obj" operand object tag-number CMP
    ! Load F_TYPE (9) if it is equal
    "x" operand f type v>operand EQ MOV
    ! Load the object header if it is not equal
    "x" operand "obj" operand object tag-number <-> NE LDR
    ! Turn the header into a fixnum
    "x" operand dup NE %untag
    "end" resolve-label
] H{
    { +input+ { { f "obj" } } }
    { +scratch+ { { f "x" } { f "y" } } }
    { +output+ { "x" } }
} define-intrinsic

: userenv ( reg -- )
    #! Load the userenv pointer in a register.
    "userenv" f rot %alien-global ;

\ getenv [
    "n" operand dup 1 <ASR> MOV
    "x" operand userenv
    "x" operand "x" operand "n" operand <+> LDR
] H{
    { +input+ { { f "n" } } }
    { +scratch+ { { f "x" } } }
    { +output+ { "x" } }
    { +clobber+ { "n" } }
} define-intrinsic

\ setenv [
    "n" operand dup 1 <ASR> MOV
    "x" operand userenv
    "val" operand "x" operand "n" operand <+> STR
] H{
    { +input+ { { f "val" } { f "n" } } }
    { +scratch+ { { f "x" } } }
    { +clobber+ { "n" } }
} define-intrinsic

\ <tuple> [
    tuple "n" get 2 + cells %allot
    ! Store length
    R12 "n" operand MOV
    R12 "allot-tmp" operand cell <+> STR
    ! Store class
    "class" operand "allot-tmp" operand 2 cells <+> STR
    ! Zero out the rest of the tuple
    R12 f v>operand MOV
    "n" get 1- [ R12 "allot-tmp" operand rot 3 + cells <+> STR ] each
    ! Store tagged ptr in reg
    object %tag-allot
] H{
    { +input+ { { f "class" } { [ inline-array? ] "n" } } }
    { +scratch+ { { f "allot-tmp" } } }
    { +output+ { "allot-tmp" } }
} define-intrinsic

\ <array> [
    array "n" get 2 + cells %allot
    ! Store length
    R12 "n" operand MOV
    R12 "allot-tmp" operand cell <+> STR
    ! Store initial element
    "initial" operand "n" get [
        "allot-tmp" operand swap 2 + cells <+> STR
    ] each-with
    ! Store tagged ptr in reg
    object %tag-allot
] H{
    { +input+ { { [ inline-array? ] "n" } { f "initial" } } }
    { +scratch+ { { f "allot-tmp" } } }
    { +output+ { "allot-tmp" } }
} define-intrinsic
