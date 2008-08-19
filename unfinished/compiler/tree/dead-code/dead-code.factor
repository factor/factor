! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors namespaces assocs dequeues search-dequeues
kernel sequences words sets stack-checker.inlining
compiler.tree
compiler.tree.combinators
compiler.tree.dataflow-analysis
compiler.tree.dataflow-analysis.backward ;
IN: compiler.tree.dead-code

! Dead code elimination: remove #push and flushable #call whose
! outputs are unused using backward DFA.
GENERIC: mark-live-values ( node -- )

M: #introduce mark-live-values
    value>> look-at-value ;

M: #if mark-live-values look-at-inputs ;

M: #dispatch mark-live-values look-at-inputs ;

M: #call mark-live-values
    dup word>> "flushable" word-prop
    [ drop ] [ [ look-at-inputs ] [ look-at-outputs ] bi ] if ;

M: #alien-invoke mark-live-values
    [ look-at-inputs ] [ look-at-outputs ] bi ;

M: #alien-indirect mark-live-values
    [ look-at-inputs ] [ look-at-outputs ] bi ;

M: #return mark-live-values
    look-at-inputs ;

M: node mark-live-values drop ;

SYMBOL: live-values

: live-value? ( value -- ? ) live-values get at ;

: compute-live-values ( node -- )
    [ mark-live-values ] backward-dfa live-values set ;

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

: filter-live ( values -- values' )
    [ live-value? ] filter ;

M: #call remove-dead-values*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    drop ;

M: #recursive remove-dead-values*
    [ filter-live ] change-in-d
    drop ;

M: #call-recursive remove-dead-values*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    drop ;

M: #enter-recursive remove-dead-values*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    drop ;

M: #return-recursive remove-dead-values*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    drop ;

M: #shuffle remove-dead-values*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    drop ;

M: #declare remove-dead-values*
    [ [ drop live-value? ] assoc-filter ] change-declaration
    drop ;

M: #copy remove-dead-values*
    dup
    [ in-d>> ] [ out-d>> ] bi
    filter-corresponding-values
    [ >>in-d ] [ >>out-d ] bi*
    drop ;

: remove-dead-phi-d ( #phi -- #phi )
    dup
    [ phi-in-d>> ] [ out-d>> ] bi
    filter-corresponding-values
    [ >>phi-in-d ] [ >>out-d ] bi* ;

: remove-dead-phi-r ( #phi -- #phi )
    dup
    [ phi-in-r>> ] [ out-r>> ] bi
    filter-corresponding-values
    [ >>phi-in-r ] [ >>out-r ] bi* ;

M: #phi remove-dead-values*
    remove-dead-phi-d
    remove-dead-phi-r
    drop ;

M: node remove-dead-values* drop ;

: remove-dead-values ( nodes -- )
    [ remove-dead-values* ] each-node ;

GENERIC: remove-dead-nodes* ( node -- node/f )

: prune-if-empty ( node seq -- node/f )
    empty? [ drop f ] when ; inline

: live-call? ( #call -- ? ) out-d>> [ live-value? ] contains? ;

M: #declare remove-dead-nodes* dup declaration>> prune-if-empty ;

M: #call remove-dead-nodes* dup live-call? [ in-d>> #drop ] unless ;

M: #shuffle remove-dead-nodes* dup in-d>> prune-if-empty ;

M: #push remove-dead-nodes* dup out-d>> prune-if-empty ;

M: #>r remove-dead-nodes* dup in-d>> prune-if-empty ;

M: #r> remove-dead-nodes* dup in-r>> prune-if-empty ;

M: #copy remove-dead-nodes* dup in-d>> prune-if-empty ;

M: node remove-dead-nodes* ;

: remove-dead-nodes ( nodes -- nodes' )
    [ remove-dead-nodes* ] map-nodes ;

: remove-dead-code ( node -- newnode )
    [ compute-live-values ]
    [ remove-dead-values ]
    [ remove-dead-nodes ]
    tri ;
