USING: arrays errors inspector io kernel math namespaces
prettyprint sequences vectors words ;
IN: units

: seq-intersect ( seq1 seq2 -- seq1/\seq2 )
    [ swap member? ] subset-with ;

TUPLE: dimensioned value top bot ;
C: dimensioned 
    [ set-dimensioned-bot ] keep
    [ set-dimensioned-top ] keep
    over number? [ "dimensioned must be a number" throw ] unless
    [ set-dimensioned-value ] keep ;

: remove-one ( obj seq -- seq )
    [ index ] keep over -1 = [
        2drop
    ] [
        [ 0 -rot <slice> ] 2keep
        >r 1+ r> [ length ] keep <slice> append 
    ] if ;

: dimensions ( dimensioned -- top bot )
    dup >r dimensioned-top r> dimensioned-bot ;

: 2remove-one ( obj seq seq -- seq seq )
    pick swap remove-one >r remove-one r> ;

: symbolic-reduce ( seq seq -- seq seq )
    [ seq-intersect ] 2keep rot dup empty? [
            drop
        ] [
            first -rot 2remove-one symbolic-reduce
    ] if ;

: reduce-units ( dimensioned -- )
    dup dimensions symbolic-reduce pick set-dimensioned-bot swap set-dimensioned-top ;

: 2reduce-units ( d d -- )
    >r dup reduce-units r> dup reduce-units ;

: 2value ( d d -- )
    [ dimensioned-value ] 2apply ;

: =units?
    >r dimensions 2array r> dimensions 2array = ;
    

: d+ ( d d -- )
    2dup =units? [
        "d+: dimensions must be the same" throw
    ] unless
    dup dimensions
    >r >r 2value + r> r> <dimensioned> ;

: d- ( d d -- )
    2dup =units? [
        "d-: dimensions must be the same" throw
    ] unless
    dup dimensions
    >r >r 2value - r> r> <dimensioned> ;

: add-dimensions ( d d -- d )
    >r dimensions r> dimensions >r swap >r append r> r> append 0 -rot <dimensioned> ;

: (d*)
    >r add-dimensions r> over set-dimensioned-value dup reduce-units ;

: d* ( d d -- )
    2dup 2value * (d*) ;

: swap-dimensions ( d -- d )
    dup dimensions rot [ set-dimensioned-top ] keep [ set-dimensioned-bot ] keep ;

: d/ ( d d -- )
    swap-dimensions 2dup 2value / (d*) ;

: d-inv ( d -- d )
    swap-dimensions dup dimensioned-value 1 swap / over set-dimensioned-value ;

: d-product ( v -- d ) 1 { } { } <dimensioned> [ d* ] reduce ;

! does not compile
! Example: 4 m { km } { } convert
: convert ( d top bot -- value )
    >r [ [ 1 swap execute , ] each ] { } make d-product r>
    [ [ 1 swap execute d-inv , ] each ] { } make d-product
    d*
    2dup =units? [ "cannot make that conversion" throw ] unless
    [ 2value / ] keep [ set-dimensioned-value ] keep ;

