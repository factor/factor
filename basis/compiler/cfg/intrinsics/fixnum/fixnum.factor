! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences accessors layouts kernel math namespaces
combinators fry locals
compiler.tree.propagation.info
compiler.cfg.stacks compiler.cfg.hats
compiler.cfg.intrinsics.utilities ;
IN: compiler.cfg.intrinsics.fixnum

: (emit-fixnum-imm-op) ( infos insn -- dst )
    1 phantom-drop
    [ phantom-pop ] [ second literal>> tag-fixnum ] [ ] tri*
    call ; inline

: (emit-fixnum-op) ( insn -- dst )
    [ 2phantom-pop ] dip call ; inline

:: emit-fixnum-op ( node insn imm-insn -- )
    [let | infos [ node node-input-infos ] |
        infos second value-info-small-tagged?
        [ infos imm-insn (emit-fixnum-imm-op) ]
        [ insn (emit-fixnum-op) ]
        if
        phantom-push
    ] ; inline

: emit-fixnum-shift-fast ( node -- )
    dup node-input-infos dup second value-info-small-tagged? [
        nip
        [ 1 phantom-drop phantom-pop ] dip
        second literal>> dup sgn {
            { -1 [ neg tag-bits get + ^^sar-imm ^^tag-fixnum ] }
            {  0 [ drop ] }
            {  1 [ ^^shl-imm ] }
        } case
        phantom-push
    ] [ drop emit-primitive ] if ;

: emit-fixnum-bitnot ( -- )
    phantom-pop ^^not tag-mask get ^^xor-imm phantom-push ;

: (emit-fixnum*fast) ( -- dst )
    2phantom-pop ^^untag-fixnum ^^mul ;

: (emit-fixnum*fast-imm) ( infos -- dst )
    1 phantom-drop
    [ phantom-pop ] [ second literal>> ] bi* ^^mul-imm ;

: emit-fixnum*fast ( node -- )
    node-input-infos
    dup second value-info-small-tagged?
    [ (emit-fixnum*fast-imm) ] [ drop (emit-fixnum*fast) ] if
    phantom-push ;

: emit-fixnum-comparison ( node cc -- )
    [ '[ _ ^^compare ] ] [ '[ _ ^^compare-imm ] ] bi
    emit-fixnum-op ;

: emit-bignum>fixnum ( -- )
    phantom-pop ^^bignum>integer ^^tag-fixnum phantom-push ;

: emit-fixnum>bignum ( -- )
    phantom-pop ^^untag-fixnum ^^integer>bignum phantom-push ;
