! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel cpu.architecture cpu.arm.assembler
cpu.arm.architecture namespaces math math.functions sequences
generator generator.registers generator.fixup system layouts
alien ;
IN: cpu.arm.allot

: load-zone-ptr ( reg -- ) "nursery" f rot %alien-global ;

: object@ "allot-tmp" operand swap cells <+> ;

: %allot ( header size -- )
    #! Store a pointer to 'size' bytes allocated from the
    #! nursery in allot-tmp.
    8 align ! align the size
    R12 load-zone-ptr ! nusery -> r12
    "allot-tmp" operand R12 cell <+> LDR ! nursery.here -> allot-tmp
    "allot-tmp" operand dup pick ADD ! increment allot-tmp
    "allot-tmp" operand R12 cell <+> STR ! allot-tmp -> nursery.here
    "allot-tmp" operand dup rot SUB ! old value
    R12 swap type-number tag-header MOV ! compute header
    R12 0 object@ STR ! store header
    ;
    
: %tag-allot ( tag -- )
    "allot-tmp" operand dup rot tag-number ORR
    "allot-tmp" get fresh-object ;

: %allot-bignum ( #digits -- )
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    bignum over 3 + cells %allot
    R12 swap 1+ v>operand MOV ! compute the length
    R12 1 object@ STR ! store the length
    ;

: %allot-bignum-signed-1 ( reg -- )
    #! on entry, reg is a 30-bit quantity sign-extended to
    #! 32-bits.
    #! exits with tagged ptr to bignum in allot-tmp.
    [
        "end" define-label
        ! is it zero?
        dup v>operand 0 CMP
        0 >bignum "allot-tmp" operand EQ load-indirect
        "end" get EQ B
        ! ! it is non-zero
        1 %allot-bignum
        ! is the fixnum negative?
        dup v>operand 0 CMP
        ! negative sign
        R12 1 LT MOV
        ! negate fixnum
        dup v>operand dup 0 LT RSB
        ! positive sign
        R12 0 GE MOV
        ! store sign
        R12 2 object@ STR
        ! store the number
        v>operand 3 object@ STR
        ! tag the bignum, store it in reg
        bignum %tag-allot
        "end" resolve-label
    ] with-scope ;

: %allot-alien ( ptr -- )
    #! Tagged pointer to alien is in allot-tmp on exit.
    [
        "temp" set
        "end" define-label
        "temp" operand 0 CMP
        "allot-tmp" operand f v>operand EQ MOV
        "end" get EQ B
        alien 4 cells %allot
        "temp" operand 2 object@ STR
        "temp" operand f v>operand MOV
        "temp" operand 1 object@ STR
        "temp" operand 0 MOV
        "temp" operand 3 object@ STR
        ! Store tagged ptr in reg
        object %tag-allot
        "end" resolve-label
    ] with-scope ;
