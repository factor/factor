! (c)Joe Groff bsd license
USING: accessors classes.struct kernel locals math math.functions
math.matrices.simd math.vectors math.vectors.simd sequences
sequences.private specialized-arrays typed ;
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
:: 2map-rows ( a b quot -- c )
    matrix4 (struct) :> c

    a rows>> first  :> a1
    a rows>> second :> a2
    a rows>> third  :> a3
    a rows>> fourth :> a4
    b rows>> first  :> b1
    b rows>> second :> b2
    b rows>> third  :> b3
    b rows>> fourth :> b4

    a1 b1 quot call :> c1
    a2 b2 quot call :> c2
    a3 b3 quot call :> c3
    a4 b4 quot call :> c4

    c1 c rows>> set-first
    c2 c rows>> set-second
    c3 c rows>> set-third
    c4 c rows>> set-fourth

    c ; inline

:: map-rows ( a quot -- c )
    matrix4 (struct) :> c

    a rows>> first  :> a1
    a rows>> second :> a2
    a rows>> third  :> a3
    a rows>> fourth :> a4

    a1 quot call :> c1
    a2 quot call :> c2
    a3 quot call :> c3
    a4 quot call :> c4

    c1 c rows>> set-first
    c2 c rows>> set-second
    c3 c rows>> set-third
    c4 c rows>> set-fourth

    c ; inline
    
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

    a rows>> first  :> a1
    a rows>> second :> a2
    a rows>> third  :> a3
    a rows>> fourth :> a4
    b rows>> first  :> b1
    b rows>> second :> b2
    b rows>> third  :> b3
    b rows>> fourth :> b4

    a1 { 0 0 0 0 } vshuffle b1 v* :> c1a
    a2 { 0 0 0 0 } vshuffle b1 v* :> c2a
    a3 { 0 0 0 0 } vshuffle b1 v* :> c3a
    a4 { 0 0 0 0 } vshuffle b1 v* :> c4a

    a1 { 1 1 1 1 } vshuffle b2 v* c1a v+ :> c1b 
    a2 { 1 1 1 1 } vshuffle b2 v* c2a v+ :> c2b
    a3 { 1 1 1 1 } vshuffle b2 v* c3a v+ :> c3b
    a4 { 1 1 1 1 } vshuffle b2 v* c4a v+ :> c4b

    a1 { 2 2 2 2 } vshuffle b3 v* c1b v+ :> c1c 
    a2 { 2 2 2 2 } vshuffle b3 v* c2b v+ :> c2c
    a3 { 2 2 2 2 } vshuffle b3 v* c3b v+ :> c3c
    a4 { 2 2 2 2 } vshuffle b3 v* c4b v+ :> c4c

    a1 { 3 3 3 3 } vshuffle b4 v* c1c v+ :> c1 
    a2 { 3 3 3 3 } vshuffle b4 v* c2c v+ :> c2
    a3 { 3 3 3 3 } vshuffle b4 v* c3c v+ :> c3
    a4 { 3 3 3 3 } vshuffle b4 v* c4c v+ :> c4

    c1 c rows>> set-first
    c2 c rows>> set-second
    c3 c rows>> set-third
    c4 c rows>> set-fourth

    c ;

CONSTANT: identity-matrix4
    S{ matrix4 f
        float-4-array{
            float-4{ 1.0 0.0 0.0 0.0 }
            float-4{ 0.0 1.0 0.0 0.0 }
            float-4{ 0.0 0.0 1.0 0.0 }
            float-4{ 0.0 0.0 0.0 1.0 }
        }
    }

TYPED:: scale-matrix4 ( factors: float-4 -- matrix: matrix4 )
    matrix4 (struct) :> c

    factors { t t t f } vmask :> factors'
    factors' { 0 3 3 3 } vshuffle :> c1
    factors' { 3 1 3 3 } vshuffle :> c2
    factors' { 3 3 2 3 } vshuffle :> c3
    float-4{ 0.0 0.0 0.0 1.0 } :> c4

    c1 c rows>> set-first
    c2 c rows>> set-second
    c3 c rows>> set-third
    c4 c rows>> set-fourth

    c ;

: ortho-matrix4 ( factors -- matrix )
    float-4{ 1.0 1.0 1.0 1.0 } swap v/ scale-matrix4 ; inline

TYPED:: translation-matrix4 ( offset: float-4 -- matrix: matrix4 )
    matrix4 (struct) :> c

    float-4{ 0.0 0.0 0.0 1.0 } :> c4
    { t t t f } offset c4 v? :> offset'
    offset' { 3 3 3 0 } vshuffle { t f f t } vmask :> c1
    offset' { 3 3 3 1 } vshuffle { f t f t } vmask :> c2
    offset' { 3 3 3 2 } vshuffle { f f t t } vmask :> c3

    c1 c rows>> set-first
    c2 c rows>> set-second
    c3 c rows>> set-third
    c4 c rows>> set-fourth

    c ;

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
    triangle-hi { 3 0 1 3 } vshuffle :> tri1
    triangle-hi { 3 3 2 3 } vshuffle
    triangle-lo { 0 3 3 3 } vshuffle v+ :> tri2
    triangle-lo { 1 2 3 3 } vshuffle :> tri3
    tri1 triangle-m rows>> set-first
    tri2 triangle-m rows>> set-second
    tri3 triangle-m rows>> set-third
    float-4 new triangle-m rows>> set-fourth

    diagonal-m triangle-m m4+ ;

TYPED:: frustum-matrix4 ( xy: float-4 near: float far: float -- matrix: matrix4 )
    matrix4 (struct) :> c

    float-4{ 0.0 0.0 -1.0 0.0 } :> c4

    near near near far + 2 near far * * float-4-boa :> num
    { t t f f } xy near far - float-4-with v? :> denom
    num denom v/ :> fov

    fov { 0 0 0 0 } vshuffle { t f f f } vmask :> c1
    fov { 1 1 1 1 } vshuffle { f t f f } vmask :> c2
    fov { 2 2 2 3 } vshuffle { f f t t } vmask :> c3

    c1 c rows>> set-first
    c2 c rows>> set-second
    c3 c rows>> set-third
    c4 c rows>> set-fourth

    c ;

