USING: arrays io kernel math namespaces splitting prettyprint
sequences sorting vectors words inverse inspector shuffle
math.functions ;
IN: units

TUPLE: dimensioned value top bot ;

TUPLE: dimensions-not-equal ;

: dimensions-not-equal ( -- * )
    \ dimensions-not-equal construct-empty throw ;

M: dimensions-not-equal summary drop "Dimensions do not match" ;

: seq-intersect ( seq1 seq2 -- seq1/\seq2 )
    swap [ member? ] curry subset ;

: remove-one ( seq obj -- seq )
    1array split1 append ;

: 2remove-one ( seq seq obj -- seq seq )
    [ remove-one ] curry 2apply ;

: symbolic-reduce ( seq seq -- seq seq )
    2dup seq-intersect dup empty?
    [ drop ] [ first 2remove-one symbolic-reduce ] if ;

: <dimensioned> ( n top bot -- obj )
    symbolic-reduce
    [ natural-sort ] 2apply
    dimensioned construct-boa ;

: >dimensioned< ( d -- n top bot )
    { dimensioned-value dimensioned-top dimensioned-bot }
    get-slots ;

\ <dimensioned> [ >dimensioned< ] define-inverse

: dimensions ( dimensioned -- top bot )
    { dimensioned-top dimensioned-bot } get-slots ;

: check-dimensions ( d d -- )
    [ dimensions 2array ] 2apply =
    [ dimensions-not-equal ] unless ;

: 2values [ dimensioned-value ] 2apply ;

: <dimension-op
    2dup check-dimensions dup dimensions 2swap 2values ;

: dimension-op>
    -rot <dimensioned> ;

: d+ ( d d -- d ) <dimension-op + dimension-op> ;

: d- ( d d -- d ) <dimension-op - dimension-op> ;

: scalar ( n -- d )
    { } { } <dimensioned> ;

: d* ( d d -- d )
    [ dup number? [ scalar ] when ] 2apply
    [ [ dimensioned-top ] 2apply append ] 2keep
    [ [ dimensioned-bot ] 2apply append ] 2keep
    2values * dimension-op> ;

: d-neg ( d -- d ) -1 d* ;

: d-sq ( d -- d ) dup d* ;

: d-recip ( d -- d' )
    >dimensioned< swap rot recip dimension-op> ;

: d/ ( d d -- d ) d-recip d* ;

: comparison-op ( d d -- n n ) 2dup check-dimensions 2values ;

: d< ( d d -- ? ) comparison-op < ;

: d<= ( d d -- ? ) comparison-op <= ;

: d> ( d d -- ? ) comparison-op > ;

: d>= ( d d -- ? ) comparison-op >= ;

: d= ( d d -- ? ) comparison-op number= ;

: d~ ( d d delta -- ? ) >r comparison-op r> ~ ;

: d-min ( d d -- d ) [ d< ] most ;

: d-max ( d d -- d ) [ d> ] most ;

: d-product ( v -- d ) 1 scalar [ d* ] reduce ;

: d-sum ( v -- d ) unclip-slice [ d+ ] reduce ;

: d-infimum ( v -- d ) unclip-slice [ d-min ] reduce ;

: d-supremum ( v -- d ) unclip-slice [ d-max ] reduce ;
