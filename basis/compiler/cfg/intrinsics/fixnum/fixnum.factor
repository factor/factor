! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences accessors layouts kernel math namespaces
combinators fry locals
compiler.tree.propagation.info
compiler.cfg.hats
compiler.cfg.stacks
compiler.cfg.iterator
compiler.cfg.instructions
compiler.cfg.utilities
compiler.cfg.registers ;
IN: compiler.cfg.intrinsics.fixnum

: emit-both-fixnums? ( -- )
    2inputs
    ^^or
    tag-mask get ^^and-imm
    0 cc= ^^compare-imm
    ds-push ;

: tag-literal ( n -- tagged )
    literal>> [ tag-fixnum ] [ \ f tag-number ] if* ;

: emit-fixnum-imm-op1 ( infos insn -- dst )
    [ ds-pop ds-drop ] [ first tag-literal ] [ ] tri* call ; inline

: emit-fixnum-imm-op2 ( infos insn -- dst )
    [ ds-drop ds-pop ] [ second tag-literal ] [ ] tri* call ; inline

: (emit-fixnum-op) ( insn -- dst )
    [ 2inputs ] dip call ; inline

:: emit-fixnum-op ( node insn imm-insn -- )
    [let | infos [ node node-input-infos ] |
        infos second value-info-small-tagged?
        [ infos imm-insn emit-fixnum-imm-op2 ]
        [ insn (emit-fixnum-op) ] if
        ds-push
    ] ; inline

:: emit-commutative-fixnum-op ( node insn imm-insn -- )
    [let | infos [ node node-input-infos ] |
        infos first value-info-small-tagged?
        [ infos imm-insn emit-fixnum-imm-op1 ]
        [
            infos second value-info-small-tagged? [
                infos imm-insn emit-fixnum-imm-op2
            ] [
                insn (emit-fixnum-op)
            ] if
        ] if
        ds-push
    ] ; inline

: (emit-fixnum-shift-fast) ( obj node -- obj )
    literal>> dup sgn {
        { -1 [ neg tag-bits get + ^^sar-imm ^^tag-fixnum ] }
        {  0 [ drop ] }
        {  1 [ ^^shl-imm ] }
    } case ;

: emit-fixnum-shift-fast ( node -- )
    dup node-input-infos dup first value-info-small-fixnum? [
        nip
        [ ds-pop ds-drop ] dip first (emit-fixnum-shift-fast) ds-push
    ] [
        drop
        dup node-input-infos dup second value-info-small-fixnum? [
            nip
            [ ds-drop ds-pop ] dip second (emit-fixnum-shift-fast) ds-push
        ] [
            drop emit-primitive
        ] if
    ] if ;
    
: emit-fixnum-bitnot ( -- )
    ds-pop ^^not tag-mask get ^^xor-imm ds-push ;

: emit-fixnum-log2 ( -- )
    ds-pop ^^log2 tag-bits get ^^sub-imm ^^tag-fixnum ds-push ;

: (emit-fixnum*fast) ( -- dst )
    2inputs ^^untag-fixnum ^^mul ;

: (emit-fixnum*fast-imm1) ( infos -- dst )
    [ ds-pop ds-drop ] [ first literal>> ] bi* ^^mul-imm ;

: (emit-fixnum*fast-imm2) ( infos -- dst )
    [ ds-drop ds-pop ] [ second literal>> ] bi* ^^mul-imm ;

: emit-fixnum*fast ( node -- )
    node-input-infos
    dup first value-info-small-fixnum?
    [
        (emit-fixnum*fast-imm1)
    ] [
        dup second value-info-small-fixnum?
        [ (emit-fixnum*fast-imm2) ] [ drop (emit-fixnum*fast) ] if
    ] if
    ds-push ;

: (emit-fixnum-comparison) ( cc -- quot1 quot2 )
    [ ^^compare ] [ ^^compare-imm ] bi-curry ; inline

: emit-eq ( node cc -- )
    (emit-fixnum-comparison) emit-commutative-fixnum-op ;

: emit-fixnum-comparison ( node cc -- )
    (emit-fixnum-comparison) emit-fixnum-op ;

: emit-bignum>fixnum ( -- )
    ds-pop ^^bignum>integer ^^tag-fixnum ds-push ;

: emit-fixnum>bignum ( -- )
    ds-pop ^^untag-fixnum ^^integer>bignum ds-push ;

: emit-fixnum-overflow-op ( quot quot-tail -- next )
    [ 2inputs 1 ##inc-d ] 2dip
    tail-call? [
        ##epilogue
        nip call
        stop-iterating
    ] [
        drop call
        ##branch
        begin-basic-block
        iterate-next
    ] if ; inline
