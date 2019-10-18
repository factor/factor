! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel cpu.architecture cpu.arm.assembler
cpu.arm.architecture namespaces math sequences
generator generator.registers generator.fixup system layouts
alien ;
IN: cpu.arm.allot

: load-zone-ptr ( reg -- ) "nursery" f rot %alien-global ;

: %allot ( header size -- )
    #! Store a pointer to 'size' bytes allocated from the
    #! nursery in R11
    8 align ! align the size
    R12 load-zone-ptr ! nusery -> r12
    R11 R12 cell <+> LDR ! nursery.here -> r11
    R11 R11 pick ADD ! increment r11
    R11 R12 cell <+> STR ! r11 -> nursery.here
    R11 R11 rot SUB ! old value
    R12 swap type-number tag-fixnum MOV ! compute header
    R12 R11 0 <+> STR ! store header
    ;
    
: %store-tagged ( reg tag -- )
    >r dup fresh-object v>operand R11 r> tag-number ORR ;

: %allot-bignum ( #digits -- )
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    bignum over 3 + cells %allot
    R12 swap 1+ v>operand MOV ! compute the length
    R12 R11 cell <+> STR ! store the length
    ;

: %allot-bignum-signed-1 ( dst src -- )
    #! on entry, reg is a 30-bit quantity sign-extended to
    #! 32-bits.
    #! exits with tagged ptr to bignum in reg.
    [
        "end" define-label
        ! is it zero?
        dup v>operand 0 CMP
        0 >bignum pick EQ load-literal
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
        R12 R11 2 cells <+> STR
        ! store the number
        v>operand R11 3 cells <+> STR
        ! tag the bignum, store it in reg
        bignum %store-tagged
        "end" resolve-label
    ] with-scope ;

M: arm-backend %box-alien ( dst src -- )
    "end" define-label
    dup v>operand 0 CMP
    over v>operand f v>operand EQ MOV
    "end" get EQ B
    alien 4 cells %allot
    ! Store offset
    v>operand R11 3 cells <+> STR
    R12 f v>operand MOV
    ! Store expired slot
    R12 R11 1 cells <+> STR
    ! Store underlying-alien slot
    R12 R11 2 cells <+> STR
    ! Store tagged ptr in reg
    object %store-tagged
    "end" resolve-label ;
