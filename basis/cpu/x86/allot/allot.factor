! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel cpu.architecture cpu.x86.assembler
cpu.x86.architecture kernel.private namespaces math sequences
generic arrays compiler.generator compiler.generator.fixup
compiler.generator.registers system layouts alien locals
compiler.constants ;
IN: cpu.x86.allot

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
