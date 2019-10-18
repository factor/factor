! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: kernel assembler-ppc kernel-internals namespaces math
sequences generic arrays ;

: load-zone-ptr ( reg -- )
    "nursery" f pick compile-dlsym dup 0 LWZ ;

: %allot ( header size -- )
    #! Store a pointer to 'size' bytes allocated from the
    #! nursery in r11.
    dup maybe-gc
    8 align ! align the size
    12 load-zone-ptr ! nusery -> r12
    11 12 cell LWZ ! nursery.here -> r11
    11 11 pick ADDI ! increment r11
    11 12 cell STW ! r11 -> nursery.here
    11 11 rot SUBI ! old value
    type-number tag-header 12 LI ! compute header
    12 11 0 STW ! store header
    ;

: %allot-float ( reg -- )
    #! exits with tagged ptr to object in r12, untagged in r11
    float 16 %allot
    11 8 STFD
    12 11 float tag-number ORI ;

M: float-regs (%replace)
    drop
    swap v>operand %allot-float
    12 swap loc>operand STW ;

: %move-float>int ( dst src -- )
    [ v>operand ] 2apply %allot-float 12 MR ;

: %allot-bignum ( #digits -- )
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    bignum over 3 + cells %allot
    1+ v>operand 12 LI ! compute the length
    12 11 cell STW ! store the length
    ;

: %allot-bignum-signed-1 ( reg -- )
    #! on entry, reg is a 30-bit quantity sign-extended to
    #! 32-bits.
    #! exits with tagged ptr to bignum in reg
    [
        { "end" "non-zero" "pos" "store" } [ define-label ] each
        ! is it zero?
        0 over 0 CMPI
        "non-zero" get BNE
        0 >bignum over load-indirect
        "end" get B
        ! it is non-zero
        "non-zero" resolve-label
        1 %allot-bignum
        ! is the fixnum negative?
        0 over 0 CMPI
        "pos" get BGE
        1 12 LI
        ! store negative sign
        12 11 2 cells STW
        ! negate fixnum
        dup dup -1 MULI
        "store" get B
        "pos" resolve-label
        0 12 LI
        ! store positive sign
        12 11 2 cells STW
        "store" resolve-label
        ! store the number
        dup 11 3 cells STW
        ! tag the bignum, store it in reg
        11 bignum tag-number ORI
        "end" resolve-label
    ] with-scope ;

: %allot-tuple ( reg class n -- )
    tuple over 2 + cells %allot
    ! Store length
    dup v>operand 12 LI
    12 11 cell STW
    ! Store class
    swap 11 2 cells STW
    ! Zero out the rest of the tuple
    f v>operand 12 LI
    1- [ 12 11 rot 3 + cells STW ] each
    ! Store tagged ptr in reg
    11 object tag-number ORI ;

: %allot-array ( reg initial n -- )
    array over 2 + cells %allot
    ! Store length
    dup v>operand 12 LI
    12 11 cell STW
    ! Store initial element
    [ 11 swap 2 + cells STW ] each-with
    ! Store tagged ptr in reg
    11 object tag-number ORI ;
