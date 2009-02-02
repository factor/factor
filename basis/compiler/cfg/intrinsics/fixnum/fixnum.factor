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

: emit-fixnum-log2 ( -- )
    ds-pop ^^log2 tag-bits get ^^sub-imm ^^tag-fixnum ds-push ;

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
    [  ^^compare ] [ ^^compare-imm ] bi-curry
    emit-fixnum-op ;

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
