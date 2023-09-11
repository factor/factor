USING: accessors arrays classes compiler.test compiler.tree.debugger
effects fry io kernel kernel.private math math.functions
math.private math.vectors math.vectors.simd ranges
math.vectors.simd.private prettyprint random sequences system
tools.test vocabs assocs compiler.cfg.debugger words
locals combinators cpu.architecture namespaces byte-arrays alien
specialized-arrays classes.struct eval classes.algebra sets
quotations math.constants compiler.units splitting math.matrices
math.vectors.simd.cords alien.data ;
FROM: math.vectors.simd.intrinsics => alien-vector set-alien-vector ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
IN: math.vectors.simd.tests

! Test type propagation
{ V{ float } } [ [ { float-4 } declare norm-sq ] final-classes ] unit-test

{ V{ float } } [ [ { float-4 } declare norm ] final-classes ] unit-test

{ V{ float-4 } } [ [ { float-4 } declare normalize ] final-classes ] unit-test

{ V{ float-4 } } [ [ { float-4 float-4 } declare v+ ] final-classes ] unit-test

{ V{ float } } [ [ { float-4 } declare second ] final-classes ] unit-test

{ V{ int-4 } } [ [ { int-4 int-4 } declare v+ ] final-classes ] unit-test

{ t } [ [ { int-4 } declare second ] final-classes first integer class<= ] unit-test

{ V{ longlong-2 } } [ [ { longlong-2 longlong-2 } declare v+ ] final-classes ] unit-test

{ V{ integer } } [ [ { longlong-2 } declare second ] final-classes ] unit-test

! Test puns; only on x86
cpu x86? [
    [ double-2{ 4 1024 } ] [
        float-4{ 0 1 0 2 }
        [ { float-4 } declare dup v+ underlying>> double-2 boa dup v+ ] compile-call
    ] unit-test
] when

! Fuzz testing
CONSTANT: simd-classes
    {
        char-16
        uchar-16
        short-8
        ushort-8
        int-4
        uint-4
        longlong-2
        ulonglong-2
        float-4
        double-2
    }

SYMBOLS: -> +vector+ +any-vector+ +scalar+ +boolean+ +nonnegative+ +literal+ ;

CONSTANT: vector-words
    H{
        { [v-] { +vector+ +vector+ -> +vector+ } }
        { distance { +vector+ +vector+ -> +nonnegative+ } }
        { n*v { +scalar+ +vector+ -> +vector+ } }
        { n+v { +scalar+ +vector+ -> +vector+ } }
        { n-v { +scalar+ +vector+ -> +vector+ } }
        { n/v { +scalar+ +vector+ -> +vector+ } }
        { norm { +vector+ -> +nonnegative+ } }
        { norm-sq { +vector+ -> +nonnegative+ } }
        { normalize { +vector+ -> +vector+ } }
        { v* { +vector+ +vector+ -> +vector+ } }
        { vs* { +vector+ +vector+ -> +vector+ } }
        { v*n { +vector+ +scalar+ -> +vector+ } }
        { v*high { +vector+ +vector+ -> +vector+ } }
        { v*hs+ { +vector+ +vector+ -> +vector+ } }
        { v+ { +vector+ +vector+ -> +vector+ } }
        { vs+ { +vector+ +vector+ -> +vector+ } }
        { v+- { +vector+ +vector+ -> +vector+ } }
        { v+n { +vector+ +scalar+ -> +vector+ } }
        { v- { +vector+ +vector+ -> +vector+ } }
        { vneg { +vector+ -> +vector+ } }
        { vs- { +vector+ +vector+ -> +vector+ } }
        { v-n { +vector+ +scalar+ -> +vector+ } }
        { vdot { +vector+ +vector+ -> +scalar+ } }
        { vsad { +vector+ +vector+ -> +scalar+ } }
        { v/ { +vector+ +vector+ -> +vector+ } }
        { v/n { +vector+ +scalar+ -> +vector+ } }
        { vceiling { +vector+ -> +vector+ } }
        { vfloor { +vector+ -> +vector+ } }
        { vmax { +vector+ +vector+ -> +vector+ } }
        { vmin { +vector+ +vector+ -> +vector+ } }
        { vavg { +vector+ +vector+ -> +vector+ } }
        { vneg { +vector+ -> +vector+ } }
        { vtruncate { +vector+ -> +vector+ } }
        { sum { +vector+ -> +scalar+ } }
        { vcount { +vector+ -> +scalar+ } }
        { vabs { +vector+ -> +vector+ } }
        { vsqrt { +vector+ -> +vector+ } }
        { vbitand { +vector+ +vector+ -> +vector+ } }
        { vbitandn { +vector+ +vector+ -> +vector+ } }
        { vbitor { +vector+ +vector+ -> +vector+ } }
        { vbitxor { +vector+ +vector+ -> +vector+ } }
        { vbitnot { +vector+ -> +vector+ } }
        { vand { +vector+ +vector+ -> +vector+ } }
        { vandn { +vector+ +vector+ -> +vector+ } }
        { vor { +vector+ +vector+ -> +vector+ } }
        { vxor { +vector+ +vector+ -> +vector+ } }
        { vnot { +vector+ -> +vector+ } }
        { vlshift { +vector+ +scalar+ -> +vector+ } }
        { vrshift { +vector+ +scalar+ -> +vector+ } }
        { (vmerge-head) { +vector+ +vector+ -> +vector+ } }
        { (vmerge-tail) { +vector+ +vector+ -> +vector+ } }
        { v<= { +vector+ +vector+ -> +vector+ } }
        { v< { +vector+ +vector+ -> +vector+ } }
        { v= { +vector+ +vector+ -> +vector+ } }
        { v> { +vector+ +vector+ -> +vector+ } }
        { v>= { +vector+ +vector+ -> +vector+ } }
        { vunordered? { +vector+ +vector+ -> +vector+ } }
    }

: vector-word-inputs ( schema -- seq ) { -> } split first ;

: with-ctors ( -- seq )
    simd-classes [ [ name>> "-with" append ] [ vocabulary>> ] bi lookup-word ] map ;

: boa-ctors ( -- seq )
    simd-classes [ [ name>> "-boa" append ] [ vocabulary>> ] bi lookup-word ] map ;

TUPLE: simd-test-failure
    input
    input-quot
    unoptimized-result
    optimized-result
    nonintrinsic-result ;

:: check-optimizer (
    seq
    test-quot: ( input -- input-quot: ( -- ..v ) code-quot: ( ..v -- result ) )
    eq-quot: ( resulta resultb -- ? )
    --
    failures
)
    ! Use test-quot to generate a bunch of test cases from the
    ! given inputs. Run each test case optimized and
    ! unoptimized. Compare results with eq-quot.
    !
    ! seq: sequence of inputs
    ! test-quot: ( input -- input-quot: ( -- ..v ) code-quot: ( ..v -- result ) )
    ! eq-quot: ( result1 result2 -- ? )
    seq [| input |
        input test-quot call :> ( input-quot code-quot )
        input-quot [ class-of ] { } map-as :> input-classes
        input-classes code-quot '[ _ declare @ ] :> code-quot'

        "print-mr" get [ code-quot' regs. ] when
        "print-checks" get [ input-quot . code-quot' . ] when

        input-quot code-quot' [ [ call ] dip call ]
        call( i c -- result ) :> unoptimized-result
        input-quot code-quot' [ [ call ] dip compile-call ]
        call( i c -- result ) :> optimized-result
        input-quot code-quot' [
            t "always-inline-simd-intrinsics" [
                "print-inline-mr" get [ code-quot' regs. ] when
                [ call ] dip compile-call
            ] with-variable
        ] call( i c -- result ) :> nonintrinsic-result

        unoptimized-result optimized-result eq-quot call
        optimized-result nonintrinsic-result eq-quot call
        and
        [ f ] [
            input input-quot unoptimized-result optimized-result nonintrinsic-result
            simd-test-failure boa
        ] if
    ] map sift
    dup empty? [ dup ... ] unless ! Print full errors
    ; inline

"== Checking -new constructors" print

{ { } } [
    simd-classes [ [ [ ] ] dip '[ _ new ] ] [ = ] check-optimizer
] unit-test

{ { } } [
    simd-classes [ '[ _ new ] compile-call [ zero? ] all? ] reject
] unit-test

"== Checking -with constructors" print

{ { } } [
    with-ctors [
        [ 1000 random '[ _ ] ] dip '[ _ execute ]
    ] [ = ] check-optimizer
] unit-test

{ 0xffffffff } [ 0xffffffff uint-4-with first ] unit-test

{ 0xffffffff } [ 0xffffffff [ uint-4-with ] compile-call first ] unit-test

{ 0xffffffff } [ [ 0xffffffff uint-4-with ] compile-call first ] unit-test

"== Checking -boa constructors" print

{ { } } [
    boa-ctors [
        [ stack-effect in>> length [ 1000 random ] [ ] replicate-as ] keep
        '[ _ execute ]
    ] [ = ] check-optimizer
] unit-test

{ 0xffffffff } [ 0xffffffff 2 3 4 [ uint-4-boa ] compile-call first ] unit-test

"== Checking vector operations" print

: random-int-vector ( class -- vec )
    new [ drop 1000 random ] map ;

: random-float-vector ( class -- vec )
    new [
        drop
        1000 random
        10 swap <array> 0/0. suffix random
    ] map ;

: random-vector ( class elt-class -- vec )
    float =
    [ random-float-vector ]
    [ random-int-vector ] if ;

:: check-vector-op ( word inputs class elt-class -- inputs quot )
    inputs [
        {
            { +vector+ [ class elt-class random-vector ] }
            { +scalar+ [ 1000 random elt-class float = [ >float ] when ] }
        } case
    ] [ ] map-as
    word '[ _ execute ] ;

: remove-float-words ( alist -- alist' )
    { distance vsqrt n/v v/n v/ normalize }
    '[ _ member? ] reject-keys ;

: remove-integer-words ( alist -- alist' )
    { vlshift vrshift v*high v*hs+ }
    '[ _ member? ] reject-keys ;

: boolean-ops ( -- words )
    { vand vandn vor vxor vnot vcount } ;

: remove-boolean-words ( alist -- alist' )
    boolean-ops '[ _ member? ] reject-keys ;

: ops-to-check ( elt-class -- alist )
    [ vector-words >alist ] dip
    float = [ remove-integer-words ] [ remove-float-words ] if
    remove-boolean-words ;

: check-vector-ops ( class elt-class compare-quot -- failures )
    [
        [ nip ops-to-check ] 2keep
        '[ first2 vector-word-inputs _ _ check-vector-op ]
    ] dip check-optimizer ; inline

: (approx=) ( x y -- ? )
    {
        { [ 2dup [ fp-nan? ] both? ] [ 2drop t ] }
        { [ 2dup [ fp-nan? ] either? ] [ 2drop f ] }
        { [ 2dup [ fp-infinity? ] either? ] [ fp-bitwise= ] }
        { [ 2dup [ float? ] both? ] [ -1.e8 ~ ] }
        [ = ]
    } cond ;

: approx= ( x y -- ? )
    2dup [ sequence? ] both?
    [ [ (approx=) ] 2all? ] [ (approx=) ] if ;

: exact= ( x y -- ? )
    {
        { [ 2dup [ float? ] both? ] [ fp-bitwise= ] }
        { [ 2dup [ sequence? ] both? ] [ [ fp-bitwise= ] 2all? ] }
        [ = ]
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

: check-boolean-ops ( class elt-class compare-quot -- seq )
    [
        [ boolean-ops [ dup vector-words at ] { } map>assoc ] 2dip
        '[ first2 vector-word-inputs _ _ check-boolean-op ]
    ] dip check-optimizer ; inline

simd-classes&reps [
    [ [ { } ] ] dip first3 '[ _ _ _ check-boolean-ops ] unit-test
] each

"== Checking vector blend" print

{ char-16{ 0 1 22 33 4 5 6 77 8 99 110 121 12 143 14 15 } }
[
    char-16{ t  t  f  f  t  t  t  f  t  f   f   f   t   f   t   t }
    char-16{ 0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15 }
    char-16{ 0 11 22 33 44 55 66 77 88 99 110 121 132 143 154 165 } v?
] unit-test

{ char-16{ 0 1 22 33 4 5 6 77 8 99 110 121 12 143 14 15 } }
[
    char-16{ t  t  f  f  t  t  t  f  t  f   f   f   t   f   t   t }
    char-16{ 0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15 }
    char-16{ 0 11 22 33 44 55 66 77 88 99 110 121 132 143 154 165 }
    [ { char-16 char-16 char-16 } declare v? ] compile-call
] unit-test

{ int-4{ 1 22 33 4 } }
[ int-4{ t f f t } int-4{ 1 2 3 4 } int-4{ 11 22 33 44 } v? ] unit-test

{ int-4{ 1 22 33 4 } }
[
    int-4{ t f f t } int-4{ 1 2 3 4 } int-4{ 11 22 33 44 }
    [ { int-4 int-4 int-4 } declare v? ] compile-call
] unit-test

{ float-4{ 1.0 22.0 33.0 4.0 } }
[ float-4{ t f f t } float-4{ 1.0 2.0 3.0 4.0 } float-4{ 11.0 22.0 33.0 44.0 } v? ] unit-test

{ float-4{ 1.0 22.0 33.0 4.0 } }
[
    float-4{ t f f t } float-4{ 1.0 2.0 3.0 4.0 } float-4{ 11.0 22.0 33.0 44.0 }
    [ { float-4 float-4 float-4 } declare v? ] compile-call
] unit-test

"== Checking shifts and permutations" print

{ char-16{ 0 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 } }
[ char-16{ 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 } 1 hlshift ] unit-test

{ char-16{ 0 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 } }
[ char-16{ 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 } [ { char-16 } declare 1 hlshift ] compile-call ] unit-test

{ char-16{ 0 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 } }
[ char-16{ 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 } [ { char-16 } declare 1 >bignum hlshift ] compile-call ] unit-test

{ char-16{ 0 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 } }
[ char-16{ 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 } 1 [ { char-16 fixnum } declare hlshift ] compile-call ] unit-test

{ char-16{ 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 0 } }
[ char-16{ 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 } 1 hrshift ] unit-test

{ char-16{ 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 0 } }
[ char-16{ 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 } [ { char-16 } declare 1 hrshift ] compile-call ] unit-test

{ char-16{ 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 0 } }
[ char-16{ 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 } [ { char-16 } declare 1 >bignum hrshift ] compile-call ] unit-test

{ char-16{ 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 0 } }
[ char-16{ 1 2 4 8 1 2 4 8 1 2 4 8 1 2 4 8 } 1 [ { char-16 fixnum } declare hrshift ] compile-call ] unit-test

{ int-4{ 4 8 12 16 } }
[ int-4{ 1 2 3 4 } 2 vlshift ] unit-test

{ int-4{ 4 8 12 16 } }
[ int-4{ 1 2 3 4 } 2 [ { int-4 fixnum } declare vlshift ] compile-call ] unit-test

{ int-4{ 4 8 12 16 } }
[ int-4{ 1 2 3 4 } 2 >bignum [ { int-4 bignum } declare vlshift ] compile-call ] unit-test

! Invalid inputs should not cause the compiler to throw errors
{ } [
    [ [ { int-4 } declare t hrshift ] ( a -- b ) define-temp drop ] with-compilation-unit
] unit-test

{ } [
    [ [ { int-4 } declare { 3 2 1 } vshuffle ] ( a -- b ) define-temp drop ] with-compilation-unit
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

: 2shuffles-for ( n -- shuffles )
    {
        { 2 [
            {
                { 0 1 }
                { 0 3 }
                { 2 3 }
                { 2 0 }
            }
        ] }
        { 4 [
            {
                { 0 1 2 3 }
                { 4 1 2 3 }
                { 0 5 2 3 }
                { 0 1 6 3 }
                { 0 1 2 7 }
                { 4 5 2 3 }
                { 0 1 6 7 }
                { 4 5 6 7 }
                { 0 5 2 7 }
            }
        ] }
        { 8 [
            4 2shuffles-for
            4 2shuffles-for
            [ [ 8 + ] map ] map
            [ append ] 2map
        ] }
        [ dup 2 * '[ _ random ] replicate 1array ]
    } case ;

simd-classes [
    [ [ { } ] ] dip
    [ new length shuffles-for ] keep
    '[
        _ [ [ _ new [ length <iota> ] keep like 1quotation ] dip '[ _ vshuffle ] ]
        [ = ] check-optimizer
    ] unit-test
] each

simd-classes [
    [ [ { } ] ] dip
    [ new length 2shuffles-for ] keep
    '[
        _ [ [
            _ new
            [ [ length <iota> ] keep like ]
            [ [ length dup dup + [a..b) ] keep like ] bi [ ] 2sequence
        ] dip '[ _ vshuffle2-elements ] ]
        [ = ] check-optimizer
    ] unit-test
] each

"== Checking variable shuffles" print

: random-shift-vector ( class -- vec )
    new [ drop 16 random ] map ;

:: test-shift-vector ( class -- ? )
    [
        class random-int-vector :> src
        char-16 random-shift-vector :> perm
        { class char-16 } :> decl

        src perm vshuffle
        src perm [ decl declare vshuffle ] compile-call
        =
    ] call( -- ? ) ;

{ char-16 uchar-16 short-8 ushort-8 int-4 uint-4 longlong-2 ulonglong-2 }
[ 10 swap '[ [ t ] [ _ test-shift-vector ] unit-test ] times ] each

"== Checking vector tests" print

:: test-vector-tests-bool ( vector declaration -- none? any? all? )
    [
        vector
        [ [ declaration declare vnone? ] compile-call ]
        [ [ declaration declare vany?  ] compile-call ]
        [ [ declaration declare vall?  ] compile-call ] tri
    ] call( -- none? any? all? ) ;

: yes ( -- x ) t ;
: no ( -- x ) f ;

:: test-vector-tests-branch ( vector declaration -- none? any? all? )
    [
        vector
        [ [ declaration declare vnone? [ yes ] [ no ] if ] compile-call ]
        [ [ declaration declare vany?  [ yes ] [ no ] if ] compile-call ]
        [ [ declaration declare vall?  [ yes ] [ no ] if ] compile-call ] tri
    ] call( -- none? any? all? ) ;

TUPLE: inconsistent-vector-test bool branch ;

: ?inconsistent ( bool branch -- ?/inconsistent )
    2dup = [ drop ] [ inconsistent-vector-test boa ] if ;

:: test-vector-tests ( vector decl -- none? any? all? )
    [
        vector decl test-vector-tests-bool :> ( bool-none bool-any bool-all )
        vector decl test-vector-tests-branch :> ( branch-none branch-any branch-all )

        bool-none branch-none ?inconsistent
        bool-any  branch-any  ?inconsistent
        bool-all  branch-all  ?inconsistent
    ] call( -- none? any? all? ) ;

{ f t t }
[ float-4{ t t t t } { float-4 } test-vector-tests ] unit-test
{ f t f }
[ float-4{ f t t t } { float-4 } test-vector-tests ] unit-test
{ t f f }
[ float-4{ f f f f } { float-4 } test-vector-tests ] unit-test

{ f t t }
[ double-2{ t t } { double-2 } test-vector-tests ] unit-test
{ f t f }
[ double-2{ f t } { double-2 } test-vector-tests ] unit-test
{ t f f }
[ double-2{ f f } { double-2 } test-vector-tests ] unit-test

{ f t t }
[ int-4{ t t t t } { int-4 } test-vector-tests ] unit-test
{ f t f }
[ int-4{ f t t t } { int-4 } test-vector-tests ] unit-test
{ t f f }
[ int-4{ f f f f } { int-4 } test-vector-tests ] unit-test

"== Checking element access" print

! Test element access -- it should box bignums for int-4 on x86
: test-accesses ( seq -- failures )
    [ length <iota> dup [ >bignum ] map append ] keep
    '[ [ _ 1quotation ] dip '[ _ swap nth ] ] [ = ] check-optimizer ; inline

{ { } } [ float-4{ 1.0 2.0 3.0 4.0 } test-accesses ] unit-test
{ { } } [ int-4{ 0x7fffffff 3 4 -8 } test-accesses ] unit-test
{ { } } [ uint-4{ 0xffffffff 2 3 4 } test-accesses ] unit-test

{ 0x7fffffff } [ int-4{ 0x7fffffff 3 4 -8 } first ] unit-test
{ -8 } [ int-4{ 0x7fffffff 3 4 -8 } last ] unit-test
{ 0xffffffff } [ uint-4{ 0xffffffff 2 3 4 } first ] unit-test

{ { } } [ double-2{ 1.0 2.0 } test-accesses ] unit-test
{ { } } [ longlong-2{ 1 2 } test-accesses ] unit-test
{ { } } [ ulonglong-2{ 1 2 } test-accesses ] unit-test

"== Checking broadcast" print
: test-broadcast ( seq -- failures )
    [ length <iota> >array ] keep
    '[ [ _ 1quotation ] dip '[ _ vbroadcast ] ] [ = ] check-optimizer ;

{ { } } [ float-4{ 1.0 2.0 3.0 4.0 } test-broadcast ] unit-test
{ { } } [ int-4{ 0x7fffffff 3 4 -8 } test-broadcast ] unit-test
{ { } } [ uint-4{ 0xffffffff 2 3 4 } test-broadcast ] unit-test

{ { } } [ double-2{ 1.0 2.0 } test-broadcast ] unit-test
{ { } } [ longlong-2{ 1 2 } test-broadcast ] unit-test
{ { } } [ ulonglong-2{ 1 2 } test-broadcast ] unit-test

! Make sure we use the fallback in the correct situations
{ int-4{ 3 3 3 3 } } [ int-4{ 12 34 3 17 } 2 [ { int-4 fixnum } declare vbroadcast ] compile-call ] unit-test

"== Checking alien operations" print

{ float-4{ 1 2 3 4 } } [
    [
        float-4{ 1 2 3 4 }
        underlying>> 0 float-4-rep alien-vector
    ] compile-call float-4 boa
] unit-test

{ B{ 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 } } [
    16 [ 1 ] B{ } replicate-as 16 <byte-array>
    [
        0 [
            { byte-array c-ptr fixnum } declare
            float-4-rep set-alien-vector
        ] compile-call
    ] keep
] unit-test

{ float-array{ 1 2 3 4 } } [
    [
        float-array{ 1 2 3 4 } underlying>>
        float-array{ 4 3 2 1 } clone
        [ underlying>> 0 float-4-rep set-alien-vector ] keep
    ] compile-call
] unit-test

STRUCT: simd-struct
{ x float-4 }
{ y longlong-2 }
{ z double-2 }
{ w int-4 } ;

{ t } [ [ simd-struct <struct> ] compile-call >c-ptr [ 0 = ] all? ] unit-test

{
    float-4{ 1 2 3 4 }
    longlong-2{ 2 1 }
    double-2{ 4 3 }
    int-4{ 1 2 3 4 }
} [
    simd-struct <struct>
    float-4{ 1 2 3 4 } >>x
    longlong-2{ 2 1 } >>y
    double-2{ 4 3 } >>z
    int-4{ 1 2 3 4 } >>w
    { [ x>> ] [ y>> ] [ z>> ] [ w>> ] } cleave
] unit-test

{
    float-4{ 1 2 3 4 }
    longlong-2{ 2 1 }
    double-2{ 4 3 }
    int-4{ 1 2 3 4 }
} [
    [
        simd-struct <struct>
        float-4{ 1 2 3 4 } >>x
        longlong-2{ 2 1 } >>y
        double-2{ 4 3 } >>z
        int-4{ 1 2 3 4 } >>w
        { [ x>> ] [ y>> ] [ z>> ] [ w>> ] } cleave
    ] compile-call
] unit-test

"== Misc tests" print

{ } [ char-16 new 1array stack. ] unit-test

! Test some sequence protocol stuff
{ t } [ 4 double-4{ 1 2 3 4 } new-sequence double-4? ] unit-test
{ double-4{ 2 3 4 5 } } [ double-4{ 1 2 3 4 } [ 1 + ] map ] unit-test

! Test cross product
{ float-4{ 0.0 0.0 1.0 0.0 } } [ float-4{ 1.0 0.0 0.0 0.0 } float-4{ 0.0 1.0 0.0 0.0 } cross ] unit-test
{ float-4{ 0.0 0.0 1.0 0.0 } } [ float-4{ 1.0 0.0 0.0 0.0 } float-4{ 0.0 1.0 0.0 0.0 } [ { float-4 float-4 } declare cross ] compile-call ] unit-test
{ float-4{ 0.0 -1.0 0.0 0.0 } } [ float-4{ 1.0 0.0 0.0 0.0 } float-4{ 0.0 0.0 1.0 0.0 } cross ] unit-test
{ float-4{ 0.0 -1.0 0.0 0.0 } } [ float-4{ 1.0 0.0 0.0 0.0 } float-4{ 0.0 0.0 1.0 0.0 } [ { float-4 float-4 } declare cross ] compile-call ] unit-test

{ double-4{ 0.0 0.0 1.0 0.0 } } [ double-4{ 1.0 0.0 0.0 0.0 } double-4{ 0.0 1.0 0.0 0.0 } cross ] unit-test
{ double-4{ 0.0 0.0 1.0 0.0 } } [ double-4{ 1.0 0.0 0.0 0.0 } double-4{ 0.0 1.0 0.0 0.0 } [ { double-4 double-4 } declare cross ] compile-call ] unit-test
{ double-4{ 0.0 -1.0 0.0 0.0 } } [ double-4{ 1.0 0.0 0.0 0.0 } double-4{ 0.0 0.0 1.0 0.0 } cross ] unit-test
{ double-4{ 0.0 -1.0 0.0 0.0 } } [ double-4{ 1.0 0.0 0.0 0.0 } double-4{ 0.0 0.0 1.0 0.0 } [ { double-4 double-4 } declare cross ] compile-call ] unit-test

! CSSA bug
{ 4000000 } [
    int-4{ 1000 1000 1000 1000 }
    [ { int-4 } declare dup [ * ] [ + ] 2map-reduce ] compile-call
] unit-test

! Coalescing was too aggressive
:: broken ( axis theta -- a b c )
   axis { float-4 } declare drop
   theta { float } declare drop

   theta cos float-4-with :> cc
   theta sin float-4-with :> ss

   axis cc v+ :> diagonal

   diagonal cc ss ; inline

{ t } [
    float-4{ 1.0 0.0 1.0 0.0 } pi [ broken 3array ]
    [ compile-call ] [ call ] 3bi =
] unit-test

! Spilling SIMD values -- this basically just tests that the
! stack was aligned properly by the runtime

: simd-spill-test-1 ( a b c -- v )
    { float-4 float-4 float } declare
    [ v+ ] dip sin v*n ;

{ float-4{ 0 0 0 0 } }
[ float-4{ 1 2 3 4 } float-4{ 4 5 6 7 } 0.0 simd-spill-test-1 ] unit-test

: simd-spill-test-2 ( a b d c -- v )
    { float float-4 float-4 float } declare
    [ [ 3.0 + ] 2dip v+ ] dip sin v*n n*v ;

{ float-4{ 0 0 0 0 } }
[ 5.0 float-4{ 1 2 3 4 } float-4{ 4 5 6 7 } 0.0 simd-spill-test-2 ] unit-test

: callback-1 ( -- c )
    c:int { c:int c:int c:int c:int c:int } cdecl [ + + + + ] alien-callback ;

: indirect-1 ( x x x x x c -- y )
    c:int { c:int c:int c:int c:int c:int } cdecl alien-indirect ; inline

: simd-spill-test-3 ( a b d c -- v )
    { float float-4 float-4 float } declare
    [ [ 3.0 + ] 2dip v+ ] dip sin v*n n*v
    10 5 100 50 500 callback-1 indirect-1 665 assert= ;

{ float-4{ 0 0 0 0 } }
[ 5.0 float-4{ 1 2 3 4 } float-4{ 4 5 6 7 } 0.0 simd-spill-test-3 ] unit-test

! Stack allocation of SIMD values -- make sure that everything is
! aligned right

: simd-stack-test ( -- b c )
    { c:int float-4 } [
        [ 123 swap 0 c:int c:set-alien-value ]
        [ float-4{ 1 2 3 4 } swap 0 float-4 c:set-alien-value ] bi*
    ] with-out-parameters ;

{ 123 float-4{ 1 2 3 4 } } [ simd-stack-test ] unit-test

! Stack allocation + spilling

: (simd-stack-spill-test) ( -- n ) 17 ;

: simd-stack-spill-test ( x -- b c )
    { c:int } [
        123 swap 0 c:int c:set-alien-value
        >float (simd-stack-spill-test) float-4-with swap cos v*n
    ] with-out-parameters ;

{ } [
    1.047197551196598 simd-stack-spill-test
    [ float-4{ 8.5 8.5 8.5 8.5 } approx= t assert= ]
    [ 123 assert= ]
    bi*
] unit-test

! #1308
: test-1308 ( a b -- c )
    { double-4 double-4 } declare
    v+ dup first 10 > [ first ] [ third ] if 1array ;

! Before the fix, this evaluated to an uninitialized value.
{ 33.0 } [
    double-4{ 2 20 30 40 } double-4{ 2 4 3 2 } test-1308 first
] unit-test
