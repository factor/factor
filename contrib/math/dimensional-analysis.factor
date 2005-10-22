USING: physical-constants conversions ;
USING: kernel prettyprint io sequences words lists vectors inspector math errors ;
IN: dimensional-analysis


IN: sequences
: seq-diff ( seq1 seq2 -- seq2-seq1 )
    [ swap member? not ] subset-with ; flushable

: seq-intersect ( seq1 seq2 -- seq1/\seq2 )
    [ swap member? ] subset-with ; flushable

IN: dimensional-analysis

TUPLE: dimensioned val top bot ;
C: dimensioned 
    [ set-dimensioned-bot ] keep
    [ set-dimensioned-top ] keep
    over number? [ "dimensioned must be a number" throw ] unless
    [ set-dimensioned-val ] keep ;

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

: 2val ( d d -- )
    >r dimensioned-val r> dimensioned-val ;

: =units?
    >r dimensions 2list r> dimensions 2list = ;
    

: d+ ( d d -- )
    2dup =units? [
        "d+: dimensions must be the same" throw
    ] unless
    dup dimensions
    >r >r 2val + r> r> <dimensioned> ;

: d- ( d d -- )
    2dup =units? [
        "d-: dimensions must be the same" throw
    ] unless
    dup dimensions
    >r >r 2val - r> r> <dimensioned> ;

: add-dimensions ( d d -- d )
    >r dimensions r> dimensions >r swap >r append r> r> append 0 -rot <dimensioned> ;

: (d*)
    >r add-dimensions r> over set-dimensioned-val dup reduce-units ;

: d* ( d d -- )
    2dup 2val * (d*) ;

: d/ ( d d -- )
    2dup 2val / (d*) ;


