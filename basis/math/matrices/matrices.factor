! Copyright (C) 2005, 2010, 2018, 2020 Slava Pestov, Joe Groff, and Cat Stevens.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators combinators.short-circuit kernel math
math.functions math.order math.private math.vectors ranges
sequences sequences.deep sequences.private slots.private ;
IN: math.matrices

! defined here because of issue #1943
DEFER: regular-matrix?
: regular-matrix? ( object -- ? )
    [ t ] [
        dup first-unsafe length
        '[ length _ = ] all?
    ] if-empty ;

! the MRO (class linearization) is performed in the order the predicates appear here
! except that null-matrix is last (but it is relied upon by zero-matrix)
! in other words:
! sequence > matrix > zero-matrix > square-matrix > zero-square-matrix > null-matrix

! Factor bug that's hard to repro: using `bi and` in these predicates
! instead of 1&& will cause spirious no-method and bounds-error errors in <square-cols>
! and the tests/docs for no apparent reason
PREDICATE: matrix < sequence
    { [ [ sequence? ] all? ] [ regular-matrix? ] } 1&& ;

PREDICATE: irregular-matrix < sequence
    { [ [ sequence? ] all? ] [ regular-matrix? not ] } 1&& ;

DEFER: dimension
! can't define dim using this predicate for this reason,
! unless we are going to write two versions of dim, one of which is generic
PREDICATE: square-matrix < matrix
    dimension first2-unsafe = ;

PREDICATE: null-matrix < matrix
    flatten empty? ;

PREDICATE: zero-matrix < matrix
    dup null-matrix? [ drop f ] [ flatten [ zero? ] all? ] if ;

PREDICATE: zero-square-matrix < square-matrix
    { [ zero-matrix? ] [ square-matrix? ] } 1&& ;

! Benign matrix constructors
: <matrix> ( m n element -- matrix )
    '[ _ _ <array> ] replicate ; inline

: <matrix-by> ( ... m n quot: ( ... -- ... elt ) -- ... matrix )
    '[ _ _ replicate ] replicate ; inline

: <matrix-by-indices> ( ... m n quot: ( ... m' n' -- ... elt ) -- ... matrix )
    [ [ <iota> ] bi@ ] dip cartesian-map ; inline

: <zero-matrix> ( m n -- matrix )
    0 <matrix> ; inline

: <zero-square-matrix> ( n -- matrix )
    dup <zero-matrix> ; inline

<PRIVATE
: (nth-from-tail) ( n seq -- n )
    length 1 - swap - ; inline flushable

: nth-end ( n seq -- elt )
    [ (nth-from-tail) ] keep nth ; inline flushable

: nth-end-unsafe ( n seq -- elt )
    [ (nth-from-tail) ] keep nth-unsafe ; inline flushable

: array-nth-end-unsafe ( n seq -- elt )
    [ (nth-from-tail) ] 1check 2 fixnum+fast slot ; inline flushable

: set-nth-end ( elt n seq -- )
    [ (nth-from-tail) ] keep set-nth ; inline

: set-nth-end-unsafe ( elt n seq -- )
    [ (nth-from-tail) ] keep set-nth-unsafe ; inline
PRIVATE>

! main-diagonal matrix
: <diagonal-matrix> ( diagonal-seq -- matrix )
    [ length <zero-square-matrix> ] keep over
    '[ dup _ nth set-nth-unsafe ] each-index ; inline

! could also be written slower as: <diagonal-matrix> [ reverse ] map
: <anti-diagonal-matrix> ( diagonal-seq -- matrix )
    [ length <zero-square-matrix> ] keep over
    '[ dup _ nth set-nth-end-unsafe ] each-index ; inline

: <identity-matrix> ( n -- matrix )
    1 <repetition> <diagonal-matrix> ; inline

: <eye> ( m n k z -- matrix )
    [ [ <iota> ] bi@ ] 2dip
    '[ _ neg + = _ 0 ? ]
    cartesian-map ; inline

! if m = n and k = 0 then <identity-matrix> is (possibly) more efficient
:: <simple-eye> ( m n k -- matrix )
    m n = k 0 = and
    [ n <identity-matrix> ]
    [ m n k 1 <eye> ] if ; inline

: <coordinate-matrix> ( dim -- coordinates )
  first2 [ <iota> ] bi@ cartesian-product ; inline

ALIAS: <cartesian-indices> <coordinate-matrix>

: <cartesian-square-indices> ( n -- matrix )
    dup 2array <cartesian-indices> ; inline

ALIAS: transpose flip

<PRIVATE
: array-matrix? ( matrix -- ? )
    [ array? ]
    [ [ array? ] all? ] bi and ; inline foldable flushable

: matrix-cols-iota ( matrix -- cols-iota )
  first-unsafe length <iota> ; inline

: unshaped-cols-iota ( matrix -- cols-iota )
  [ first-unsafe length ] keep
  [ length min ] 1 each-from <iota> ; inline

: generic-anti-transpose-unsafe ( cols-iota matrix -- newmatrix )
    [ <reversed> [ nth-end-unsafe ] with { } map-as ] curry { } map-as ; inline

: array-anti-transpose-unsafe ( cols-iota matrix -- newmatrix )
    [ <reversed> [ array-nth-end-unsafe ] with map ] curry map ; inline
PRIVATE>

! much faster than [ reverse ] map flip [ reverse ] map
: anti-transpose ( matrix -- newmatrix )
    dup empty? [ ] [
        [ dup regular-matrix?
            [ matrix-cols-iota ] [ unshaped-cols-iota ] if
        ] keep

        dup array-matrix? [
            array-anti-transpose-unsafe
        ] [
            generic-anti-transpose-unsafe
        ] if
    ] if ;

ALIAS: anti-flip anti-transpose

: row ( n matrix -- row )
    nth ; inline

: rows ( seq matrix -- rows )
    '[ _ row ] map ; inline

: col ( n matrix -- col )
    swap '[ _ swap nth ] map ; inline

: cols ( seq matrix -- cols )
    '[ _ col ] map ; inline

:: >square-matrix ( m -- subset )
    m dimension first2 :> ( x y ) {
        { [ x y = ] [ m ] }
        { [ x y < ] [ x <iota> m cols transpose ] }
        { [ x y > ] [ y <iota> m rows ] }
    } cond ;

GENERIC: <square-rows> ( desc -- matrix )
M: integer <square-rows>
    <iota> <square-rows> ;
M: sequence <square-rows>
    [ length ] keep >array '[ _ clone ] { } replicate-as ;

M: square-matrix <square-rows> ;
M: matrix <square-rows> >square-matrix ; ! coercing to square is more useful than no-method

GENERIC: <square-cols> ( desc -- matrix )
M: integer <square-cols>
    <iota> <square-cols> ;
M: sequence <square-cols>
    <square-rows> flip ;

M: square-matrix <square-cols> ;
M: matrix <square-cols>
    >square-matrix ;

<PRIVATE ! implementation details of <lower-matrix> and <upper-matrix>
: dimension-range ( matrix -- dim range )
    dimension [ <coordinate-matrix> ] [ first [1..b] ] bi ;

: upper-matrix-indices ( matrix -- matrix' )
    dimension-range <reversed> [ tail-slice* >array ] 2map concat ;

: lower-matrix-indices ( matrix -- matrix' )
    dimension-range [ head-slice >array ] 2map concat ;
PRIVATE>

! triangulars
DEFER: matrix-set-nths
: <lower-matrix> ( object m n -- matrix )
    <zero-matrix> [ lower-matrix-indices ] [ matrix-set-nths ] [ ] tri ;

: <upper-matrix> ( object m n -- matrix )
    <zero-matrix> [ upper-matrix-indices ] [ matrix-set-nths ] [ ] tri ;

! element- and sequence-wise operations, getters and setters
: stitch ( m -- m' )
    [ ] [ [ append ] 2map ] map-reduce ;

: matrix-map ( matrix quot: ( ... elt -- ... elt' ) -- matrix' )
    '[ _ map ] map ; inline

: matrix-map-index ( matrix quot: ( ... elt i j -- ... elt' ) -- matrix' )
    '[ [ swap @ ] curry map-index ] map-index ; inline

: column-map ( matrix quot: ( ... col -- ... col' ) -- matrix' )
    [ transpose ] dip map transpose ; inline

: matrix-nth ( pair matrix -- elt )
    [ first2 swap ] dip nth nth ; inline

: matrix-nths ( pairs matrix -- elts )
    '[ _ matrix-nth ] map ; inline

: matrix-set-nth ( obj pair matrix -- )
    [ first2 swap ] dip nth set-nth ; inline

: matrix-set-nths ( obj pairs matrix -- )
    '[ _ matrix-set-nth ] with each ; inline

! -------------------------------------------
! simple math of matrices follows
: mneg ( m -- m' ) [ vneg ] map ;
: mabs ( m -- m' ) [ vabs ] map ;

: n+m ( n m -- m ) [ n+v ] with map ;
: m+n ( m n -- m ) [ v+n ] curry map ;
: n-m ( n m -- m ) [ n-v ] with map ;
: m-n ( m n -- m ) [ v-n ] curry map ;
: n*m ( n m -- m ) [ n*v ] with map ;
: m*n ( m n -- m ) [ v*n ] curry map ;
: n/m ( n m -- m ) [ n/v ] with map ;
: m/n ( m n -- m ) [ v/n ] curry map ;

: m+  ( m1 m2 -- m ) [ v+ ] 2map ;
: m-  ( m1 m2 -- m ) [ v- ] 2map ;
: m*  ( m1 m2 -- m ) [ v* ] 2map ;
: m/  ( m1 m2 -- m ) [ v/ ] 2map ;

: vdotm ( v m -- p ) flip [ vdot ] with map ;
: mdotv ( m v -- p ) [ vdot ] curry map ;
: mdot ( m m -- m ) flip [ swap mdotv ] curry map ;

: m~  ( m1 m2 epsilon -- ? ) [ v~ ] curry 2all? ;

: mmin ( m -- n ) [ 1/0. ] dip [ [ min ] each ] each ;
: mmax ( m -- n ) [ -1/0. ] dip [ [ max ] each ] each ;

: matrix-l-infinity-norm ( m -- n )
    dup zero-matrix? [ drop 0 ] [
        [ [ abs ] map-sum ] map maximum
    ] if ; inline foldable

: matrix-l1-norm ( m -- n )
    dup zero-matrix? [ drop 0 ] [
        flip matrix-l-infinity-norm
    ] if ; inline foldable

: matrix-l2-norm ( m -- n )
    dup zero-matrix? [ drop 0 ] [
        [ [ sq ] map-sum ] map-sum sqrt
    ] if ; inline foldable

! XXX: M: zero-matrix l1-norm drop 0 ; inline
! XXX: M: matrix l1-norm matrix-l1-norm ; inline

! XXX: M: zero-matrix l2-norm drop 0 ; inline
! XXX: M: matrix l2-norm matrix-l2-norm ; inline

! XXX: M: zero-matrix l-infinity-norm drop 0 ; inline
! XXX: M: matrix l-infinity-norm matrix-l-infinity-norm ; inline

ALIAS: frobenius-norm matrix-l2-norm
ALIAS: hilbert-schmidt-norm matrix-l2-norm

:: matrix-p-q-norm ( m p q -- n )
    m dup zero-matrix? [ drop 0 ] [
        [ [ sq ] map-sum q p / ^ ] map-sum q recip ^
    ] if ; inline foldable

: matrix-p-norm-entrywise ( m p -- n )
    [ flatten1 V{ } like ] dip p-norm-default ; inline

! XXX: M: zero-matrix p-norm-default 2drop 0 ; inline
! XXX: M: matrix p-norm-default matrix-p-norm-entrywise ; inline

: matrix-p-norm ( m p -- n )
    over zero-matrix? [ 2drop 0 ] [
        {
            { [ dup 1 number= ] [ drop matrix-l1-norm ] }
            { [ dup 2 number= ] [ drop matrix-l2-norm ] }
            { [ dup fp-infinity? ] [ drop matrix-l-infinity-norm ] }
            [ matrix-p-norm-entrywise ]
        } cond
    ] if ; inline foldable

! XXX: M: zero-matrix p-norm 2drop 0 ; inline
! XXX: M: matrix p-norm matrix-p-norm ; inline

: matrix-normalize ( m -- m' )
    dup zero-matrix? [
        dup mabs mmax m/n
    ] unless ; inline foldable

! well-defined for square matrices; but works on nonsquare too
: main-diagonal ( matrix -- seq )
    >square-matrix [ swap nth-unsafe ] map-index ; inline

! top right to bottom left; reverse the result if you expected it to start in the lower left
: anti-diagonal ( matrix -- seq )
    >square-matrix [ swap nth-end-unsafe ] map-index ; inline

<PRIVATE
: (rows-iota) ( matrix -- rows-iota )
    dimension first-unsafe <iota> ;
: (cols-iota) ( matrix -- cols-iota )
    dimension second-unsafe <iota> ;

: simple-rows-except ( matrix desc quot -- others )
    curry [ dup (rows-iota) ] dip
    pick reject-as swap rows ; inline

: simple-cols-except ( matrix desc quot -- others )
    curry [ dup (cols-iota) ] dip
    pick reject-as swap cols transpose ; inline ! need to un-transpose the result of cols

CONSTANT: scalar-except-quot [ = ]
CONSTANT: sequence-except-quot [ member? ]
PRIVATE>

GENERIC: rows-except ( matrix desc -- others )
M: integer rows-except  scalar-except-quot   simple-rows-except ;
M: sequence rows-except sequence-except-quot simple-rows-except ;

GENERIC: cols-except ( matrix desc -- others )
M: integer cols-except  scalar-except-quot   simple-cols-except ;
M: sequence cols-except sequence-except-quot simple-cols-except ;

! well-defined for any regular matrix
: matrix-except ( matrix exclude-pair -- submatrix )
    first2 [ rows-except ] dip cols-except ;

ALIAS: submatrix-excluding matrix-except

:: matrix-except-all ( matrix -- submatrices )
    matrix dimension [ <iota> ] map first2-unsafe cartesian-product
    [ [ matrix swap matrix-except ] map ] map ;

ALIAS: all-submatrices matrix-except-all

: dimension ( matrix -- dimension )
    [ { 0 0 } ]
    [ [ length ] [ first-unsafe length ] bi 2array ] if-empty ;
