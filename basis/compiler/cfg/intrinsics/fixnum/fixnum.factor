! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators compiler.cfg.builder.blocks
compiler.cfg.comparisons compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.stacks
compiler.tree.propagation.info cpu.architecture fry kernel
layouts math math.intervals namespaces sequences ;
IN: compiler.cfg.intrinsics.fixnum

: emit-both-fixnums? ( -- )
    [
        [ ^^tagged>integer ] bi@
        ^^or tag-mask get ^^and-imm
        0 cc= ^^compare-integer-imm
    ] binary-op ;

: emit-fixnum-left-shift ( -- )
    [ ^^shl ] binary-op ;

: emit-fixnum-right-shift ( -- )
    [
        [ tag-bits get ^^shl-imm ] dip
        ^^neg ^^sar
        tag-bits get ^^sar-imm
    ] binary-op ;

: emit-fixnum-shift-general ( -- )
    ds-peek 0 cc> ##compare-integer-imm-branch,
    [ emit-fixnum-left-shift ] with-branch
    [ emit-fixnum-right-shift ] with-branch
    2array emit-conditional ;

: emit-fixnum-shift-fast ( node -- )
    node-input-infos second interval>> {
        { [ dup 0 [a,inf] interval-subset? ] [ drop emit-fixnum-left-shift ] }
        { [ dup 0 [-inf,a] interval-subset? ] [ drop emit-fixnum-right-shift ] }
        [ drop emit-fixnum-shift-general ]
    } cond ;

: emit-fixnum-comparison ( cc -- )
    '[ _ ^^compare-integer ] binary-op ;

: emit-no-overflow-case ( dst -- final-bb )
    [ ds-drop ds-drop ds-push ] with-branch ;

: emit-overflow-case ( word -- final-bb )
    [
        ##call,
        -1 adjust-d
        make-kill-block
    ] with-branch ;

: emit-fixnum-overflow-op ( quot word -- )
    ! Inputs to the final instruction need to be copied because
    ! of loc>vreg sync
    [ [ (2inputs) [ any-rep ^^copy ] bi@ cc/o ] dip call ] dip
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
    [ ^^fixnum-mul ] \ fixnum*overflow emit-fixnum-overflow-op ;
