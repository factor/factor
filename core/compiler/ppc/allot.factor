! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: kernel assembler-ppc kernel-internals namespaces math ;

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
    tag-header 12 LI ! compute header
    12 11 0 STW ! store header
    ;

: %allot-float ( reg -- )
    #! exits with tagged ptr to object in r12, untagged in r11
    float-tag 16 %allot
    11 8 STFD
    12 11 float-tag ORI ;

M: float-regs (%replace)
    drop
    swap v>operand %allot-float
    12 swap loc>operand STW ;

: %move-float>int ( dst src -- )
    [ v>operand ] 2apply %allot-float 12 MR ;

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
        11 bignum-tag ORI ! tag the bignum, store it in reg
    ] with-scope ;
