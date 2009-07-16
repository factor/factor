! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences accessors layouts kernel math namespaces
combinators fry arrays
compiler.tree.propagation.info
compiler.cfg.hats
compiler.cfg.stacks
compiler.cfg.instructions
compiler.cfg.utilities
compiler.cfg.registers
compiler.cfg.comparisons ;
IN: compiler.cfg.intrinsics.fixnum

: emit-both-fixnums? ( -- )
    2inputs
    ^^or
    tag-mask get ^^and-imm
    0 cc= ^^compare-imm
    ds-push ;

: tag-literal ( n -- tagged )
    literal>> [ tag-fixnum ] [ \ f tag-number ] if* ;

: emit-fixnum-op ( insn -- dst )
    [ 2inputs ] dip call ds-push ; inline

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

: emit-fixnum*fast ( -- )
    2inputs ^^untag-fixnum ^^mul ds-push ;

: emit-fixnum-comparison ( cc -- )
    '[ _ ^^compare ] emit-fixnum-op ;

: emit-bignum>fixnum ( -- )
    ds-pop ^^bignum>integer ^^tag-fixnum ds-push ;

: emit-fixnum>bignum ( -- )
    ds-pop ^^untag-fixnum ^^integer>bignum ds-push ;

: emit-no-overflow-case ( dst -- final-bb )
    [ -2 ##inc-d ds-push ] with-branch ;

: emit-overflow-case ( word -- final-bb )
    [ ##call ] with-branch ;

: emit-fixnum-overflow-op ( quot word -- )
    [ [ D 1 ^^peek D 0 ^^peek ] dip call ] dip
    [ emit-no-overflow-case ] [ emit-overflow-case ] bi* 2array
    emit-conditional ; inline

: fixnum+overflow ( x y -- z ) [ >bignum ] bi@ + ;

: fixnum-overflow ( x y -- z ) [ >bignum ] bi@ - ;

: fixnum*overflow ( x y -- z ) [ >bignum ] bi@ * ;

: emit-fixnum+ ( -- )
    [ ^^fixnum-add ] \ fixnum+overflow emit-fixnum-overflow-op ;

: emit-fixnum- ( -- )
    [ ^^fixnum-sub ] \ fixnum-overflow emit-fixnum-overflow-op ;

: emit-fixnum* ( -- )
    [ ^^untag-fixnum ^^fixnum-mul ] \ fixnum*overflow emit-fixnum-overflow-op ;