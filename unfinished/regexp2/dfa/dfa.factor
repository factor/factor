! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators fry kernel locals
math math.order regexp2.nfa regexp2.transition-tables sequences
sets sorting vectors regexp2.utils sequences.lib combinators.lib
sequences.deep ;
USING: io prettyprint threads ;
IN: regexp2.dfa

: find-delta ( states transition regexp -- new-states )
    nfa-table>> transitions>>
    rot [ swap at at ] with with map sift concat prune ;

: (find-epsilon-closure) ( states regexp -- new-states )
    eps swap find-delta ;

: find-epsilon-closure ( states regexp -- new-states )
    '[ dup , (find-epsilon-closure) union ] [ length ] while-changes
    natural-sort ;

: find-closure ( states transition regexp -- new-states )
    [ find-delta ] 2keep nip find-epsilon-closure ;

: find-start-state ( regexp -- state )
    [ nfa-table>> start-state>> 1vector ] keep find-epsilon-closure ;

: find-transitions ( seq1 regexp -- seq2 )
    nfa-table>> transitions>>
    [ at keys ] curry map concat eps swap remove ;

: add-todo-state ( state regexp -- )
    2dup visited-states>> key? [
        2drop
    ] [
        [ visited-states>> conjoin ]
        [ new-states>> push ] 2bi
    ] if ;

: new-transitions ( regexp -- )
    dup new-states>> [
        drop
    ] [
        dupd pop dup pick find-transitions rot
        [
            [ [ find-closure ] 2keep nip dupd add-todo-state ] 3keep
            >r swapd transition make-transition r> dfa-table>> add-transition 
        ] curry with each
        new-transitions
    ] if-empty ;

: states ( hashtable -- array )
    [ keys ]
    [ values [ values concat ] map concat append ] bi ;

: set-final-states ( regexp -- )
    dup
    [ nfa-table>> final-states>> keys ]
    [ dfa-table>> transitions>> states ] bi
    [ intersect empty? not ] with filter

    swap dfa-table>> final-states>>
    [ conjoin ] curry each ;

: set-initial-state ( regexp -- )
    dup
    [ dfa-table>> ] [ find-start-state ] bi
    [ >>start-state drop ] keep
    1vector >>new-states drop ;

: set-traversal-flags ( regexp -- )
    [ dfa-table>> transitions>> keys ]
    [ nfa-traversal-flags>> ]
    bi 2drop ;

: construct-dfa ( regexp -- )
    [ set-initial-state ]
    [ new-transitions ]
    [ set-final-states ] tri ;
    ! [ set-traversal-flags ] quad ;
