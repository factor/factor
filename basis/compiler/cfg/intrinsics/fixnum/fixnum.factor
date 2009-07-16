! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences accessors layouts kernel math namespaces
combinators fry
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

: emit-fixnum-overflow-op ( quot -- next )
    [ 2inputs 1 ##inc-d ] dip call ##branch
    begin-basic-block ; inline
