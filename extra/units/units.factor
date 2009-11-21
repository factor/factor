USING: accessors arrays io kernel math namespaces splitting
prettyprint sequences sorting vectors words inverse summary
shuffle math.functions sets ;
IN: units

TUPLE: dimensioned value top bot ;

TUPLE: dimensions-not-equal ;

: dimensions-not-equal ( -- * )
    \ dimensions-not-equal new throw ;

M: dimensions-not-equal summary drop "Dimensions do not match" ;

: remove-one ( seq obj -- seq )
    1array split1 append ;

: 2remove-one ( seq seq obj -- seq seq )
    [ remove-one ] curry bi@ ;

: symbolic-reduce ( seq seq -- seq seq )
    2dup intersect
    [ first 2remove-one symbolic-reduce ] unless-empty ;

: <dimensioned> ( n top bot -- obj )
    symbolic-reduce
    [ natural-sort ] bi@
    dimensioned boa ;

: >dimensioned< ( d -- n top bot )
    [ bot>> ] [ top>> ] [ value>> ] tri ;

\ <dimensioned> [ [ dimensioned boa ] undo ] define-inverse

: dimensions ( dimensioned -- top bot )
    [ top>> ] [ bot>> ] bi ;

: check-dimensions ( d d -- )
    [ dimensions 2array ] bi@ =
    [ dimensions-not-equal ] unless ;

: 2values ( dim dim -- val val ) [ value>> ] bi@ ;

: <dimension-op ( dim dim -- top bot val val )
    2dup check-dimensions dup dimensions 2swap 2values ;

: dimension-op> ( top bot val -- dim )
    -rot <dimensioned> ;

: d+ ( d d -- d ) <dimension-op + dimension-op> ;

: d- ( d d -- d ) <dimension-op - dimension-op> ;

: scalar ( n -- d )
    { } { } <dimensioned> ;

: d* ( d d -- d )
    [ dup number? [ scalar ] when ] bi@
    [ [ top>> ] bi@ append ] 2keep
    [ [ bot>> ] bi@ append ] 2keep
    2values * dimension-op> ;

: d-neg ( d -- d ) -1 d* ;

: d-sq ( d -- d ) dup d* ;

: d-recip ( d -- d' )
    >dimensioned< recip dimension-op> ;

: d/ ( d d -- d ) d-recip d* ;

: comparison-op ( d d -- n n ) 2dup check-dimensions 2values ;

: d< ( d d -- ? ) comparison-op < ;

: d<= ( d d -- ? ) comparison-op <= ;

: d> ( d d -- ? ) comparison-op > ;

: d>= ( d d -- ? ) comparison-op >= ;

: d= ( d d -- ? ) comparison-op number= ;

: d~ ( d d delta -- ? ) [ comparison-op ] dip ~ ;

: d-min ( d d -- d ) [ d< ] most ;

: d-max ( d d -- d ) [ d> ] most ;

: d-product ( v -- d ) 1 scalar [ d* ] reduce ;

: d-sum ( v -- d ) unclip-slice [ d+ ] reduce ;

: d-infimum ( v -- d ) unclip-slice [ d-min ] reduce ;

: d-supremum ( v -- d ) unclip-slice [ d-max ] reduce ;

\ d+ [ d- ] [ d- ] define-math-inverse
\ d- [ d+ ] [ d- ] define-math-inverse
\ d* [ d/ ] [ d/ ] define-math-inverse
\ d/ [ d* ] [ d/ ] define-math-inverse
\ d-recip [ d-recip ] define-inverse
