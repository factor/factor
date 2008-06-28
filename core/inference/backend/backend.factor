! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inference.dataflow inference.state arrays generic io
io.streams.string kernel math namespaces parser prettyprint
sequences strings vectors words quotations effects classes
continuations debugger assocs combinators compiler.errors
generic.standard.engines.tuple accessors math.order definitions
sets ;
IN: inference.backend

: recursive-label ( word -- label/f )
    recursive-state get at ;

GENERIC: inline? ( word -- ? )

M: method-body inline?
    "method-generic" word-prop inline? ;

M: engine-word inline?
    "tuple-dispatch-generic" word-prop inline? ;

M: word inline?
    "inline" word-prop ;

SYMBOL: visited

: reset-on-redefine { "inferred-effect" "cannot-infer" } ; inline

: (redefined) ( word -- )
    dup visited get key? [ drop ] [
        [ reset-on-redefine reset-props ]
        [ visited get conjoin ]
        [
            crossref get at keys
            [ word? ] filter
            [
                [ reset-on-redefine [ word-prop ] with contains? ]
                [ inline? ]
                bi or
            ] filter
            [ (redefined) ] each
        ] tri
    ] if ;

M: word redefined H{ } clone visited [ (redefined) ] with-variable ;

: local-recursive-state ( -- assoc )
    recursive-state get dup keys
    [ dup word? [ inline? ] when not ] find drop
    [ head-slice ] when* ;

: inline-recursive-label ( word -- label/f )
    local-recursive-state at ;

: recursive-quotation? ( quot -- ? )
    local-recursive-state [ first eq? ] with contains? ;

TUPLE: inference-error error type rstate ;

M: inference-error compiler-error-type type>> ;

M: inference-error error-help error>> error-help ;

: (inference-error) ( ... class type -- * )
    >r boa r>
    recursive-state get
    \ inference-error boa throw ; inline

: inference-error ( ... class -- * )
    +error+ (inference-error) ; inline

: inference-warning ( ... class -- * )
    +warning+ (inference-error) ; inline

TUPLE: literal-expected ;

M: object value-literal \ literal-expected inference-warning ;

: pop-literal ( -- rstate obj )
    1 #drop node,
    pop-d dup value-literal >r value-recursion r> ;

: value-vector ( n -- vector ) [ <computed> ] V{ } replicate-as ;

: add-inputs ( seq stack -- n stack )
    tuck [ length ] bi@ - dup 0 >
    [ dup value-vector [ swapd push-all ] keep ]
    [ drop 0 swap ] if ;

: ensure-values ( seq -- )
    meta-d [ add-inputs ] change d-in [ + ] change ;

: current-effect ( -- effect )
    d-in get
    meta-d get length <effect>
    terminated? get >>terminated? ;

: init-inference ( -- )
    terminated? off
    V{ } clone meta-d set
    V{ } clone meta-r set
    0 d-in set
    dataflow-graph off
    current-node off ;

GENERIC: apply-object ( obj -- )

: apply-literal ( obj -- )
    <value> push-d #push 1 0 pick node-outputs node, ;

M: object apply-object apply-literal ;

M: wrapper apply-object
    wrapped dup +called+ depends-on apply-literal ;

: terminate ( -- )
    terminated? on #terminate node, ;

: infer-quot ( quot rstate -- )
    recursive-state get [
        recursive-state set
        [ apply-object terminated? get not ] all? drop
    ] dip recursive-state set ;

: infer-quot-recursive ( quot word label -- )
    2array recursive-state get swap prefix infer-quot ;

: time-bomb ( error -- )
    [ throw ] curry recursive-state get infer-quot ;

: bad-call ( -- )
    "call must be given a callable" time-bomb ;

TUPLE: recursive-quotation-error quot ;

: infer-quot-value ( value -- )
    dup recursive-quotation? [
        value-literal recursive-quotation-error inference-error
    ] [
        dup value-literal callable? [
            [ value-literal ]
            [ [ value-recursion ] keep f 2array prefix ]
            bi infer-quot
        ] [
            drop bad-call
        ] if
    ] if ;

TUPLE: too-many->r ;

: check->r ( -- )
    meta-r get empty? terminated? get or
    [ \ too-many->r inference-error ] unless ;

TUPLE: too-many-r> ;

: check-r> ( n -- )
    meta-r get length >
    [ \ too-many-r> inference-error ] when ;

: infer->r ( n -- )
    dup ensure-values
    #>r
    over 0 pick node-inputs
    over [ pop-d ] replicate reverse [ push-r ] each
    0 pick pick node-outputs
    node,
    drop ;

: infer-r> ( n -- )
    dup check-r>
    #r>
    0 pick pick node-inputs
    over [ pop-r ] replicate reverse [ push-d ] each
    over 0 pick node-outputs
    node,
    drop ;

: undo-infer ( -- )
    recorded get [ f "inferred-effect" set-word-prop ] each ;

: (consume-values) ( n -- )
    meta-d get [ length swap - ] keep set-length ;

: consume-values ( seq node -- )
    >r length r>
    over ensure-values
    over 0 rot node-inputs
    (consume-values) ;

: produce-values ( seq node -- )
    >r value-vector dup r> set-node-out-d
    meta-d get push-all ;

: if-inline ( word true false -- )
    [ dup inline? ] 2dip if ; inline

: consume/produce ( effect node -- )
    [ [ in>> ] dip consume-values ]
    [ [ out>> ] dip produce-values ]
    [ node, terminated?>> [ terminate ] when ]
    2tri ;

GENERIC: constructor ( value -- word/f )

GENERIC: infer-uncurry ( value -- )

M: curried infer-uncurry
    drop pop-d [ obj>> push-d ] [ quot>> push-d ] bi ;

M: curried constructor
    drop \ curry ;

M: composed infer-uncurry
    drop pop-d [ quot1>> push-d ] [ quot2>> push-d ] bi ;

M: composed constructor
    drop \ compose ;

M: object infer-uncurry drop ;

M: object constructor drop f ;

: reify-curry ( value -- )
    dup infer-uncurry
    constructor [
        peek-d reify-curry
        1 infer->r
        peek-d reify-curry
        1 infer-r>
        (( obj quot -- curry )) swap #call consume/produce
    ] when* ;

: reify-curries ( n -- )
    meta-d get reverse [
        dup special? [
            over infer->r
            dup reify-curry
            over infer-r>
        ] when 2drop
    ] 2each ;

: reify-all ( -- )
    meta-d get length reify-curries ;

: end-infer ( -- )
    check->r
    reify-all
    f #return node, ;

: unify-lengths ( seq -- newseq )
    dup empty? [
        dup [ length ] map supremum
        [ swap add-inputs nip ] curry map
    ] unless ;

DEFER: unify-values

: unify-curries ( seq -- value )
    [ [ obj>> ] map unify-values ]
    [ [ quot>> ] map unify-values ] bi
    <curried> ;

: unify-composed ( seq -- value )
    [ [ quot1>> ] map unify-values ]
    [ [ quot2>> ] map unify-values ] bi
    <composed> ;

TUPLE: cannot-unify-specials ;

: cannot-unify-specials ( -- * )
    \ cannot-unify-specials inference-warning ;

: unify-values ( seq -- value )
    {
        { [ dup all-eq? ] [ first ] }
        { [ dup [ curried? ] all? ] [ unify-curries ] }
        { [ dup [ composed? ] all? ] [ unify-composed ] }
        { [ dup [ special? ] contains? ] [ cannot-unify-specials ] }
        [ drop <computed> ]
    } cond ;

: unify-stacks ( seq -- stack )
    flip [ unify-values ] V{ } map-as ;

: balanced? ( in out -- ? )
    [ dup [ length - ] [ 2drop f ] if ] 2map
    sift all-equal? ;

TUPLE: unbalanced-branches-error quots in out ;

: unbalanced-branches-error ( quots in out -- * )
    \ unbalanced-branches-error inference-error ;

: unify-inputs ( max-d-in d-in meta-d -- meta-d )
    dup [
        [ [ - ] dip length + ] keep add-inputs nip
    ] [
        2nip
    ] if ;

: unify-effect ( quots in out -- newin newout )
    #! in is a sequence of integers, out is a sequence of
    #! stacks.
    2dup balanced? [
        over supremum -rot
        [ >r dupd r> unify-inputs ] 2map
        sift unify-stacks
        rot drop
    ] [
        unbalanced-branches-error
    ] if ;

: active-variable ( seq symbol -- seq )
    [
        swap terminated? over at [ 2drop f ] [ at ] if
    ] curry map ;

: branch-variable ( seq symbol -- seq )
    [ swap at ] curry map ;

: datastack-effect ( seq -- )
    [ quotation branch-variable ]
    [ d-in branch-variable ]
    [ meta-d active-variable ] tri
    unify-effect
    [ d-in set ] [ meta-d set ] bi* ;

: retainstack-effect ( seq -- )
    [ quotation branch-variable ]
    [ length 0 <repetition> ]
    [ meta-r active-variable ] tri
    unify-effect
    [ drop ] [ meta-r set ] bi* ;

: unify-effects ( seq -- )
    [ datastack-effect ]
    [ retainstack-effect ]
    [ [ terminated? swap at ] all? terminated? set ]
    tri ;

: unify-dataflow ( effects -- nodes )
    dataflow-graph branch-variable ;

: copy-inference ( -- )
    meta-d [ clone ] change
    meta-r [ clone ] change
    d-in [ ] change
    dataflow-graph off
    current-node off ;

: infer-branch ( last value -- namespace )
    [
        copy-inference

        [ value-literal quotation set ]
        [ infer-quot-value ]
        bi

        terminated? get [ drop ] [ call node, ] if
    ] H{ } make-assoc ; inline

: (infer-branches) ( last branches -- list )
    [ infer-branch ] with map
    [ unify-effects ] [ unify-dataflow ] bi ; inline

: infer-branches ( last branches node -- )
    #! last is a quotation which provides a #return or a #values
    1 reify-curries
    call dup node,
    pop-d drop
    >r (infer-branches) r> set-node-children
    #merge node, ; inline

: make-call-node ( word effect -- )
    swap dup inline?
    over dup recursive-label eq? not and [
        meta-d get clone -rot
        recursive-label #call-label [ consume/produce ] keep
        set-node-in-d
    ] [
        over effect-in length reify-curries
        #call consume/produce
    ] if ;

TUPLE: cannot-infer-effect word ;

: cannot-infer-effect ( word -- * )
    \ cannot-infer-effect inference-warning ;

TUPLE: effect-error word inferred declared ;

: effect-error ( word inferred declared -- * )
    \ effect-error inference-error ;

TUPLE: missing-effect word ;

: effect-required? ( word -- ? )
    {
        { [ dup inline? ] [ drop f ] }
        { [ dup deferred? ] [ drop f ] }
        { [ dup crossref? not ] [ drop f ] }
        [ word-def [ [ word? ] [ primitive? not ] bi and ] contains? ]
    } cond ;

: ?missing-effect ( word -- )
    dup effect-required?
    [ missing-effect inference-error ] [ drop ] if ;

: check-effect ( word effect -- )
    over stack-effect {
        { [ dup not ] [ 2drop ?missing-effect ] }
        { [ 2dup effect<= ] [ 3drop ] }
        [ effect-error ]
    } cond ;

: finish-word ( word -- )
    current-effect
    [ check-effect ]
    [ drop recorded get push ]
    [ "inferred-effect" set-word-prop ]
    2tri ;

: maybe-cannot-infer ( word quot -- )
    [ ] [ t "cannot-infer" set-word-prop ] cleanup ; inline

: infer-word ( word -- effect )
    [
        [
            init-inference
            dependencies off
            dup word-def over dup infer-quot-recursive
            end-infer
            finish-word
            current-effect
        ] with-scope
    ] maybe-cannot-infer ;

: custom-infer ( word -- )
    #! Customized inference behavior
    [ +inlined+ depends-on ] [ "infer" word-prop call ] bi ;

: cached-infer ( word -- )
    dup "inferred-effect" word-prop make-call-node ;

: apply-word ( word -- )
    {
        { [ dup "infer" word-prop ] [ custom-infer ] }
        { [ dup "cannot-infer" word-prop ] [ cannot-infer-effect ] }
        { [ dup "inferred-effect" word-prop ] [ cached-infer ] }
        [ dup infer-word make-call-node ]
    } cond ;

: declared-infer ( word -- )                       
    dup stack-effect [
        make-call-node
    ] [
        \ missing-effect inference-error
    ] if* ;

GENERIC: collect-label-info* ( label node -- )

M: node collect-label-info* 2drop ;

: (collect-label-info) ( label node vector -- )
    >r tuck [ param>> ] bi@ eq? r> [ push ] curry [ drop ] if ;
    inline

M: #call-label collect-label-info*
    over calls>> (collect-label-info) ;

M: #return collect-label-info*
    over returns>> (collect-label-info) ;

: collect-label-info ( #label -- )
    V{ } clone >>calls
    V{ } clone >>returns
    dup [ collect-label-info* ] with each-node ;

: nest-node ( -- ) #entry node, ;

: unnest-node ( new-node -- new-node )
    dup node-param #return node,
    dataflow-graph get 1array over set-node-children ;

: inlined-block? ( word -- ? )
    "inlined-block" word-prop ;

: <inlined-block> ( -- word )
    gensym dup t "inlined-block" set-word-prop ;

: inline-block ( word -- #label data )
    [
        copy-inference nest-node
        [ word-def ] [ <inlined-block> ] bi
        [ infer-quot-recursive ] 2keep
        #label unnest-node
        dup collect-label-info
    ] H{ } make-assoc ;

: join-values ( #label -- )
    calls>> [ in-d>> ] map meta-d get suffix
    unify-lengths unify-stacks
    meta-d [ length tail* ] change ;

: splice-node ( node -- )
    dup successor>> [
        [ node, ] [ penultimate-node ] bi
        f >>successor
        current-node set
    ] [ drop ] if ;

: apply-infer ( data -- )
    { meta-d meta-r d-in terminated? } swap extract-keys
    namespace swap update ;

: current-stack-height ( -- n )
    d-in get meta-d get length - ;

: word-stack-height ( word -- n )
    stack-effect effect-height ;

: bad-recursive-declaration ( word inferred -- )
    dup 0 < [ 0 swap ] [ 0 ] if <effect>
    over stack-effect
    effect-error ;

: check-stack-height ( word height -- )
    over word-stack-height over =
    [ 2drop ] [ bad-recursive-declaration ] if ;

: inline-recursive-word ( word #label -- )
    current-stack-height [
        flatten-meta-d [ join-values inline-block apply-infer ] dip >>in-d
        [ node, ]
        [ calls>> [ [ flatten-curries ] modify-values ] each ]
        [ word>> ]
        tri
    ] dip
    current-stack-height -
    check-stack-height ;

: inline-word ( word -- )
    dup inline-block over recursive-label?
    [ drop inline-recursive-word ]
    [ apply-infer node-child successor>> splice-node drop ] if ;

M: word apply-object
    [
        dup +inlined+ depends-on
        dup inline-recursive-label
        [ declared-infer ] [ inline-word ] if
    ] [
        dup +called+ depends-on
        dup recursive-label
        [ declared-infer ] [ apply-word ] if
    ] if-inline ;

: with-infer ( quot -- effect dataflow )
    [
        [
            V{ } clone recorded set
            init-inference
            call
            end-infer
            current-effect
            dataflow-graph get
        ] [ ] [ undo-infer ] cleanup
    ] with-scope ;
