! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences accessors layouts kernel math namespaces
combinators fry locals
compiler.tree.propagation.info
compiler.cfg.stacks compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.utilities ;
IN: compiler.cfg.intrinsics.fixnum

: (emit-fixnum-imm-op) ( infos insn -- dst )
    ds-drop
    [ ds-pop ]
    [ second literal>> [ tag-fixnum ] [ \ f tag-number ] if* ]
    [ ]
    tri*
    call ; inline

: (emit-fixnum-op) ( insn -- dst )
    [ 2inputs ] dip call ; inline

:: emit-fixnum-op ( node insn imm-insn -- )
    [let | infos [ node node-input-infos ] |
        infos second value-info-small-tagged?
        [ infos imm-insn (emit-fixnum-imm-op) ]
        [ insn (emit-fixnum-op) ]
        if
        ds-push
    ] ; inline

: emit-fixnum-shift-fast ( node -- )
    dup node-input-infos dup second value-info-small-fixnum? [
        nip
        [ ds-drop ds-pop ] dip
        second literal>> dup sgn {
            { -1 [ neg tag-bits get + ^^sar-imm ^^tag-fixnum ] }
            {  0 [ drop ] }
            {  1 [ ^^shl-imm ] }
        } case
        ds-push
    ] [ drop emit-primitive ] if ;

: emit-fixnum-bitnot ( -- )
    ds-pop ^^not tag-mask get ^^xor-imm ds-push ;

: (emit-fixnum*fast) ( -- dst )
    2inputs ^^untag-fixnum ^^mul ;

: (emit-fixnum*fast-imm) ( infos -- dst )
    ds-drop
    [ ds-pop ] [ second literal>> ] bi* ^^mul-imm ;

: emit-fixnum*fast ( node -- )
    node-input-infos
    dup second value-info-small-fixnum?
    [ (emit-fixnum*fast-imm) ] [ drop (emit-fixnum*fast) ] if
    ds-push ;

: emit-fixnum-comparison ( node cc -- )
    [ '[ _ ^^compare ] ] [ '[ _ ^^compare-imm ] ] bi
    emit-fixnum-op ;

: emit-bignum>fixnum ( -- )
    ds-pop ^^bignum>integer ^^tag-fixnum ds-push ;

: emit-fixnum>bignum ( -- )
    ds-pop ^^untag-fixnum ^^integer>bignum ds-push ;

: emit-fixnum-overflow-op ( quot -- )
    [ 2inputs i 1 ##inc-d ] dip call begin-basic-block ; inline
