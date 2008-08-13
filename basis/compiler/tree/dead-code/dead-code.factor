! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry accessors namespaces assocs dequeues search-dequeues
kernel sequences words sets arrays
stack-checker.state stack-checker.inlining
compiler.tree
compiler.tree.combinators
compiler.tree.dataflow-analysis
compiler.tree.dataflow-analysis.backward ;
IN: compiler.tree.dead-code

! Dead code elimination: remove #push and flushable #call whose
! outputs are unused using backward DFA.
GENERIC: mark-live-values ( node -- )

M: #if mark-live-values look-at-inputs ;

M: #dispatch mark-live-values look-at-inputs ;

M: #call mark-live-values
    dup word>> "flushable" word-prop
    [ drop ] [ look-at-inputs ] if ;

M: #alien-invoke mark-live-values look-at-inputs ;

M: #alien-indirect mark-live-values look-at-inputs ;

M: #return mark-live-values look-at-inputs ;

M: node mark-live-values drop ;

SYMBOL: live-values

: live-value? ( value -- ? ) live-values get at ;

GENERIC: remove-dead-code* ( node -- node' )

M: #introduce remove-dead-code*
    dup value>> live-value? [
        dup value>> 1array #drop 2array
    ] unless ;

: filter-live ( values -- values' )
    [ live-value? ] filter ;

M: #>r remove-dead-code*
    [ filter-live ] change-out-r
    [ filter-live ] change-in-d
    dup in-d>> empty? [ drop f ] when ;

M: #r> remove-dead-code*
    [ filter-live ] change-out-d
    [ filter-live ] change-in-r
    dup in-r>> empty? [ drop f ] when ;

M: #push remove-dead-code*
    dup out-d>> first live-value? [ drop f ] unless ;

: dead-flushable-call? ( #call -- ? )
    [ word>> "flushable" word-prop ]
    [ out-d>> [ live-value? not ] all? ] bi and ;

: remove-flushable-call ( #call -- node )
    in-d>> #drop remove-dead-code* ;

: some-outputs-dead? ( #call -- ? )
    out-d>> [ live-value? not ] contains? ;

: remove-dead-outputs ( #call -- nodes )
    [ out-d>> ] [ [ [ <value> ] replicate ] change-out-d ] bi
    [ nip ] [ out-d>> swap #copy remove-dead-code* ] 2bi
    2array ;

M: #call remove-dead-code*
    dup dead-flushable-call? [
        remove-flushable-call
    ] [
        dup some-outputs-dead? [
            remove-dead-outputs
        ] when
    ] if ;

M: #recursive remove-dead-code*
    [ filter-live ] change-in-d ;

M: #call-recursive remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d ;

M: #enter-recursive remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d ;

M: #return-recursive remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d ;

M: #shuffle remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    dup in-d>> empty? [ drop f ] when ;

M: #copy remove-dead-code*
    [ in-d>> ] [ out-d>> ] bi
    2dup swap zip #shuffle
    remove-dead-code* ;

: filter-corresponding-values ( in out -- in' out' )
    zip live-values get '[ drop _ , key? ] assoc-filter unzip ;

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

M: #phi remove-dead-code*
    remove-dead-phi-d
    remove-dead-phi-r ;

M: node remove-dead-code* ;

: remove-dead-code ( node -- newnode )
    [ [ mark-live-values ] backward-dfa live-values set ]
    [ [ remove-dead-code* ] map-nodes ]
    bi ;
