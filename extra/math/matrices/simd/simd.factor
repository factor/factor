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
    { rows float-4[4] } ;

INSTANCE: matrix4 immutable-sequence

M: matrix4 length drop 4 ; inline
M: matrix4 nth-unsafe rows>> nth-unsafe ; inline
M: matrix4 new-sequence 2drop matrix4 (struct) ; inline

<PRIVATE

: rows ( a -- a1 a2 a3 a4 )
    rows>> 4 firstn ; inline

:: set-rows ( c1 c2 c3 c4 c -- c )
    c rows>> :> rows
    c1 rows set-first
    c2 rows set-second
    c3 rows set-third
    c4 rows set-fourth
    c ; inline

: make-matrix4 ( quot: ( -- c1 c2 c3 c4 ) -- c )
    matrix4 (struct) swap dip set-rows ; inline

:: 2map-rows ( a b quot -- c )
    [
        a rows :> a4 :> a3 :> a2 :> a1
        b rows :> b4 :> b3 :> b2 :> b1

        a1 b1 quot call
        a2 b2 quot call
        a3 b3 quot call
        a4 b4 quot call
    ] make-matrix4 ; inline

: map-rows ( a quot -- c )
    '[ rows _ 4 napply ] make-matrix4 ; inline
    
PRIVATE>

TYPED: m4+ ( a: matrix4 b: matrix4 -- c: matrix4 ) [ v+ ] 2map-rows ;
TYPED: m4- ( a: matrix4 b: matrix4 -- c: matrix4 ) [ v- ] 2map-rows ;
TYPED: m4* ( a: matrix4 b: matrix4 -- c: matrix4 ) [ v* ] 2map-rows ;
TYPED: m4/ ( a: matrix4 b: matrix4 -- c: matrix4 ) [ v/ ] 2map-rows ;

TYPED: m4*n ( a: matrix4 b: float -- c: matrix4 ) [ v*n ] curry map-rows ;
TYPED: m4/n ( a: matrix4 b: float -- c: matrix4 ) [ v/n ] curry map-rows ;
TYPED: n*m4 ( a: float b: matrix4 -- c: matrix4 ) [ n*v ] with map-rows ;
TYPED: n/m4 ( a: float b: matrix4 -- c: matrix4 ) [ n/v ] with map-rows ;

TYPED:: m4. ( a: matrix4 b: matrix4 -- c: matrix4 )
    [
        a rows :> a4 :> a3 :> a2 :> a1
        b rows :> b4 :> b3 :> b2 :> b1

        a1 first  b1 n*v :> c1a
        a2 first  b1 n*v :> c2a
        a3 first  b1 n*v :> c3a
        a4 first  b1 n*v :> c4a

        a1 second b2 n*v c1a v+ :> c1b 
        a2 second b2 n*v c2a v+ :> c2b
        a3 second b2 n*v c3a v+ :> c3b
        a4 second b2 n*v c4a v+ :> c4b

        a1 third  b3 n*v c1b v+ :> c1c 
        a2 third  b3 n*v c2b v+ :> c2c
        a3 third  b3 n*v c3b v+ :> c3c
        a4 third  b3 n*v c4b v+ :> c4c

        a1 fourth b4 n*v c1c v+
        a2 fourth b4 n*v c2c v+
        a3 fourth b4 n*v c3c v+
        a4 fourth b4 n*v c4c v+
    ] make-matrix4 ;

TYPED:: v.m4 ( a: float-4 b: matrix4 -- c: float-4 )
    b rows :> b4 :> b3 :> b2 :> b1
    
    a first  b1 n*v
    a second b2 n*v v+
    a third  b3 n*v v+
    a fourth b4 n*v v+ ;

TYPED:: m4.v ( a: matrix4 b: float-4 -- c: float-4 )
    a rows [ b v. ] 4 napply float-4-boa ;

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
    [ vmerge-head ] [ swap vmerge-tail ] 2bi ; inline
: vmerge-diagonal ( x -- h t )
    0.0 float-4-with vmerge-diagonal* ; inline

TYPED: diagonal-matrix4 ( diagonal: float-4 -- matrix: matrix4 )
    [ vmerge-diagonal [ vmerge-diagonal ] bi@ ] make-matrix4 ;

: vmerge-transpose ( a b c d -- a' b' c' d' )
    [ vmerge ] bi-curry@ bi* ; inline

TYPED: transpose-matrix4 ( matrix: matrix4 -- matrix: matrix4 )
    [ rows vmerge-transpose vmerge-transpose ] make-matrix4 ;

: scale-matrix4 ( factors -- matrix )
    [ float-4{ t t t f } ] dip float-4{ 0.0 0.0 0.0 1.0 } v?
    diagonal-matrix4 ; inline

: ortho-matrix4 ( factors -- matrix )
    float-4{ 1.0 1.0 1.0 1.0 } swap v/ scale-matrix4 ; inline

TYPED:: translation-matrix4 ( offset: float-4 -- matrix: matrix4 )
    [
        float-4{ 1.0 1.0 1.0 1.0 } :> diagonal

        offset 0 float-4-with vmerge
        [ 0 float-4-with swap vmerge ] bi@ drop :> z :> y :> x

        diagonal y vmerge-diagonal*
        [ x vmerge-diagonal* ]
        [ z vmerge-diagonal* ] bi*
    ] make-matrix4 ;

TYPED:: rotation-matrix4 ( axis: float-4 theta: float -- matrix: matrix4 )
    !   x*x + c*(1.0 - x*x)   x*y*(1.0 - c) - s*z   x*z*(1.0 - c) + s*y   0
    !   x*y*(1.0 - c) + s*z   y*y + c*(1.0 - y*y)   y*z*(1.0 - c) - s*x   0
    !   x*z*(1.0 - c) - s*y   y*z*(1.0 - c) + s*x   z*z + c*(1.0 - z*z)   0
    !   0                     0                     0                     1
    matrix4 (struct) :> triangle-m
    theta cos :> c
    theta sin :> s

    float-4{  1.0 -1.0  1.0 0.0 } :> triangle-sign

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

    triangle-m set-rows drop

    diagonal-m triangle-m m4+ ;

TYPED:: frustum-matrix4 ( xy: float-4 near: float far: float -- matrix: matrix4 )
    [
        near near near far + 2 near far * * float-4-boa ! num
        float-4{ t t f f } xy near far - float-4-with v? ! denom
        v/ :> fov
        
        fov 0.0 float-4-with vmerge-head vmerge-diagonal
        fov float-4{ f f t t } vand
        float-4{ 0.0 0.0 -1.0 0.0 }
    ] make-matrix4 ;

