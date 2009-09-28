! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences accessors layouts kernel math math.intervals
namespaces combinators fry arrays
cpu.architecture
compiler.tree.propagation.info
compiler.cfg.hats
compiler.cfg.stacks
compiler.cfg.instructions
compiler.cfg.utilities
compiler.cfg.builder.blocks
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

: emit-fixnum-op ( insn -- )
    [ 2inputs ] dip call ds-push ; inline

: emit-fixnum-left-shift ( -- )
    [ ^^untag-fixnum ^^shl ] emit-fixnum-op ;

: emit-fixnum-right-shift ( -- )
    [ ^^untag-fixnum ^^neg ^^sar dup tag-mask get ^^and-imm ^^xor ] emit-fixnum-op ;

: emit-fixnum-shift-general ( -- )
    ds-peek 0 cc> ##compare-imm-branch
    [ emit-fixnum-left-shift ] with-branch
    [ emit-fixnum-right-shift ] with-branch
    2array emit-conditional ;

: emit-fixnum-shift-fast ( node -- )
    node-input-infos second interval>> {
        { [ dup 0 [a,inf] interval-subset? ] [ drop emit-fixnum-left-shift ] }
        { [ dup 0 [-inf,a] interval-subset? ] [ drop emit-fixnum-right-shift ] }
        [ drop emit-fixnum-shift-general ]
    } cond ;
    
: emit-fixnum-bitnot ( -- )
    ds-pop ^^not tag-mask get ^^xor-imm ds-push ;

: emit-fixnum-log2 ( -- )
    ds-pop ^^log2 tag-bits get ^^sub-imm ^^tag-fixnum ds-push ;

: emit-fixnum*fast ( -- )
    2inputs ^^untag-fixnum ^^mul ds-push ;

: emit-fixnum-comparison ( cc -- )
    '[ _ ^^compare ] emit-fixnum-op ;

: emit-no-overflow-case ( dst -- final-bb )
    [ ds-drop ds-drop ds-push ] with-branch ;

: emit-overflow-case ( word -- final-bb )
    [ ##call -1 adjust-d ] with-branch ;

: emit-fixnum-overflow-op ( quot word -- )
    ! Inputs to the final instruction need to be copied because
    ! of loc>vreg sync
    [ [ (2inputs) [ any-rep ^^copy ] bi@ ] dip call ] dip
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