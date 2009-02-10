! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators kernel math
quotations sequences regexp.parser regexp.classes fry arrays
combinators.short-circuit regexp.utils prettyprint regexp.nfa ;
IN: regexp.traversal

TUPLE: dfa-traverser
    dfa-table
    traversal-flags
    traverse-forward
    lookahead-counters
    lookbehind-counters
    capture-counters
    captured-groups
    capture-group-index
    last-state current-state
    text
    match-failed?
    start-index current-index
    matches ;

: <dfa-traverser> ( text regexp -- match )
    [ dfa-table>> ] [ dfa-traversal-flags>> ] bi
    dfa-traverser new
        swap >>traversal-flags
        swap [ start-state>> >>current-state ] [ >>dfa-table ] bi
        swap >>text
        t >>traverse-forward
        0 >>start-index
        0 >>current-index
        0 >>capture-group-index
        V{ } clone >>matches
        V{ } clone >>capture-counters
        V{ } clone >>lookbehind-counters
        V{ } clone >>lookahead-counters
        H{ } clone >>captured-groups ;

: final-state? ( dfa-traverser -- ? )
    [ current-state>> ]
    [ dfa-table>> final-states>> ] bi key? ;

: beginning-of-text? ( dfa-traverser -- ? )
    current-index>> 0 <= ; inline

: end-of-text? ( dfa-traverser -- ? )
    [ current-index>> ] [ text>> length ] bi >= ; inline

: text-finished? ( dfa-traverser -- ? )
    {
        [ current-state>> empty? ]
        [ end-of-text? ]
        [ match-failed?>> ]
    } 1|| ;

: save-final-state ( dfa-straverser -- )
    [ current-index>> ] [ matches>> ] bi push ;

: match-done? ( dfa-traverser -- ? )
    dup final-state? [
        dup save-final-state
    ] when text-finished? ;

: previous-text-character ( dfa-traverser -- ch )
    [ text>> ] [ current-index>> 1- ] bi nth ;

: current-text-character ( dfa-traverser -- ch )
    [ text>> ] [ current-index>> ] bi nth ;

: next-text-character ( dfa-traverser -- ch )
    [ text>> ] [ current-index>> 1+ ] bi nth ;

GENERIC: flag-action ( dfa-traverser flag -- )


M: beginning-of-input flag-action ( dfa-traverser flag -- )
    drop
    dup beginning-of-text? [ t >>match-failed? ] unless drop ;

M: end-of-input flag-action ( dfa-traverser flag -- )
    drop
    dup end-of-text? [ t >>match-failed? ] unless drop ;


M: beginning-of-line flag-action ( dfa-traverser flag -- )
    drop
    dup {
        [ beginning-of-text? ]
        [ previous-text-character terminator-class class-member? ]
    } 1|| [ t >>match-failed? ] unless drop ;

M: end-of-line flag-action ( dfa-traverser flag -- )
    drop
    dup {
        [ end-of-text? ]
        [ next-text-character terminator-class class-member? ]
    } 1|| [ t >>match-failed? ] unless drop ;


M: word-boundary flag-action ( dfa-traverser flag -- )
    drop
    dup {
        [ end-of-text? ]
        [ current-text-character terminator-class class-member? ]
    } 1|| [ t >>match-failed? ] unless drop ;


M: lookahead-on flag-action ( dfa-traverser flag -- )
    drop
    lookahead-counters>> 0 swap push ;

M: lookahead-off flag-action ( dfa-traverser flag -- )
    drop
    dup lookahead-counters>>
    [ drop ] [ pop '[ _ - ] change-current-index drop ] if-empty ;

M: lookbehind-on flag-action ( dfa-traverser flag -- )
    drop
    f >>traverse-forward
    [ 2 - ] change-current-index
    lookbehind-counters>> 0 swap push ;

M: lookbehind-off flag-action ( dfa-traverser flag -- )
    drop
    t >>traverse-forward
    dup lookbehind-counters>>
    [ drop ] [ pop '[ _ + 2 + ] change-current-index drop ] if-empty ;

M: capture-group-on flag-action ( dfa-traverser flag -- )
    drop
    [ current-index>> 0 2array ]
    [ capture-counters>> ] bi push ;

M: capture-group-off flag-action ( dfa-traverser flag -- )
    drop
    dup capture-counters>> empty? [
        drop
    ] [
        {
            [ capture-counters>> pop first2 dupd + ]
            [ text>> <slice> ]
            [ [ 1+ ] change-capture-group-index capture-group-index>> ]
            [ captured-groups>> set-at ]
        } cleave
    ] if ;

: process-flags ( dfa-traverser -- )
    [ [ 1+ ] map ] change-lookahead-counters
    [ [ 1+ ] map ] change-lookbehind-counters
    [ [ first2 1+ 2array ] map ] change-capture-counters
    ! dup current-state>> .
    dup [ current-state>> ] [ traversal-flags>> ] bi
    at [ flag-action ] with each ;

: increment-state ( dfa-traverser state -- dfa-traverser )
    [
        dup traverse-forward>>
        [ [ 1+ ] change-current-index ]
        [ [ 1- ] change-current-index ] if
        dup current-state>> >>last-state
    ] [ first ] bi* >>current-state ;

: match-literal ( transition from-state table -- to-state/f )
    transitions>> at at ;

: match-class ( transition from-state table -- to-state/f )
    transitions>> at* [
        [ drop class-member? ] assoc-with assoc-find [ nip ] [ drop ] if
    ] [ drop ] if ;

: match-default ( transition from-state table -- to-state/f )
    [ drop ] 2dip transitions>> at t swap at ;

: match-transition ( obj from-state dfa -- to-state/f )
    { [ match-literal ] [ match-class ] [ match-default ] } 3|| ;

: setup-match ( match -- obj state dfa-table )
    [ [ current-index>> ] [ text>> ] bi nth ]
    [ current-state>> ]
    [ dfa-table>> ] tri ;

: do-match ( dfa-traverser -- dfa-traverser )
    dup process-flags
    dup match-done? [
        dup setup-match match-transition
        [ increment-state do-match ] when*
    ] unless ;

: return-match ( dfa-traverser -- slice/f )
    dup matches>>
    [ drop f ]
    [
        [ [ text>> ] [ start-index>> ] bi ]
        [ peek ] bi* rot <slice>
    ] if-empty ;
