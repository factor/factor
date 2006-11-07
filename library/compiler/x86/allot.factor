! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: kernel assembler kernel-internals namespaces math ;

: load-zone-ptr ( reg -- )
    #! Load pointer to start of zone array
    dup 0 MOV
    "generations" f rel-absolute-cell rel-dlsym
    dup [] MOV ;

: load-allot-ptr ( reg -- )
    dup load-zone-ptr dup cell [+] MOV ;

: inc-allot-ptr ( reg n -- )
    >r dup load-zone-ptr cell [+] r> ADD ;

: %allot ( header size quot -- )
    swap >r >r
    alloc-tmp-reg PUSH
    alloc-tmp-reg load-allot-ptr
    alloc-tmp-reg [] rot tag-header MOV
    r> call
    alloc-tmp-reg r> 8 align inc-allot-ptr
    alloc-tmp-reg POP ; inline

: %allot-float ( loc vreg -- )
    #! Only called by pentium4 backend
    float-tag 16 [
        alloc-tmp-reg 8 [+] rot v>operand MOVSD
        alloc-tmp-reg float-tag OR
        v>operand alloc-tmp-reg MOV
    ] %allot ;

M: float-regs (%replace)
    drop swap %allot-float ;

: %allot-bignum ( #digits quot -- )
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    bignum-tag pick 3 + cells [
        >r alloc-tmp-reg cell [+] swap 1+ tag-bits shift MOV r>
        call
    ] %allot ; inline

: %allot-bignum-signed-1 ( reg -- )
    #! on entry, reg is a signed 32-bit quantity
    #! exits with tagged ptr to bignum in reg
    [
        1 [
            ! todo: neg
            alloc-tmp-reg 2 cells [+] 0 MOV ! positive sign
            alloc-tmp-reg 3 cells [+] over MOV
            alloc-tmp-reg bignum-tag OR
            MOV
        ] %allot-bignum
    ] with-scope ;

: %allot-bignum-signed-2 ( reg1 reg2 -- )
    #! on entry, reg1 and reg2 together form a signed 64-bit
    #! quantity.
    #! exits with tagged ptr to bignum in reg1
    [
        2 [
            alloc-tmp-reg 2 cells [+] 0 MOV ! positive sign
            alloc-tmp-reg 3 cells [+] swap MOV
            alloc-tmp-reg 4 cells [+] over MOV
            alloc-tmp-reg bignum-tag OR
            MOV
        ] %allot-bignum
    ] with-scope ;
