! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators compiler.cfg.builder.blocks
compiler.cfg.comparisons compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local
compiler.tree.propagation.info cpu.architecture kernel layouts
math math.intervals namespaces sequences ;
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

: emit-fixnum-shift-general ( block -- block' )
    ds-peek 0 cc> ##compare-integer-imm-branch, dup
    [ [ emit-fixnum-left-shift ] with-branch ]
    [ [ emit-fixnum-right-shift ] with-branch ] bi 2array
    emit-conditional ;

: emit-fixnum-shift-fast ( block #call -- block' )
    node-input-infos second interval>> {
        { [ dup 0 [a,inf] interval-subset? ] [ drop emit-fixnum-left-shift ] }
        { [ dup 0 [-inf,b] interval-subset? ] [ drop emit-fixnum-right-shift ] }
        [ drop emit-fixnum-shift-general ]
    } cond ;

: emit-fixnum-comparison ( cc -- )
    '[ _ ^^compare-integer ] binary-op ;

: emit-no-overflow-case ( dst block -- final-bb )
    [ swap D: -2 inc-stack ds-push ] with-branch ;

: emit-overflow-case ( word block -- final-bb )
    [ -1 swap [ emit-call-block ] keep ] with-branch ;

:: emit-fixnum-overflow-op ( block quot word -- block' )
    (2inputs) [ any-rep ^^copy ] bi@ cc/o
    quot call( vreg1 vreg2 cc -- vreg ) block emit-no-overflow-case
    word block emit-overflow-case 2array
    block swap emit-conditional ; inline

: fixnum+overflow ( x y -- z ) [ >bignum ] bi@ + ;

: fixnum-overflow ( x y -- z ) [ >bignum ] bi@ - ;

: fixnum*overflow ( x y -- z ) [ >bignum ] bi@ * ;

: emit-fixnum+ ( block -- block' )
    [ ^^fixnum-add ] \ fixnum+overflow emit-fixnum-overflow-op ;

: emit-fixnum- ( block -- block' )
    [ ^^fixnum-sub ] \ fixnum-overflow emit-fixnum-overflow-op ;

: emit-fixnum* ( block -- block' )
    [ ^^fixnum-mul ] \ fixnum*overflow emit-fixnum-overflow-op ;
