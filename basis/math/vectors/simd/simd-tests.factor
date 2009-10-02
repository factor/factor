USING: accessors arrays classes compiler compiler.tree.debugger
effects fry io kernel kernel.private math math.functions
math.private math.vectors math.vectors.simd
math.vectors.simd.private prettyprint random sequences system
tools.test vocabs assocs compiler.cfg.debugger words
locals math.vectors.specialization combinators cpu.architecture
math.vectors.simd.intrinsics namespaces byte-arrays alien
specialized-arrays classes.struct eval classes.algebra sets
quotations math.constants compiler.units ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
SIMD: c:char
SIMD: c:uchar
SIMD: c:short
SIMD: c:ushort
SIMD: c:int
SIMD: c:uint
SIMD: c:longlong
SIMD: c:ulonglong
SIMD: c:float
SIMD: c:double
IN: math.vectors.simd.tests

! Make sure the functor doesn't generate bogus vocabularies
2 [ [ "USE: math.vectors.simd SIMD: rubinius" eval( -- ) ] must-fail ] times

[ f ] [ "math.vectors.simd.instances.rubinius" vocab ] unit-test

! Test type propagation
[ V{ float } ] [ [ { float-4 } declare norm-sq ] final-classes ] unit-test

[ V{ float } ] [ [ { float-4 } declare norm ] final-classes ] unit-test

[ V{ float-4 } ] [ [ { float-4 } declare normalize ] final-classes ] unit-test

[ V{ float-4 } ] [ [ { float-4 float-4 } declare v+ ] final-classes ] unit-test

[ V{ float } ] [ [ { float-4 } declare second ] final-classes ] unit-test

[ V{ int-4 } ] [ [ { int-4 int-4 } declare v+ ] final-classes ] unit-test

[ t ] [ [ { int-4 } declare second ] final-classes first integer class<= ] unit-test

[ V{ longlong-2 } ] [ [ { longlong-2 longlong-2 } declare v+ ] final-classes ] unit-test

[ V{ integer } ] [ [ { longlong-2 } declare second ] final-classes ] unit-test

[ V{ int-8 } ] [ [ { int-8 int-8 } declare v+ ] final-classes ] unit-test

[ t ] [ [ { int-8 } declare second ] final-classes first integer class<= ] unit-test

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
        longlong-2
        ulonglong-2
        longlong-4
        ulonglong-4
        float-4
        float-8
        double-2
        double-4
    }

: with-ctors ( -- seq )
    simd-classes [ [ name>> "-with" append ] [ vocabulary>> ] bi lookup ] map ;

: boa-ctors ( -- seq )
    simd-classes [ [ name>> "-boa" append ] [ vocabulary>> ] bi lookup ] map ;

: check-optimizer ( seq quot eq-quot -- failures )
    '[
        @
        [ dup [ class ] { } map-as ] dip '[ _ declare @ ]
        {
            [ "print-mr" get [ nip test-mr mr. ] [ 2drop ] if ]
            [ "print-checks" get [ [ . ] bi@ ] [ 2drop ] if ]
            [ [ call ] dip call ]
            [ [ call ] dip compile-call ]
        } 2cleave
        @ not
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
        [ 1000 random '[ _ ] ] dip '[ _ execute ]
    ] [ = ] check-optimizer
] unit-test

[ HEX: ffffffff ] [ HEX: ffffffff uint-4-with first ] unit-test

[ HEX: ffffffff ] [ HEX: ffffffff [ uint-4-with ] compile-call first ] unit-test

"== Checking -boa constructors" print

[ { } ] [
    boa-ctors [
        [ stack-effect in>> length [ 1000 random ] [ ] replicate-as ] keep
        '[ _ execute ]
    ] [ = ] check-optimizer
] unit-test

[ HEX: ffffffff ] [ HEX: ffffffff 2 3 4 [ uint-4-boa ] compile-call first ] unit-test

"== Checking vector operations" print

: random-vector ( class -- vec )
    new [ drop 1000 random ] map ;

:: check-vector-op ( word inputs class elt-class -- inputs quot )
    inputs [
        {
            { +vector+ [ class random-vector ] }
            { +scalar+ [ 1000 random elt-class float = [ >float ] when ] }
        } case
    ] [ ] map-as
    word '[ _ execute ] ;

: remove-float-words ( alist -- alist' )
    { vsqrt n/v v/n v/ normalize } unique assoc-diff ;

: remove-integer-words ( alist -- alist' )
    { vlshift vrshift } unique assoc-diff ;

: boolean-ops ( -- words )
    { vand vandn vor vxor } ;

: remove-boolean-words ( alist -- alist' )
    boolean-ops unique assoc-diff ;

: remove-special-words ( alist -- alist' )
    ! These have their own tests later
    {
        hlshift hrshift vshuffle vbroadcast
        v= vany? vall? vnone?
    } unique assoc-diff ;

: ops-to-check ( elt-class -- alist )
    [ vector-words >alist ] dip
    float = [ remove-integer-words ] [ remove-float-words ] if
    remove-boolean-words
    remove-special-words ;

: check-vector-ops ( class elt-class compare-quot -- )
    [
        [ nip ops-to-check ] 2keep
        '[ first2 inputs _ _ check-vector-op ]
    ] dip check-optimizer ; inline

: approx= ( x y -- ? )
    {
        { [ 2dup [ float? ] both? ] [ -1.e8 ~ ] }
        { [ 2dup [ fp-infinity? ] either? ] [ fp-bitwise= ] }
        { [ 2dup [ sequence? ] both? ] [
            [
                {
                    { [ 2dup [ fp-nan? ] both? ] [ 2drop t ] }
                    { [ 2dup [ fp-infinity? ] either? ] [ fp-bitwise= ] }
                    { [ 2dup [ fp-nan? ] either? not ] [ -1.e8 ~ ] }
                } cond
            ] 2all?
        ] }
    } cond ;

: exact= ( x y -- ? )
    {
        { [ 2dup [ float? ] both? ] [ fp-bitwise= ] }
        { [ 2dup [ sequence? ] both? ] [ [ fp-bitwise= ] 2all? ] }
    } cond ;

: simd-classes&reps ( -- alist )
    simd-classes [
        {
            { [ dup name>> "float" head? ] [ float [ approx= ] ] }
            { [ dup name>> "double" head? ] [ float [ exact= ] ] }
            [ fixnum [ = ] ]
        } cond 3array
    ] map ;

simd-classes&reps [
    [ [ { } ] ] dip first3 '[ _ _ _ check-vector-ops ] unit-test
] each

"== Checking boolean operations" print

: random-boolean-vector ( class -- vec )
    new [ drop 2 random zero? ] map ;

:: check-boolean-op ( word inputs class elt-class -- inputs quot )
    inputs [
        {
            { +vector+ [ class random-boolean-vector ] }
            { +scalar+ [ 1000 random elt-class float = [ >float ] when ] }
        } case
    ] [ ] map-as
    word '[ _ execute ] ;

: check-boolean-ops ( class elt-class compare-quot -- )
    [
        [ boolean-ops [ dup word-schema ] { } map>assoc ] 2dip
        '[ first2 inputs _ _ check-boolean-op ]
    ] dip check-optimizer ; inline

simd-classes&reps [
    [ [ { } ] ] dip first3 '[ _ _ _ check-boolean-ops ] unit-test
] each

"== Checking shifts and permutations" print

[ int-4{ 256 512 1024 2048 } ]
[ int-4{ 1 2 4 8 } 1 hlshift ] unit-test

[ int-4{ 256 512 1024 2048 } ]
[ int-4{ 1 2 4 8 } [ { int-4 } declare 1 hlshift ] compile-call ] unit-test

[ int-4{ 256 512 1024 2048 } ]
[ int-4{ 1 2 4 8 } 1 [ { int-4 fixnum } declare hlshift ] compile-call ] unit-test

[ int-4{ 1 2 4 8 } ]
[ int-4{ 256 512 1024 2048 } 1 hrshift ] unit-test

[ int-4{ 1 2 4 8 } ]
[ int-4{ 256 512 1024 2048 } [ { int-4 } declare 1 hrshift ] compile-call ] unit-test

[ int-4{ 1 2 4 8 } ]
[ int-4{ 256 512 1024 2048 } 1 [ { int-4 fixnum } declare hrshift ] compile-call ] unit-test

! Invalid inputs should not cause the compiler to throw errors
[ ] [
    [ [ { int-4 } declare t hrshift ] (( a -- b )) define-temp drop ] with-compilation-unit
] unit-test

[ ] [
    [ [ { int-4 } declare { 3 2 1 } vshuffle ] (( a -- b )) define-temp drop ] with-compilation-unit
] unit-test

! Shuffles
: shuffles-for ( n -- shuffles )
    {
        { 2 [
            {
                { 0 1 }
                { 1 1 }
                { 1 0 }
                { 0 0 }
            }
        ] }
        { 4 [
            {
                { 1 2 3 0 }
                { 0 1 2 3 }
                { 1 1 2 2 }
                { 0 0 1 1 }
                { 2 2 3 3 }
                { 0 1 0 1 }
                { 2 3 2 3 }
                { 0 0 2 2 }
                { 1 1 3 3 }
                { 0 1 0 1 }
                { 2 2 3 3 }
            }
        ] }
        { 8 [
            4 shuffles-for
            4 shuffles-for
            [ [ 4 + ] map ] map
            [ append ] 2map
        ] }
        [ dup '[ _ random ] replicate 1array ]
    } case ;

simd-classes [
    [ [ { } ] ] dip
    [ new length shuffles-for ] keep
    '[
        _ [ [ _ new [ length iota ] keep like 1quotation ] dip '[ _ vshuffle ] ]
        [ = ] check-optimizer
    ] unit-test
] each

"== Checking element tests" print

[ short-8{ t f t f f f t f } ]
[ short-8{ 1 2 3 4 5 6 7 8 } short-8{ 1 0 3 -1 -2 -3 7 -4 } v= ] unit-test

[ short-8{ t f t f f f t f } ]
[ short-8{ 1 2 3 4 5 6 7 8 } short-8{ 1 0 3 -1 -2 -3 7 -4 } [ { short-8 short-8 } declare v= ] compile-call ] unit-test

[ int-8{ t f t f f f t f } ]
[ int-8{ 1 2 3 4 5 6 7 8 } int-8{ 1 0 3 -1 -2 -3 7 -4 } v= ] unit-test

[ int-8{ t f t f f f t f } ]
[ int-8{ 1 2 3 4 5 6 7 8 } int-8{ 1 0 3 -1 -2 -3 7 -4 } [ { int-8 int-8 } declare v= ] compile-call ] unit-test

[ int-4{ t f t f } ]
[ int-4{ 1 2 3 4 } int-4{ 1 0 3 -1 } [ { int-4 int-4 } declare v= ] compile-call ] unit-test

[ int-4{ t f t f } ]
[ int-4{ 1 2 3 4 } int-4{ 1 0 3 -1 } v= ] unit-test

[ int-4{ t f t f } ]
[ int-4{ 1 2 3 4 } int-4{ 1 0 3 -1 } [ { int-4 int-4 } declare v= ] compile-call ] unit-test

[ t ]
[
    float-4{ t f t f }
    float-4{ 1.0 0/0. 3.0 4.0 } float-4{ 1.0 0/0. 3.0 -1.0 } v=
    exact=
] unit-test

[ t ]
[
    float-4{ t f t f }
    float-4{ 1.0 0/0. 3.0 4.0 } float-4{ 1.0 0/0. 3.0 -1.0 } [ { float-4 float-4 } declare v= ] compile-call
    exact=
] unit-test

[ t ]
[
    float-8{ t f t f f t t t }
    float-8{ 1.0 0/0. 3.0 4.0 5.0 6.0 7.0 8.0 } float-8{ 1.0 0/0. 3.0 -1.0 -2.0 6.0 7.0 8.0 } v=
    exact=
] unit-test

[ t ]
[
    float-8{ t f t f f t t t }
    float-8{ 1.0 0/0. 3.0 4.0 5.0 6.0 7.0 8.0 } float-8{ 1.0 0/0. 3.0 -1.0 -2.0 6.0 7.0 8.0 } [ { float-8 float-8 } declare v= ] compile-call
    exact=
] unit-test

[ t ]
[
    double-2{ f t }
    double-2{ 0/0. 3.0 } double-2{ 0/0. 3.0 } v=
    exact=
] unit-test

[ t ]
[
    double-2{ f t }
    double-2{ 0/0. 3.0 } double-2{ 0/0. 3.0 } [ { double-2 double-2 } declare v= ] compile-call
    exact=
] unit-test

:: test-vector-tests-bool ( vector declaration -- none? any? all? )
    vector
    [ [ declaration declare vnone? ] compile-call ]
    [ [ declaration declare vany?  ] compile-call ]
    [ [ declaration declare vall?  ] compile-call ] tri ; inline

: yes ( -- x ) t ;
: no ( -- x ) f ;

:: test-vector-tests-branch ( vector declaration -- none? any? all? )
    vector
    [ [ declaration declare vnone? [ yes ] [ no ] if ] compile-call ]
    [ [ declaration declare vany?  [ yes ] [ no ] if ] compile-call ]
    [ [ declaration declare vall?  [ yes ] [ no ] if ] compile-call ] tri ; inline

SYMBOL: !!inconsistent!!

: ?inconsistent ( a b -- ab/inconsistent )
    2dup = [ drop ] [ 2drop !!inconsistent!! ] if ;

:: test-vector-tests ( vector decl -- none? any? all? )
    vector decl test-vector-tests-bool :> bool-all :> bool-any :> bool-none
    vector decl test-vector-tests-branch :> branch-all :> branch-any :> branch-none
    
    bool-none branch-none ?inconsistent
    bool-any  branch-any  ?inconsistent
    bool-all  branch-all  ?inconsistent ; inline

[ f t t ]
[ float-4{ t t t t } { float-4 } test-vector-tests ] unit-test
[ f t f ]
[ float-4{ f t t t } { float-4 } test-vector-tests ] unit-test
[ t f f ]
[ float-4{ f f f f } { float-4 } test-vector-tests ] unit-test

[ f t t ]
[ double-2{ t t } { double-2 } test-vector-tests ] unit-test
[ f t f ]
[ double-2{ f t } { double-2 } test-vector-tests ] unit-test
[ t f f ]
[ double-2{ f f } { double-2 } test-vector-tests ] unit-test

[ f t t ]
[ int-4{ t t t t } { int-4 } test-vector-tests ] unit-test
[ f t f ]
[ int-4{ f t t t } { int-4 } test-vector-tests ] unit-test
[ t f f ]
[ int-4{ f f f f } { int-4 } test-vector-tests ] unit-test

[ f t t ]
[ float-8{ t t t t t t t t } { float-8 } test-vector-tests ] unit-test
[ f t f ]
[ float-8{ f t t t t f t t } { float-8 } test-vector-tests ] unit-test
[ t f f ]
[ float-8{ f f f f f f f f } { float-8 } test-vector-tests ] unit-test

[ f t t ]
[ double-4{ t t t t } { double-4 } test-vector-tests ] unit-test
[ f t f ]
[ double-4{ f t t f } { double-4 } test-vector-tests ] unit-test
[ t f f ]
[ double-4{ f f f f } { double-4 } test-vector-tests ] unit-test

[ f t t ]
[ int-8{ t t t t t t t t } { int-8 } test-vector-tests ] unit-test
[ f t f ]
[ int-8{ f t t t t f f f } { int-8 } test-vector-tests ] unit-test
[ t f f ]
[ int-8{ f f f f f f f f } { int-8 } test-vector-tests ] unit-test

"== Checking element access" print

! Test element access -- it should box bignums for int-4 on x86
: test-accesses ( seq -- failures )
    [ length >array ] keep
    '[ [ _ 1quotation ] dip '[ _ swap nth ] ] [ = ] check-optimizer ; inline

[ { } ] [ float-4{ 1.0 2.0 3.0 4.0 } test-accesses ] unit-test
[ { } ] [ int-4{ HEX: 7fffffff 3 4 -8 } test-accesses ] unit-test
[ { } ] [ uint-4{ HEX: ffffffff 2 3 4 } test-accesses ] unit-test

[ HEX: 7fffffff ] [ int-4{ HEX: 7fffffff 3 4 -8 } first ] unit-test
[ -8 ] [ int-4{ HEX: 7fffffff 3 4 -8 } last ] unit-test
[ HEX: ffffffff ] [ uint-4{ HEX: ffffffff 2 3 4 } first ] unit-test

[ { } ] [ double-2{ 1.0 2.0 } test-accesses ] unit-test
[ { } ] [ longlong-2{ 1 2 } test-accesses ] unit-test
[ { } ] [ ulonglong-2{ 1 2 } test-accesses ] unit-test

[ { } ] [ float-8{ 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 } test-accesses ] unit-test
[ { } ] [ int-8{ 1 2 3 4 5 6 7 8 } test-accesses ] unit-test
[ { } ] [ uint-8{ 1 2 3 4 5 6 7 8 } test-accesses ] unit-test

[ { } ] [ double-4{ 1.0 2.0 3.0 4.0 } test-accesses ] unit-test
[ { } ] [ longlong-4{ 1 2 3 4 } test-accesses ] unit-test
[ { } ] [ ulonglong-4{ 1 2 3 4 } test-accesses ] unit-test

"== Checking broadcast" print
: test-broadcast ( seq -- failures )
    [ length >array ] keep
    '[ [ _ 1quotation ] dip '[ _ vbroadcast ] ] [ = ] check-optimizer ; inline

[ { } ] [ float-4{ 1.0 2.0 3.0 4.0 } test-broadcast ] unit-test
[ { } ] [ int-4{ HEX: 7fffffff 3 4 -8 } test-broadcast ] unit-test
[ { } ] [ uint-4{ HEX: ffffffff 2 3 4 } test-broadcast ] unit-test

[ { } ] [ double-2{ 1.0 2.0 } test-broadcast ] unit-test
[ { } ] [ longlong-2{ 1 2 } test-broadcast ] unit-test
[ { } ] [ ulonglong-2{ 1 2 } test-broadcast ] unit-test

[ { } ] [ float-8{ 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 } test-broadcast ] unit-test
[ { } ] [ int-8{ 1 2 3 4 5 6 7 8 } test-broadcast ] unit-test
[ { } ] [ uint-8{ 1 2 3 4 5 6 7 8 } test-broadcast ] unit-test

[ { } ] [ double-4{ 1.0 2.0 3.0 4.0 } test-broadcast ] unit-test
[ { } ] [ longlong-4{ 1 2 3 4 } test-broadcast ] unit-test
[ { } ] [ ulonglong-4{ 1 2 3 4 } test-broadcast ] unit-test

! Make sure we use the fallback in the correct situations
[ int-4{ 3 3 3 3 } ] [ int-4{ 12 34 3 17 } 2 [ { int-4 fixnum } declare vbroadcast ] compile-call ] unit-test

"== Checking alien operations" print

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

"== Misc tests" print

[ ] [ char-16 new 1array stack. ] unit-test

! CSSA bug
[ 8000000 ] [
    int-8{ 1000 1000 1000 1000 1000 1000 1000 1000 }
    [ { int-8 } declare dup [ * ] [ + ] 2map-reduce ] compile-call
] unit-test

! Coalescing was too aggressive
:: broken ( axis theta -- a b c )
   axis { float-4 } declare drop
   theta { float } declare drop

   theta cos float-4-with :> cc
   theta sin float-4-with :> ss
   
   axis cc v+ :> diagonal

   diagonal cc ss ; inline

[ t ] [
    float-4{ 1.0 0.0 1.0 0.0 } pi [ broken 3array ]
    [ compile-call ] [ call ] 3bi =
] unit-test
