! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words kernel.private namespaces math math.private
sequences generic arrays system layouts alien locals
cpu.architecture cpu.x86.assembler cpu.x86.architecture
compiler.constants compiler.cfg.templates compiler.cfg.builder
compiler.codegen compiler.codegen.fixup ;
IN: cpu.x86.allot

M:: x86 %write-barrier ( src card# table -- )
    #! Mark the card pointed to by vreg.
    ! Mark the card
    card# src MOV
    card# card-bits SHR
    "cards_offset" f table %alien-global
    table card# [+] card-mark <byte> MOV

    ! Mark the card deck
    card# deck-bits card-bits - SHR
    "decks_offset" f table %alien-global
    table card# [+] card-mark <byte> MOV ;

: load-zone-ptr ( reg -- )
    #! Load pointer to start of zone array
    0 MOV "nursery" f rc-absolute-cell rel-dlsym ;

: load-allot-ptr ( nursery-ptr allot-ptr -- )
    [ drop load-zone-ptr ] [ swap cell [+] MOV ] 2bi ;

: inc-allot-ptr ( nursery-ptr n -- )
    [ cell [+] ] dip 8 align ADD ;

: store-header ( temp type -- )
    [ [] ] [ type-number tag-fixnum ] bi* MOV ;

: store-tagged ( dst tag -- )
    tag-number OR ;

M:: x86 %allot ( dst size type tag nursery-ptr -- )
    nursery-ptr dst load-allot-ptr
    dst type store-header
    dst tag store-tagged
    nursery-ptr size inc-allot-ptr ;

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
        dst 1 bignum@ 2 tag-fixnum MOV
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

: overflow-check ( word -- )
    "end" define-label
    "z" operand "x" operand MOV
    "z" operand "y" operand pick execute
    ! If the previous arithmetic operation overflowed, then we
    ! turn the result into a bignum and leave it in EAX.
    "end" get JNO
    ! There was an overflow. Recompute the original operand.
    { "y" "x" } [ %untag-fixnum ] unique-operands
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

\ fixnum>bignum [
    "x" operand %untag-fixnum
    "y" operand "x" operand "scratch" operand %allot-bignum-signed-1
] T{ template
    { input { { f "x" } } }
    { scratch { { f "y" } { f "scratch" } } }
    { output { "y" } }
    { clobber { "x" } }
    { gc t }
} define-intrinsic
