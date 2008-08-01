! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays cpu.architecture cpu.arm.assembler
cpu.arm.architecture cpu.arm.allot kernel kernel.private math
math.private namespaces sequences words
quotations byte-arrays hashtables.private hashtables generator
generator.registers generator.fixup sequences.private sbufs
sbufs.private vectors vectors.private system
classes.tuple.private layouts strings.private slots.private ;
IN: cpu.arm.intrinsics

: %slot-literal-known-tag
    "val" operand
    "obj" operand
    "n" get cells
    "obj" get operand-tag - <+/-> ;

: %slot-literal-any-tag
    "scratch" operand "obj" operand %untag
    "val" operand "scratch" operand "n" get cells <+> ;

: %slot-any
    "scratch" operand "obj" operand %untag
    "n" operand dup 1 <LSR> MOV
    "val" operand "scratch" operand "n" operand <+> ;

\ slot {
    ! Slot number is literal and the tag is known
    {
        [ %slot-literal-known-tag LDR ] H{
            { +input+ { { f "obj" known-tag } { [ small-slot? ] "n" } } }
            { +scratch+ { { f "val" } } }
            { +output+ { "val" } }
        }
    }
    ! Slot number is literal
    {
        [ %slot-literal-any-tag LDR ] H{
            { +input+ { { f "obj" } { [ small-slot? ] "n" } } }
            { +scratch+ { { f "scratch" } { f "val" } } }
            { +output+ { "val" } }
        }
    }
    ! Slot number in a register
    {
        [ %slot-any LDR ] H{
            { +input+ { { f "obj" } { f "n" } } }
            { +scratch+ { { f "val" } { f "scratch" } } }
            { +output+ { "val" } }
            { +clobber+ { "n" } }
        }
    }
} define-intrinsics

: %write-barrier ( -- )
    "val" get operand-immediate? "obj" get fresh-object? or [
        "cards_offset" f R12 %alien-global
        "scratch" operand R12 "obj" operand card-bits <LSR> ADD
        "val" operand "scratch" operand 0 <+> LDRB
        "val" operand dup card-mark ORR
        "val" operand "scratch" operand 0 <+> STRB
    ] unless ;

\ set-slot {
    ! Slot number is literal and tag is known
    {
        [ %slot-literal-known-tag STR %write-barrier ] H{
            { +input+ { { f "val" } { f "obj" known-tag } { [ small-slot? ] "n" } } }
            { +scratch+ { { f "scratch" } } }
            { +clobber+ { "val" } }
        }
    }
    ! Slot number is literal
    {
        [ %slot-literal-any-tag STR %write-barrier ] H{
            { +input+ { { f "val" } { f "obj" } { [ small-slot? ] "n" } } }
            { +scratch+ { { f "scratch" } } }
            { +clobber+ { "val" } }
        }
    }
    ! Slot number is in a register
    {
        [ %slot-any STR %write-barrier ] H{
            { +input+ { { f "val" } { f "obj" } { f "n" } } }
            { +scratch+ { { f "scratch" } } }
            { +clobber+ { "val" "n" } }
        }
    }
} define-intrinsics

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
        [ "out" operand "x" operand "y" operand roll S execute ] keep
        "end" get VC B
        { "x" "y" } %untag-fixnums
        "x" operand "x" operand "y" operand roll execute
        "out" get "x" get %allot-bignum-signed-1
        "end" resolve-label
    ] with-scope ; inline

: overflow-template ( word insn -- )
    [ overflow-check ] curry H{
        { +input+ { { f "x" } { f "y" } } }
        { +scratch+ { { f "out" } } }
        { +output+ { "out" } }
        { +clobber+ { "x" "y" } }
    } define-intrinsic ;

\ fixnum+ \ ADD overflow-template
\ fixnum- \ SUB overflow-template

\ fixnum>bignum [
    "x" operand dup %untag-fixnum
    "out" get "x" get %allot-bignum-signed-1
] H{
    { +input+ { { f "x" } } }
    { +scratch+ { { f "out" } } }
    { +clobber+ { "x" } }
    { +output+ { "out" } }
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
    ! Get the tag
    "out" operand "obj" operand tag-mask get AND
    ! Compare with object tag number (3).
    "out" operand object tag-number CMP
    ! Tag the tag if it is not equal to 3
    "out" operand dup NE %tag-fixnum
    ! Load the object header if tag is equal to 3
    "out" operand "obj" operand object tag-number <-> EQ LDR
] H{
    { +input+ { { f "obj" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ class-hash [
    "end" define-label
    ! Get the tag
    "out" operand "obj" operand tag-mask get AND
    ! Compare with tuple tag number (2).
    "out" operand tuple tag-number CMP
    "out" operand "obj" operand tuple-class-offset <+/-> EQ LDR
    "out" operand dup class-hash-offset <+/-> EQ LDR
    "end" get EQ B
    ! Compare with object tag number (3).
    "out" operand object tag-number CMP
    "out" operand "obj" operand object tag-number <-> EQ LDR
    ! Tag the tag
    "out" operand dup NE %tag-fixnum
    "end" resolve-label
] H{
    { +input+ { { f "obj" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

: userenv ( reg -- )
    #! Load the userenv pointer in a register.
    "userenv" f rot compile-dlsym ;

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

: %set-slot R11 swap cells <+> STR ;

: %store-length
    R12 "n" operand MOV
    R12 1 %set-slot ;

: %fill-array swap 2 + %set-slot ;

\ <tuple> [
    tuple "n" get 2 + cells %allot
    %store-length
    ! Store class
    "class" operand 2 %set-slot
    ! Zero out the rest of the tuple
    "initial" operand f v>operand MOV
    "n" get 1- [ 1+ "initial" operand %fill-array ] each
    "out" get tuple %store-tagged
] H{
    { +input+ { { f "class" } { [ inline-array? ] "n" } } }
    { +scratch+ { { f "out" } { f "initial" } } }
    { +output+ { "out" } }
} define-intrinsic

\ <array> [
    array "n" get 2 + cells %allot
    %store-length
    ! Store initial element
    "n" get [ "initial" operand %fill-array ] each
    "out" get object %store-tagged
] H{
    { +input+ { { [ inline-array? ] "n" } { f "initial" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ <byte-array> [
    byte-array "n" get 2 cells + %allot
    %store-length
    ! Store initial element
    R12 0 MOV
    "n" get cell align cell /i [ R12 %fill-array ] each
    "out" get object %store-tagged
] H{
    { +input+ { { [ inline-array? ] "n" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ <ratio> [
    ratio 3 cells %allot
    "numerator" operand 1 %set-slot
    "denominator" operand 2 %set-slot
    "out" get ratio %store-tagged
] H{
    { +input+ { { f "numerator" } { f "denominator" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ <complex> [
    complex 3 cells %allot
    "real" operand 1 %set-slot
    "imaginary" operand 2 %set-slot
    ! Store tagged ptr in reg
    "out" get complex %store-tagged
] H{
    { +input+ { { f "real" } { f "imaginary" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ <wrapper> [
    wrapper 2 cells %allot
    "obj" operand 1 %set-slot
    ! Store tagged ptr in reg
    "out" get object %store-tagged
] H{
    { +input+ { { f "obj" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

! Alien intrinsics
: %alien-accessor ( quot -- )
    "offset" operand dup %untag-fixnum
    "offset" operand dup "alien" operand ADD
    "value" operand "offset" operand 0 <+> roll call ; inline

: alien-integer-get-template
    H{
        { +input+ {
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { +scratch+ { { f "value" } } }
        { +output+ { "value" } }
        { +clobber+ { "offset" } }
    } ;

: %alien-integer-get ( quot -- )
    %alien-accessor
    "value" operand dup %tag-fixnum ; inline

: alien-integer-set-template
    H{
        { +input+ {
            { f "value" fixnum }
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { +clobber+ { "value" "offset" } }
    } ;

: %alien-integer-set ( quot -- )
    "offset" get "value" get = [
        "value" operand dup %untag-fixnum
    ] unless
    %alien-accessor ; inline

: define-alien-integer-intrinsics ( word get-quot word set-quot -- )
    [ %alien-integer-set ] curry
    alien-integer-set-template
    define-intrinsic
    [ %alien-integer-get ] curry
    alien-integer-get-template
    define-intrinsic ;

\ alien-unsigned-1 [ LDRB ]
\ set-alien-unsigned-1 [ STRB ]
define-alien-integer-intrinsics

: alien-cell-template
    H{
        { +input+ {
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { +scratch+ { { unboxed-alien "value" } } }
        { +output+ { "value" } }
        { +clobber+ { "offset" } }
    } ;

\ alien-cell
[ [ LDR ] %alien-accessor ]
alien-cell-template define-intrinsic

: set-alien-cell-template
    H{
        { +input+ {
            { unboxed-c-ptr "value" pinned-c-ptr }
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { +clobber+ { "offset" } }
    } ;

\ set-alien-cell
[ [ STR ] %alien-accessor ]
set-alien-cell-template define-intrinsic
