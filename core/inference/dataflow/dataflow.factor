! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs kernel math namespaces parser
sequences words vectors math.intervals effects classes
inference.state ;
IN: inference.dataflow

! Computed value
: <computed> \ <computed> counter ;

! Literal value
TUPLE: value literal uid recursion ;

: <value> ( obj -- value )
    <computed> recursive-state get value construct-boa ;

M: value hashcode* nip value-uid ;

M: value equal? 2drop f ;

! Result of curry
TUPLE: curried obj quot ;

C: <curried> curried

! Result of compose
TUPLE: composed quot1 quot2 ;

C: <composed> composed

UNION: special curried composed ;

TUPLE: node param
in-d out-d in-r out-r
classes literals intervals
history successor children ;

M: node equal? 2drop f ;

M: node hashcode* drop node hashcode* ;

GENERIC: flatten-curry ( value -- )

M: curried flatten-curry
    dup curried-obj flatten-curry
    curried-quot flatten-curry ;

M: composed flatten-curry
    dup composed-quot1 flatten-curry
    composed-quot2 flatten-curry ;

M: object flatten-curry , ;

: flatten-curries ( seq -- newseq )
    dup [ special? ] contains? [
        [ [ flatten-curry ] each ] { } make
    ] when ;

: flatten-meta-d ( -- seq )
    meta-d get clone flatten-curries ;

: modify-values ( node quot -- )
    [ swap [ node-in-d swap call ] keep set-node-in-d ] 2keep
    [ swap [ node-in-r swap call ] keep set-node-in-r ] 2keep
    [ swap [ node-out-d swap call ] keep set-node-out-d ] 2keep
    swap [ node-out-r swap call ] keep set-node-out-r ; inline

: node-shuffle ( node -- shuffle )
    dup node-in-d swap node-out-d <effect> ;

: make-node ( slots class -- node )
    >r node construct r> construct-delegate ; inline

: empty-node ( class -- node )
    { } swap make-node ; inline

: param-node ( param class -- node )
    { set-node-param } swap make-node ; inline

: in-node ( seq class -- node )
    { set-node-in-d } swap make-node ; inline

: all-in-node ( class -- node )
    flatten-meta-d swap in-node ; inline

: out-node ( seq class -- node )
    { set-node-out-d } swap make-node ; inline

: all-out-node ( class -- node )
    flatten-meta-d swap out-node ; inline

: d-tail ( n -- seq )
    dup zero? [ drop f ] [ meta-d get swap tail* ] if ;

: r-tail ( n -- seq )
    dup zero? [ drop f ] [ meta-r get swap tail* ] if ;

: node-child node-children first ;

TUPLE: #label word loop? ;

: #label ( word label -- node )
    \ #label param-node [ set-#label-word ] keep ;

PREDICATE: #loop < #label #label-loop? ;

TUPLE: #entry ;

: #entry ( -- node ) \ #entry all-out-node ;

TUPLE: #call ;

: #call ( word -- node ) \ #call param-node ;

TUPLE: #call-label ;

: #call-label ( label -- node ) \ #call-label param-node ;

TUPLE: #push ;

: #push ( -- node ) \ #push empty-node ;

TUPLE: #shuffle ;

: #shuffle ( -- node ) \ #shuffle empty-node ;

TUPLE: #>r ;

: #>r ( -- node ) \ #>r empty-node ;

TUPLE: #r> ;

: #r> ( -- node ) \ #r> empty-node ;

TUPLE: #values ;

: #values ( -- node ) \ #values all-in-node ;

TUPLE: #return ;

: #return ( label -- node )
    \ #return all-in-node [ set-node-param ] keep ;

TUPLE: #if ;

: #if ( -- node ) peek-d 1array \ #if in-node ;

TUPLE: #dispatch ;

: #dispatch ( -- node ) peek-d 1array \ #dispatch in-node ;

TUPLE: #merge ;

: #merge ( -- node ) \ #merge all-out-node ;

TUPLE: #terminate ;

: #terminate ( -- node ) \ #terminate empty-node ;

TUPLE: #declare ;

: #declare ( classes -- node ) \ #declare param-node ;

UNION: #branch #if #dispatch ;

: node-inputs ( d-count r-count node -- )
    tuck
    >r r-tail flatten-curries r> set-node-in-r
    >r d-tail flatten-curries r> set-node-in-d ;

: node-outputs ( d-count r-count node -- )
    tuck
    >r r-tail flatten-curries r> set-node-out-r
    >r d-tail flatten-curries r> set-node-out-d ;

: node, ( node -- )
    dataflow-graph get [
        dup current-node [ set-node-successor ] change
    ] [
        dup dataflow-graph set  current-node set
    ] if ;

: node-values ( node -- values )
    dup node-in-d
    over node-out-d
    pick node-in-r
    roll node-out-r 4array concat ;

: last-node ( node -- last )
    dup node-successor [ last-node ] [ ] ?if ;

: penultimate-node ( node -- penultimate )
    dup node-successor dup [
        dup node-successor
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
            >r dup node-children swap node-successor add r>
            [ node-exists? ] curry contains?
        ] if
    ] [
        2drop f
    ] if ; inline

GENERIC: calls-label* ( label node -- ? )

M: node calls-label* 2drop f ;

M: #call-label calls-label* node-param eq? ;

: calls-label? ( label node -- ? )
    [ calls-label* ] with node-exists? ;

: recursive-label? ( node -- ? )
    dup node-param swap calls-label? ;

SYMBOL: node-stack

: >node node-stack get push ;
: node> node-stack get pop ;
: node@ node-stack get peek ;

: iterate-next ( -- node ) node@ node-successor ;

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

: change-children ( node quot -- )
    over [
        >r dup node-children dup r>
        [ map swap set-node-children ] curry
        [ 2drop ] if
    ] [
        2drop
    ] if ; inline

: (transform-nodes) ( prev node quot -- )
    dup >r call dup [
        dup rot set-node-successor
        dup node-successor r> (transform-nodes)
    ] [
        r> drop f swap set-node-successor drop
    ] if ; inline

: transform-nodes ( node quot -- new-node )
    over [
        [ call dup dup node-successor ] keep (transform-nodes)
    ] [ drop ] if ; inline

: node-literal? ( node value -- ? )
    dup value? >r swap node-literals key? r> or ;

: node-literal ( node value -- obj )
    dup value?
    [ nip value-literal ] [ swap node-literals at ] if ;

: node-interval ( node value -- interval )
    swap node-intervals at ;

: node-class ( node value -- class )
    swap node-classes at object or ;

: node-input-classes ( node -- seq )
    dup node-in-d [ node-class ] with map ;

: node-input-intervals ( node -- seq )
    dup node-in-d [ node-interval ] with map ;

: node-class-first ( node -- class )
    dup node-in-d first node-class ;

: active-children ( node -- seq )
    node-children
    [ last-node ] map
    [ #terminate? not ] subset ;

DEFER: #tail?

PREDICATE: #tail-merge < #merge node-successor #tail? ;

PREDICATE: #tail-values < #values node-successor #tail? ;

UNION: #tail
    POSTPONE: f #return #tail-values #tail-merge #terminate ;

: tail-call? ( -- ? )
    #! We don't consider calls which do non-local exits to be
    #! tail calls, because this gives better error traces.
    node-stack get [
        node-successor dup #tail? swap #terminate? not and
    ] all? ;
