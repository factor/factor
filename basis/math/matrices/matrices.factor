! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays columns kernel locals math math.bits
math.functions math.order math.vectors sequences
sequences.private fry ;
IN: math.matrices

! Matrices
: zero-matrix ( m n -- matrix )
    '[ _ 0 <array> ] replicate ;

: identity-matrix ( n -- matrix )
    #! Make a nxn identity matrix.
    dup [ [ = 1 0 ? ] with map ] curry map ;

:: rotation-matrix3 ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> z :> y :> x
    x sq 1.0 x sq - c * +     x y * 1.0 c - * z s * -   x z * 1.0 c - * y s * + 3array
    x y * 1.0 c - * z s * +   y sq 1.0 y sq - c * +     y z * 1.0 c - * x s * - 3array
    x z * 1.0 c - * y s * -   y z * 1.0 c - * x s * +   z sq 1.0 z sq - c * +   3array
    3array ;

:: rotation-matrix4 ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> z :> y :> x
    x sq 1.0 x sq - c * +     x y * 1.0 c - * z s * -   x z * 1.0 c - * y s * +   0 4array
    x y * 1.0 c - * z s * +   y sq 1.0 y sq - c * +     y z * 1.0 c - * x s * -   0 4array
    x z * 1.0 c - * y s * -   y z * 1.0 c - * x s * +   z sq 1.0 z sq - c * +     0 4array
    { 0.0 0.0 0.0 1.0 } 4array ;

:: translation-matrix4 ( offset -- matrix )
    offset first3 :> z :> y :> x
    {
        { 1.0 0.0 0.0 x   }
        { 0.0 1.0 0.0 y   }
        { 0.0 0.0 1.0 z   }
        { 0.0 0.0 0.0 1.0 }
    } ;

: >scale-factors ( number/sequence -- x y z )
    dup number? [ dup dup ] [ first3 ] if ;

:: scale-matrix3 ( factors -- matrix )
    factors >scale-factors :> z :> y :> x
    {
        { x   0.0 0.0 }
        { 0.0 y   0.0 }
        { 0.0 0.0 z   }
    } ;

:: scale-matrix4 ( factors -- matrix )
    factors >scale-factors :> z :> y :> x
    {
        { x   0.0 0.0 0.0 }
        { 0.0 y   0.0 0.0 }
        { 0.0 0.0 z   0.0 }
        { 0.0 0.0 0.0 1.0 }
    } ;

: ortho-matrix4 ( dim -- matrix )
    [ recip ] map scale-matrix4 ;

:: frustum-matrix4 ( xy-dim near far -- matrix )
    xy-dim first2 :> y :> x
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

<PRIVATE

: x ( seq -- elt ) first ; inline
: y ( seq -- elt ) second ; inline
: z ( seq -- elt ) third ; inline

: i ( seq1 seq2 -- n ) [ [ y ] [ z ] bi* * ] [ [ z ] [ y ] bi* * ] 2bi - ;
: j ( seq1 seq2 -- n ) [ [ z ] [ x ] bi* * ] [ [ x ] [ z ] bi* * ] 2bi - ;
: k ( seq1 seq2 -- n ) [ [ y ] [ x ] bi* * ] [ [ x ] [ y ] bi* * ] 2bi - ;

PRIVATE>

: cross ( vec1 vec2 -- vec3 )
    [ [ { 1 2 1 } vshuffle ] [ { 2 0 0 } vshuffle ] bi* v* ]
    [ [ { 2 0 0 } vshuffle ] [ { 1 2 1 } vshuffle ] bi* v* ] 2bi v- ; inline

: proj ( v u -- w )
    [ [ v. ] [ norm-sq ] bi / ] keep n*v ;

: (gram-schmidt) ( v seq -- newseq )
    [ dupd proj v- ] each ;

: gram-schmidt ( seq -- orthogonal )
    V{ } clone [ over (gram-schmidt) over push ] reduce ;

: norm-gram-schmidt ( seq -- orthonormal )
    gram-schmidt [ normalize ] map ;

: cross-zip ( seq1 seq2 -- seq1xseq2 )
    [ [ 2array ] with map ] curry map ;
    
: m^n ( m n -- n ) 
    make-bits over first length identity-matrix
    [ [ dupd m. ] when [ dup m. ] dip ] reduce nip ;
