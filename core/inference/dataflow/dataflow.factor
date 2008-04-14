! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs kernel math namespaces parser
sequences words vectors math.intervals effects classes
inference.state accessors combinators ;
IN: inference.dataflow

! Computed value
: <computed> \ <computed> counter ;

! Literal value
TUPLE: value < identity-tuple literal uid recursion ;

: <value> ( obj -- value )
    <computed> recursive-state get value boa ;

M: value hashcode* nip value-uid ;

! Result of curry
TUPLE: curried obj quot ;

C: <curried> curried

! Result of compose
TUPLE: composed quot1 quot2 ;

C: <composed> composed

UNION: special curried composed ;

TUPLE: node < identity-tuple
param
in-d out-d in-r out-r
classes literals intervals
history successor children ;

M: node hashcode* drop node hashcode* ;

GENERIC: flatten-curry ( value -- )

M: curried flatten-curry
    [ obj>> flatten-curry ]
    [ quot>> flatten-curry ] bi ;

M: composed flatten-curry
    [ quot1>> flatten-curry ]
    [ quot2>> flatten-curry ] bi ;

M: object flatten-curry , ;

: flatten-curries ( seq -- newseq )
    dup [ special? ] contains? [
        [ [ flatten-curry ] each ] { } make
    ] when ;

: flatten-meta-d ( -- seq )
    meta-d get clone flatten-curries ;

: modify-values ( node quot -- )
    {
        [ change-in-d ]
        [ change-in-r ]
        [ change-out-d ]
        [ change-out-r ]
    } cleave drop ; inline

: node-shuffle ( node -- shuffle )
    [ in-d>> ] [ out-d>> ] bi <effect> ;

: param-node ( param class -- node )
    new swap >>param ; inline

: in-node ( seq class -- node )
    new swap >>in-d ; inline

: all-in-node ( class -- node )
    flatten-meta-d swap in-node ; inline

: out-node ( seq class -- node )
    new swap >>out-d ; inline

: all-out-node ( class -- node )
    flatten-meta-d swap out-node ; inline

: d-tail ( n -- seq )
    dup zero? [ drop f ] [ meta-d get swap tail* ] if ;

: r-tail ( n -- seq )
    dup zero? [ drop f ] [ meta-r get swap tail* ] if ;

: node-child node-children first ;

TUPLE: #label < node word loop? ;

: #label ( word label -- node )
    \ #label param-node swap >>word ;

PREDICATE: #loop < #label #label-loop? ;

TUPLE: #entry < node ;

: #entry ( -- node ) \ #entry all-out-node ;

TUPLE: #call < node ;

: #call ( word -- node ) \ #call param-node ;

TUPLE: #call-label < node ;

: #call-label ( label -- node ) \ #call-label param-node ;

TUPLE: #push < node ;

: #push ( -- node ) \ #push new ;

TUPLE: #shuffle < node ;

: #shuffle ( -- node ) \ #shuffle new ;

TUPLE: #>r < node ;

: #>r ( -- node ) \ #>r new ;

TUPLE: #r> < node ;

: #r> ( -- node ) \ #r> new ;

TUPLE: #values < node ;

: #values ( -- node ) \ #values all-in-node ;

TUPLE: #return < node ;

: #return ( label -- node )
    \ #return all-in-node swap >>param ;

TUPLE: #branch < node ;

TUPLE: #if < #branch ;

: #if ( -- node ) peek-d 1array \ #if in-node ;

TUPLE: #dispatch < #branch ;

: #dispatch ( -- node ) peek-d 1array \ #dispatch in-node ;

TUPLE: #merge < node ;

: #merge ( -- node ) \ #merge all-out-node ;

TUPLE: #terminate < node ;

: #terminate ( -- node ) \ #terminate new ;

TUPLE: #declare < node ;

: #declare ( classes -- node ) \ #declare param-node ;

: node-inputs ( d-count r-count node -- )
    tuck
    [ swap d-tail flatten-curries >>in-d drop ]
    [ swap r-tail flatten-curries >>in-r drop ] 2bi* ;

: node-outputs ( d-count r-count node -- )
    tuck
    [ swap d-tail flatten-curries >>out-d drop ]
    [ swap r-tail flatten-curries >>out-r drop ] 2bi* ;

: node, ( node -- )
    dataflow-graph get [
        dup current-node [ set-node-successor ] change
    ] [
        dup dataflow-graph set  current-node set
    ] if ;

: node-values ( node -- values )
    { [ in-d>> ] [ out-d>> ] [ in-r>> ] [ out-r>> ] } cleave
    4array concat ;

: last-node ( node -- last )
    dup successor>> [ last-node ] [ ] ?if ;

: penultimate-node ( node -- penultimate )
    dup successor>> dup [
        dup successor>>
        [ nip penultimate-node ] [ drop ] if
    ] [
        2drop f
    ] if ;

: #drop ( n -- #shuffle )
    d-tail flatten-curries \ #shuffle in-node ;

: node-exists? ( node quot -- ? )
    over [
        2dup 2slip rot [
            2drop t
        ] [
            >r [ children>> ] [ successor>> ] bi suffix r>
            [ node-exists? ] curry contains?
        ] if
    ] [
        2drop f
    ] if ; inline

GENERIC: calls-label* ( label node -- ? )

M: node calls-label* 2drop f ;

M: #call-label calls-label* param>> eq? ;

: calls-label? ( label node -- ? )
    [ calls-label* ] with node-exists? ;

: recursive-label? ( node -- ? )
    [ param>> ] keep calls-label? ;

SYMBOL: node-stack

: >node node-stack get push ;
: node> node-stack get pop ;
: node@ node-stack get peek ;

: iterate-next ( -- node ) node@ successor>> ;

: iterate-nodes ( node quot -- )
    over [
        [ swap >node call node> drop ] keep iterate-nodes
    ] [
        2drop
    ] if ; inline

: (each-node) ( quot -- next )
    node@ [ swap call ] 2keep
    node-children [
        [
            [ (each-node) ] keep swap
        ] iterate-nodes
    ] each drop
    iterate-next ; inline

: with-node-iterator ( quot -- )
    >r V{ } clone node-stack r> with-variable ; inline

: each-node ( node quot -- )
    [
        swap [
            [ (each-node) ] keep swap
        ] iterate-nodes drop
    ] with-node-iterator ; inline

: map-children ( node quot -- )
    over [
        over children>> [
            [ map ] curry change-children drop
        ] [
            2drop
        ] if
    ] [
        2drop
    ] if ; inline

: (transform-nodes) ( prev node quot -- )
    dup >r call dup [
        >>successor
        successor>> dup successor>>
        r> (transform-nodes)
    ] [
        r> 2drop f >>successor drop
    ] if ; inline

: transform-nodes ( node quot -- new-node )
    over [
        [ call dup dup successor>> ] keep (transform-nodes)
    ] [ drop ] if ; inline

: node-literal? ( node value -- ? )
    dup value? >r swap literals>> key? r> or ;

: node-literal ( node value -- obj )
    dup value?
    [ nip value-literal ] [ swap literals>> at ] if ;

: node-interval ( node value -- interval )
    swap intervals>> at ;

: node-class ( node value -- class )
    swap classes>> at object or ;

: node-input-classes ( node -- seq )
    dup in-d>> [ node-class ] with map ;

: node-input-intervals ( node -- seq )
    dup in-d>> [ node-interval ] with map ;

: node-class-first ( node -- class )
    dup in-d>> first node-class ;

: active-children ( node -- seq )
    children>> [ last-node ] map [ #terminate? not ] subset ;

DEFER: #tail?

PREDICATE: #tail-merge < #merge node-successor #tail? ;

PREDICATE: #tail-values < #values node-successor #tail? ;

UNION: #tail
    POSTPONE: f #return #tail-values #tail-merge #terminate ;

: tail-call? ( -- ? )
    #! We don't consider calls which do non-local exits to be
    #! tail calls, because this gives better error traces.
    node-stack get [
        successor>> [ #tail? ] [ #terminate? not ] bi and
    ] all? ;
