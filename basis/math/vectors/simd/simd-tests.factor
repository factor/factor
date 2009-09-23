USING: accessors arrays classes compiler compiler.tree.debugger
effects fry io kernel kernel.private math math.functions
math.private math.vectors math.vectors.simd
math.vectors.simd.private prettyprint random sequences system
tools.test vocabs assocs compiler.cfg.debugger words
locals math.vectors.specialization combinators cpu.architecture
math.vectors.simd.intrinsics namespaces byte-arrays alien
specialized-arrays classes.struct ;
FROM: alien.c-types => c-type-boxed-class ;
SPECIALIZED-ARRAY: float
SIMD: char-16
SIMD: uchar-16
SIMD: char-32
SIMD: uchar-32
SIMD: short-8
SIMD: ushort-8
SIMD: short-16
SIMD: ushort-16
SIMD: int-4
SIMD: uint-4
SIMD: int-8
SIMD: uint-8
SIMD: float-4
SIMD: float-8
SIMD: double-2
SIMD: double-4
IN: math.vectors.simd.tests

[ float-4{ 0 0 0 0 } ] [ float-4 new ] unit-test

[ float-4{ 0 0 0 0 } ] [ [ float-4 new ] compile-call ] unit-test

[ V{ float } ] [ [ { float-4 } declare norm-sq ] final-classes ] unit-test

[ V{ float } ] [ [ { float-4 } declare norm ] final-classes ] unit-test

! Test puns; only on x86
cpu x86? [
    [ double-2{ 4 1024 } ] [
        float-4{ 0 1 0 2 }
        [ { float-4 } declare dup v+ underlying>> double-2 boa dup v+ ] compile-call
    ] unit-test
    
    [ 33.0 ] [
        double-2{ 1 2 } double-2{ 10 20 }
        [ { double-2 double-2 } declare v+ underlying>> 3.0 float* ] compile-call
    ] unit-test
] when

! Fuzz testing
CONSTANT: simd-classes
    {
        char-16
        uchar-16
        char-32
        uchar-32
        short-8
        ushort-8
        short-16
        ushort-16
        int-4
        uint-4
        int-8
        uint-8
        float-4
        float-8
        double-2
        double-4
    }

: with-ctors ( -- seq )
    simd-classes [ [ name>> "-with" append ] [ vocabulary>> ] bi lookup ] map ;

: boa-ctors ( -- seq )
    simd-classes [ [ name>> "-boa" append ] [ vocabulary>> ] bi lookup ] map ;

: check-optimizer ( seq inputs quot eq-quot -- )
    '[
        @
        [ "print-mr" get [ nip test-mr mr. ] [ 2drop ] if ]
        [ [ call ] dip call ]
        [ [ call ] dip compile-call ] 2tri @ not
    ] filter ; inline

"== Checking -new constructors" print

[ { } ] [
    simd-classes [ [ [ ] ] dip '[ _ new ] ] [ = ] check-optimizer
] unit-test

[ { } ] [
    simd-classes [ '[ _ new ] compile-call [ zero? ] all? not ] filter
] unit-test

"== Checking -with constructors" print

[ { } ] [
    with-ctors [
        [ 1000 random '[ _ ] ] dip '[ { fixnum } declare _ execute ]
    ] [ = ] check-optimizer
] unit-test

"== Checking -boa constructors" print

[ { } ] [
    boa-ctors [
        dup stack-effect in>> length
        [ nip [ 1000 random ] [ ] replicate-as ]
        [ fixnum <array> swap '[ _ declare _ execute ] ]
        2bi
    ] [ = ] check-optimizer
] unit-test

"== Checking vector operations" print

: random-vector ( class -- vec )
    new [ drop 1000 random ] map ;

:: check-vector-op ( word inputs class elt-class -- inputs quot )
    inputs [
        [
            {
                { +vector+ [ class random-vector ] }
                { +scalar+ [ 1000 random elt-class float = [ >float ] when ] }
            } case
        ] [ ] map-as
    ] [
        [
            {
                { +vector+ [ class ] }
                { +scalar+ [ elt-class ] }
            } case
        ] map
    ] bi
    word '[ _ declare _ execute ] ;

: remove-float-words ( alist -- alist' )
    [ drop { vsqrt n/v v/n v/ normalize } member? not ] assoc-filter ;

: ops-to-check ( elt-class -- alist )
    [ vector-words >alist ] dip
    float = [ remove-float-words ] unless ;

: check-vector-ops ( class elt-class compare-quot -- )
    [
        [ nip ops-to-check ] 2keep
        '[ first2 inputs _ _ check-vector-op ]
    ] dip check-optimizer ; inline

: approx= ( x y -- ? )
    {
        { [ 2dup [ float? ] both? ] [ -1.e8 ~ ] }
        { [ 2dup [ sequence? ] both? ] [
            [
                {
                    { [ 2dup [ fp-nan? ] both? ] [ 2drop t ] }
                    { [ 2dup [ fp-nan? ] either? not ] [ -1.e8 ~ ] }
                } cond
            ] 2all?
        ] }
    } cond ;

: simd-classes&reps ( -- alist )
    simd-classes [
        {
            { [ dup name>> "float" head? ] [ float [ approx= ] ] }
            { [ dup name>> "double" tail? ] [ float [ = ] ] }
            [ fixnum [ = ] ]
        } cond 3array
    ] map ;

simd-classes&reps [
    [ [ { } ] ] dip first3 '[ _ _ _ check-vector-ops ] unit-test
] each

! Other regressions
[ 8000000 ] [
    int-8{ 1000 1000 1000 1000 1000 1000 1000 1000 }
    [ { int-8 } declare dup [ * ] [ + ] 2map-reduce ] compile-call
] unit-test

! Vector alien intrinsics
[ float-4{ 1 2 3 4 } ] [
    [
        float-4{ 1 2 3 4 }
        underlying>> 0 float-4-rep alien-vector
    ] compile-call float-4 boa
] unit-test

[ B{ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 } ] [
    16 [ 1 ] B{ } replicate-as 16 <byte-array>
    [
        0 [
            { byte-array c-ptr fixnum } declare
            float-4-rep set-alien-vector
        ] compile-call
    ] keep
] unit-test

[ float-array{ 1 2 3 4 } ] [
    [
        float-array{ 1 2 3 4 } underlying>>
        float-array{ 4 3 2 1 } clone
        [ underlying>> 0 float-4-rep set-alien-vector ] keep
    ] compile-call
] unit-test

STRUCT: simd-struct
{ x float-4 }
{ y double-2 }
{ z double-4 }
{ w float-8 } ;

[ t ] [ [ simd-struct <struct> ] compile-call >c-ptr [ 0 = ] all? ] unit-test

[
    float-4{ 1 2 3 4 }
    double-2{ 2 1 }
    double-4{ 4 3 2 1 }
    float-8{ 1 2 3 4 5 6 7 8 }
] [
    simd-struct <struct>
    float-4{ 1 2 3 4 } >>x
    double-2{ 2 1 } >>y
    double-4{ 4 3 2 1 } >>z
    float-8{ 1 2 3 4 5 6 7 8 } >>w
    { [ x>> ] [ y>> ] [ z>> ] [ w>> ] } cleave
] unit-test

[
    float-4{ 1 2 3 4 }
    double-2{ 2 1 }
    double-4{ 4 3 2 1 }
    float-8{ 1 2 3 4 5 6 7 8 }
] [
    [
        simd-struct <struct>
        float-4{ 1 2 3 4 } >>x
        double-2{ 2 1 } >>y
        double-4{ 4 3 2 1 } >>z
        float-8{ 1 2 3 4 5 6 7 8 } >>w
        { [ x>> ] [ y>> ] [ z>> ] [ w>> ] } cleave
    ] compile-call
] unit-test

[ ] [ char-16 new 1array stack. ] unit-test
