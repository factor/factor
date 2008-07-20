! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors namespaces assocs dequeues search-dequeues
kernel sequences words sets stack-checker.inlining compiler.tree
compiler.tree.combinators compiler.tree.def-use ;
IN: compiler.tree.dead-code

! Dead code elimination: remove #push and flushable #call whose
! outputs are unused.

SYMBOL: live-values
SYMBOL: work-list

: live-value? ( value -- ? )
    live-values get at ;

: look-at-value ( values -- )
    work-list get push-front ;

: look-at-values ( values -- )
    work-list get '[ , push-front ] each ;

GENERIC: mark-live-values ( node -- )

: look-at-inputs ( node -- ) in-d>> look-at-values ;

: look-at-outputs ( node -- ) out-d>> look-at-values ;

M: #introduce mark-live-values look-at-outputs ;

M: #if mark-live-values look-at-inputs ;

M: #dispatch mark-live-values look-at-inputs ;

M: #call mark-live-values
    dup word>> "flushable" word-prop [ drop ] [
        [ look-at-inputs ]
        [ look-at-outputs ]
        bi
    ] if ;

M: #return mark-live-values
    #! Values returned by local #recursive functions can be
    #! killed if they're unused.
    dup label>>
    [ drop ] [ look-at-inputs ] if ;

M: node mark-live-values drop ;

GENERIC: propagate* ( value node -- )

M: #copy propagate*
    #! If the output of a copy is live, then the corresponding
    #! input is live also.
    [ out-d>> index ] keep in-d>> nth look-at-value ;

M: #call propagate*
    #! If any of the outputs of a call are live, then all
    #! inputs and outputs must be live.
    nip [ look-at-inputs ] [ look-at-outputs ] bi ;

M: #call-recursive propagate*
    #! If the output of a copy is live, then the corresponding
    #! inputs to #return nodes are live also.
    [ out-d>> <reversed> index ] keep label>> returns>>
    [ <reversed> nth look-at-value ] with each ;

M: #>r propagate* nip in-d>> first look-at-value ;

M: #r> propagate* nip in-r>> first look-at-value ;

M: #shuffle propagate* mapping>> at look-at-value ;

: look-at-corresponding ( value inputs outputs -- )
    [ index ] dip over [ nth look-at-values ] [ 2drop ] if ;

M: #phi propagate*
    #! If any of the outputs of a #phi are live, then the
    #! corresponding inputs are live too.
    [ [ out-d>> ] [ phi-in-d>> flip ] bi look-at-corresponding ]
    [ [ out-r>> ] [ phi-in-r>> flip ] bi look-at-corresponding ]
    2bi ;

M: node propagate* 2drop ;

: propogate-liveness ( value -- )
    live-values get 2dup key? [
        2drop
    ] [
        dupd conjoin
        dup defined-by propagate*
    ] if ;

: compute-live-values ( node -- )
    #! We add f initially because #phi nodes can have f in their
    #! inputs.
    <hashed-dlist> work-list set
    H{ { f f } } clone live-values set
    [ mark-live-values ] each-node
    work-list get [ propogate-liveness ] slurp-dequeue ;

GENERIC: remove-dead-values* ( node -- )

M: #>r remove-dead-values*
    dup out-r>> first live-value? [ { } >>out-r ] unless
    dup in-d>> first live-value? [ { } >>in-d ] unless
    drop ;

M: #r> remove-dead-values*
    dup out-d>> first live-value? [ { } >>out-d ] unless
    dup in-r>> first live-value? [ { } >>in-r ] unless
    drop ;

M: #push remove-dead-values*
    dup out-d>> first live-value? [ { } >>out-d ] unless
    drop ;

: filter-corresponding-values ( in out -- in' out' )
    zip live-values get '[ drop _ , key? ] assoc-filter unzip ;

: remove-dead-copies ( node -- )
    dup
    [ in-d>> ] [ out-d>> ] bi
    filter-corresponding-values
    [ >>in-d ] [ >>out-d ] bi*
    drop ;

: filter-live ( values -- values' )
    [ live-value? ] filter ;

M: #shuffle remove-dead-values*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    drop ;

M: #declare remove-dead-values* remove-dead-copies ;

M: #copy remove-dead-values* remove-dead-copies ;

: remove-dead-phi-d ( #phi -- #phi )
    dup
    [ phi-in-d>> flip ] [ out-d>> ] bi
    filter-corresponding-values
    [ flip >>phi-in-d ] [ >>out-d ] bi* ;

: remove-dead-phi-r ( #phi -- #phi )
    dup
    [ phi-in-r>> flip ] [ out-r>> ] bi
    filter-corresponding-values
    [ flip >>phi-in-r ] [ >>out-r ] bi* ;

M: #phi remove-dead-values*
    remove-dead-phi-d
    remove-dead-phi-r
    drop ;

M: node remove-dead-values* drop ;

GENERIC: remove-dead-nodes* ( node -- newnode/t )

: live-call? ( #call -- ? )
    out-d>> [ live-value? ] contains? ;

M: #call remove-dead-nodes*
    dup live-call? [ drop t ] [
        [ in-d>> #drop ] [ successor>> ] bi >>successor
    ] if ;

: prune-if ( node quot -- successor/t )
    over >r call [ r> successor>> ] [ r> drop t ] if ;
    inline

M: #shuffle remove-dead-nodes* 
    [ in-d>> empty? ] prune-if ;

M: #push remove-dead-nodes*
    [ out-d>> empty? ] prune-if ;

M: #>r remove-dead-nodes*
    [ in-d>> empty? ] prune-if ;

M: #r> remove-dead-nodes*
    [ in-r>> empty? ] prune-if ;

M: node remove-dead-nodes* drop t ;

: (remove-dead-code) ( node -- newnode )
    dup [
        dup remove-dead-values*
        dup remove-dead-nodes* dup t eq? [
            drop dup [ (remove-dead-code) ] map-children
        ] [
            nip (remove-dead-code)
        ] if
    ] when ;

: remove-dead-code ( node -- newnode )
    [
        [ compute-live-values ]
        [ [ (remove-dead-code) ] transform-nodes ] bi
    ] with-scope ;
