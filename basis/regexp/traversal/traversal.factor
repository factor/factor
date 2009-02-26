! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators kernel math
quotations sequences regexp.classes fry arrays
combinators.short-circuit prettyprint regexp.nfa ;
IN: regexp.traversal

TUPLE: dfa-traverser
    dfa-table
    current-state
    text
    start-index current-index
    matches ;

: <dfa-traverser> ( text dfa -- match )
    dfa-traverser new
        swap [ start-state>> >>current-state ] [ >>dfa-table ] bi
        swap >>text
        0 >>start-index
        0 >>current-index
        V{ } clone >>matches ;

: final-state? ( dfa-traverser -- ? )
    [ current-state>> ]
    [ dfa-table>> final-states>> ] bi key? ;

: end-of-text? ( dfa-traverser -- ? )
    [ current-index>> ] [ text>> length ] bi >= ; inline

: text-finished? ( dfa-traverser -- ? )
    {
        [ current-state>> not ]
        [ end-of-text? ]
    } 1|| ;

: save-final-state ( dfa-straverser -- )
    [ current-index>> ] [ matches>> ] bi push ;

: match-done? ( dfa-traverser -- ? )
    dup final-state? [
        dup save-final-state
    ] when text-finished? ;

: text-character ( dfa-traverser n -- ch )
    [ text>> ] swap '[ current-index>> _ + ] bi nth ;

: previous-text-character ( dfa-traverser -- ch )
    -1 text-character ;

: current-text-character ( dfa-traverser -- ch )
    0 text-character ;

: next-text-character ( dfa-traverser -- ch )
    1 text-character ;

: increment-state ( dfa-traverser state -- dfa-traverser )
    >>current-state
    [ 1 + ] change-current-index ;

: match-literal ( transition from-state table -- to-state/f )
    transitions>> at at ;

: match-class ( transition from-state table -- to-state/f )
    transitions>> at* [
        swap '[ drop _ swap class-member? ] assoc-find spin ?
    ] [ drop ] if ;

: match-transition ( obj from-state dfa -- to-state/f )
    { [ match-literal ] [ match-class ] } 3|| ;

: setup-match ( match -- obj state dfa-table )
    [ [ current-index>> ] [ text>> ] bi nth ]
    [ current-state>> ]
    [ dfa-table>> ] tri ;

: do-match ( dfa-traverser -- dfa-traverser )
    dup match-done? [
        dup setup-match match-transition
        [ increment-state do-match ] when*
    ] unless ;

: return-match ( dfa-traverser -- slice/f )
    dup matches>>
    [ drop f ]
    [
        [ [ start-index>> ] [ text>> ] bi ]
        [ peek ] bi* swap <slice>
    ] if-empty ;
