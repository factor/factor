! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: kernel assembler kernel-internals namespaces math ;

: load-zone-ptr ( reg -- )
    #! Load pointer to start of zone array
    allot-tmp-reg 0 MOV
    "generations" f rel-absolute-cell rel-dlsym
    allot-tmp-reg allot-tmp-reg [] MOV ;

: load-allot-ptr ( -- )
    load-zone-ptr
    allot-tmp-reg allot-tmp-reg cell [+] MOV ;

: inc-allot-ptr ( n -- )
    load-zone-ptr
    allot-tmp-reg cell [+] swap 8 align ADD ;

: store-header ( header -- )
    allot-tmp-reg [] swap tag-header MOV ;

: %allot ( header size quot -- )
    swap >r >r
    allot-tmp-reg PUSH
    load-allot-ptr
    store-header
    r> call
    r> inc-allot-ptr
    allot-tmp-reg POP ; inline

: %allot-float ( loc vreg -- )
    #! Only called by pentium4 backend, uses SSE2 instruction
    float-tag 16 [
        allot-tmp-reg 8 [+] rot v>operand MOVSD
        allot-tmp-reg float-tag OR
        v>operand allot-tmp-reg MOV
    ] %allot ;

: %allot-bignum ( #digits quot -- )
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    bignum-tag pick 3 + cells [
        ! Write length
        >r allot-tmp-reg cell [+] swap 1+ tag-bits shift MOV r>
        ! Call quot
        call
    ] %allot ; inline

: %allot-bignum-signed-1 ( outreg inreg -- )
    #! on entry, inreg is a signed 32-bit quantity
    #! exits with tagged ptr to bignum in outreg
    [
        "positive" define-label
        "end" define-label
        1 [
            dup 0 CMP
            "positive" get JGE
            allot-tmp-reg 2 cells [+] 1 MOV ! negative sign
            dup NEG
            "end" get JMP
            "positive" resolve-label
            allot-tmp-reg 2 cells [+] 0 MOV ! positive sign
            "end" resolve-label
            allot-tmp-reg 3 cells [+] swap MOV
            allot-tmp-reg bignum-tag OR
            allot-tmp-reg MOV
        ] %allot-bignum
    ] with-scope ;

: %allot-bignum-signed-2 ( reg1 reg2 -- )
    #! on entry, reg1 and reg2 together form a signed 64-bit
    #! quantity.
    #! exits with tagged ptr to bignum in reg1
    [
        2 [
            ! todo: neg
            allot-tmp-reg 2 cells [+] 0 MOV ! positive sign
            allot-tmp-reg 3 cells [+] swap MOV
            allot-tmp-reg 4 cells [+] over MOV
            allot-tmp-reg bignum-tag OR
            allot-tmp-reg MOV
        ] %allot-bignum
    ] with-scope ;
