! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
grouping kernel locals math math.functions math.order math.vectors
parser prettyprint.backend prettyprint.custom sequences sequences.deep
sequences.private sets vectors ;
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
ERROR: noninteger-shape-components shape ;
ERROR: invalid-reshape shape ;

: check-shape-domain ( seq -- seq )
    dup [ integer? ] all? [ dup noninteger-shape-components ] unless
    dup [ 0 < ] any? [ no-negative-shape-components ] when ;

GENERIC: shape-capacity ( shape -- n )

M: sequence shape-capacity check-shape-domain product ;

M: uniform-shape shape-capacity
    shape>> shape-capacity ;

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
INSTANCE: shaped-array sequence

M: shaped-array length underlying>> length ; inline

M: shaped-array nth-unsafe underlying>> nth-unsafe ;
M: shaped-array set-nth-unsafe underlying>> set-nth-unsafe ;

M: shaped-array like shape>> <shaped-array> ;

M: shaped-array shape shape>> ;

: make-shaped-array ( underlying shape class -- shaped-array )
    [ check-underlying-shape ] dip new
        swap >array >>shape
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

M: number >shaped-array 1array { } <shaped-array> ;
M: number shape drop { } ;

M: shaped-array >row-array
    [ underlying>> ] [ shape>> ] bi <row-array> ;

M: shaped-array >col-array
    [ underlying>> ] [ shape>> ] bi <col-array> ;

M: sequence >col-array
    [ flatten ] [ shape ] bi <col-array> ;

: shaped-unary-op ( shaped quot -- result )
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

<PRIVATE

:: reshape-dimensions ( size shape -- dimensions )
    shape dup integer? [ 1array ] when
    dup uniform-shape? [ shape>> ] when >array :> dimensions
    dimensions [ integer? ] all?
    [ dimensions noninteger-shape-components ] unless
    dimensions [ -1 < ] any? [ dimensions invalid-reshape ] when
    dimensions [ -1 = ] count :> inferred
    inferred 1 > [ dimensions invalid-reshape ] when
    inferred 1 = [
        dimensions [ dup -1 = [ drop 1 ] when ] map product :> known
        known zero? [ dimensions invalid-reshape ] when
        size known mod zero? [ dimensions invalid-reshape ] unless
        dimensions [ dup -1 = [ drop size known /i ] when ] map
    ] [ dimensions ] if ;

GENERIC: reshape-storage ( storage -- storage' )
M: sequence reshape-storage ;
M: virtual-sequence reshape-storage >array ;

PRIVATE>

:: reshape ( array shape -- result )
    array >shaped-array underlying>> :> storage
    storage length shape reshape-dimensions :> dimensions
    storage reshape-storage dimensions <shaped-array> ;

: shaped-like ( shaped-array shape -- array )
    [ underlying>> >array ] dip <shaped-array> ;

: repeated-shaped ( shape element -- shaped-array )
    [ [ shape-capacity ] dip <array> ]
    [ drop ] 2bi <shaped-array> ;

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
M: shaped-array pprint*
    dup shape>> { [ empty? ] [ [ zero? ] any? ] } 1||
    [ pprint-tuple ] [ pprint-object ] if ;
M: shaped-array pprint-narrow? drop f ;

ERROR: shaped-bounds-error seq shape ;

:: shaped-bounds-check ( seq shaped -- seq shaped )
    shaped shape :> dimensions
    seq length dimensions length = [
        seq dimensions [| index size |
            index integer? [ index size neg >= index size < and ] [ f ] if
        ] 2all?
    ] [ f ] if [ seq shaped shaped-bounds-error ] unless
    seq dimensions [ swap dup 0 < [ + ] [ nip ] if ] 2map shaped ;

: calculate-row-major-index ( seq shape -- i )
    reverse 1 [ * ] accumulate nip reverse [ * ] 2map sum ;

: calculate-column-major-index ( seq shape -- i )
    1 [ * ] accumulate nip [ * ] 2map sum ;

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
    '[ _ map! ] change-underlying ; inline

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

! Axis operations and writable views.
ERROR: invalid-shaped-axis axis rank ;
ERROR: duplicate-shaped-axes axes ;
ERROR: invalid-shaped-permutation axes rank ;
ERROR: invalid-shaped-slice selector ;

TUPLE: shaped-slice start stop step ;

: <shaped-slice> ( start stop step -- slice )
    shaped-slice boa ;

<PRIVATE

:: normalize-axis ( axis rank -- normalized )
    axis integer? [ axis rank neg >= axis rank < and ] [ f ] if
    [ axis rank invalid-shaped-axis ] unless
    axis dup 0 < [ rank + ] when ;

:: normalize-axes ( axes rank -- normalized )
    axes [ dup integer? [ 1array ] when ] [ rank <iota> ] if*
    [ rank normalize-axis ] map >array :> normalized
    normalized members length normalized length =
    [ normalized duplicate-shaped-axes ] unless
    normalized ;

:: flat-coordinate ( index dimensions -- coordinate )
    dimensions row-major-strides dimensions [| stride dimension |
        index stride /i dimension mod
    ] 2map ;

: coordinate-offset ( coordinate strides -- offset )
    [ * ] 2map sum ;

TUPLE: shaped-storage source dimensions strides offset ;
INSTANCE: shaped-storage virtual-sequence
M: shaped-storage length dimensions>> product ;
M: shaped-storage virtual-exemplar source>> ;
M:: shaped-storage virtual@ ( index storage -- index' source )
    index storage bounds-check 2drop
    index storage dimensions>> flat-coordinate
    storage strides>> coordinate-offset storage offset>> +
    storage source>> ;

:: <shaped-view> ( source dimensions strides offset -- view )
    source dimensions clone strides clone offset shaped-storage boa
    dimensions <shaped-array> ;

:: slice-bound ( bound size lower upper default -- normalized )
    bound [
        dup integer? [ bound invalid-shaped-slice ] unless
        dup 0 < [ size + ] when lower max upper min
    ] [ default ] if* ;

:: slice-parameters ( selector size -- start count step )
    selector step>> [ ] [ 1 ] if* :> step
    step integer? [ step zero? not ] [ f ] if
    [ selector invalid-shaped-slice ] unless
    step 0 > [
        selector start>> size 0 size 0 slice-bound
        selector stop>> size 0 size size slice-bound
    ] [
        selector start>> size -1 size 1 - size 1 - slice-bound
        selector stop>> size -1 size 1 - -1 slice-bound
    ] if :> ( start stop )
    start stop start - step sgn * 0 max step abs 1 - + step abs /i step ;

PRIVATE>

:: shaped-permute ( array axes -- view )
    array >shaped-array :> shaped
    shaped shape>> :> dimensions
    axes dimensions length normalize-axes :> permutation
    permutation length dimensions length =
    [ axes dimensions length invalid-shaped-permutation ] unless
    dimensions row-major-strides :> strides
    shaped underlying>>
    permutation [ dimensions nth ] map
    permutation [ strides nth ] map 0 <shaped-view> ;

: shaped-transpose ( array -- view )
    >shaped-array dup ndim <iota> reverse shaped-permute ;

:: shaped-slice-view ( array selectors -- view )
    array >shaped-array :> shaped
    shaped shape>> :> dimensions
    selectors length dimensions length >
    [ selectors invalid-shaped-slice ] when
    selectors dimensions length f pad-tail :> selection
    dimensions row-major-strides :> strides
    V{ } clone :> result-shape
    V{ } clone :> result-strides
    0 :> offset!
    selection [| selector axis |
        axis dimensions nth :> size
        axis strides nth :> stride
        selector integer? [
            selector size normalize-axis stride * offset + offset!
        ] [
            selector [ ] [ f f 1 <shaped-slice> ] if* :> range
            range shaped-slice? [ selector invalid-shaped-slice ] unless
            range size slice-parameters :> ( start count step )
            offset start stride * + offset!
            count result-shape push
            stride step * result-strides push
        ] if
    ] each-index
    shaped underlying>> result-shape >array result-strides >array offset
    <shaped-view> ;

! Axis reductions always return shaped arrays, including scalar results.
ERROR: empty-shaped-reduction shape axes ;

<PRIVATE

:: reduction-shape ( dimensions axes keepdims? -- shape )
    dimensions [| size axis |
        axis axes member? [ keepdims? [ { 1 } ] [ { } ] if ] [ size 1array ] if
    ] map-index concat ;

:: reduction-coordinate ( coordinate axes keepdims? -- result )
    coordinate [| index axis |
        axis axes member? [ keepdims? [ { 0 } ] [ { } ] if ] [ index 1array ] if
    ] map-index concat ;

:: reduce-shaped ( array axes keepdims? identity quot -- result count )
    array >shaped-array :> shaped
    shaped shape>> :> dimensions
    axes dimensions length normalize-axes :> normalized
    normalized [ dimensions nth ] map product :> count
    identity not count zero? and
    [ dimensions normalized empty-shaped-reduction ] when
    dimensions normalized keepdims? reduction-shape :> result-shape
    result-shape row-major-strides :> strides
    result-shape product identity <array> :> storage
    shaped underlying>> [| value index |
        index dimensions flat-coordinate normalized keepdims? reduction-coordinate
        strides coordinate-offset :> target
        target storage nth [ value quot call ] [ value ] if*
        target storage set-nth
    ] each-index
    storage result-shape <shaped-array> count ; inline

: nan-min ( a b -- c )
    2dup [ fp-nan? ] either? [ 2drop 0/0. ] [ min ] if ;

: nan-max ( a b -- c )
    2dup [ fp-nan? ] either? [ 2drop 0/0. ] [ max ] if ;

PRIVATE>

: shaped-sum ( array axes keepdims? -- result )
    0 [ + ] reduce-shaped drop ;

: shaped-mean ( array axes keepdims? -- result )
    0 [ + ] reduce-shaped
    dup zero? [ drop [ drop 0/0. ] shaped-map ]
    [ >float '[ _ / ] shaped-map ] if ;

: shaped-min ( array axes keepdims? -- result )
    f [ nan-min ] reduce-shaped drop ;

: shaped-max ( array axes keepdims? -- result )
    f [ nan-max ] reduce-shaped drop ;

ERROR: invalid-shaped-matmul left-shape right-shape ;

<PRIVATE

:: matmul-batch-shape ( left right -- shape )
    left length right length max :> rank
    left rank 1 pad-head :> a
    right rank 1 pad-head :> b
    a b [ compatible-dimensions? ] 2all?
    [ left right shape-mismatch ] unless
    a b [ over 1 = [ nip ] [ drop ] if ] 2map ;

PRIVATE>

:: shaped-matmul ( a b -- result )
    a >shaped-array :> left
    b >shaped-array :> right
    left shape>> :> ls
    right shape>> :> rs
    ls empty? rs empty? or [ ls rs invalid-shaped-matmul ] when
    ls length 1 = :> left-vector?
    rs length 1 = :> right-vector?
    left-vector? [ ls 1 prefix ] [ ls ] if :> lm
    right-vector? [ rs 1 suffix ] [ rs ] if :> rm
    lm last :> contracted
    rm length 2 - rm nth contracted =
    [ ls rs invalid-shaped-matmul ] unless
    lm lm length 2 - head rm rm length 2 - head matmul-batch-shape :> batch
    lm length 2 - lm nth :> rows
    rm last :> columns
    batch rows suffix columns suffix :> full-shape
    lm full-shape length broadcast-strides :> left-strides
    rm full-shape length broadcast-strides :> right-strides
    full-shape product <iota> [| index |
        index full-shape flat-coordinate :> coordinate
        coordinate batch length head :> batch-coordinate
        batch length coordinate nth :> row
        coordinate last :> column
        contracted <iota> [| k |
            batch-coordinate row suffix k suffix left-strides coordinate-offset
            left underlying>> nth
            batch-coordinate k suffix column suffix right-strides coordinate-offset
            right underlying>> nth *
        ] map sum
    ] map
    batch left-vector? [ ] [ rows suffix ] if
    right-vector? [ ] [ columns suffix ] if <shaped-array> ;
