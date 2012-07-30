! Copyright (C) 2005, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays columns kernel locals math math.bits
math.functions math.order math.vectors sequences
sequences.private fry ;
IN: math.matrices

! Matrices
: zero-matrix ( m n -- matrix )
    '[ _ 0 <array> ] replicate ;

: diagonal-matrix ( diagonal-seq -- matrix )
    dup length dup zero-matrix
    [ '[ dup _ nth set-nth ] each-index ] keep ; inline

: identity-matrix ( n -- matrix )
    1 <repetition> diagonal-matrix ; inline

: eye ( m n k -- matrix )
    [ [ iota ] bi@ ] dip neg '[ _ + = 1 0 ? ] cartesian-map ;

: hilbert-matrix ( m n -- matrix )
    [ iota ] bi@ [ + 1 + recip ] cartesian-map ;

: toeplitz-matrix ( n -- matrix )
    iota dup [ - abs 1 + ] cartesian-map ;

: hankel-matrix ( n -- matrix )
    [ iota dup ] keep '[ + abs 1 + dup _ > [ drop 0 ] when ] cartesian-map ;

: box-matrix ( r -- matrix )
    2 * 1 + dup '[ _ 1 <array> ] replicate ;

: van-der-monde-matrix ( u n -- matrix )
    iota [ v^n ] with map reverse flip ;

:: rotation-matrix3 ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> ( x y z )
    x sq 1.0 x sq - c * +     x y * 1.0 c - * z s * -   x z * 1.0 c - * y s * + 3array
    x y * 1.0 c - * z s * +   y sq 1.0 y sq - c * +     y z * 1.0 c - * x s * - 3array
    x z * 1.0 c - * y s * -   y z * 1.0 c - * x s * +   z sq 1.0 z sq - c * +   3array
    3array ;

:: rotation-matrix4 ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> ( x y z )
    x sq 1.0 x sq - c * +     x y * 1.0 c - * z s * -   x z * 1.0 c - * y s * +   0 4array
    x y * 1.0 c - * z s * +   y sq 1.0 y sq - c * +     y z * 1.0 c - * x s * -   0 4array
    x z * 1.0 c - * y s * -   y z * 1.0 c - * x s * +   z sq 1.0 z sq - c * +     0 4array
    { 0.0 0.0 0.0 1.0 } 4array ;

:: translation-matrix4 ( offset -- matrix )
    offset first3 :> ( x y z )
    {
        { 1.0 0.0 0.0 x   }
        { 0.0 1.0 0.0 y   }
        { 0.0 0.0 1.0 z   }
        { 0.0 0.0 0.0 1.0 }
    } ;

: >scale-factors ( number/sequence -- x y z )
    dup number? [ dup dup ] [ first3 ] if ;

:: scale-matrix3 ( factors -- matrix )
    factors >scale-factors :> ( x y z )
    {
        { x   0.0 0.0 }
        { 0.0 y   0.0 }
        { 0.0 0.0 z   }
    } ;

:: scale-matrix4 ( factors -- matrix )
    factors >scale-factors :> ( x y z )
    {
        { x   0.0 0.0 0.0 }
        { 0.0 y   0.0 0.0 }
        { 0.0 0.0 z   0.0 }
        { 0.0 0.0 0.0 1.0 }
    } ;

: ortho-matrix4 ( dim -- matrix )
    [ recip ] map scale-matrix4 ;

:: frustum-matrix4 ( xy-dim near far -- matrix )
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

:: skew-matrix4 ( theta -- matrix )
    theta tan :> zf

    {
        { 1.0 0.0 0.0 0.0 }
        { 0.0 1.0 0.0 0.0 }
        { 0.0 zf  1.0 0.0 }
        { 0.0 0.0 0.0 1.0 }
    } ;

! Matrix operations
: mneg ( m -- m ) [ vneg ] map ;

: n*m ( n m -- m ) [ n*v ] with map ;
: m*n ( m n -- m ) [ v*n ] curry map ;
: n/m ( n m -- m ) [ n/v ] with map ;
: m/n ( m n -- m ) [ v/n ] curry map ;

: m+   ( m m -- m ) [ v+ ] 2map ;
: m-   ( m m -- m ) [ v- ] 2map ;
: m*   ( m m -- m ) [ v* ] 2map ;
: m/   ( m m -- m ) [ v/ ] 2map ;

: v.m ( v m -- v ) flip [ v. ] with map ;
: m.v ( m v -- v ) [ v. ] curry map ;
: m.  ( m m -- m ) flip [ swap m.v ] curry map ;

: m~  ( m m epsilon -- ? ) [ v~ ] curry 2all? ;

: mmin ( m -- n ) [ 1/0. ] dip [ [ min ] each ] each ;
: mmax ( m -- n ) [ -1/0. ] dip [ [ max ] each ] each ;
: mnorm ( m -- n ) dup mmax abs m/n ;

: cross ( vec1 vec2 -- vec3 )
    [ [ { 1 2 0 } vshuffle ] [ { 2 0 1 } vshuffle ] bi* v* ]
    [ [ { 2 0 1 } vshuffle ] [ { 1 2 0 } vshuffle ] bi* v* ] 2bi v- ; inline

:: normal ( vec1 vec2 vec3 -- vec4 )
    vec2 vec1 v- vec3 vec1 v- cross normalize ; inline

: proj ( v u -- w )
    [ [ v. ] [ norm-sq ] bi / ] keep n*v ;

: perp ( v u -- w )
    dupd proj v- ;

: angle-between ( v u -- a )
    [ normalize ] bi@ h. acos ;

: (gram-schmidt) ( v seq -- newseq )
    [ dupd proj v- ] each ;

: gram-schmidt ( seq -- orthogonal )
    V{ } clone [ over (gram-schmidt) over push ] reduce ;

: norm-gram-schmidt ( seq -- orthonormal )
    gram-schmidt [ normalize ] map ;

: m^n ( m n -- n ) 
    make-bits over first length identity-matrix
    [ [ dupd m. ] when [ dup m. ] dip ] reduce nip ;

: stitch ( m -- m' )
    [ ] [ [ append ] 2map ] map-reduce ;

: kron ( m1 m2 -- m )
    '[ [ _ n*m  ] map ] map stitch stitch ;
