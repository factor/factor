! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler-x86 kernel kernel-internals math
math-internals namespaces sequences words ;
IN: generator

! Type checks
\ tag [
    "in" operand tag-mask AND
    "in" operand tag-bits SHL
] H{
    { +input+ { { f "in" } } }
    { +output+ { "in" } }
} define-intrinsic

\ type [
    #! Intrinstic version of type primitive.
    "header" define-label
    "f" define-label
    "end" define-label
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
    "header" resolve-label
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    "x" operand object-tag CMP
    "f" get JE
    ! The pointer is not equal to 3. Load the object header.
    "obj" operand "x" operand object-tag neg [+] MOV
    ! Mask off header tag, making a fixnum.
    "obj" operand object-tag XOR
    "end" get JMP
    "f" resolve-label
    ! The pointer is equal to 3. Load F_TYPE (9).
    "obj" operand f type tag-bits shift MOV
    "end" resolve-label
] H{
    { +input+ { { f "obj" } } }
    { +scratch+ { { f "x" } { f "y" } } }
    { +output+ { "obj" } }
} define-intrinsic

! Slots
: %untag ( reg -- ) tag-mask bitnot AND ;

: %untag-fixnum ( reg -- ) tag-bits SAR ;

\ slot {
    ! Slot number is literal
    {
        [
            "obj" operand %untag
            ! load slot value
            "obj" operand dup "n" get cells [+] MOV
        ] H{
            { +input+ { { f "obj" } { [ cells ] "n" } } }
            { +output+ { "obj" } }
            { +clobber+ { "obj" "n" } }
        }
    }
    ! Slot number in a register
    {
        [
            "obj" operand %untag
            ! turn tagged fixnum slot # into an offset,
            ! multiple of 4
            "n" operand fixnum>slot@
            ! load slot value
            "obj" operand dup "n" operand [+] MOV
        ] H{
            { +input+ { { f "obj" } { f "n" } } }
            { +output+ { "obj" } }
            { +clobber+ { "obj" "n" } }
        }
    }
} define-intrinsics

: generate-write-barrier ( -- )
    #! Mark the card pointed to by vreg.
    "obj" operand card-bits SHR
    "scratch" operand HEX: ffffffff MOV
    "cards_offset" f rc-absolute-cell rel-dlsym
    "scratch" operand dup [] MOV
    "scratch" operand "obj" operand [+] card-mark OR ;

\ set-slot {
    ! Slot number is literal
    {
        [
            "obj" operand %untag
            ! store new slot value
            "obj" operand "n" get cells [+] "val" operand MOV
            generate-write-barrier
        ] H{
            { +input+ { { f "val" } { f "obj" } { [ cells ] "n" } } }
            { +scratch+ { { f "scratch" } } }
            { +clobber+ { "obj" } }
        }
    }
    ! Slot number in a register
    {
        [
            ! turn tagged fixnum slot # into an offset
            "n" operand fixnum>slot@
            "obj" operand %untag
            ! store new slot value
            "obj" operand "n" operand [+] "val" operand MOV
            generate-write-barrier
        ] H{
            { +input+ { { f "val" } { f "obj" } { f "n" } } }
            { +scratch+ { { f "scratch" } } }
            { +clobber+ { "obj" "n" } }
        }
    }
} define-intrinsics

: char-reg cell 8 = RDI EDI ? ; inline
: char-reg-16 DI ; inline

\ char-slot [
    char-reg PUSH
    "n" operand 2 SHR
    char-reg dup XOR
    "obj" operand "n" operand ADD
    char-reg-16 "obj" operand string-offset [+] MOV
    char-reg tag-bits SHL
    "obj" operand char-reg MOV
    char-reg POP
] H{
    { +input+ { { f "n" } { f "obj" } } }
    { +output+ { "obj" } }
    { +clobber+ { "obj" "n" } }
} define-intrinsic

\ set-char-slot [
    char-reg PUSH
    "val" operand tag-bits SHR
    "slot" operand 2 SHR
    "obj" operand "slot" operand ADD
    char-reg "val" operand MOV
    "obj" operand string-offset [+] char-reg-16 MOV
    char-reg POP
] H{
    { +input+ { { f "val" } { f "slot" } { f "obj" } } }
    { +clobber+ { "val" "slot" "obj" } }
} define-intrinsic

! Fixnums
: fixnum-op ( op hash -- pair )
    >r [ "x" operand "y" operand ] swap add r> 2array ;

: fixnum-value-op ( op -- pair )
    H{
        { +input+ { { f "x" } { [ v>operand ] "y" } } }
        { +output+ { "x" } }
    } fixnum-op ;

: fixnum-register-op ( op -- pair )
    H{
        { +input+ { { f "x" } { f "y" } } }
        { +output+ { "x" } }
    } fixnum-op ;

: define-fixnum-op ( word op -- )
    [ fixnum-value-op ] keep fixnum-register-op
    2array define-intrinsics ;

{
    { fixnum+fast ADD }
    { fixnum-fast SUB }
    { fixnum-bitand AND }
    { fixnum-bitor OR }
    { fixnum-bitxor XOR }
} [
    first2 define-fixnum-op
] each

\ fixnum-bitnot [
    "x" operand NOT
    "x" operand tag-mask XOR
] H{
    { +input+ { { f "x" } } }
    { +output+ { "x" } }
} define-intrinsic

! This has specific register requirements. Inputs are in
! ECX and EAX, and the result is in EDX.
\ fixnum-mod [
    prepare-division
    "y" operand IDIV
] H{
    { +input+ { { 0 "x" } { 1 "y" } } }
    { +scratch+ { { 2 "out" } } }
    { +output+ { "out" } }
} define-intrinsic

: %untag-fixnums ( seq -- )
    [ %untag-fixnum ] unique-operands ;

: simple-overflow ( word -- )
    "end" define-label
    "z" operand "x" operand MOV
    "z" operand "y" operand pick execute
    ! If the previous arithmetic operation overflowed, then we
    ! turn the result into a bignum and leave it in EAX.
    "end" get JNO
    ! There was an overflow. Recompute the original operand.
    { "y" "x" } %untag-fixnums
    "x" operand "y" operand rot execute
    "z" operand "x" operand %allot-bignum-signed-1
    "end" resolve-label ; inline

: simple-overflow-template ( word insn -- )
    [ simple-overflow ] curry H{
        { +input+ { { f "x" } { f "y" } } }
        { +scratch+ { { f "z" } } }
        { +output+ { "z" } }
        { +clobber+ { "x" "y" } }
    } define-intrinsic ;

\ fixnum+ \ ADD simple-overflow-template
\ fixnum- \ SUB simple-overflow-template

: %tag-overflow ( -- )
    #! Tag a cell-size value, where the tagging might posibly
    #! overflow BUT IT MUST NOT EXCEED cell-2 BITS
    "y" operand "x" operand MOV ! Make a copy
    "x" operand 1 tag-bits shift IMUL2 ! Tag it
    "end" get JNO ! Overflow?
    "x" operand "y" operand %allot-bignum-signed-1 ! Yes, box bignum
    ;

: generate-fixnum/mod
    #! The same code is used for fixnum/i and fixnum/mod.
    #! This has specific register
    #! ECX and EAX, and the result is in EDX.
    "end" define-label
    prepare-division
    "y" operand IDIV
    %tag-overflow
    "end" resolve-label ;

\ fixnum/i [ generate-fixnum/mod ] H{
    { +input+ { { 0 "x" } { 1 "y" } } }
    { +scratch+ { { 2 "r" } } }
    { +output+ { "x" } }
    { +clobber+ { "x" "y" } }
} define-intrinsic

\ fixnum/mod [ generate-fixnum/mod ] H{
    { +input+ { { 0 "x" } { 1 "y" } } }
    { +scratch+ { { 2 "r" } } }
    { +output+ { "x" "r" } }
    { +clobber+ { "x" "y" } }
} define-intrinsic

: fixnum-jump ( op inputs -- pair )
    >r [ "x" operand "y" operand CMP ] swap add r> 2array ;

: fixnum-value-jump ( op -- pair )
    { { f "x" } { [ v>operand ] "y" } } fixnum-jump ;

: fixnum-register-jump ( op -- pair )
    { { f "x" } { f "y" } } fixnum-jump ;

: define-fixnum-jump ( word op -- )
    [ fixnum-value-jump ] keep fixnum-register-jump
    2array define-if-intrinsics ;

{
    { fixnum< JL }
    { fixnum<= JLE }
    { fixnum> JG }
    { fixnum>= JGE }
    { eq? JE }
} [
    first2 define-fixnum-jump
] each

\ fixnum>bignum [
    "nonzero" define-label
    "end" define-label
    "x" operand 0 CMP ! is it zero?
    "nonzero" get JNE
    0 >bignum "x" get load-literal ! this is our result
    "end" get JMP
    "nonzero" resolve-label
    "x" operand %untag-fixnum
    "x" operand dup %allot-bignum-signed-1 ! copy it to a bignum
    "end" resolve-label
] H{
    { +input+ { { f "x" } } }
    { +output+ { "x" } }
} define-intrinsic

\ bignum>fixnum [
    "nonzero" define-label
    "positive" define-label
    "end" define-label
    "x" operand %untag
    "y" operand "x" operand cell [+] MOV
     ! if the length is 1, its just the sign and nothing else,
     ! so output 0
    "y" operand 1 tag-bits shift CMP
    "nonzero" get JNE
    "y" operand 0 MOV
    "end" get JMP
    "nonzero" resolve-label
    ! load the value
    "y" operand "x" operand 3 cells [+] MOV
    ! load the sign
    "x" operand "x" operand 2 cells [+] MOV
    ! is the sign negative?
    "x" operand 0 CMP
    "positive" get JE
    "y" operand -1 IMUL2
    "positive" resolve-label
    "y" operand 3 SHL
    "end" resolve-label
] H{
    { +input+ { { f "x" } } }
    { +scratch+ { { f "y" } } }
    { +clobber+ { "x" } }
    { +output+ { "y" } }
} define-intrinsic

! User environment
: %userenv ( -- )
    "x" operand 0 MOV
    "userenv" f rc-absolute-cell rel-dlsym
    "n" operand fixnum>slot@
    "n" operand "x" operand ADD ;

\ getenv [
    %userenv  "n" operand dup [] MOV
] H{
    { +input+ { { f "n" } } }
    { +scratch+ { { f "x" } } }
    { +output+ { "n" } }
} define-intrinsic

\ setenv [
    %userenv  "n" operand [] "val" operand MOV
] H{
    { +input+ { { f "val" } { f "n" } } }
    { +scratch+ { { f "x" } } }
    { +clobber+ { "n" } }
} define-intrinsic
