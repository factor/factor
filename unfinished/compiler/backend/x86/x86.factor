! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays alien.accessors
compiler.backend kernel kernel.private math memory namespaces
make sequences words system layouts combinators math.order
math.private alien alien.c-types slots.private cpu.x86
cpu.x86.private locals compiler.backend compiler.codegen.fixup
compiler.constants compiler.intrinsics compiler.cfg.builder
compiler.cfg.registers compiler.cfg.stacks
compiler.cfg.templates compiler.codegen ;
IN: compiler.backend.x86

HOOK: ds-reg cpu ( -- reg )
HOOK: rs-reg cpu ( -- reg )
HOOK: stack-reg cpu ( -- reg )
HOOK: stack-save-reg cpu ( -- reg )

: stack@ ( n -- op ) stack-reg swap [+] ;

: reg-stack ( n reg -- op ) swap cells neg [+] ;

GENERIC: loc>operand ( loc -- operand )

M: ds-loc loc>operand n>> ds-reg reg-stack ;
M: rs-loc loc>operand n>> rs-reg reg-stack ;

M: int-regs %save-param-reg drop >r stack@ r> MOV ;
M: int-regs %load-param-reg drop swap stack@ MOV ;

GENERIC: MOVSS/D ( dst src reg-class -- )

M: single-float-regs MOVSS/D drop MOVSS ;
M: double-float-regs MOVSS/D drop MOVSD ;

M: float-regs %save-param-reg >r >r stack@ r> r> MOVSS/D ;
M: float-regs %load-param-reg >r swap stack@ r> MOVSS/D ;

GENERIC: push-return-reg ( reg-class -- )
GENERIC: load-return-reg ( stack@ reg-class -- )
GENERIC: store-return-reg ( stack@ reg-class -- )

! Only used by inline allocation
HOOK: temp-reg-1 cpu ( -- reg )
HOOK: temp-reg-2 cpu ( -- reg )

HOOK: fixnum>slot@ cpu ( op -- )

HOOK: prepare-division cpu ( -- )

M: f load-literal
    \ f tag-number MOV drop ;

M: fixnum load-literal
    swap tag-fixnum MOV ;

M: x86 stack-frame ( n -- i )
    3 cells + 16 align cell - ;

: factor-area-size ( -- n ) 4 cells ;

M: x86 %prologue ( n -- )
    temp-reg-1 0 MOV rc-absolute-cell rel-this
    dup cell + PUSH
    temp-reg-1 PUSH
    stack-reg swap 2 cells - SUB ;

M: x86 %epilogue ( n -- )
    stack-reg swap ADD ;

HOOK: %alien-global cpu ( symbol dll register -- )

M: x86 %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    "stack_chain" f temp-reg-1 %alien-global
    temp-reg-1 [] stack-reg MOV
    temp-reg-1 [] cell SUB
    temp-reg-1 2 cells [+] ds-reg MOV
    temp-reg-1 3 cells [+] rs-reg MOV ;

M: x86 %call ( label -- ) CALL ;

M: x86 %jump-label ( label -- ) JMP ;

M: x86 %jump-f ( label vreg -- ) \ f tag-number CMP JE ;

M: x86 %jump-t ( label vreg -- ) \ f tag-number CMP JNE ;

: code-alignment ( -- n )
    building get length dup cell align swap - ;

: align-code ( n -- )
    0 <repetition> % ;

M:: x86 %dispatch ( src temp -- )
    ! Load jump table base. We use a temporary register
    ! since on AMD64 we have to load a 64-bit immediate. On
    ! x86, this is redundant.
    ! Untag and multiply to get a jump table offset
    src fixnum>slot@
    ! Add jump table base
    temp HEX: ffffffff MOV rc-absolute-cell rel-here
    src temp ADD
    src HEX: 7f [+] JMP
    ! Fix up the displacement above
    code-alignment dup bootstrap-cell 8 = 15 9 ? +
    building get dup pop* push
    align-code ;

M: x86 %dispatch-label ( word -- )
    0 cell, rc-absolute-cell rel-word ;

M: x86 %peek loc>operand MOV ;

M: x86 %replace loc>operand swap MOV ;

: (%inc) ( n reg -- ) swap cells dup 0 > [ ADD ] [ neg SUB ] if ;

M: x86 %inc-d ( n -- ) ds-reg (%inc) ;

M: x86 %inc-r ( n -- ) rs-reg (%inc) ;

M: x86 fp-shadows-int? ( -- ? ) f ;

M: x86 value-structs? t ;

M: x86 small-enough? ( n -- ? )
    HEX: -80000000 HEX: 7fffffff between? ;

: %untag ( reg -- ) tag-mask get bitnot AND ;

: %untag-fixnum ( reg -- ) tag-bits get SAR ;

: %tag-fixnum ( reg -- ) tag-bits get SHL ;

: temp@ ( n -- op ) stack-reg \ stack-frame get rot - [+] ;

M: x86 %return ( -- ) 0 %unwind ;

! Alien intrinsics
M: x86 %unbox-byte-array ( dst src -- )
    byte-array-offset [+] LEA ;

M: x86 %unbox-alien ( dst src -- )
    alien-offset [+] MOV ;

M: x86 %unbox-f ( dst src -- )
    drop 0 MOV ;

M: x86 %unbox-any-c-ptr ( dst src -- )
    { "is-byte-array" "end" "start" } [ define-label ] each
    ! Address is computed in ds-reg
    ds-reg PUSH
    ds-reg 0 MOV
    ! Object is stored in ds-reg
    rs-reg PUSH
    rs-reg swap MOV
    ! We come back here with displaced aliens
    "start" resolve-label
    ! Is the object f?
    rs-reg \ f tag-number CMP
    "end" get JE
    ! Is the object an alien?
    rs-reg header-offset [+] alien type-number tag-fixnum CMP
    "is-byte-array" get JNE
    ! If so, load the offset and add it to the address
    ds-reg rs-reg alien-offset [+] ADD
    ! Now recurse on the underlying alien
    rs-reg rs-reg underlying-alien-offset [+] MOV
    "start" get JMP
    "is-byte-array" resolve-label
    ! Add byte array address to address being computed
    ds-reg rs-reg ADD
    ! Add an offset to start of byte array's data
    ds-reg byte-array-offset ADD
    "end" resolve-label
    ! Done, store address in destination register
    ds-reg MOV
    ! Restore rs-reg
    rs-reg POP
    ! Restore ds-reg
    ds-reg POP ;

M:: x86 %write-barrier ( src temp -- )
    #! Mark the card pointed to by vreg.
    ! Mark the card
    src card-bits SHR
    "cards_offset" f temp %alien-global
    temp temp [+] card-mark <byte> MOV

    ! Mark the card deck
    temp deck-bits card-bits - SHR
    "decks_offset" f temp %alien-global
    temp temp [+] card-mark <byte> MOV ;

: load-zone-ptr ( reg -- )
    #! Load pointer to start of zone array
    0 MOV "nursery" f rc-absolute-cell rel-dlsym ;

: load-allot-ptr ( temp -- )
    [ load-zone-ptr ] [ PUSH ] [ dup cell [+] MOV ] tri ;

: inc-allot-ptr ( n temp -- )
    [ POP ] [ cell [+] swap 8 align ADD ] bi ;

: store-header ( temp type -- )
    [ 0 [+] ] [ type-number tag-fixnum ] bi* MOV ;

: store-tagged ( dst temp tag -- )
    dupd tag-number OR MOV ;

M:: x86 %allot ( dst size type tag temp -- )
    temp load-allot-ptr
    temp type store-header
    temp size inc-allot-ptr
    dst temp store-tagged ;

M: x86 %gc ( -- )
    "end" define-label
    temp-reg-1 load-zone-ptr
    temp-reg-2 temp-reg-1 cell [+] MOV
    temp-reg-2 1024 ADD
    temp-reg-1 temp-reg-1 3 cells [+] MOV
    temp-reg-2 temp-reg-1 CMP
    "end" get JLE
    %prepare-alien-invoke
    "minor_gc" f %alien-invoke
    "end" resolve-label ;

: bignum@ ( reg n -- op ) cells bignum tag-number - [+] ;

:: %allot-bignum-signed-1 ( dst src temp -- )
    #! on entry, inreg is a signed 32-bit quantity
    #! exits with tagged ptr to bignum in outreg
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    [
        { "end" "nonzero" "positive" "store" } [ define-label ] each
        src 0 CMP ! is it zero?
        "nonzero" get JNE
        ! Use cached zero value
        0 >bignum dst load-indirect
        "end" get JMP
        "nonzero" resolve-label
        ! Allocate a bignum
        dst 4 cells bignum bignum temp %allot
        ! Write length
        dst 1 bignum@ 2 MOV
        ! Test sign
        src 0 CMP
        "positive" get JGE
        dst 2 bignum@ 1 MOV ! negative sign
        src NEG
        "store" get JMP
        "positive" resolve-label
        dst 2 bignum@ 0 MOV ! positive sign
        "store" resolve-label
        dst 3 bignum@ src MOV
        "end" resolve-label
    ] with-scope ;

: alien@ ( reg n -- op ) cells object tag-number - [+] ;

M:: x86 %box-alien ( dst src temp -- )
    [
        { "end" "f" } [ define-label ] each
        src 0 CMP
        "f" get JE
        dst 4 cells alien object temp %allot
        dst 1 alien@ \ f tag-number MOV
        dst 2 alien@ \ f tag-number MOV
        ! Store src in alien-offset slot
        dst 3 alien@ src MOV
        "end" get JMP
        "f" resolve-label
        \ f tag-number MOV
        "end" resolve-label
    ] with-scope ;

! Type checks
\ tag [
    "in" operand tag-mask get AND
    "in" operand %tag-fixnum
] T{ template
    { input { { f "in" } } }
    { output { "in" } }
} define-intrinsic

! Slots
: %slot-literal-known-tag ( -- op )
    "obj" operand
    "n" get cells
    "obj" operand-tag - [+] ;

: %slot-literal-any-tag ( -- op )
    "obj" operand %untag
    "obj" operand "n" get cells [+] ;

: %slot-any ( -- op )
    "obj" operand %untag
    "n" operand fixnum>slot@
    "obj" operand "n" operand [+] ;

\ slot {
    ! Slot number is literal and the tag is known
    {
        [ "val" operand %slot-literal-known-tag MOV ] T{ template
            { input { { f "obj" known-tag } { small-slot "n" } } }
            { scratch { { f "val" } } }
            { output { "val" } }
        }
    }
    ! Slot number is literal
    {
        [ "obj" operand %slot-literal-any-tag MOV ] T{ template
            { input { { f "obj" } { small-slot "n" } } }
            { output { "obj" } }
        }
    }
    ! Slot number in a register
    {
        [ "obj" operand %slot-any MOV ] T{ template
            { input { { f "obj" } { f "n" } } }
            { output { "obj" } }
            { clobber { "n" } }
        }
    }
} define-intrinsics

\ (set-slot) {
    ! Slot number is literal and the tag is known
    {
        [ %slot-literal-known-tag "val" operand MOV ] T{ template
            { input { { f "val" } { f "obj" known-tag } { small-slot "n" } } }
            { scratch { { f "scratch" } } }
            { clobber { "obj" } }
        }
    }
    ! Slot number is literal
    {
        [ %slot-literal-any-tag "val" operand MOV ] T{ template
            { input { { f "val" } { f "obj" } { small-slot "n" } } }
            { scratch { { f "scratch" } } }
            { clobber { "obj" } }
        }
    }
    ! Slot number in a register
    {
        [ %slot-any "val" operand MOV ] T{ template
            { input { { f "val" } { f "obj" } { f "n" } } }
            { scratch { { f "scratch" } } }
            { clobber { "obj" "n" } }
        }
    }
} define-intrinsics

! Sometimes, we need to do stuff with operands which are
! less than the word size. Instead of teaching the register
! allocator about the different sized registers, with all
! the complexity this entails, we just push/pop a register
! which is guaranteed to be unused (the tempreg)
: small-reg cell 8 = RBX EBX ? ; inline
: small-reg-8 BL ; inline
: small-reg-16 BX ; inline
: small-reg-32 EBX ; inline

! Fixnums
: fixnum-op ( op hash -- pair )
    >r [ "x" operand "y" operand ] swap suffix r> 2array ;

: fixnum-value-op ( op -- pair )
    T{ template
        { input { { f "x" } { small-tagged "y" } } }
        { output { "x" } }
    } fixnum-op ;

: fixnum-register-op ( op -- pair )
    T{ template
        { input { { f "x" } { f "y" } } }
        { output { "x" } }
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
    "x" operand tag-mask get XOR
] T{ template
    { input { { f "x" } } }
    { output { "x" } }
} define-intrinsic

\ fixnum*fast {
    {
        [
            "x" operand "y" get IMUL2
        ] T{ template
            { input { { f "x" } { [ small-tagged? ] "y" } } }
            { output { "x" } }
        }
    } {
        [
            "out" operand "x" operand MOV
            "out" operand %untag-fixnum
            "y" operand "out" operand IMUL2
        ] T{ template
            { input { { f "x" } { f "y" } } }
            { scratch { { f "out" } } }
            { output { "out" } }
        }
    }
} define-intrinsics

: %untag-fixnums ( seq -- )
    [ %untag-fixnum ] unique-operands ;

\ fixnum-shift-fast [
    "x" operand "y" get
    dup 0 < [ neg SAR ] [ SHL ] if
    ! Mask off low bits
    "x" operand %untag
] T{ template
    { input { { f "x" } { [ ] "y" } } }
    { output { "x" } }
} define-intrinsic

: overflow-check ( word -- )
    "end" define-label
    "z" operand "x" operand MOV
    "z" operand "y" operand pick execute
    ! If the previous arithmetic operation overflowed, then we
    ! turn the result into a bignum and leave it in EAX.
    "end" get JNO
    ! There was an overflow. Recompute the original operand.
    { "y" "x" } %untag-fixnums
    "x" operand "y" operand rot execute
    "z" operand "x" operand "y" operand %allot-bignum-signed-1
    "end" resolve-label ; inline

: overflow-template ( word insn -- )
    [ overflow-check ] curry T{ template
        { input { { f "x" } { f "y" } } }
        { scratch { { f "z" } } }
        { output { "z" } }
        { clobber { "x" "y" } }
        { gc t }
    } define-intrinsic ;

\ fixnum+ \ ADD overflow-template
\ fixnum- \ SUB overflow-template

: fixnum-jump ( op inputs -- pair )
    >r [ "x" operand "y" operand CMP ] swap suffix r> 2array ;

: fixnum-value-jump ( op -- pair )
    { { f "x" } { [ small-tagged? ] "y" } } fixnum-jump ;

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
    "x" operand %untag-fixnum
    "x" operand dup "scratch" operand %allot-bignum-signed-1
] T{ template
    { input { { f "x" } } }
    { scratch { { f "scratch" } } }
    { output { "x" } }
    { gc t }
} define-intrinsic

\ bignum>fixnum [
    "nonzero" define-label
    "positive" define-label
    "end" define-label
    "x" operand %untag
    "y" operand "x" operand cell [+] MOV
     ! if the length is 1, its just the sign and nothing else,
     ! so output 0
    "y" operand 1 tag-fixnum CMP
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
] T{ template
    { input { { f "x" } } }
    { scratch { { f "y" } } }
    { clobber { "x" } }
    { output { "y" } }
} define-intrinsic

! User environment
: %userenv ( -- )
    "x" operand 0 MOV
    "userenv" f rc-absolute-cell rel-dlsym
    "n" operand fixnum>slot@
    "n" operand "x" operand ADD ;

\ getenv [
    %userenv  "n" operand dup [] MOV
] T{ template
    { input { { f "n" } } }
    { scratch { { f "x" } } }
    { output { "n" } }
} define-intrinsic

\ setenv [
    %userenv  "n" operand [] "val" operand MOV
] T{ template
    { input { { f "val" } { f "n" } } }
    { scratch { { f "x" } } }
    { clobber { "n" } }
} define-intrinsic

! Alien intrinsics
: %alien-accessor ( quot -- )
    "offset" operand %untag-fixnum
    "offset" operand "alien" operand ADD
    "offset" operand [] swap call ; inline

: %alien-integer-get ( quot reg -- )
    small-reg PUSH
    swap %alien-accessor
    "value" operand small-reg MOV
    "value" operand %tag-fixnum
    small-reg POP ; inline

: alien-integer-get-template
    T{ template
        { input {
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { scratch { { f "value" } } }
        { output { "value" } }
        { clobber { "offset" } }
    } ;

: define-getter ( word quot reg -- )
    [ %alien-integer-get ] 2curry
    alien-integer-get-template
    define-intrinsic ;

: define-unsigned-getter ( word reg -- )
    [ small-reg dup XOR MOV ] swap define-getter ;

: define-signed-getter ( word reg -- )
    [ [ >r MOV small-reg r> MOVSX ] curry ] keep define-getter ;

: %alien-integer-set ( quot reg -- )
    small-reg PUSH
    small-reg "value" operand MOV
    small-reg %untag-fixnum
    swap %alien-accessor
    small-reg POP ; inline

: alien-integer-set-template
    T{ template
        { input {
            { f "value" fixnum }
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { clobber { "value" "offset" } }
    } ;

: define-setter ( word reg -- )
    [ swap MOV ] swap
    [ %alien-integer-set ] 2curry
    alien-integer-set-template
    define-intrinsic ;

\ alien-unsigned-1 small-reg-8 define-unsigned-getter
\ set-alien-unsigned-1 small-reg-8 define-setter

\ alien-signed-1 small-reg-8 define-signed-getter
\ set-alien-signed-1 small-reg-8 define-setter

\ alien-unsigned-2 small-reg-16 define-unsigned-getter
\ set-alien-unsigned-2 small-reg-16 define-setter

\ alien-signed-2 small-reg-16 define-signed-getter
\ set-alien-signed-2 small-reg-16 define-setter

\ alien-cell [
    "value" operand [ MOV ] %alien-accessor
] T{ template
    { input {
        { unboxed-c-ptr "alien" c-ptr }
        { f "offset" fixnum }
    } }
    { scratch { { unboxed-alien "value" } } }
    { output { "value" } }
    { clobber { "offset" } }
} define-intrinsic

\ set-alien-cell [
    "value" operand [ swap MOV ] %alien-accessor
] T{ template
    { input {
        { unboxed-c-ptr "value" pinned-c-ptr }
        { unboxed-c-ptr "alien" c-ptr }
        { f "offset" fixnum }
    } }
    { clobber { "offset" } }
} define-intrinsic
