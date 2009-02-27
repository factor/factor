! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators kernel math
quotations sequences regexp.classes fry arrays regexp.matchers
combinators.short-circuit prettyprint regexp.nfa ;
IN: regexp.traversal

TUPLE: dfa-traverser
    dfa-table
    current-state
    text
    current-index
    match-index ;

: <dfa-traverser> ( start-index text dfa -- match )
    dfa-traverser new
        swap [ start-state>> >>current-state ] [ >>dfa-table ] bi
        swap >>text
        swap >>current-index ;

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

: save-final-state ( dfa-traverser -- dfa-traverser )
    dup current-index>> >>match-index ;

: match-done? ( dfa-traverser -- ? )
    dup final-state? [ save-final-state ] when text-finished? ;

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

TUPLE: dfa-matcher dfa ;
C: <dfa-matcher> dfa-matcher
M: dfa-matcher match-index-from
    dfa>> <dfa-traverser> do-match match-index>> ;
