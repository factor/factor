! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel assocs sequences sequences.lib fry accessors
compiler.cfg compiler.vops compiler.vops.builder
namespaces math inference.dataflow optimizer.allot combinators
math.order ;
IN: compiler.cfg.builder

! Convert dataflow IR to procedure CFG.
! We construct the graph and set successors first, then we
! set predecessors in a separate pass. This simplifies the
! logic.

SYMBOL: procedures

SYMBOL: values>vregs

SYMBOL: loop-nesting

GENERIC: convert* ( node -- )

GENERIC: convert ( node -- )

: init-builder ( -- )
    H{ } clone values>vregs set
    V{ } clone loop-nesting set ;

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
    dup basic-block get and [
        [ convert ] [ successor>> convert-nodes ] bi
    ] [ drop ] if ;

: (build-cfg) ( node word -- )
    init-builder
    begin-basic-block
    basic-block get swap procedures get set-at
    %prolog emit
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

: load-inputs ( node -- )
    [ in-d>> %data (load-inputs) ]
    [ in-r>> %retain (load-inputs) ]
    bi ;

: (store-outputs) ( seq stack -- )
    over empty? [ 2drop ] [
        [ <reversed> ] dip
        [ [ length ] dip %height emit ]
        [ '[ value>vreg _ , %replace emit ] each-index ]
        2bi
    ] if ;

: store-outputs ( node -- )
    [ out-d>> %data (store-outputs) ]
    [ out-r>> %retain (store-outputs) ]
    bi ;

M: #push convert*
    out-d>> [
        [ produce-vreg ] [ value-literal ] bi
        emit-literal
    ] each ;

M: #shuffle convert* drop ;

M: #>r convert* drop ;

M: #r> convert* drop ;

M: node convert
    [ load-inputs ]
    [ convert* ]
    [ store-outputs ]
    tri ;

: (emit-call) ( word -- )
    begin-basic-block %call emit begin-basic-block ;

: intrinsic-inputs ( node -- )
    [ load-inputs ]
    [ in-d>> { #1 #2 #3 #4 } [ [ value>vreg ] dip set ] 2each ]
    bi ;

: intrinsic-outputs ( node -- )
    [ out-d>> { ^1 ^2 ^3 ^4 } [ get output-vreg ] 2each ]
    [ store-outputs ]
    bi ;

: intrinsic ( node quot -- )
    [
        init-intrinsic

        [ intrinsic-inputs ]
        swap
        [ intrinsic-outputs ]
        tri
    ] with-scope ; inline

USING: kernel.private math.private slots.private
optimizer.allot ;

: maybe-emit-fixnum-shift-fast ( node -- node )
    dup dup in-d>> second node-literal? [
        dup dup in-d>> second node-literal
        '[ , emit-fixnum-shift-fast ] intrinsic
    ] [
        dup param>> (emit-call)
    ] if ;

: emit-call ( node -- )
    dup param>> {
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

        { \ (tuple) [ dup first-input '[ , emit-(tuple) ] intrinsic ] }
        { \ (array) [ dup first-input '[ , emit-(array) ] intrinsic ] }
        { \ (byte-array) [ dup first-input '[ , emit-(byte-array) ] intrinsic ] }

        [ (emit-call) ]
    } case drop ;

M: #call convert emit-call ;

M: #call-label convert
    dup param>> loop-nesting get at [
        basic-block get successors>> push
        end-basic-block
        basic-block off
        drop
    ] [
        (emit-call)
    ] if* ;

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

: phi-inputs ( #if -- vregs-seq )
    children>>
    [ last-node ] map
    [ #values? ] filter
    [ in-d>> [ value>vreg ] map ] map ;

: phi-outputs ( #if -- vregs )
    successor>> out-d>> [ produce-vreg ] map ;

: emit-phi ( #if -- )
    [ phi-outputs ] [ phi-inputs ] bi %phi emit ;

M: #if convert
    {
        [ load-inputs ]
        [ emit-if ]
        [ convert-if-children ]
        [ emit-phi ]
    } cleave ;

M: #values convert drop ;

M: #merge convert drop ;

M: #entry convert drop ;

M: #declare convert drop ;

M: #terminate convert drop ;

M: #label convert
    #! Labels create a new procedure.
    [ [ param>> ] [ node-child ] bi (build-cfg) ] [ (emit-call) ] bi ;

M: #loop convert
    #! Loops become part of the current CFG.
    begin-basic-block
    [ param>> basic-block get 2array loop-nesting get push ]
    [ node-child convert-nodes ]
    bi
    loop-nesting get pop* ;

M: #return convert
    param>> loop-nesting get key? [
        %epilog emit
        %return emit
    ] unless ;
