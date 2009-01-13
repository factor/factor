! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators fry kernel locals
math math.order regexp.nfa regexp.transition-tables sequences
sets sorting vectors regexp.utils sequences.deep ;
USING: io prettyprint threads ;
IN: regexp.dfa

: find-delta ( states transition regexp -- new-states )
    nfa-table>> transitions>>
    rot [ swap at at ] with with gather sift ;

: (find-epsilon-closure) ( states regexp -- new-states )
    eps swap find-delta ;

: find-epsilon-closure ( states regexp -- new-states )
    '[ dup _ (find-epsilon-closure) union ] [ length ] while-changes
    natural-sort ;

: find-closure ( states transition regexp -- new-states )
    [ find-delta ] 2keep nip find-epsilon-closure ;

: find-start-state ( regexp -- state )
    [ nfa-table>> start-state>> 1vector ] keep find-epsilon-closure ;

: find-transitions ( seq1 regexp -- seq2 )
    nfa-table>> transitions>>
    [ at keys ] curry gather
    eps swap remove ;

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
            [ swapd transition make-transition ] dip
            dfa-table>> add-transition 
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
    [ intersects? ] with filter

    swap dfa-table>> final-states>>
    [ conjoin ] curry each ;

: set-initial-state ( regexp -- )
    dup
    [ dfa-table>> ] [ find-start-state ] bi
    [ >>start-state drop ] keep
    1vector >>new-states drop ;

: set-traversal-flags ( regexp -- )
    dup
    [ nfa-traversal-flags>> ]
    [ dfa-table>> transitions>> keys ] bi
    [ tuck [ swap at ] with map concat ] with H{ } map>assoc
    >>dfa-traversal-flags drop ;

: construct-dfa ( regexp -- )
    {
        [ set-initial-state ]
        [ new-transitions ]
        [ set-final-states ]
        [ set-traversal-flags ]
    } cleave ;
