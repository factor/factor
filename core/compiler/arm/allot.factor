! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: kernel assembler-arm namespaces math sequences ;

: load-zone-ptr ( reg -- )
    "nursery" f pick %alien-global
    dup 0 <+> LDR ;

: %allot ( header size -- )
    #! Store a pointer to 'size' bytes allocated from the
    #! nursery in allot-tmp.
    dup maybe-gc
    8 align ! align the size
    R12 load-zone-ptr ! nusery -> r12
    "allot-tmp" operand R12 cell <+> LDR ! nursery.here -> allot-tmp
    "allot-tmp" operand dup pick ADD ! increment allot-tmp
    "allot-tmp" operand R12 cell <+> STR ! allot-tmp -> nursery.here
    "allot-tmp" operand dup rot SUB ! old value
    R12 swap type-number tag-header MOV ! compute header
    R12 "allot-tmp" operand 0 <+> STR ! store header
    ;
    
: %tag-allot ( tag -- )
    "allot-tmp" operand dup rot tag-number ORR ;

: %allot-bignum ( #digits -- )
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    bignum over 3 + cells %allot
    R12 swap 1+ v>operand MOV ! compute the length
    R12 "allot-tmp" operand cell <+> STR ! store the length
    ;

: %allot-bignum-signed-1 ( reg -- )
    #! on entry, reg is a 30-bit quantity sign-extended to
    #! 32-bits.
    #! exits with tagged ptr to bignum in allot-tmp.
    [
        "end" define-label
        ! is it zero?
        dup 0 CMP
        0 >bignum "allot-tmp" operand EQ load-indirect
        "end" get EQ B
        ! ! it is non-zero
        1 %allot-bignum
        ! is the fixnum negative?
        dup 0 CMP
        ! negative sign
        R12 1 LT MOV
        ! negate fixnum
        dup dup 0 LT RSB
        ! positive sign
        R12 0 GE MOV
        ! store sign
        R12 "allot-tmp" operand 2 cells <+> STR
        ! store the number
        "allot-tmp" operand 3 cells <+> STR
        ! tag the bignum, store it in reg
        bignum %tag-allot
        "end" resolve-label
    ] with-scope ;
