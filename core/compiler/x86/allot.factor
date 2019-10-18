! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: kernel assembler-x86 kernel-internals namespaces math
sequences generic arrays ;

: object@ ( n -- operand ) temp-reg v>operand swap [+] ;

: load-zone-ptr ( -- )
    #! Load pointer to start of zone array
    temp-reg v>operand 0 MOV
    "nursery" f rc-absolute-cell rel-dlsym
    temp-reg v>operand dup [] MOV ;

: load-allot-ptr ( -- )
    load-zone-ptr
    temp-reg v>operand dup cell [+] MOV ;

: inc-allot-ptr ( n -- )
    load-zone-ptr
    temp-reg v>operand cell [+] swap 8 align ADD ;

: store-header ( header -- )
    0 object@ swap type-number tag-header MOV ;

: %allot ( header size quot -- )
    dup maybe-gc
    swap >r >r
    load-allot-ptr
    store-header
    r> call
    r> inc-allot-ptr ; inline

: %store-tagged ( reg tag -- )
    temp-reg v>operand swap tag-number OR
    temp-reg v>operand MOV ;

: %move-float>int ( dst src -- )
    #! Only called by pentium4 backend, uses SSE2 instruction
    #! dest is a loc or a vreg
    float 16 [
        8 object@ swap v>operand MOVSD
        v>operand float %store-tagged
    ] %allot ;

: %allot-bignum-signed-1 ( outreg inreg -- )
    #! on entry, inreg is a signed 32-bit quantity
    #! exits with tagged ptr to bignum in outreg
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    [
        { "end" "nonzero" "positive" "store" }
        [ define-label ] each
        dup 0 CMP ! is it zero?
        "nonzero" get JNE
        0 >bignum pick load-indirect ! this is our result
        "end" get JMP
        "nonzero" resolve-label
        bignum 4 cells [
            ! Write length
            cell object@ 2 v>operand MOV
            ! Test sign
            dup 0 CMP
            "positive" get JGE
            2 cells object@ 1 MOV ! negative sign
            dup NEG
            "store" get JMP
            "positive" resolve-label
            2 cells object@ 0 MOV ! positive sign
            "store" resolve-label
            3 cells object@ swap MOV
            ! Store tagged ptr in reg
            bignum %store-tagged
        ] %allot
        "end" resolve-label
    ] with-scope ;

: %allot-tuple ( reg class n -- )
    tuple over 2 + cells [
        ! Store length
        cell object@ over v>operand MOV
        ! Store class
        2 cells object@ rot MOV
        ! Zero out the rest of the tuple
        1- [ 3 + cells object@ f v>operand MOV ] each
        ! Store tagged ptr in reg
        object %store-tagged
    ] %allot ;

: %allot-array ( reg initial n -- )
    array over 2 + cells [
        ! Store length
        cell object@ over v>operand MOV
        ! Zero out the rest of the tuple
        [ 2 + cells object@ swap MOV ] each-with
        ! Store tagged ptr in reg
        object %store-tagged
    ] %allot ;
