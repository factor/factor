! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel assocs sequences sequences.lib fry accessors
namespaces math combinators math.order
compiler.tree
compiler.tree.combinators
compiler.tree.propagation.info
compiler.cfg
compiler.vops
compiler.vops.builder ;
IN: compiler.cfg.builder

! Convert tree SSA IR to CFG SSA IR.

! We construct the graph and set successors first, then we
! set predecessors in a separate pass. This simplifies the
! logic.

SYMBOL: procedures

SYMBOL: loop-nesting

SYMBOL: values>vregs

GENERIC: convert ( node -- )

M: #introduce convert drop ;

: init-builder ( -- )
    H{ } clone values>vregs set ;

: end-basic-block ( -- )
    basic-block get [ %b emit ] when ;

: set-basic-block ( basic-block -- )
    [ basic-block set ] [ instructions>> building set ] bi ;

: begin-basic-block ( -- )
    <basic-block> basic-block get
    [
        end-basic-block
        dupd successors>> push
    ] when*
    set-basic-block ;

: convert-nodes ( node -- )
    [ convert ] each ;

: (build-cfg) ( node word -- )
    init-builder
    begin-basic-block
    basic-block get swap procedures get set-at
    convert-nodes ;

: build-cfg ( node word -- procedures )
    H{ } clone [
        procedures [ (build-cfg) ] with-variable
    ] keep ;

: value>vreg ( value -- vreg )
    values>vregs get at ;

: output-vreg ( value vreg -- )
    swap values>vregs get set-at ;

: produce-vreg ( value -- vreg )
    next-vreg [ output-vreg ] keep ;

: (load-inputs) ( seq stack -- )
    over empty? [ 2drop ] [
        [ <reversed> ] dip
        [ '[ produce-vreg _ , %peek emit ] each-index ]
        [ [ length neg ] dip %height emit ]
        2bi
    ] if ;

: load-in-d ( node -- ) in-d>> %data (load-inputs) ;

: load-in-r ( node -- ) in-r>> %retain (load-inputs) ;

: (store-outputs) ( seq stack -- )
    over empty? [ 2drop ] [
        [ <reversed> ] dip
        [ [ length ] dip %height emit ]
        [ '[ value>vreg _ , %replace emit ] each-index ]
        2bi
    ] if ;

: store-out-d ( node -- ) out-d>> %data (store-outputs) ;

: store-out-r ( node -- ) out-r>> %retain (store-outputs) ;

: (emit-call) ( word -- )
    begin-basic-block %call emit begin-basic-block ;

: intrinsic-inputs ( node -- )
    [ load-in-d ]
    [ in-d>> { #1 #2 #3 #4 } [ [ value>vreg ] dip set ] 2each ]
    bi ;

: intrinsic-outputs ( node -- )
    [ out-d>> { ^1 ^2 ^3 ^4 } [ get output-vreg ] 2each ]
    [ store-out-d ]
    bi ;

: intrinsic ( node quot -- )
    [
        init-intrinsic

        [ intrinsic-inputs ]
        swap
        [ intrinsic-outputs ]
        tri
    ] with-scope ; inline

USING: kernel.private math.private slots.private ;

: maybe-emit-fixnum-shift-fast ( node -- node )
    dup dup in-d>> second node-value-info literal>> dup fixnum? [
        '[ , emit-fixnum-shift-fast ] intrinsic
    ] [
        drop dup word>> (emit-call)
    ] if ;

: emit-call ( node -- )
    dup word>> {
        { \ tag [ [ emit-tag ] intrinsic ] }

        { \ slot [ [ dup emit-slot ] intrinsic ] }
        { \ set-slot [ [ dup emit-set-slot ] intrinsic ] }

        { \ fixnum-bitnot [ [ emit-fixnum-bitnot ] intrinsic ] }
        { \ fixnum+fast [ [ emit-fixnum+fast ] intrinsic ] }
        { \ fixnum-fast [ [ emit-fixnum-fast ] intrinsic ] }
        { \ fixnum-bitand [ [ emit-fixnum-bitand ] intrinsic ] }
        { \ fixnum-bitor [ [ emit-fixnum-bitor ] intrinsic ] }
        { \ fixnum-bitxor [ [ emit-fixnum-bitxor ] intrinsic ] }
        { \ fixnum*fast [ [ emit-fixnum*fast ] intrinsic ] }
        { \ fixnum<= [ [ emit-fixnum<= ] intrinsic ] }
        { \ fixnum>= [ [ emit-fixnum>= ] intrinsic ] }
        { \ fixnum< [ [ emit-fixnum< ] intrinsic ] }
        { \ fixnum> [ [ emit-fixnum> ] intrinsic ] }
        { \ eq? [ [ emit-eq? ] intrinsic ] }

        { \ fixnum-shift-fast [ maybe-emit-fixnum-shift-fast ] }

        { \ float+ [ [ emit-float+ ] intrinsic ] }
        { \ float- [ [ emit-float- ] intrinsic ] }
        { \ float* [ [ emit-float* ] intrinsic ] }
        { \ float/f [ [ emit-float/f ] intrinsic ] }
        { \ float<= [ [ emit-float<= ] intrinsic ] }
        { \ float>= [ [ emit-float>= ] intrinsic ] }
        { \ float< [ [ emit-float< ] intrinsic ] }
        { \ float> [ [ emit-float> ] intrinsic ] }
        { \ float? [ [ emit-float= ] intrinsic ] }

        ! { \ (tuple) [ dup first-input '[ , emit-(tuple) ] intrinsic ] }
        ! { \ (array) [ dup first-input '[ , emit-(array) ] intrinsic ] }
        ! { \ (byte-array) [ dup first-input '[ , emit-(byte-array) ] intrinsic ] }

        [ (emit-call) ]
    } case drop ;

M: #call convert emit-call ;

: emit-call-loop ( #recursive -- )
    dup label>> loop-nesting get at basic-block get successors>> push
    end-basic-block
    basic-block off
    drop ;

: emit-call-recursive ( #recursive -- )
    label>> id>> (emit-call) ;

M: #call-recursive convert
    dup label>> loop?>>
    [ emit-call-loop ] [ emit-call-recursive ] if ;

M: #push convert
    [
        [ out-d>> first produce-vreg ]
        [ node-output-infos first literal>> ]
        bi emit-literal
    ]
    [ store-out-d ] bi ;

M: #shuffle convert [ load-in-d ] [ store-out-d ] bi ;

M: #>r convert [ load-in-d ] [ store-out-r ] bi ;

M: #r> convert [ load-in-r ] [ store-out-d ] bi ;

M: #terminate convert drop ;

: integer-conditional ( in1 in2 cc -- )
    [ [ next-vreg dup ] 2dip %icmp emit ] dip %bi emit ; inline

: float-conditional ( in1 in2 branch -- )
    [ next-vreg [ %fcmp emit ] keep ] dip emit ; inline

: emit-if ( #if -- )
    in-d>> first value>vreg
    next-vreg dup f emit-literal
    cc/= integer-conditional ;

: convert-nested ( node -- last-bb )
    [
        <basic-block>
        [ set-basic-block ] keep
        [ convert-nodes end-basic-block ] dip
        basic-block get
    ] with-scope
    [ basic-block get successors>> push ] dip ;

: convert-if-children ( #if -- )
    children>> [ convert-nested ] map sift
    <basic-block>
    [ '[ , _ successors>> push ] each ]
    [ set-basic-block ]
    bi ;

M: #if convert
    [ load-in-d ] [ emit-if ] [ convert-if-children ] tri ;

M: #dispatch convert
    "Unimplemented" throw ;

M: #phi convert drop ;

M: #declare convert drop ;

M: #return convert drop %return emit ;

: convert-recursive ( #recursive -- )
    [ [ label>> id>> ] [ child>> ] bi (build-cfg) ]
    [ (emit-call) ]
    bi ;

: begin-loop ( #recursive -- )
    label>> basic-block get 2array loop-nesting get push ;

: end-loop ( -- )
    loop-nesting get pop* ;

: convert-loop ( #recursive -- )
    begin-basic-block
    [ begin-loop ]
    [ child>> convert-nodes ]
    [ drop end-loop ]
    tri ;

M: #recursive convert
    dup label>> loop?>>
    [ convert-loop ] [ convert-recursive ] if ;

M: #copy convert drop ;
