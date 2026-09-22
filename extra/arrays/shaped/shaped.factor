! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
grouping kernel locals math math.functions math.order math.vectors
parser prettyprint.custom sequences sequences.deep
sequences.private ;
IN: arrays.shaped

: flat? ( array -- ? ) [ sequence? ] none? ; inline

GENERIC: array-replace ( object -- shape )

M: f array-replace ;

M: object array-replace drop f ;

M: sequence array-replace
    dup flat? [
        length
    ] [
        [ array-replace ] map
    ] if ;

TUPLE: uniform-shape shape ;
C: <uniform-shape> uniform-shape

TUPLE: abnormal-shape shape ;
C: <abnormal-shape> abnormal-shape

GENERIC: wrap-shape ( object -- shape )

M: integer wrap-shape
    1array <uniform-shape> ;

M: sequence wrap-shape
    dup all-equal? [
        dup first wrap-shape dup uniform-shape? [
            shape>> swap length prefix <uniform-shape>
        ] [
            drop <abnormal-shape>
        ] if
    ] [
        <abnormal-shape>
    ] if ;

GENERIC: shape ( array -- shape )

M: sequence shape array-replace wrap-shape ;

: ndim ( array -- n )
    shape dup uniform-shape? [ shape>> ] when length ;

ERROR: no-negative-shape-components shape ;

: check-shape-domain ( seq -- seq )
    dup [ 0 < ] any? [ no-negative-shape-components ] when ;

GENERIC: shape-capacity ( shape -- n )

M: sequence shape-capacity check-shape-domain product ;

M: uniform-shape shape-capacity
    shape>> product ;

M: abnormal-shape shape-capacity
    shape>> 0 swap [
        [ dup sequence? [ drop ] [ + ] if ] [ 1 + ] if*
    ] deep-each ;

ERROR: underlying-shape-mismatch underlying shape ;

ERROR: no-abnormally-shaped-arrays underlying shape ;

GENERIC: check-underlying-shape ( underlying shape -- underlying shape )

M: abnormal-shape check-underlying-shape
    no-abnormally-shaped-arrays ;

M: uniform-shape check-underlying-shape
    shape>> check-underlying-shape ;

M: sequence check-underlying-shape
    2dup [ length ] [ shape-capacity ] bi*
    = [ underlying-shape-mismatch ] unless ; inline

ERROR: shape-mismatch shaped0 shaped1 ;

DEFER: >shaped-array
DEFER: <shaped-array>

: check-shape ( shaped-array shaped-array -- shaped-array shaped-array )
    [ >shaped-array ] bi@
    2dup [ shape>> ] bi@
    sequence= [ shape-mismatch ] unless ;

TUPLE: shaped-array underlying shape ;
TUPLE: row-array < shaped-array ;
TUPLE: col-array < shaped-array ;

M: shaped-array length underlying>> length ; inline

M: shaped-array nth-unsafe underlying>> nth-unsafe ;

M: shaped-array like shape>> <shaped-array> ;

M: shaped-array shape shape>> ;

: make-shaped-array ( underlying shape class -- shaped-array )
    [ check-underlying-shape ] dip new
        swap >>shape
        swap >>underlying ; inline

: <shaped-array> ( underlying shape -- shaped-array )
    shaped-array make-shaped-array ; inline

: <row-array> ( underlying shape -- shaped-array )
    row-array make-shaped-array ; inline

: <col-array> ( underlying shape -- shaped-array )
    col-array make-shaped-array ; inline

GENERIC: >shaped-array ( array -- shaped-array )
GENERIC: >row-array ( array -- shaped-array )
GENERIC: >col-array ( array -- shaped-array )

M: sequence >shaped-array
    [ { } flatten-as ] [ shape ] bi <shaped-array> ;

M: shaped-array >shaped-array ;

M: shaped-array >row-array
    [ underlying>> ] [ shape>> ] bi <row-array> ;

M: shaped-array >col-array
    [ underlying>> ] [ shape>> ] bi <col-array> ;

M: sequence >col-array
    [ flatten ] [ shape ] bi <col-array> ;

: shaped-unary-op ( shaped quot -- )
    [ >shaped-array ] dip
    [ underlying>> ] prepose
    [ shape>> clone ] bi shaped-array boa ; inline

: shaped-shaped-binary-op ( shaped0 shaped1 quot -- c )
    [ check-shape ] dip
    [ [ underlying>> ] bi@ ] prepose
    [ drop shape>> clone ] 2bi shaped-array boa ; inline


: shaped*n ( a b -- c ) [ v*n ] curry shaped-unary-op ;
: n*shaped ( a b -- c ) swap shaped*n ;

: shaped-cos ( a -- b ) [ [ cos ] map ] shaped-unary-op ;
: shaped-sin ( a -- b ) [ [ sin ] map ] shaped-unary-op ;

<PRIVATE

:: nest-shaped ( underlying shape -- array )
    shape length 1 <= [ underlying >array ] [
        shape rest :> tail
        tail product :> width
        shape first <iota> [| i |
            i width * dup width + underlying subseq
            tail nest-shaped
        ] map
    ] if ;

PRIVATE>

: shaped-array>array ( shaped-array -- array )
    [ underlying>> ] [ shape>> ] bi nest-shaped ;

: reshape ( shaped-array shape -- array )
    check-underlying-shape
    [ >shaped-array ] dip >>shape ;

: shaped-like ( shaped-array shape -- array )
    [ underlying>> clone ] dip <shaped-array> ;

: repeated-shaped ( shape element -- shaped-array )
    [ [ shape-capacity ] dip <array> ]
    [ drop 1 1 pad-head ] 2bi <shaped-array> ;

: zeros ( shape -- shaped-array ) 0 repeated-shaped ;

: ones ( shape -- shaped-array ) 1 repeated-shaped ;

: increasing ( shape -- shaped-array )
    [ shape-capacity <iota> >array ] [ ] bi <shaped-array> ;

: decreasing ( shape -- shaped-array )
    [ shape-capacity <iota> <reversed> >array ] [ ] bi <shaped-array> ;

: row-length ( shape -- n ) rest-slice product ; inline

: column-length ( shape -- n ) first ; inline

: each-row ( shaped-array quot -- )
    [ [ underlying>> ] [ shape>> row-length <groups> ] bi ] dip
    each ; inline

TUPLE: transposed shaped-array ;

: transposed-shape ( shaped-array -- shape )
    shape>> <reversed> ;

TUPLE: row-traverser shaped-array index ;

GENERIC: next-index ( object -- index )

SYNTAX: sa{ \ } [ >shaped-array ] parse-literal ;

! M: row-array pprint* shaped-array>array pprint* ;
! M: col-array pprint* shaped-array>array flip pprint* ;
M: shaped-array pprint-delims drop \ sa{ \ } ;
M: shaped-array >pprint-sequence shaped-array>array ;
M: shaped-array pprint* pprint-object ;
M: shaped-array pprint-narrow? drop f ;

ERROR: shaped-bounds-error seq shape ;

:: shaped-bounds-check ( seq shaped -- seq shaped )
    shaped shape :> dimensions
    seq length dimensions length = [
        seq dimensions [| index size |
            index integer? [ index 0 >= index size < and ] [ f ] if
        ] 2all?
    ] [ f ] if [ seq shaped shaped-bounds-error ] unless
    seq shaped ;

: calculate-row-major-index ( seq shape -- i )
    reverse 1 [ * ] accumulate nip reverse vdot ;

: calculate-column-major-index ( seq shape -- i )
    1 [ * ] accumulate nip vdot ;

: get-shaped-row-major ( seq shaped -- elt )
    shaped-bounds-check [ shape calculate-row-major-index ] [ underlying>> ] bi nth ;

: set-shaped-row-major ( obj seq shaped -- )
    shaped-bounds-check [ shape calculate-row-major-index ] [ underlying>> ] bi set-nth ;

: get-shaped-column-major ( seq shaped -- elt )
    shaped-bounds-check [ shape calculate-column-major-index ] [ underlying>> ] bi nth ;

: set-shaped-column-major ( obj seq shaped -- )
    shaped-bounds-check [ shape calculate-column-major-index ] [ underlying>> ] bi set-nth ;

! Matrices
: 2d? ( shape -- ? ) length 2 = ;
ERROR: 2d-expected shaped ;
: check-2d ( shaped -- shaped ) dup shape>> 2d? [ 2d-expected ] unless ;

: diagonal? ( coord -- ? ) { [ 2d? ] [ first2 = ] } 1&& ;

! : definite? ( sa -- ? )

: shaped-each ( .. sa quot -- )
    [ underlying>> ] dip each ; inline

! : set-shaped-where ( .. elt sa quot -- )
    ! [
        ! [ underlying>> [ length <iota> ] keep zip ]
        ! [ ] bi
    ! ] dip '[ _ [ _ set- ] @ ] assoc-each ; inline

: shaped-map! ( .. sa quot -- sa )
    '[ _ map ] change-underlying ; inline

: shaped-map ( .. sa quot -- sa' )
    [ [ underlying>> ] dip map ]
    [ drop shape>> ] 2bi <shaped-array> ; inline

: pad-shapes ( sa0 sa1 -- sa0' sa1' )
    2dup [ shape>> ] bi@
    2dup longer length '[ _ 1 pad-head ] bi@
    [ shaped-like ] bi-curry@ bi* ;

<PRIVATE

:: aligned-shapes ( sa0 sa1 -- shape0 shape1 )
    sa0 shape>> :> shape0
    sa1 shape>> :> shape1
    shape0 length shape1 length max :> rank
    shape0 rank 1 pad-head shape1 rank 1 pad-head ;

: compatible-dimensions? ( a b -- ? )
    { [ = ] [ drop 1 = ] [ nip 1 = ] } 2|| ;

PRIVATE>

: broadcastable? ( sa0 sa1 -- ? )
    aligned-shapes [ compatible-dimensions? ] 2all? ;

:: output-shape ( sa0 sa1 -- shape )
    sa0 sa1 broadcastable? [
        sa0 sa1 aligned-shapes [ over 1 = [ nip ] [ drop ] if ] 2map
    ] [ sa0 sa1 shape-mismatch ] if ;

<PRIVATE

: row-major-strides ( shape -- strides )
    reverse 1 [ * ] accumulate nip reverse ;

:: broadcast-strides ( shape rank -- strides )
    shape rank 1 pad-head dup row-major-strides
    [ swap 1 = [ drop 0 ] when ] 2map ;

:: broadcast-binary-op ( a b quot -- c )
    a >shaped-array :> left
    b >shaped-array :> right
    left right output-shape :> dimensions
    dimensions row-major-strides :> strides
    left shape>> dimensions length broadcast-strides :> left-strides
    right shape>> dimensions length broadcast-strides :> right-strides
    dimensions product <iota> [| index |
        strides dimensions [| stride dimension |
            index stride /i dimension mod
        ] 2map :> coordinate
        coordinate left-strides [ * ] 2map sum left underlying>> nth
        coordinate right-strides [ * ] 2map sum right underlying>> nth
        quot call
    ] map dimensions <shaped-array> ; inline

PRIVATE>

: shaped+ ( a b -- c ) [ + ] broadcast-binary-op ;
: shaped- ( a b -- c ) [ - ] broadcast-binary-op ;
: shaped*. ( a b -- c ) [ * ] broadcast-binary-op ;

: broadcast-shape-matches? ( sa broadcast-shape -- ? )
    [ { [ drop 1 = ] [ = ] } 2|| ] 2all? ;

TUPLE: block-array shaped shape ;

: <block-array> ( underlying shape -- obj )
    block-array boa ;

: iteration-indices ( shaped -- seq )
    [ <iota> ] [
        cartesian-product concat
        [ dup first array? [ first2 suffix ] when ] map
    ] map-reduce ;

: map-shaped-index ( shaped quot -- shaped )
    over [
        [ [ underlying>> ] [ shape>> iteration-indices ] bi zip ] dip map
    ] dip swap >>underlying ; inline

: identity-matrix ( n -- shaped )
    dup 2array zeros [ second first2 = 1 0 ? ] map-shaped-index ;

: map-strict-lower ( shaped quot -- shaped )
    [ check-2d ] dip
    '[ first2 first2 > _ when ] map-shaped-index ; inline

: map-lower ( shaped quot -- shaped )
    [ check-2d ] dip
    '[ first2 first2 >= _ when ] map-shaped-index ; inline

: map-strict-upper ( shaped quot -- shaped )
    [ check-2d ] dip
    '[ first2 first2 < _ when ] map-shaped-index ; inline

: map-upper ( shaped quot -- shaped )
    [ check-2d ] dip
    '[ first2 first2 <= _ when ] map-shaped-index ; inline

: map-diagonal ( shaped quot -- shaped )
    [ check-2d ] dip
    '[ first2 first2 = _ when ] map-shaped-index ; inline

: upper ( shape obj -- shaped )
    [ zeros check-2d ] dip '[ drop _ ] map-upper ;

: strict-upper ( shape obj -- shaped )
    [ zeros check-2d ] dip '[ drop _ ] map-strict-upper ;

: lower ( shape obj -- shaped )
    [ zeros check-2d ] dip '[ drop _ ] map-lower ;

: strict-lower ( shape obj -- shaped )
    [ zeros check-2d ] dip '[ drop _ ] map-strict-lower ;
