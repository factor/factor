! Copyright (C) 2009, 2011 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.struct generalizations kernel
math math.functions math.matrices.simd math.vectors
math.vectors.simd math.quaternions sequences
sequences.generalizations sequences.private specialized-arrays
typed ;
FROM: sequences.private => nth-unsafe ;
FROM: math.quaternions.private => (q*sign) ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: float-4
IN: math.matrices.simd

STRUCT: matrix4
    { columns float-4[4] } ;

INSTANCE: matrix4 immutable-sequence

M: matrix4 length drop 4 ; inline
M: matrix4 nth-unsafe columns>> nth-unsafe ; inline
M: matrix4 new-sequence 2drop matrix4 (struct) ; inline

<PRIVATE

: columns ( a -- a1 a2 a3 a4 )
    columns>> first4 ; inline

:: set-columns ( c1 c2 c3 c4 c -- c )
    c columns>> :> columns
    c1 c2 c3 c4 columns 4 set-firstn-unsafe
    c ; inline

: make-matrix4 ( ..a quot: ( ..a -- ..b c1 c2 c3 c4 ) -- ..b c )
    matrix4 (struct) swap dip set-columns ; inline

:: 2map-columns ( a b quot -- c )
    [
        a columns :> ( a1 a2 a3 a4 )
        b columns :> ( b1 b2 b3 b4 )

        a1 b1 quot call
        a2 b2 quot call
        a3 b3 quot call
        a4 b4 quot call
    ] make-matrix4 ; inline

: map-columns ( ... a quot: ( ... col -- ... newcol ) -- ... c )
    '[ columns _ 4 napply ] make-matrix4 ; inline

PRIVATE>

TYPED: m4+ ( a: matrix4 b: matrix4 -- c: matrix4 ) [ v+ ] 2map-columns ;
TYPED: m4- ( a: matrix4 b: matrix4 -- c: matrix4 ) [ v- ] 2map-columns ;
TYPED: m4* ( a: matrix4 b: matrix4 -- c: matrix4 ) [ v* ] 2map-columns ;
TYPED: m4/ ( a: matrix4 b: matrix4 -- c: matrix4 ) [ v/ ] 2map-columns ;

TYPED: m4*n ( a: matrix4 b: float -- c: matrix4 ) [ v*n ] curry map-columns ;
TYPED: m4/n ( a: matrix4 b: float -- c: matrix4 ) [ v/n ] curry map-columns ;
TYPED: n*m4 ( a: float b: matrix4 -- c: matrix4 ) [ n*v ] with map-columns ;
TYPED: n/m4 ( a: float b: matrix4 -- c: matrix4 ) [ n/v ] with map-columns ;

TYPED:: m4. ( a: matrix4 b: matrix4 -- c: matrix4 )
    [
        a columns :> ( a1 a2 a3 a4 )
        b columns :> ( b1 b2 b3 b4 )

        b1 first  a1 n*v :> c1a
        b2 first  a1 n*v :> c2a
        b3 first  a1 n*v :> c3a
        b4 first  a1 n*v :> c4a

        b1 second a2 n*v c1a v+ :> c1b
        b2 second a2 n*v c2a v+ :> c2b
        b3 second a2 n*v c3a v+ :> c3b
        b4 second a2 n*v c4a v+ :> c4b

        b1 third  a3 n*v c1b v+ :> c1c
        b2 third  a3 n*v c2b v+ :> c2c
        b3 third  a3 n*v c3b v+ :> c3c
        b4 third  a3 n*v c4b v+ :> c4c

        b1 fourth a4 n*v c1c v+
        b2 fourth a4 n*v c2c v+
        b3 fourth a4 n*v c3c v+
        b4 fourth a4 n*v c4c v+
    ] make-matrix4 ;

TYPED:: m4.v ( m: matrix4 v: float-4 -- v': float-4 )
    m columns :> ( m1 m2 m3 m4 )

    v first  m1 n*v
    v second m2 n*v v+
    v third  m3 n*v v+
    v fourth m4 n*v v+ ;

TYPED:: v.m4 ( v: float-4 m: matrix4 -- c: float-4 )
    m columns [ v vdot ] 4 napply float-4-boa ;

CONSTANT: identity-matrix4
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0 0.0 0.0 0.0 }
            float-4{ 0.0 1.0 0.0 0.0 }
            float-4{ 0.0 0.0 1.0 0.0 }
            float-4{ 0.0 0.0 0.0 1.0 }
        }
    }

CONSTANT: zero-matrix4
    S{ matrix4 f
        float-4-array{
            float-4{ 0.0 0.0 0.0 0.0 }
            float-4{ 0.0 0.0 0.0 0.0 }
            float-4{ 0.0 0.0 0.0 0.0 }
            float-4{ 0.0 0.0 0.0 0.0 }
        }
    }

TYPED:: m4^n ( m: matrix4 n: fixnum -- m^n: matrix4 )
    identity-matrix4 n [ m m4. ] times ;

: vmerge-diagonal* ( x y -- h t )
    [ (vmerge-head) ] [ swap (vmerge-tail) ] 2bi ; inline
: vmerge-diagonal ( x -- h t )
    0.0 float-4-with vmerge-diagonal* ; inline

TYPED: diagonal-matrix4 ( diagonal: float-4 -- matrix: matrix4 )
    [ vmerge-diagonal [ vmerge-diagonal ] bi@ ] make-matrix4 ;

: vmerge-transpose ( a b c d -- a' b' c' d' )
    [ (vmerge) ] bi-curry@ bi* ; inline

TYPED: transpose-matrix4 ( matrix: matrix4 -- matrix: matrix4 )
    [ columns vmerge-transpose vmerge-transpose ] make-matrix4 ;

: linear>homogeneous ( v -- v' )
    [ float-4{ t t t f } ] dip float-4{ 0.0 0.0 0.0 1.0 } v? ; inline

: scale-matrix4 ( factors -- matrix )
    linear>homogeneous diagonal-matrix4 ; inline

: ortho-matrix4 ( factors -- matrix )
    float-4{ 1.0 1.0 1.0 1.0 } swap v/ scale-matrix4 ; inline

TYPED: translation-matrix4 ( offset: float-4 -- matrix: matrix4 )
    [
        linear>homogeneous
        [
            float-4{ 1.0 0.0 0.0 0.0 }
            float-4{ 0.0 1.0 0.0 0.0 }
            float-4{ 0.0 0.0 1.0 0.0 }
        ] dip
    ] make-matrix4 ;

:: (rotation-matrix4) ( diagonal triangle-hi triangle-lo -- matrix )
    matrix4 (struct) :> triangle-m
    diagonal scale-matrix4 :> diagonal-m

    triangle-hi { 3 2 1 3 } vshuffle
    triangle-hi { 3 3 0 3 } vshuffle triangle-lo { 2 3 3 3 } vshuffle vbitor
                                     triangle-lo { 1 0 3 3 } vshuffle
    float-4 new

    triangle-m set-columns drop

    diagonal-m triangle-m m4+ ; inline

TYPED:: rotation-matrix4 ( axis: float-4 theta: float -- matrix: matrix4 )
    !   x*x + c*(1.0 - x*x)   x*y*(1.0 - c) + s*z   x*z*(1.0 - c) - s*y   0
    !   x*y*(1.0 - c) - s*z   y*y + c*(1.0 - y*y)   y*z*(1.0 - c) + s*x   0
    !   x*z*(1.0 - c) + s*y   y*z*(1.0 - c) - s*x   z*z + c*(1.0 - z*z)   0
    !   0                     0                     0                     1
    theta cos :> c
    theta sin :> s

    float-4{ -1.0  1.0 -1.0 0.0 } :> triangle-sign

    c float-4-with :> cc
    s float-4-with :> ss
    1.0 float-4-with :> ones
    ones cc v- :> 1-c
    axis axis v* :> axis2

    axis2 cc ones axis2 v- v* v+ :> diagonal

    axis { 1 0 0 3 } vshuffle axis { 2 2 1 3 } vshuffle v* 1-c v*
    float-4{ t t t f } vbitand :> triangle-a
    ss axis v* triangle-sign v* :> triangle-b
    triangle-a triangle-b v+ :> triangle-lo
    triangle-a triangle-b v- :> triangle-hi

    diagonal triangle-hi triangle-lo (rotation-matrix4) ;

TYPED:: frustum-matrix4 ( xy: float-4 near: float far: float -- matrix: matrix4 )
    [
        near near near far + 2 near far * * float-4-boa ! num
        float-4{ t t f f } xy near far - float-4-with v? ! denom
        v/ :> fov

        float-4{ 0.0 -1.0 0.0 0.0 } :> negone

        fov vmerge-diagonal
        [ vmerge-diagonal ]
        [ negone (vmerge) ] bi*
    ] make-matrix4 ;

! interface with quaternions
M: float-4 (q*sign)
    float-4{ -0.0  0.0  0.0  0.0 } vbitxor ; inline
M: float-4 qconjugate
    float-4{  0.0 -0.0 -0.0 -0.0 } vbitxor ; inline

: euler4 ( phi theta psi -- q )
    float-4{ 0 0 0 0 } euler-like ; inline

TYPED:: q>matrix4 ( q: float-4 -- matrix: matrix4 )
    !   a*a + b*b - c*c - d*d  2*b*c - 2*a*d          2*b*d + 2*a*c          0
    !   2*b*c + 2*a*d          a*a - b*b + c*c - d*d  2*c*d - 2*a*b          0
    !   2*b*d - 2*a*c          2*c*d + 2*a*b          a*a - b*b - c*c + d*d  0
    !   0                      0                      0                      1
    q { 2 1 1 3 } vshuffle  q { 3 3 2 3 } vshuffle  v*  :> triangle-a
    q { 0 0 0 3 } vshuffle  q { 1 2 3 3 } vshuffle  v*  :> triangle-b

    triangle-a float-4{ 2.0 2.0 2.0 0.0 } v*  triangle-b float-4{ -2.0 2.0 -2.0 0.0 } v*
    [ v- ] [ v+ ] 2bi :> ( triangle-hi triangle-lo )

    q q v* first4 {
        [ [ + ] [ - ] [ - ] tri* ]
        [ [ - ] [ + ] [ - ] tri* ]
        [ [ - ] [ - ] [ + ] tri* ]
    } 4 ncleave 1.0 float-4-boa :> diagonal

    diagonal triangle-hi triangle-lo (rotation-matrix4) ;
