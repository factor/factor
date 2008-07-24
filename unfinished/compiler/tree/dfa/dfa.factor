! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors namespaces assocs dequeues search-dequeues
kernel sequences words sets stack-checker.inlining compiler.tree
compiler.tree.def-use compiler.tree.combinators ;
IN: compiler.tree.dfa

! Dataflow analysis
SYMBOL: work-list

: look-at-value ( values -- )
    work-list get push-front ;

: look-at-values ( values -- )
    work-list get '[ , push-front ] each ;

: look-at-inputs ( node -- ) in-d>> look-at-values ;

: look-at-outputs ( node -- ) out-d>> look-at-values ;

: look-at-corresponding ( value inputs outputs -- )
    [ index ] dip over [ nth look-at-values ] [ 2drop ] if ;

: init-dfa ( -- )
    #! We add f initially because #phi nodes can have f in their
    #! inputs.
    <hashed-dlist> work-list set ;

: iterate-dfa ( value assoc quot -- )
    2over key? [
        3drop
    ] [
        [ dupd conjoin dup defined-by ] dip call
    ] if ; inline

: dfa ( node mark-quot iterate-quot -- assoc )
    init-dfa
    [ each-node ] dip
    work-list get H{ { f f } } clone
    [ rot '[ , , iterate-dfa ] slurp-dequeue ] keep ; inline
