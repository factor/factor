! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel cpu.architecture cpu.x86.assembler
cpu.x86.architecture kernel.private namespaces math
math.functions sequences generic arrays generator
generator.fixup generator.registers system layouts alien ;
IN: cpu.x86.allot

: (object@) ( n -- operand ) temp-reg v>operand swap [+] ;

: object@ ( n -- operand ) cells (object@) ;

: load-zone-ptr ( -- )
    #! Load pointer to start of zone array
    "nursery" f %alien-global ;

: load-allot-ptr ( -- )
    load-zone-ptr
    temp-reg v>operand dup cell [+] MOV ;

: inc-allot-ptr ( n -- )
    load-zone-ptr
    temp-reg v>operand cell [+] swap 8 align ADD ;

: store-header ( header -- )
    0 object@ swap type-number tag-header MOV ;

: %allot ( header size quot -- )
    swap >r >r
    load-allot-ptr
    store-header
    r> call
    r> inc-allot-ptr ; inline

: %store-tagged ( reg tag -- )
    >r dup fresh-object v>operand r>
    temp-reg v>operand swap tag-number OR
    temp-reg v>operand MOV ;

M: x86-backend %box-float ( dst src -- )
    #! Only called by pentium4 backend, uses SSE2 instruction
    #! dest is a loc or a vreg
    float 16 [
        8 (object@) swap v>operand MOVSD
        float %store-tagged
    ] %allot ;

: %allot-bignum-signed-1 ( outreg inreg -- )
    #! on entry, inreg is a signed 32-bit quantity
    #! exits with tagged ptr to bignum in outreg
    #! 1 cell header, 1 cell length, 1 cell sign, + digits
    #! length is the # of digits + sign
    [
        { "end" "nonzero" "positive" "store" }
        [ define-label ] each
        dup v>operand 0 CMP ! is it zero?
        "nonzero" get JNE
        0 >bignum pick load-literal ! this is our result
        "end" get JMP
        "nonzero" resolve-label
        bignum 4 cells [
            ! Write length
            1 object@ 2 v>operand MOV
            ! Test sign
            dup v>operand 0 CMP
            "positive" get JGE
            2 object@ 1 MOV ! negative sign
            dup v>operand NEG
            "store" get JMP
            "positive" resolve-label
            2 object@ 0 MOV ! positive sign
            "store" resolve-label
            3 object@ swap v>operand MOV
            ! Store tagged ptr in reg
            bignum %store-tagged
        ] %allot
        "end" resolve-label
    ] with-scope ;

: %allot-alien ( ptr -- )
    [
        "temp" set
        { "end" "f" } [ define-label ] each
        "temp" operand 0 CMP
        "f" get JE
        alien 4 cells [
            1 object@ f v>operand MOV
            2 object@ f v>operand MOV
            3 object@ "temp" operand MOV
            ! Store tagged ptr in reg
            "temp" get object %store-tagged
        ] %allot
        "end" get JMP
        "f" resolve-label
        "temp" operand f v>operand MOV
        "end" resolve-label
    ] with-scope ;
