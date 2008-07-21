! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry arrays generic assocs kernel math namespaces parser
sequences words vectors math.intervals effects classes
accessors combinators compiler.tree ;
IN: compiler.tree.combinators

: node-exists? ( node quot -- ? )
    over [
        2dup 2slip rot [
            2drop t
        ] [
            [ [ children>> ] [ successor>> ] bi suffix ] dip
            '[ , node-exists? ] contains?
        ] if
    ] [
        2drop f
    ] if ; inline

SYMBOL: node-stack

: >node ( node -- ) node-stack get push ;
: node> ( -- node ) node-stack get pop ;
: node@ ( -- node ) node-stack get peek ;

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
            '[ , map ] change-children drop
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

: tail-call? ( -- ? )
    #! We don't consider calls which do non-local exits to be
    #! tail calls, because this gives better error traces.
    node-stack get [
        successor>> [ #tail? ] [ #terminate? not ] bi and
    ] all? ;
