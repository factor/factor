! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, and Cat Stevens.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators formatting kernel math
math.bits math.functions math.matrices math.order
math.statistics math.text.english math.vectors random sequences
sequences.deep summary ;
IN: math.matrices.extras

! this is a questionable implementation
SINGLETONS:      +full-rank+ +half-rank+ +zero-rank+ +deficient-rank+ +uncalculated-rank+ ;
UNION: rank-kind +full-rank+ +half-rank+ +zero-rank+ +deficient-rank+ +uncalculated-rank+ ;

ERROR: negative-power-matrix
    { m matrix } { n integer } ;
ERROR: non-square-determinant
    { m integer }  { n integer } ;
ERROR: undefined-inverse
    { m integer }  { n integer } { r rank-kind initial: +uncalculated-rank+ } ;

M: negative-power-matrix summary
    n>> dup ordinal-suffix "%s%s power of a matrix is undefined" sprintf ;
M: non-square-determinant summary
    [ m>> ] [ n>> ] bi "non-square %s x %s matrix has no determinant" sprintf ;
M: undefined-inverse summary
    [ m>> ] [ n>> ] [ r>> name>> ] tri "%s x %s matrix of rank %s has no inverse" sprintf ;

<PRIVATE
DEFER: alternating-sign
: finish-randomizing-matrix ( matrix -- matrix' )
    [ f alternating-sign randomize ] map randomize ; inline
PRIVATE>

: <random-integer-matrix> ( m n max -- matrix )
    '[ _ _ 1 + randoms ] replicate
    finish-randomizing-matrix ; inline

: <random-unit-matrix> ( m n max -- matrix )
    '[ _ random-units [ _ * ] map ] replicate
    finish-randomizing-matrix ; inline

<PRIVATE
: (gram-schmidt) ( v seq -- newseq )
    [ dupd proj v- ] each ;
PRIVATE>

: gram-schmidt ( matrix -- orthogonal )
    [ V{ } clone [ over (gram-schmidt) suffix! ] reduce ] keep like ;

: gram-schmidt-normalize ( matrix -- orthonormal )
    gram-schmidt [ normalize ] map ; inline

: kronecker-product ( m1 m2 -- m )
    '[ [ _ n*m  ] map ] map stitch stitch ;

: outer-product ( u v -- matrix )
    '[ _ n*v ] map ;

! Special matrix constructors follow
: <hankel-matrix> ( n -- matrix )
  [ <iota> dup ] keep '[ + abs 1 + dup _ > [ drop 0 ] when ] cartesian-map ;

: <hilbert-matrix> ( m n -- matrix )
    [ <iota> ] bi@ [ + 1 + recip ] cartesian-map ;

: <toeplitz-matrix> ( n -- matrix )
    <iota> dup [ - abs 1 + ] cartesian-map ;

: <box-matrix> ( r -- matrix )
    2 * 1 + dup '[ _ 1 <array> ] replicate ;

: <vandermonde-matrix> ( u n -- matrix )
    <iota> [ v^n ] with map reverse flip ;

! Transformation matrices
:: <rotation-matrix3> ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> ( x y z )
    x sq 1.0 x sq - c * +    x y * 1.0 c - * z s * -  x z * 1.0 c - * y s * + 3array
    x y * 1.0 c - * z s * +  y sq 1.0 y sq - c * +    y z * 1.0 c - * x s * - 3array
    x z * 1.0 c - * y s * -  y z * 1.0 c - * x s * +  z sq 1.0 z sq - c * +   3array
    3array ;

:: <rotation-matrix4> ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> ( x y z )
    x sq 1.0 x sq - c * +    x y * 1.0 c - * z s * -  x z * 1.0 c - * y s * +  0 4array
    x y * 1.0 c - * z s * +  y sq 1.0 y sq - c * +    y z * 1.0 c - * x s * -  0 4array
    x z * 1.0 c - * y s * -  y z * 1.0 c - * x s * +  z sq 1.0 z sq - c * +    0 4array
    { 0.0 0.0 0.0 1.0 } 4array ;

:: <translation-matrix4> ( offset -- matrix )
    offset first3 :> ( x y z )
    {
        { 1.0 0.0 0.0 x   }
        { 0.0 1.0 0.0 y   }
        { 0.0 0.0 1.0 z   }
        { 0.0 0.0 0.0 1.0 }
    } ;

<PRIVATE
GENERIC: >scale-factors ( object -- x y z )
M: number >scale-factors
    dup dup ;
M: sequence >scale-factors
    first3 ;
PRIVATE>

:: <scale-matrix3> ( factors -- matrix )
    factors >scale-factors :> ( x y z )
    {
        { x   0.0 0.0 }
        { 0.0 y   0.0 }
        { 0.0 0.0 z   }
    } ;

:: <scale-matrix4> ( factors -- matrix )
    factors >scale-factors :> ( x y z )
    {
        { x   0.0 0.0 0.0 }
        { 0.0 y   0.0 0.0 }
        { 0.0 0.0 z   0.0 }
        { 0.0 0.0 0.0 1.0 }
    } ;

: <ortho-matrix4> ( factors -- matrix )
    [ recip ] map <scale-matrix4> ;

:: <frustum-matrix4> ( xy-dim near far -- matrix )
    xy-dim first2 :> ( x y )
    near x /f :> xf
    near y /f :> yf
    near far + near far - /f :> zf
    2 near far * * near far - /f :> wf

    {
        { xf  0.0  0.0 0.0 }
        { 0.0 yf   0.0 0.0 }
        { 0.0 0.0  zf  wf  }
        { 0.0 0.0 -1.0 0.0 }
    } ;

:: <skew-matrix4> ( theta -- matrix )
    theta tan :> zf
    {
        { 1.0 0.0 0.0 0.0 }
        { 0.0 1.0 0.0 0.0 }
        { 0.0 zf  1.0 0.0 }
        { 0.0 0.0 0.0 1.0 }
    } ;

! a simpler verison of this, like matrix-map -except, but map-index, should be possible
: cartesian-matrix-map ( matrix quot: ( ... pair matrix -- ... matrix' ) -- matrix-seq )
    [ [ first length <cartesian-square-indices> ] keep ] dip
    '[ _ @ ] matrix-map ; inline

: cartesian-column-map ( matrix quot: ( ... pair matrix -- ... matrix' ) -- matrix-seq )
    [ cols first2 ] prepose cartesian-matrix-map ; inline

! -------------------------------------------------
! numerical analysis of matrices follows
<PRIVATE

: square-rank ( square-matrix -- rank ) ;
: nonsquare-rank ( matrix -- rank ) ;
PRIVATE>

GENERIC: rank ( matrix -- rank )
M: zero-matrix rank
    drop +zero-rank+ ;

M: square-matrix rank
    square-rank ;

M: matrix rank
    nonsquare-rank ;

GENERIC: nullity ( matrix -- nullity )


! implementation details of determinant and inverse
<PRIVATE
: alternating-sign ( seq odd-elts? -- seq' )
    '[ even? _ = [ neg ] unless ] map-index ;

! the determinant of a 1x1 matrix is the value itself
! this works for any-dimensional matrices too
: (1determinant) ( matrix -- 1det ) flatten first ; inline

! optimized to find the determinant of a 2x2 matrix
: (2determinant) ( matrix -- 2det )
    ! multiply the diagonals and subtract
    [ main-diagonal ] [ anti-diagonal ] bi [ first2 * ] bi@ - ; inline

! optimized for 3x3
! https://www.mathsisfun.com/algebra/matrix-determinant.html
:: (3determinant) ( matrix-seq -- 3det )
    ! first 3 elements of row 1
    matrix-seq first first3 :> ( a b c )
    ! last 2 rows, transposed to make the next step easier
    matrix-seq rest transpose
    ! get the lower sub-matrices in reverse order of a b c columns
    [ rest ] [ [ first ] [ third ] bi 2array ] [ 1 head* ] tri 3array
    ! find determinants
    [ (2determinant) ] map
    ! negate odd elements of a b c and multiply by the new determinants
    { a b c } t alternating-sign v*
    ! sum the resulting sequence
    sum ;

DEFER: (ndeterminant)
: make-determinants ( n matrix -- seq )
    <repetition> [
        cols-except [ length ] keep (ndeterminant) ! recurses here
    ] map-index ;

DEFER: (determinant)
! generalized to 4 and higher
: (ndeterminant) ( n matrix -- ndet )
    ! TODO? recurse for n < 3
    over 4 < [ (determinant) ] [
        [ nip first t alternating-sign ] [ rest make-determinants ] 2bi
        v* sum
    ] if ;

! switches on dimensions only
: (determinant) ( n matrix -- determinant )
    over {
        { 1 [ nip (1determinant) ] }
        { 2 [ nip (2determinant) ] }
        { 3 [ nip (3determinant) ] }
        [ drop (ndeterminant) ]
    } case ;
PRIVATE>

GENERIC: determinant ( matrix -- determinant )
M: zero-square-matrix determinant
    drop 0 ;

M: square-matrix determinant
    [ length ] keep (determinant) ;

! determinant is undefined for m =/= n, unlike inverse
M: matrix determinant
    dimension first2 non-square-determinant ;

: 1/det ( matrix -- 1/det )
    determinant recip ; inline

! -----------------------------------------------------
! inverse operations and implementations follow
ALIAS: multiplicative-inverse recip

! per element, find the determinant of all other elements except the element's row / col
! https://www.mathsisfun.com/algebra/matrix-inverse-minors-cofactors-adjugate.html
: >minors ( matrix -- matrix' )
    matrix-except-all [ [ determinant ] map ] map ;

! alternately invert values of the matrix (see alternating-sign)
: >cofactors ( matrix -- matrix' )
    [ even? alternating-sign ] map-index ;

! multiply a matrix by the inverse of its determinant
: m*1/det ( matrix -- matrix' )
    [ 1/det ] keep n*m ; inline

! inverse implementation
<PRIVATE
! https://www.mathsisfun.com/algebra/matrix-inverse-minors-cofactors-adjugate.html
: (square-inverse) ( square-matrix -- inverted )
    ! inverse of the determinant of the input matrix
    [ 1/det ]
    ! adjugate of the cofactors of the matrix of minors
    [ >minors >cofactors transpose ]
    ! adjugate * 1/det
    bi n*m ;

! TODO
: (left-inverse) ( matrix -- left-invert )   ;
: (right-inverse) ( matrix -- right-invert ) ;

! TODO update this when rank works properly
! only defined for rank(A) = rows(A) OR rank(A) = cols(M)
! https://en.wikipedia.org/wiki/Invertible_matrix
: (specialized-inverse) ( rect-matrix -- inverted )
    dup [ rank ] [ dimension ] bi [ = ] with map {
        { { t f } [ (left-inverse) ] }
        { { f t } [ (right-inverse) ] }
        [ no-case ]
    } case ;
PRIVATE>

M: zero-square-matrix recip
    ; inline

M: square-matrix recip
    (square-inverse) ; inline

M: zero-matrix recip
    transpose ; inline ! TODO: error based on rankiness

M: matrix recip
    (specialized-inverse) ; inline

! TODO: use the faster algorithm: [ determinant zero? ]
: invertible-matrix? ( matrix -- ? )
    [ dimension first2 max <identity-matrix> ] keep
    dup recip mdot = ;

: linearly-independent-matrix? ( matrix -- ? ) ;

<PRIVATE
! this is the original definition of m^n as committed in 2012; it has not been lost
: (m^n) ( m n -- n )
    make-bits over first length <identity-matrix>
    [ [ dupd mdot ] when [ dup mdot ] dip ] reduce nip ;
PRIVATE>

! A^-1 is the inverse but other negative powers are nonsense
: m^n ( m n -- n ) {
        { [ dup -1 = ] [ drop recip ] }
        { [ dup 0 >= ] [ (m^n) ] }
        [ negative-power-matrix ]
    } cond ;

: n^m ( n m -- n ) swap m^n ; inline

: covariance-matrix-ddof ( matrix ddof -- cov )
    '[ _ cov-ddof ] cartesian-column-map ; inline

: covariance-matrix ( matrix -- cov )
    0 covariance-matrix-ddof ; inline

: sample-covariance-matrix ( matrix -- cov )
    1 covariance-matrix-ddof ; inline

: population-covariance-matrix ( matrix -- cov ) 0 covariance-matrix-ddof ; inline
