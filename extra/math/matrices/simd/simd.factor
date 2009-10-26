! (c)Joe Groff bsd license
USING: accessors classes.struct fry generalizations kernel locals
math math.combinatorics math.functions math.matrices.simd math.vectors
math.vectors.simd sequences sequences.private specialized-arrays
typed ;
QUALIFIED-WITH: alien.c-types c
SIMD: c:float
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
    c1 columns set-first
    c2 columns set-second
    c3 columns set-third
    c4 columns set-fourth
    c ; inline

: make-matrix4 ( quot: ( -- c1 c2 c3 c4 ) -- c )
    matrix4 (struct) swap dip set-columns ; inline

:: 2map-columns ( a b quot -- c )
    [
        a columns :> a4 :> a3 :> a2 :> a1
        b columns :> b4 :> b3 :> b2 :> b1

        a1 b1 quot call
        a2 b2 quot call
        a3 b3 quot call
        a4 b4 quot call
    ] make-matrix4 ; inline

: map-columns ( a quot -- c )
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
        a columns :> a4 :> a3 :> a2 :> a1
        b columns :> b4 :> b3 :> b2 :> b1

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
    m columns :> m4 :> m3 :> m2 :> m1
    
    v first  m1 n*v
    v second m2 n*v v+
    v third  m3 n*v v+
    v fourth m4 n*v v+ ;

TYPED:: v.m4 ( v: float-4 m: matrix4 -- c: float-4 )
    m columns [ v v. ] 4 napply float-4-boa ;

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

TYPED:: rotation-matrix4 ( axis: float-4 theta: float -- matrix: matrix4 )
    !   x*x + c*(1.0 - x*x)   x*y*(1.0 - c) + s*z   x*z*(1.0 - c) - s*y   0
    !   x*y*(1.0 - c) - s*z   y*y + c*(1.0 - y*y)   y*z*(1.0 - c) + s*x   0
    !   x*z*(1.0 - c) + s*y   y*z*(1.0 - c) - s*x   z*z + c*(1.0 - z*z)   0
    !   0                     0                     0                     1
    matrix4 (struct) :> triangle-m
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

    diagonal scale-matrix4 :> diagonal-m

    triangle-hi { 3 2 1 3 } vshuffle
    triangle-hi { 3 3 0 3 } vshuffle triangle-lo { 2 3 3 3 } vshuffle v+
    triangle-lo { 1 0 3 3 } vshuffle
    float-4 new

    triangle-m set-columns drop

    diagonal-m triangle-m m4+ ;

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

