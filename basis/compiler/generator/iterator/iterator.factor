! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences cursors kernel compiler.tree ;
IN: compiler.generator.iterator

SYMBOL: node-stack

: >node ( cursor -- ) node-stack get push ;
: node> ( -- cursor ) node-stack get pop ;
: node@ ( -- cursor ) node-stack get peek ;
: current-node ( -- node ) node@ value ;

: iterate-next ( -- cursor ) node@ next ;

: iterate-nodes ( cursor quot: ( -- ) -- )
    over [
        [ swap >node call node> drop ] keep iterate-nodes
    ] [
        2drop
    ] if ; inline recursive

: with-node-iterator ( quot -- )
    >r V{ } clone node-stack r> with-variable ; inline

DEFER: (tail-call?)

: tail-phi? ( cursor -- ? )
    [ value #phi? ] [ next (tail-call?) ] bi and ;

: (tail-call?) ( cursor -- ? )
    dup [
        [ value [ #return? ] [ #terminate? ] bi or ]
        [ tail-phi? ]
        bi or
    ] [ drop t ] if ;

: tail-call? ( -- ? )
    node-stack get [
        next
        dup [
            [ (tail-call?) ]
            [ value #terminate? not ]
            bi and
        ] [ drop t ] if
    ] all? ;
