! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators fry kernel locals
math math.order regexp.nfa regexp.transition-tables sequences
sets sorting vectors sequences.deep math.functions regexp.classes ;
USING: io prettyprint threads ;
IN: regexp.dfa

:: (while-changes) ( obj quot: ( obj -- obj' ) comp: ( obj -- key ) old-key -- obj )
    obj quot call :> new-obj
    new-obj comp call :> new-key
    new-key old-key =
    [ new-obj ]
    [ new-obj quot comp new-key (while-changes) ]
    if ; inline recursive

: while-changes ( obj quot pred -- obj' )
    3dup nip call (while-changes) ; inline

TUPLE: parts in out ;

: make-partition ( choices classes -- partition )
    zip [ first ] partition parts boa ;

: powerset-partition ( classes -- partitions )
    ! Here is where class algebra will happen, when I implement it
    [ length [ 2^ ] keep ] keep '[
        _ [ ] map-bits _ make-partition
    ] map ;

: partition>class ( parts -- class )
    [ in>> ] [ out>> ] bi
    [ <or-class> ] bi@ <not-class> 2array <and-class> ;

: get-transitions ( partition state-transitions -- next-states )
    [ in>> ] dip '[ at ] gather ;

: disambiguate-overlap ( nfa -- nfa' )  
    [
        [
            [ keys powerset-partition ] keep '[
                [ partition>class ]
                [ _ get-transitions ] bi
            ] H{ } map>assoc
        ] assoc-map
    ] change-transitions ;

: find-delta ( states transition nfa -- new-states )
    transitions>> '[ _ swap _ at at ] gather sift ;

: (find-epsilon-closure) ( states nfa -- new-states )
    eps swap find-delta ;

: find-epsilon-closure ( states nfa -- new-states )
    '[ dup _ (find-epsilon-closure) union ] [ length ] while-changes
    natural-sort ;

: find-closure ( states transition nfa -- new-states )
    [ find-delta ] keep find-epsilon-closure ;

: find-start-state ( nfa -- state )
    [ start-state>> 1vector ] keep find-epsilon-closure ;

: find-transitions ( dfa-state nfa -- next-dfa-state )
    transitions>>
    '[ _ at keys ] gather
    eps swap remove ;

: add-todo-state ( state visited-states new-states -- )
    3dup drop key? [ 3drop ] [
        [ conjoin ] [ push ] bi-curry* bi
    ] if ;

:: new-transitions ( nfa dfa new-states visited-states -- nfa dfa )
    new-states [ nfa dfa ] [
        pop :> state
        state nfa find-transitions
        [| trans |
            state trans nfa find-closure :> new-state
            new-state visited-states new-states add-todo-state
            state new-state trans transition make-transition dfa add-transition
        ] each
        nfa dfa new-states visited-states new-transitions
    ] if-empty ;

: states ( hashtable -- array )
    [ keys ]
    [ values [ values concat ] map concat append ] bi ;

: set-final-states ( nfa dfa -- )
    [
        [ final-states>> keys ]
        [ transitions>> states ] bi*
        [ intersects? ] with filter
    ] [ final-states>> ] bi
    [ conjoin ] curry each ;

: initialize-dfa ( nfa -- dfa )
    <transition-table>
        swap find-start-state >>start-state ;

: construct-dfa ( nfa -- dfa )
    disambiguate-overlap
    dup initialize-dfa
    dup start-state>> 1vector
    H{ } clone
    new-transitions
    [ set-final-states ] keep ;
