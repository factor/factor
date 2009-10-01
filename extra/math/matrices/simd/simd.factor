! (c)Joe Groff bsd license
USING: accessors classes.struct generalizations kernel locals
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

:: 2map-rows ( a b quot -- c )
    matrix4 (struct) :> c

    a rows :> a4 :> a3 :> a2 :> a1
    b rows :> b4 :> b3 :> b2 :> b1

    a1 b1 quot call
    a2 b2 quot call
    a3 b3 quot call
    a4 b4 quot call

    c set-rows ; inline

:: map-rows ( a quot -- c )
    matrix4 (struct) :> c

    a rows :> a4 :> a3 :> a2 :> a1

    a1 quot call
    a2 quot call
    a3 quot call
    a4 quot call

    c set-rows ; inline
    
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
    matrix4 (struct) :> c

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

    c set-rows ;

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

TYPED:: scale-matrix4 ( factors: float-4 -- matrix: matrix4 )
    matrix4 (struct) :> c

    factors { t t t f } vmask :> factors'

    factors' { 0 3 3 3 } vshuffle
    factors' { 3 1 3 3 } vshuffle
    factors' { 3 3 2 3 } vshuffle
    float-4{ 0.0 0.0 0.0 1.0 }

    c set-rows ;

: ortho-matrix4 ( factors -- matrix )
    float-4{ 1.0 1.0 1.0 1.0 } swap v/ scale-matrix4 ; inline

TYPED:: translation-matrix4 ( offset: float-4 -- matrix: matrix4 )
    matrix4 (struct) :> c

    float-4{ 0.0 0.0 0.0 1.0 } :> c4
    { t t t f } offset c4 v? :> offset'

    offset' { 3 3 3 0 } vshuffle { t f f t } vmask
    offset' { 3 3 3 1 } vshuffle { f t f t } vmask
    offset' { 3 3 3 2 } vshuffle { f f t t } vmask
    c4

    c set-rows ;

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

    axis { 0 0 1 3 } vshuffle axis { 1 2 2 3 } vshuffle v* 1-c v*
    { t t t f } vmask :> triangle-a
    ss { 2 1 0 3 } vshuffle triangle-sign v* :> triangle-b
    triangle-a triangle-b v+ :> triangle-lo
    triangle-a triangle-b v- :> triangle-hi

    diagonal scale-matrix4 :> diagonal-m

    triangle-hi { 3 0 1 3 } vshuffle
    triangle-hi { 3 3 2 3 } vshuffle triangle-lo { 0 3 3 3 } vshuffle v+
    triangle-lo { 1 2 3 3 } vshuffle
    float-4 new

    triangle-m set-rows drop

    diagonal-m triangle-m m4+ ;

TYPED:: frustum-matrix4 ( xy: float-4 near: float far: float -- matrix: matrix4 )
    matrix4 (struct) :> c

    near near near far + 2 near far * * float-4-boa :> num
    { t t f f } xy near far - float-4-with v? :> denom
    num denom v/ :> fov

    fov { 0 0 0 0 } vshuffle { t f f f } vmask
    fov { 1 1 1 1 } vshuffle { f t f f } vmask
    fov { 2 2 2 3 } vshuffle { f f t t } vmask
    float-4{ 0.0 0.0 -1.0 0.0 }

    c set-rows ;

