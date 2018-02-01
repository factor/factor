! Copyright (C) 2005, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays columns kernel locals math math.bits
math.functions math.order math.vectors sequences
sequences.private fry math.vectors.private math.statistics grouping
combinators.short-circuit math.ranges combinators.smart ;
IN: math.matrices

ERROR: negative-power-matrix m n ;

! Matrices
: <matrix-by> ( m n quot: ( ... -- elt ) -- matrix )
    '[ _ _ replicate ] replicate ; inline

: <matrix-by-indices> ( ... m n quot: ( ... m' n' -- ... elt ) -- ... matrix )
    [ [ <iota> ] bi@ ] dip cartesian-map ; inline

: <matrix> ( m n element -- matrix )
    '[ _ _ <array> ] replicate ; inline

: <zero-matrix> ( m n -- matrix )
    0 <matrix> ; inline

: <zero-square-matrix> ( n -- matrix )
    dup 0 <matrix> ; inline

: <diagonal-matrix> ( diagonal-seq -- matrix )
    [ length <zero-square-matrix> ] keep swap
    [ '[ dup _ nth set-nth ] each-index ] keep ; inline

: <identity-matrix> ( n -- matrix )
    1 <repetition> <diagonal-matrix> ; inline

: <eye> ( m n k z -- matrix )
    [ [ <iota> ] bi@ ] 2dip
    '[ _ neg + = _ 0 ? ]
    cartesian-map ;

! if m = n and k = 0 then <identity-matrix> is (possibly) faster
:: <simple-eye> ( m n k -- matrix )
    m n = k 0 = and
    [ n <identity-matrix> ]
    [ m n k 1 <eye> ] if ;

DEFER: matrix-indices
DEFER: matrix-set-nths

: <lower-matrix> ( object m n -- matrix )
    <zero-matrix> [ matrix-indices ] [ matrix-set-nths ] [ ] tri ;

: <upper-matrix> ( object m n -- matrix )
    <zero-matrix> [ matrix-indices ] [ matrix-set-nths ] [ ] tri ;

: <cartesian-square-indices> ( n -- matrix )
    <iota> dup cartesian-product ; inline

! Special matrix constructors follow
: <hilbert-matrix> ( m n -- matrix )
    [ <iota> ] bi@ [ + 1 + recip ] cartesian-map ;

: <toeplitz-matrix> ( n -- matrix )
    <iota> dup [ - abs 1 + ] cartesian-map ;

: <hankel-matrix> ( n -- matrix )
    [ <iota> dup ] keep '[ + abs 1 + dup _ > [ drop 0 ] when ] cartesian-map ;

: <box-matrix> ( r -- matrix )
    2 * 1 + dup '[ _ 1 <array> ] replicate ;

: <vandermonde-matrix> ( u n -- matrix )
    <iota> [ v^n ] with map reverse flip ;

:: <rotation-matrix3> ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> ( x y z )
    x sq 1.0 x sq - c * +     x y * 1.0 c - * z s * -   x z * 1.0 c - * y s * + 3array
    x y * 1.0 c - * z s * +   y sq 1.0 y sq - c * +     y z * 1.0 c - * x s * - 3array
    x z * 1.0 c - * y s * -   y z * 1.0 c - * x s * +   z sq 1.0 z sq - c * +   3array
    3array ;

:: <rotation-matrix4> ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> ( x y z )
    x sq 1.0 x sq - c * +     x y * 1.0 c - * z s * -   x z * 1.0 c - * y s * +   0 4array
    x y * 1.0 c - * z s * +   y sq 1.0 y sq - c * +     y z * 1.0 c - * x s * -   0 4array
    x z * 1.0 c - * y s * -   y z * 1.0 c - * x s * +   z sq 1.0 z sq - c * +     0 4array
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
: >scale-factors ( number/sequence -- x y z )
    dup number? [ dup dup ] [ first3 ] if ;
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

: <ortho-matrix4> ( dim -- matrix )
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

! Matrix operations
: mneg ( m -- m ) [ vneg ] map ;

: n+m  ( n m -- m ) [ n+v ] with map ;
: m+n  ( m n -- m ) [ v+n ] curry map ;
: n-m  ( n m -- m ) [ n-v ] with map ;
: m-n  ( m n -- m ) [ v-n ] curry map ;
: n*m ( n m -- m ) [ n*v ] with map ;
: m*n ( m n -- m ) [ v*n ] curry map ;
: n/m ( n m -- m ) [ n/v ] with map ;
: m/n ( m n -- m ) [ v/n ] curry map ;

: m+   ( m1 m2 -- m ) [ v+ ] 2map ;
: m-   ( m1 m2 -- m ) [ v- ] 2map ;
: m*   ( m1 m2 -- m ) [ v* ] 2map ;
: m/   ( m1 m2 -- m ) [ v/ ] 2map ;

: v.m ( v m -- p ) flip [ v. ] with map ;
: m.v ( m v -- p ) [ v. ] curry map ;
: m.  ( m m -- m ) flip [ swap m.v ] curry map ;
! should this be called m.m ?

: m~  ( m1 m2 epsilon -- ? ) [ v~ ] curry 2all? ;

: mmin ( m -- n ) [ 1/0. ] dip [ [ min ] each ] each ;
: mmax ( m -- n ) [ -1/0. ] dip [ [ max ] each ] each ;
: mnorm ( m -- n ) dup mmax abs m/n ;


<PRIVATE

: (gram-schmidt) ( v seq -- newseq )
    [ dupd proj v- ] each ;

: (m^n) ( m n -- n )
    make-bits over first length <identity-matrix>
    [ [ dupd m. ] when [ dup m. ] dip ] reduce nip ;

PRIVATE>

: gram-schmidt ( seq -- orthogonal )
    V{ } clone [ over (gram-schmidt) suffix! ] reduce ;

: gram-schmidt-normalize ( seq -- orthonormal )
    gram-schmidt [ normalize ] map ; inline

: m^n ( m n -- n )
    dup 0 >= [ (m^n) ] [ negative-power-matrix ] if ;

: stitch ( m -- m' )
    [ ] [ [ append ] 2map ] map-reduce ;

: kronecker ( m1 m2 -- m )
    '[ [ _ n*m  ] map ] map stitch stitch ;

: outer ( u v -- m )
    [ n*v ] curry map ;

: row ( n matrix -- col )
    nth ; inline

: rows ( seq matrix -- cols )
    '[ _ row ] map ; inline

: col ( n matrix -- col )
    swap '[ _ swap nth ] map ; inline

: cols ( seq matrix -- cols )
    '[ _ col ] map ; inline

: matrix-set-nth ( obj pair matrix -- )
    [ first2 swap ] dip nth set-nth ; inline

: matrix-set-nths ( obj sequence matrix -- )
    '[ _ matrix-set-nth ] with each ; inline

: matrix-map ( matrix quot -- )
    '[ _ map ] map ; inline

: column-map ( matrix quot -- seq )
    [ [ first length <iota> ] keep ] dip '[ _ col @ ] map ; inline

: cartesian-matrix-map ( matrix quot -- matrix' )
    [ [ first length <cartesian-square-indices> ] keep ] dip
    '[ _ @ ] matrix-map ; inline

: cartesian-matrix-column-map ( matrix quot -- matrix' )
    [ cols first2 ] prepose cartesian-matrix-map ; inline

: cov-matrix-ddof ( matrix ddof -- cov )
    '[ _ cov-ddof ] cartesian-matrix-column-map ; inline

: cov-matrix ( matrix -- cov ) 0 cov-matrix-ddof ; inline

: sample-cov-matrix ( matrix -- cov ) 1 cov-matrix-ddof ; inline

GENERIC: <square-rows> ( object -- matrix )
M: integer <square-rows> <iota> <square-rows> ;
M: sequence <square-rows>
    [ length ] keep >array '[ _ clone ] { } replicate-as ;

GENERIC: <square-cols> ( object -- matrix )
M: integer <square-cols> <iota> <square-cols> ;
M: sequence <square-cols>
    [ length ] keep [ <array> ] with { } map-as ;

: null-matrix? ( matrix -- ? ) empty? ; inline

: well-formed-matrix? ( matrix -- ? )
    [ t ] [
        [ ] [ first length ] bi
        '[ length _ = ] all?
    ] if-empty ;

: dim ( matrix -- pair/f )
    [ 2 0 <array> ]
    [ [ length ] [ first length ] bi 2array ] if-empty ;

: square-matrix? ( matrix -- ? )
    { [ well-formed-matrix? ] [ dim all-eq? ] } 1&& ;

: matrix-coordinates ( dim -- coordinates )
    first2 [ <iota> ] bi@ cartesian-product ; inline

: dimension-range ( matrix -- dim range )
    dim [ matrix-coordinates ] [ first [1,b] ] bi ;

: upper-matrix-indices ( matrix -- matrix' )
    dimension-range <reversed> [ tail-slice* >array ] 2map concat ;

: lower-matrix-indices ( matrix -- matrix' )
    dimension-range [ head-slice >array ] 2map concat ;
