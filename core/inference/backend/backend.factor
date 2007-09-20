! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference.backend
USING: inference.dataflow arrays generic io io.streams.string
kernel math math.vectors namespaces parser prettyprint sequences
strings vectors words quotations effects classes continuations
debugger assocs combinators ;

: recursive-label ( word -- label/f )
    recursive-state get at ;

: local-recursive-state ( -- assoc )
    recursive-state get dup keys
    [ dup word? [ "inline" word-prop ] when not ] find drop
    [ head-slice ] when* ;

: inline-recursive-label ( word -- label/f )
    local-recursive-state at ;

: recursive-quotation? ( quot -- ? )
    local-recursive-state [ first eq? ] curry* contains? ;

: add-recursive-state ( word label -- )
    2array recursive-state [ swap add* ] change ;

TUPLE: inference-error rstate major? ;

: (inference-error) ( ... class important? -- * )
    >r construct-boa r>
    recursive-state get {
        set-delegate
        set-inference-error-major?
        set-inference-error-rstate
    } \ inference-error construct throw ; inline

: inference-error ( ... class -- * )
    t (inference-error) ; inline

: inference-warning ( ... class -- * )
    f (inference-error) ; inline

TUPLE: literal-expected ;

M: object value-literal \ literal-expected inference-warning ;

: pop-literal ( -- rstate obj )
    1 #drop node,
    pop-d dup value-literal >r value-recursion r> ;

: value-vector ( n -- vector ) [ drop <computed> ] V{ } map-as ;

: add-inputs ( seq stack -- n stack )
    tuck [ length ] compare dup 0 >
    [ dup value-vector [ swapd push-all ] keep ]
    [ drop 0 swap ] if ;

: ensure-values ( seq -- )
    meta-d [ add-inputs ] change d-in [ + ] change ;

SYMBOL: terminated?

: current-effect ( -- effect )
    d-in get meta-d get length <effect>
    terminated? get over set-effect-terminated? ;

SYMBOL: recorded

: init-inference ( recursive-state -- )
    terminated? off
    V{ } clone meta-d set
    V{ } clone meta-r set
    0 d-in set
    recursive-state set
    dataflow-graph off
    current-node off ;

GENERIC: apply-object ( obj -- )

: apply-literal ( obj -- )
    <value> push-d #push 1 0 pick node-outputs node, ;

M: object apply-object apply-literal ;

M: wrapper apply-object wrapped apply-literal ;

: terminate ( -- )
    terminated? on #terminate node, ;

: infer-quot ( quot -- )
    [ apply-object terminated? get not ] all? drop ;

TUPLE: recursive-quotation-error quot ;

: bad-call ( -- )
    [ "call must be given a callable" throw ] infer-quot ;

: infer-quot-value ( value -- )
    dup recursive-quotation? [
        value-literal recursive-quotation-error inference-error
    ] [
        dup value-literal callable? [
            recursive-state get >r
            [
                [ value-recursion ] keep f 2array add*
                recursive-state set
            ] keep value-literal infer-quot
            r> recursive-state set
        ] [
            drop bad-call
        ] if
    ] if ;

TUPLE: too-many->r ;

: check->r ( -- )
    meta-r get empty? terminated? get or
    [ \ too-many->r inference-error ] unless ;

TUPLE: too-many-r> ;

: check-r> ( -- )
    meta-r get empty?
    [ \ too-many-r> inference-error ] when ;

: infer->r ( -- )
    1 ensure-values
    #>r
    1 0 pick node-inputs
    pop-d push-r
    0 1 pick node-outputs
    node, ;

: infer-r> ( -- )
    check-r>
    #r>
    0 1 pick node-inputs
    pop-r push-d
    1 0 pick node-outputs
    node, ;

: undo-infer ( -- )
    recorded get [ f "inferred-effect" set-word-prop ] each ;

: with-infer ( quot -- )
    [
        [
            { } recursive-state set
            V{ } clone recorded set
            f init-inference
            call
            check->r
        ] [ ] [ undo-infer ] cleanup
    ] with-scope ;

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
    >r >r dup "inline" word-prop r> r> if ; inline

: consume/produce ( effect node -- )
    over effect-in over consume-values
    over effect-out over produce-values
    node,
    effect-terminated? [ terminate ] when ;

GENERIC: constructor ( value -- word/f )

GENERIC: infer-uncurry ( value -- )

M: curried infer-uncurry
    drop pop-d dup curried-obj push-d curried-quot push-d ;

M: curried constructor
    drop \ curry ;

M: composed infer-uncurry
    drop pop-d dup composed-quot1 push-d composed-quot2 push-d ;

M: composed constructor
    drop \ compose ;

M: object infer-uncurry drop ;

M: object constructor drop f ;

: reify-curry ( value -- )
    dup infer-uncurry
    constructor [
        peek-d reify-curry
        infer->r
        peek-d reify-curry
        infer-r>
        2 1 <effect> swap #call consume/produce
    ] when* ;

: reify-curries ( n -- )
    meta-d get reverse [
        dup special? [
            over [ infer->r ] times
            dup reify-curry
            over [ infer-r> ] times
        ] when 2drop
    ] 2each ;

: reify-all ( -- )
    meta-d get length reify-curries ;

: unify-lengths ( seq -- newseq )
    dup empty? [
        dup [ length ] map supremum
        [ swap add-inputs nip ] curry map
    ] unless ;

DEFER: unify-values

: unify-curries ( seq -- value )
    dup [ curried-obj ] map unify-values
    swap [ curried-quot ] map unify-values
    <curried> ;

: unify-composed ( seq -- value )
    dup [ composed-quot1 ] map unify-values
    swap [ composed-quot2 ] map unify-values
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
        { [ t ] [ drop <computed> ] }
    } cond ;

: unify-stacks ( seq -- stack )
    flip [ unify-values ] V{ } map-as ;

: balanced? ( in out -- ? )
    [ dup [ length - ] [ 2drop f ] if ] 2map
    [ ] subset all-equal? ;

TUPLE: unbalanced-branches-error quots in out ;

: unbalanced-branches-error ( quots in out -- * )
    \ unbalanced-branches-error inference-error ;

: unify-inputs ( max-d-in d-in meta-d -- meta-d )
    dup [
        [ >r - r> length + ] keep add-inputs nip
    ] [
        2nip
    ] if ;

: unify-effect ( quots in out -- newin newout )
    #! in is a sequence of integers, out is a sequence of
    #! stacks.
    2dup balanced? [
        over supremum -rot
        [ >r dupd r> unify-inputs ] 2map
        [ ] subset unify-stacks
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
    dup quotation branch-variable
    over d-in branch-variable
    rot meta-d active-variable
    unify-effect meta-d set d-in set ;

: retainstack-effect ( seq -- )
    dup quotation branch-variable
    over length 0 <repetition>
    rot meta-r active-variable
    unify-effect meta-r set drop ;

: unify-effects ( seq -- )
    dup datastack-effect
    dup retainstack-effect
    [ terminated? swap at ] all? terminated? set ;

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
        dup value-literal quotation set
        infer-quot-value
        terminated? get [ drop ] [ call node, ] if
    ] H{ } make-assoc ; inline

: (infer-branches) ( last branches -- list )
    [ infer-branch ] curry* map
    dup unify-effects unify-dataflow ; inline

: infer-branches ( last branches node -- )
    #! last is a quotation which provides a #return or a #values
    1 reify-curries
    call dup node,
    pop-d drop
    >r (infer-branches) r> set-node-children
    #merge node, ; inline

: make-call-node ( word effect -- )
    swap dup "inline" word-prop
    over dup recursive-label eq? not and [
        meta-d get clone -rot
        recursive-label #call-label [ consume/produce ] keep
        set-node-in-d
    ] [
        over effect-in length reify-curries
        #call consume/produce
    ] if ;

TUPLE: no-effect word ;

: no-effect ( word -- * ) \ no-effect inference-warning ;

: nest-node ( -- ) #entry node, ;

: unnest-node ( new-node -- new-node )
    dup node-param #return node,
    dataflow-graph get 1array over set-node-children ;

: inline-block ( word -- node-block data )
    [
        copy-inference nest-node
        gensym 2dup add-recursive-state
        over >r #label r> word-def infer-quot
        unnest-node
    ] H{ } make-assoc ;

: apply-infer ( hash -- )
    { meta-d meta-r d-in terminated? }
    [ swap [ at ] curry map ] keep
    [ set ] 2each ;

GENERIC: collect-recursion* ( label node -- )

M: node collect-recursion* 2drop ;

M: #call-label collect-recursion*
    tuck node-param eq? [ , ] [ drop ] if ;

: collect-recursion ( #label -- seq )
    dup node-param
    [ [ swap collect-recursion* ] curry each-node ] { } make ;

: join-values ( node -- )
    collect-recursion [ node-in-d ] map meta-d get add
    unify-lengths unify-stacks
    meta-d [ length tail* ] change ;

: splice-node ( node -- )
    dup node-successor [
        dup node, penultimate-node f over set-node-successor
        dup current-node set
    ] when drop ;

: inline-closure ( word -- )
    dup inline-block over recursive-label? [
        flatten-meta-d >r
        drop join-values inline-block apply-infer
        r> over set-node-in-d
        dup node,
        collect-recursion [
            [ flatten-curries ] modify-values
        ] each
    ] [
        apply-infer node-child node-successor splice-node drop
    ] if ;

: infer-compound ( word -- hash )
    [
        recursive-state get init-inference inline-block nip
    ] with-scope ;

GENERIC: infer-word ( word -- effect )

M: word infer-word no-effect ;

TUPLE: effect-error word effect ;

: effect-error ( word effect -- * )
    \ effect-error inference-error ;

: check-effect ( word effect -- )
    dup pick "declared-effect" word-prop effect<=
    [ 2drop ] [ effect-error ] if ;

: finish-word ( word -- effect )
    current-effect
    2dup check-effect
    over recorded get push
    tuck "inferred-effect" set-word-prop ;

M: compound infer-word
    [ dup infer-compound [ finish-word ] bind ]
    [ ] [ t "no-effect" set-word-prop ] cleanup ;

: custom-infer ( word -- )
    #! Customized inference behavior
    "infer" word-prop call ;

: cached-infer ( word -- )
    dup "inferred-effect" word-prop make-call-node ;

: apply-word ( word -- )
    {
        { [ dup "infer" word-prop ] [ custom-infer ] }
        { [ dup "no-effect" word-prop ] [ no-effect ] }
        { [ dup "inferred-effect" word-prop ] [ cached-infer ] }
        { [ t ] [ dup infer-word make-call-node ] }
    } cond ;

M: word apply-object apply-word ;

M: symbol apply-object apply-literal ;

TUPLE: recursive-declare-error word ;

: declared-infer ( word -- )
    dup stack-effect [
        make-call-node
    ] [
        \ recursive-declare-error inference-error
    ] if* ;

M: compound apply-object
    [
        dup inline-recursive-label
        [ declared-infer ] [ inline-closure ] if
    ] [
        dup recursive-label
        [ declared-infer ] [ apply-word ] if
    ] if-inline ;

M: undefined apply-object
    drop [ "Undefined" throw ] infer-quot ;
