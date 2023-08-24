USING: accessors arrays combinators fry inverse kernel math
math.functions sequences sets shuffle sorting splitting summary ;
IN: units

TUPLE: dimensioned value top bot ;

ERROR: dimensions-not-equal ;

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
    [ sort ] bi@
    dimensioned boa ;

: >dimensioned< ( d -- n top bot )
    [ bot>> ] [ top>> ] [ value>> ] tri ;

\ <dimensioned> [ [ dimensioned boa ] undo ] define-inverse

: dimensions ( dimensioned -- top bot )
    [ top>> ] [ bot>> ] bi ;

: check-dimensions ( d d -- )
    [ dimensions 2array ] same?
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

: d-cube ( d -- d ) dup dup d* d* ;

: d-recip ( d -- d' )
    >dimensioned< recip dimension-op> ;

: d/ ( d d -- d ) d-recip d* ;

ERROR: dimensioned-power-op-expects-integer d n ;

: d^ ( d n -- d^n )
    dup integer? [ dimensioned-power-op-expects-integer ] unless
    {
        { [ dup 0 > ] [ 1 - over '[ _ d* ] times ] }
        { [ dup 0 < ] [ 1 - abs over '[ _ d/ ] times ] }
        { [ dup 0 = ] [ 2drop 1 scalar ] }
    } cond ;

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

: d-sum ( v -- d ) [ ] [ d+ ] map-reduce ;

: d-infimum ( v -- d ) [ ] [ d-min ] map-reduce ;

: d-supremum ( v -- d ) [ ] [ d-max ] map-reduce ;

\ d+ [ d- ] [ d- ] define-math-inverse
\ d- [ d+ ] [ d- ] define-math-inverse
\ d* [ d/ ] [ d/ ] define-math-inverse
\ d/ [ d* ] [ d/ ] define-math-inverse
\ d-recip [ d-recip ] define-inverse
