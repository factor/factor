! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler kernel kernel-internals math
math-internals namespaces sequences words ;
IN: compiler

! Type checks
\ tag [
    "in" operand tag-mask AND
    "in" operand tag-bits SHL
] H{
    { +input { { f "in" } } }
    { +output { "in" } }
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
    "header" get resolve-label
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    "x" operand object-tag CMP
    "f" get JE
    ! The pointer is not equal to 3. Load the object header.
    "obj" operand "x" operand object-tag neg [+] MOV
    ! Mask off header tag, making a fixnum.
    "obj" operand object-tag XOR
    "end" get JMP
    "f" get resolve-label
    ! The pointer is equal to 3. Load F_TYPE (9).
    "obj" operand f type tag-bits shift MOV
    "end" get resolve-label
] H{
    { +input { { f "obj" } } }
    { +scratch { { f "x" } { f "y" } } }
    { +output { "obj" } }
} define-intrinsic

! Slots
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
    "slot" operand "obj" operand ADD
    ! store new slot value
    "slot" operand [] "val" operand MOV
    generate-write-barrier
] H{
    { +input { { f "val" } { f "obj" } { f "slot" } } }
    { +clobber { "obj" "slot" } }
} define-intrinsic

: char-reg cell 8 = RBX EBX ? ; inline
: char-reg-16 BX ; inline

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
    { +input { { f "n" } { f "obj" } } }
    { +output { "obj" } }
    { +clobber { "n" } }
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
    { +input { { f "val" } { f "slot" } { f "obj" } } }
    { +clobber { "val" "slot" "obj" } }
} define-intrinsic

! Fixnums
: define-fixnum-op ( word op -- )
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
    first2 define-fixnum-op
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
    "y" operand IDIV
] H{
    { +input { { 0 "x" } { 1 "y" } } }
    { +scratch { { 2 "out" } } }
    { +output { "out" } }
} define-intrinsic

: ?MOV ( dst src -- ) 2dup = [ 2drop ] [ MOV ] if ;

: unique-operands ( operands quot -- )
    >r [ operand ] map prune r> each ; inline

: simple-overflow ( word -- )
    finalize-contents
    "z" operand "x" operand MOV
    "z" operand "y" operand pick execute
    ! If the previous arithmetic operation overflowed, then we
    ! turn the result into a bignum and leave it in EAX.
    "end" define-label
    "end" get JNO
    ! There was an overflow. Recompute the original operand.
    { "y" "x" } [ tag-bits SAR ] unique-operands
    "x" operand "y" operand rot execute
    "s48_long_to_bignum" f "x" operand 1array compile-c-call*
    ! An untagged pointer to the bignum is now in EAX; tag it
    T{ int-regs } return-reg bignum-tag OR
    "z" operand T{ int-regs } return-reg ?MOV
    "end" get resolve-label ; inline

: simple-overflow-template ( word insn -- )
    [ simple-overflow ] curry H{
        { +input { { f "x" } { f "y" } } }
        { +scratch { { f "z" } } }
        { +output { "z" } }
        { +clobber { "x" "y" } }
    } define-intrinsic ;

\ fixnum+ \ ADD simple-overflow-template
\ fixnum- \ SUB simple-overflow-template

\ fixnum* [
    finalize-contents
    "y" operand tag-bits SAR
    "y" operand IMUL
    "end" define-label
    "end" get JNO
    "s48_fixnum_pair_to_bignum" f
    "x" operand remainder-reg 2array compile-c-call*
    ! now we have to shift it by three bits to remove the second
    ! tag
    "s48_bignum_arithmetic_shift" f
    "x" operand tag-bits neg 2array compile-c-call*
    ! an untagged pointer to the bignum is now in EAX; tag it
    T{ int-regs } return-reg bignum-tag OR
    "end" get resolve-label
] H{
    { +input { { 0 "x" } { 1 "y" } } }
    { +output { "x" } }
} define-intrinsic

: generate-fixnum/mod
    #! The same code is used for fixnum/i and fixnum/mod.
    #! This has specific register
    #! ECX and EAX, and the result is in EDX.
    "end" define-label
    prepare-division
    "y" operand IDIV
    ! Make a copy since following shift is destructive
    "y" operand "x" operand MOV
    ! Tag the value, since division cancelled tags from both
    ! inputs
    "x" operand 1 tag-bits shift IMUL2
    ! Did it overflow?
    "end" get JNO
    ! There was an overflow, so make ECX into a bignum. we must
    ! save EDX since its volatile.
    remainder-reg PUSH
    ! Align the stack -- only needed on Mac OS X
    stack-reg 16 cell - SUB
    "s48_long_to_bignum" f
    "y" operand 1array compile-c-call*
    ! An untagged pointer to the bignum is now in EAX; tag it
    T{ int-regs } return-reg bignum-tag OR
    ! Align the stack -- only needed on Mac OS X
    stack-reg 16 cell - ADD
    ! the remainder is now in EDX
    remainder-reg POP
    "end" get resolve-label ;

\ fixnum/i [ generate-fixnum/mod ] H{
    { +input { { 0 "x" } { 1 "y" } } }
    { +scratch { { 2 "out" } } }
    { +output { "x" } }
    { +clobber { "x" "y" } }
} define-intrinsic

\ fixnum/mod [ generate-fixnum/mod ] H{
    { +input { { 0 "x" } { 1 "y" } } }
    { +scratch { { 2 "out" } } }
    { +output { "x" "out" } }
    { +clobber { "x" "y" } }
} define-intrinsic

: define-fixnum-jump ( word op -- )
    [ end-basic-block "x" operand "y" operand CMP ] swap add
    H{ { +input { { f "x" } { f "y" } } } } define-if-intrinsic ;

{
    { fixnum< JL }
    { fixnum<= JLE }
    { fixnum> JG }
    { fixnum>= JGE }
    { eq? JE }
} [
    first2 define-fixnum-jump
] each

! User environment
: %userenv ( -- )
    "x" operand "userenv" f [ dlsym MOV ] 2keep
    rel-absolute-cell rel-dlsym
    "n" operand fixnum>slot@
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
