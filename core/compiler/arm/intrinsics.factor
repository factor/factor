! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: alien arrays assembler-arm kernel kernel-internals math
math-internals namespaces sequences words ;

\ slot {
    ! Slot number is literal
    {
        [
            "out" operand "obj" operand %untag
            "out" operand dup "n" get cells <+> LDR
        ] H{
            { +input+ { { f "obj" } { [ cells ] "n" } } }
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

! : generate-write-barrier ( -- )
!     "obj" operand R7 "obj" operand card-bits <LSR> ADD
!     "x" operand "obj" operand 0 LDRB
!     "x" operand dup card-mark ORR
!     "x" operand "obj" operand 0 STRB ;
! 
! \ set-slot {
!     ! Slot number is literal
!     {
!         [
!             "obj" operand dup %untag
!             "val" operand "obj" operand "n" get cells <+> STR
!             generate-write-barrier
!         ] H{
!             { +input+ { { f "val" } { f "obj" } { [ cells ] "n" } } }
!             { +scratch+ { { f "x" } } }
!             { +clobber+ { "obj" } }
!         }
!     }
!     ! Slot number is in a register
!     {
!         [
!             "obj" operand dup %untag
!             "n" operand "obj" operand "n" operand 1 <LSR> ADD
!             "val" operand "n" operand 0 STR
!             generate-write-barrier
!         ] H{
!             { +input+ { { f "val" } { f "obj" } { f "n" } } }
!             { +scratch+ { { f "x" } } }
!             { +clobber+ { "obj" } }
!         }
!     }
! } define-intrinsics

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
        { +input+ { { f "x" } { [ v>operand ] "y" } } }
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

: fixnum-jump ( op -- quo )
    [ "x" operand "y" operand CMP ] swap unit [ B ] 3append ;

: fixnum-register-jump ( op -- pair )
   fixnum-jump { { f "x" } { f "y" } } 2array ;

: fixnum-value-jump ( op -- pair )
    fixnum-jump { { f "x" } { [ v>operand ] "y" } } 2array ;

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
    "out" operand "in" operand tag-mask AND
    "out" operand dup %tag-fixnum
] H{
    { +input+ { { f "in" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic
