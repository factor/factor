! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.lib kernel
math math.ranges quotations sequences regexp2.parser
regexp2.classes combinators.short-circuit assocs.lib
sequences.lib regexp2.utils ;
IN: regexp2.traversal

TUPLE: dfa-traverser
    dfa-table
    traversal-flags
    capture-groups
    { capture-group-index integer }
    { lookahead-counter integer }
    last-state current-state
    text
    start-index current-index
    matches ;

: <dfa-traverser> ( text regexp -- match )
    [ dfa-table>> ] [ traversal-flags>> ] bi
    dfa-traverser new
        swap >>traversal-flags
        swap [ start-state>> >>current-state ] keep
        >>dfa-table
        swap >>text
        0 >>start-index
        0 >>current-index
        V{ } clone >>matches
        V{ } clone >>capture-groups ;

: final-state? ( dfa-traverser -- ? )
    [ current-state>> ] [ dfa-table>> final-states>> ] bi
    key? ;

: text-finished? ( dfa-traverser -- ? )
    [ current-index>> ] [ text>> length ] bi >= ;

: save-final-state ( dfa-straverser -- )
    [ current-index>> ] [ matches>> ] bi push ;

: match-done? ( dfa-traverser -- ? )
    dup final-state? [
        dup save-final-state
    ] when text-finished? ;

: increment-state ( dfa-traverser state -- dfa-traverser )
    >r [ 1+ ] change-current-index
    dup current-state>> >>last-state r>
    first >>current-state ;

: match-failed ( dfa-traverser -- dfa-traverser )
    V{ } clone >>matches ;

: match-literal ( transition from-state table -- to-state/f )
    transitions>> [ at ] [ 2drop f ] if-at ;

: match-class ( transition from-state table -- to-state/f )
    transitions>> at* [
        [ drop class-member? ] assoc-with assoc-find [ nip ] [ drop ] if
    ] [ drop ] if ;

: match-default ( transition from-state table -- to-state/f )
    [ nip ] dip transitions>>
    [ t swap [ drop f ] unless-at ] [ drop f ] if-at ;

: match-transition ( obj from-state dfa -- to-state/f )
    { [ match-literal ] [ match-class ] [ match-default ] } 3|| ;

: setup-match ( match -- obj state dfa-table )
    {
        [ current-index>> ] [ text>> ]
        [ current-state>> ] [ dfa-table>> ]
    } cleave
    [ nth ] 2dip ;

: do-match ( dfa-traverser -- dfa-traverser )
    dup match-done? [
        dup setup-match match-transition
        [ increment-state do-match ] when*
    ] unless ;

: return-match ( dfa-traverser -- interval/f )
    dup matches>>
    [ drop f ]
    [ [ start-index>> ] [ peek ] bi* 1 <range> ] if-empty ;
