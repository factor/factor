! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: kernel assembler kernel-internals namespaces math ;

: load-zone-ptr ( reg -- )
    "generations" f pick compile-dlsym dup 0 LWZ ;

: %allot ( header size -- )
    #! Store a pointer to 'size' bytes allocated from the
    #! nursery in r11.
    8 align ! align the size
    12 load-zone-ptr ! nusery -> r12
    11 12 cell LWZ ! nursery.here -> r11
    11 11 pick ADDI ! increment r11
    11 12 cell STW ! r11 -> nursery.here
    11 11 rot SUBI ! old value
    tag-header 12 LI ! compute header
    12 11 0 STW ! store header
    ;

: %allot-float ( reg -- )
    #! exits with tagged ptr to object in r12, untagged in r11
    float-tag 16 %allot
    11 8 STFD
    11 12 float-tag ORI ;

M: float-regs (%replace)
    drop
    swap v>operand %allot-float
    12 swap loc>operand STW ;

: %allot-bignum ( #digits -- )
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    bignum-tag over 3 + cells %allot
    1+ tag-bits shift 12 LI ! compute the length
    12 11 cell STW ! store the length
    ;

: %allot-bignum-signed-1 ( reg -- )
    #! on entry, reg is a 30-bit quantity sign-extended to
    #! 32-bits.
    #! exits with tagged ptr to bignum in reg
    [
        "end" define-label
        "pos" define-label
        1 %allot-bignum
        0 over 0 CMPI ! is the fixnum negative?
        "pos" get BGE
        1 12 LI
        12 11 2 cells STW ! store negative sign
        dup dup -1 MULI ! negate fixnum
        "end" get B
        "pos" resolve-label
        0 12 LI
        12 11 2 cells STW ! store positive sign
        "end" resolve-label
        dup 11 3 cells STW ! store the number
        11 swap bignum-tag ORI ! tag the bignum, store it in reg
    ] with-scope ;

: %allot-bignum-signed-2 ( reg1 reg2 -- )
    #! this word has some hairy restrictions; its really only
    #! intended to be used by fixnum*.
    #! - reg1 and reg2 together form a 60-bit signed quantity
    #!   (product of two 29-bit fixnums cannot exceed this)
    #! - the quantity must be non-zero
    #!   (if the product of two fixnums is zero, there's no
    #!   overflow so this word won't be called in that case)
    #! exits with tagged ptr to bignum in reg1
    [
        "end" define-label
        "pos" define-label
        2 %allot-bignum
        0 pick 0 CMPI ! is the 60-bit quantity negative?
        "pos" get BGE
        1 12 LI
        12 11 2 cells STW ! store negative sign
        over dup NOT ! negate 60-bit quanity
        dup dup -1 MULI
        "end" get B
        "pos" resolve-label
        0 12 LI
        12 11 2 cells STW ! store positive sign
        "end" resolve-label
        HEX: 3fffffff 12 LOAD ! first 30 bits set
        dup dup 12 AND ! store the number
        11 3 cells STW
        dup dup 12 AND
        dup 11 4 cells STW
        11 swap bignum-tag ORI ! tag the bignum, store it in reg
    ] with-scope ;
