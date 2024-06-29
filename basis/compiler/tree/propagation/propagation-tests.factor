USING: accessors alien alien.accessors alien.c-types alien.data arrays
assocs byte-arrays classes classes.algebra classes.struct
classes.tuple.private combinators.short-circuit compiler.test
compiler.tree compiler.tree.builder compiler.tree.debugger
compiler.tree.optimizer compiler.tree.propagation.info effects fry
generic.single hashtables kernel kernel.private layouts literals
locals math math.floats.private math.functions math.integers.private
math.intervals math.libm math.order math.private quotations sequences
sequences.private sets slots.private sorting specialized-arrays
strings strings.private system tools.test vectors vocabs words ;
FROM: math => float ;
SPECIALIZED-ARRAY: double
SPECIALIZED-ARRAY: void*
IN: compiler.tree.propagation.tests

! Arrays
{ V{ array } } [
    [ 10 f <array> ] final-classes
] unit-test

{ V{ array } } [
    [ { array } declare ] final-classes
] unit-test

{ V{ array } } [
    [ 10 f <array> swap [ ] [ ] if ] final-classes
] unit-test

{
    T{ value-info-state
       { class integer }
       { interval $[ array-capacity-interval ] }
    }
} [
    [ dup "foo" <array> drop ] final-info first
] unit-test

{ t } [
    [ resize-array length ] final-info first
    array-capacity <class-info> =
] unit-test

{ 42 } [
    [ 42 swap resize-array length ] final-literals first
] unit-test

{ f } [
    [ resize-array ] { resize-array } inlined?
] unit-test

{ t } [
    [ 3 { 1 2 3 } resize-array ] { resize-array } inlined?
] unit-test

{ f } [
    [ 4 { 1 2 3 } resize-array ] { resize-array } inlined?
] unit-test

{ f } [
    [ 4 swap { array } declare resize-array ] { resize-array } inlined?
] unit-test

! Byte arrays
{ V{ 3 } } [
    [ 3 <byte-array> length ] final-literals
] unit-test

{ t } [
    [ dup <byte-array> drop ] final-info first
    integer-array-capacity <class-info> =
] unit-test

{ t } [
    [ resize-byte-array length ] final-info first
    array-capacity <class-info> =
] unit-test

{ 43 } [
    [ 43 swap resize-byte-array length ] final-literals first
] unit-test

{ t } [
    [ 3 B{ 1 2 3 } resize-byte-array ] { resize-byte-array } inlined?
] unit-test

! Strings
{ V{ 3 } } [
    [ 3 f <string> length ] final-literals
] unit-test

{ t } [
    [ resize-string length ] final-info first
    array-capacity <class-info> =
] unit-test

{ V{ 44 } } [
    [ 44 swap resize-string length ] final-literals
] unit-test

{ t } [
    [ 3 "123" resize-string ] { resize-string } inlined?
] unit-test

{ V{ t } } [
    [ { string } declare string? ] final-classes
] unit-test

{ V{ string } } [
    [ dup string? t xor [ "A" throw ] [ ] if ] final-classes
] unit-test

{
    V{ $[
        integer-array-capacity <class-info>
        integer <class-info>
    ] }
} [
    [ 2dup <string> drop ] final-info
] unit-test

{ { } } [
    all-words [
        "input-classes" word-prop [ class? ] all? not
    ] filter
] unit-test

! The value interval should be limited for these.
{ t t } [
    [ fixnum>bignum ] final-info first interval>> fixnum-interval =
    [ fixnum>float ] final-info first interval>> fixnum-interval =
] unit-test

{ V{ } } [ [ ] final-classes ] unit-test

{ V{ fixnum } } [ [ 1 ] final-classes ] unit-test

{ V{ fixnum } } [ [ 1 [ ] dip ] final-classes ] unit-test

{ V{ fixnum object } } [ [ 1 swap ] final-classes ] unit-test

{ V{ fixnum } } [ [ dup fixnum? [ ] [ drop 3 ] if ] final-classes ] unit-test

{ V{ 69 } } [ [ [ 69 ] [ 69 ] if ] final-literals ] unit-test

{ V{ integer } } [ [ bitnot ] final-classes ] unit-test

{ V{ fixnum } } [ [ { fixnum } declare bitnot ] final-classes ] unit-test

! Test type propagation for math ops
: cleanup-math-class ( obj -- class )
    { null fixnum bignum integer ratio rational float real complex number }
    [ class= ] with find nip ;

: final-math-class ( quot -- class )
    final-classes first cleanup-math-class ;

{ number } [ [ + ] final-math-class ] unit-test

{ bignum } [ [ { fixnum bignum } declare + ] final-math-class ] unit-test

{ integer } [ [ { fixnum integer } declare + ] final-math-class ] unit-test

{ bignum } [ [ { integer bignum } declare + ] final-math-class ] unit-test

{ integer } [ [ { fixnum fixnum } declare + ] final-math-class ] unit-test

{ float } [ [ { float integer } declare + ] final-math-class ] unit-test

{ float } [ [ { real float } declare + ] final-math-class ] unit-test

{ float } [ [ { float real } declare + ] final-math-class ] unit-test

{ rational } [ [ { ratio ratio } declare + ] final-math-class ] unit-test

{ rational } [ [ { rational ratio } declare + ] final-math-class ] unit-test

{ number } [ [ { complex complex } declare + ] final-math-class ] unit-test

{ float } [ [ /f ] final-math-class ] unit-test

{ float } [ [ { real real } declare /f ] final-math-class ] unit-test

{ integer } [ [ /i ] final-math-class ] unit-test

{ integer } [ [ { integer float } declare /i ] final-math-class ] unit-test

{ integer } [ [ { float float } declare /i ] final-math-class ] unit-test

{ integer } [ [ { integer } declare bitnot ] final-math-class ] unit-test

{ null } [ [ { null null } declare + ] final-math-class ] unit-test

{ null } [ [ { null fixnum } declare + ] final-math-class ] unit-test

{ float } [ [ { float fixnum } declare + ] final-math-class ] unit-test

{ bignum } [ [ { bignum bignum } declare bitxor ] final-math-class ] unit-test

{ bignum } [ [ { integer } declare 123 >bignum bitand ] final-math-class ] unit-test

{ float } [ [ { float float } declare mod ] final-math-class ] unit-test

{ V{ integer float } } [ [ { float float } declare [ /i ] keep ] final-classes ] unit-test

{ V{ fixnum } } [ [ 255 bitand ] final-classes ] unit-test

{ V{ fixnum } } [
    [ [ 255 bitand ] [ 65535 bitand ] bi + ] final-classes
] unit-test

{ V{ fixnum } } [
    [
        { fixnum } declare [ 255 bitand ] [ 65535 bitand ] bi +
    ] final-classes
] unit-test

{ V{ integer } } [
    [ { fixnum } declare [ 255 bitand ] keep + ] final-classes
] unit-test

{ V{ integer } } [
    [ { fixnum } declare 615949 * ] final-classes
] unit-test

{ V{ fixnum } } [
    [ 255 bitand >fixnum 3 bitor ] final-classes
] unit-test

{ V{ 0 } } [
    [ >fixnum 1 mod ] final-literals
] unit-test

{ V{ 69 } } [
    [ >fixnum swap [ 1 mod 69 + ] [ drop 69 ] if ] final-literals
] unit-test

{ V{ fixnum } } [
    [ >fixnum dup 10 > [ 1 - ] when ] final-classes
] unit-test

{ V{ integer } } [ [ >fixnum 2 * ] final-classes ] unit-test

{ V{ integer } } [
    [ >fixnum dup 10 < drop 2 * ] final-classes
] unit-test

{ V{ integer } } [
    [ >fixnum dup 10 < [ 2 * ] when ] final-classes
] unit-test

{ V{ integer } } [
    [ >fixnum dup 10 < [ 2 * ] [ 2 * ] if ] final-classes
] unit-test

{ V{ fixnum } } [
    [ >fixnum dup 10 < [ dup -10 > [ 2 * ] when ] when ] final-classes
] unit-test

{ V{ f } } [
    [ dup 10 < [ dup 8 > [ drop 9 ] unless ] [ drop 9 ] if ] final-literals
] unit-test

{ V{ 9 } } [
    [
        123 bitand
        dup 10 < [ dup 8 > [ drop 9 ] unless ] [ drop 9 ] if
    ] final-literals
] unit-test

{ V{ t } } [ [ 40 mod 40 < ] final-literals ] unit-test

{ V{ f } } [ [ 40 mod 0 >= ] final-literals ] unit-test

{ V{ t } } [ [ 40 rem 0 >= ] final-literals ] unit-test

{ V{ t } } [ [ abs 40 mod 0 >= ] final-literals ] unit-test

{ t } [ [ abs ] final-info first interval>> [0,inf] = ] unit-test

{ t } [ [ absq ] final-info first interval>> [0,inf] = ] unit-test

{ t } [ [ { fixnum } declare abs ] final-info first interval>> [0,inf] interval-subset? ] unit-test

{ t } [ [ { fixnum } declare absq ] final-info first interval>> [0,inf] interval-subset? ] unit-test

{ V{ integer } } [ [ { fixnum } declare abs ] final-classes ] unit-test

{ V{ integer } } [ [ { fixnum } declare absq ] final-classes ] unit-test

{ t } [ [ { bignum } declare abs ] final-info first interval>> [0,inf] interval-subset? ] unit-test

{ t } [ [ { bignum } declare absq ] final-info first interval>> [0,inf] interval-subset? ] unit-test

{ t } [ [ { float } declare abs ] final-info first interval>> [0,inf] = ] unit-test

{ t } [ [ { float } declare absq ] final-info first interval>> [0,inf] = ] unit-test

{ t } [ [ { complex } declare abs ] final-info first interval>> [0,inf] = ] unit-test

{ t } [ [ { complex } declare absq ] final-info first interval>> [0,inf] = ] unit-test

{ t } [ [ { float float } declare rect> C{ 0.0 0.0 } + absq ] final-info first interval>> [0,inf] = ] unit-test

{ V{ float } } [ [ { float float } declare rect> C{ 0.0 0.0 } + absq ] final-classes ] unit-test

{ t } [ [ [ - absq ] [ + ] 2map-reduce ] final-info first interval>> [0,inf] = ] unit-test

{ t } [ [ { double-array double-array } declare [ - absq ] [ + ] 2map-reduce ] final-info first interval>> [0,inf] = ] unit-test

{ V{ string } } [
    [ dup string? not [ "Oops" throw ] [ ] if ] final-classes
] unit-test

{ V{ string } } [
    [ dup string? not not >boolean [ ] [ "Oops" throw ] if ] final-classes
] unit-test

{ f } [ [ t xor ] final-classes first null-class? ] unit-test

{ t } [ [ t or ] final-classes first true-class? ] unit-test

{ t } [ [ t swap or ] final-classes first true-class? ] unit-test

{ t } [ [ f and ] final-classes first false-class? ] unit-test

{ t } [ [ f swap and ] final-classes first false-class? ] unit-test

{ t } [ [ dup not or ] final-classes first true-class? ] unit-test

{ t } [ [ dup not swap or ] final-classes first true-class? ] unit-test

{ t } [ [ dup not and ] final-classes first false-class? ] unit-test

{ t } [ [ dup not swap and ] final-classes first false-class? ] unit-test

{ t } [ [ over [ drop f ] when [ "A" throw ] unless ] final-classes first false-class? ] unit-test

{ V{ fixnum } } [
    [
        [ { fixnum } declare ] [ drop f ] if
        dup [ dup 13 eq? [ t ] [ f ] if ] [ t ] if
        [ "Oops" throw ] when
    ] final-classes
] unit-test

{ V{ fixnum } } [
    [
        >fixnum
        dup [ 10 < ] [ -10 > ] bi and not [ 2 * ] unless
    ] final-classes
] unit-test

{ } [
    [
        dup dup dup [ 100 < ] [ drop f ] if dup
        [ 2drop f ] [ 2drop f ] if
        [ ] [ dup [ ] [ ] if ] if
    ] final-info drop
] unit-test

{ V{ fixnum } } [
    [ { fixnum } declare (clone) ] final-classes
] unit-test

{ V{ vector } } [
    [ vector new ] final-classes
] unit-test

{ V{ fixnum } } [
    [
        { fixnum byte-array } declare
        [ nth-unsafe ] 2keep [ nth-unsafe ] 2keep nth-unsafe
        [ [ 298 * ] dip 100 * - ] dip 208 * - 128 + -8 shift
        0 255 clamp
    ] final-classes
] unit-test

{ V{ fixnum } } [
    [ 0 dup 10 > [ 2 * ] when ] final-classes
] unit-test

{ V{ f } } [
    [ [ 0.0 ] [ -0.0 ] if ] final-literals
] unit-test

{ V{ 1.5 } } [
    [ /f 1.5 1.5 clamp ] final-literals
] unit-test

{ V{ 1.5 } } [
    [
        /f
        dup 1.5 <= [ dup 1.5 >= [ ] [ drop 1.5 ] if ] [ drop 1.5 ] if
    ] final-literals
] unit-test

{ V{ 1.5 } } [
    [
        /f
        dup 1.5 u<= [ dup 1.5 u>= [ ] [ drop 1.5 ] if ] [ drop 1.5 ] if
    ] final-literals
] unit-test

{ V{ 1.5 } } [
    [
        /f
        dup 1.5 <= [ dup 10 >= [ ] [ drop 1.5 ] if ] [ drop 1.5 ] if
    ] final-literals
] unit-test

{ V{ 1.5 } } [
    [
        /f
        dup 1.5 u<= [ dup 10 u>= [ ] [ drop 1.5 ] if ] [ drop 1.5 ] if
    ] final-literals
] unit-test

{ V{ f } } [
    [
        /f
        dup 0.0 <= [ dup 0.0 >= [ drop 0.0 ] unless ] [ drop 0.0 ] if
    ] final-literals
] unit-test

{ V{ f } } [
    [
        /f
        dup 0.0 u<= [ dup 0.0 u>= [ drop 0.0 ] unless ] [ drop 0.0 ] if
    ] final-literals
] unit-test

{ V{ fixnum } } [
    [ 0 dup 10 > [ 100 * ] when ] final-classes
] unit-test

{ V{ fixnum } } [
    [ 0 dup 10 > [ drop "foo" ] when ] final-classes
] unit-test

{ V{ fixnum } } [
    [ 0 dup 10 u> [ 100 * ] when ] final-classes
] unit-test

{ V{ fixnum } } [
    [ 0 dup 10 u> [ drop "foo" ] when ] final-classes
] unit-test

{ V{ fixnum } } [
    [ { fixnum } declare 3 3 - + ] final-classes
] unit-test

{ V{ t } } [
    [ dup 10 < [ 3 * 30 < ] [ drop t ] if ] final-literals
] unit-test

{ V{ t } } [
    [ dup 10 u< [ 3 * 30 u< ] [ drop t ] if ] final-literals
] unit-test

{ V{ "d" } } [
    [
        3 {
            [ "a" ]
            [ "b" ]
            [ "c" ]
            [ "d" ]
            [ "e" ]
            [ "f" ]
            [ "g" ]
            [ "h" ]
        } dispatch
    ] final-literals
] unit-test

{ V{ "hi" } } [
    [ [ "hi" ] [ 123 3 throw ] if ] final-literals
] unit-test

{ V{ fixnum } } [
    [ >fixnum dup 100 < [ 1 + ] [ "Oops" throw ] if ] final-classes
] unit-test

{ V{ fixnum } } [
    [ >fixnum dup 100 u< [ 1 + ] [ "Oops" throw ] if ] final-classes
] unit-test

{ V{ -1 } } [
    [ 0 dup 100 < not [ 1 + ] [ 1 - ] if ] final-literals
] unit-test

{ V{ -1 } } [
    [ 0 dup 100 u< not [ 1 + ] [ 1 - ] if ] final-literals
] unit-test

{ V{ 2 } } [
    [ [ 1 ] [ 1 ] if 1 + ] final-literals
] unit-test

{ V{ object } } [
    [ 0 * 10 < ] final-classes
] unit-test

{ V{ object } } [
    [ 0 * 10 u< ] final-classes
] unit-test

{ V{ 27 } } [
    [
        123 bitand dup 10 < over 8 > and [ 3 * ] [ "B" throw ] if
    ] final-literals
] unit-test

{ V{ 27 } } [
    [
        123 bitand dup 10 u< over 8 u> and [ 3 * ] [ "B" throw ] if
    ] final-literals
] unit-test

{ V{ string string } } [
    [
        2dup [ dup string? [ "Oops" throw ] unless ] bi@ 2drop
    ] final-classes
] unit-test

{ V{ fixnum } } [
    [ { fixnum fixnum } declare 7 bitand neg shift ] final-classes
] unit-test

{ V{ fixnum } } [
    [ { fixnum fixnum } declare 7 bitand neg >bignum shift ] final-classes
] unit-test

{ V{ fixnum } } [
    [ { fixnum } declare 1 swap 7 bitand shift ] final-classes
] unit-test

{ V{ fixnum } } [
    [ { fixnum } declare 1 swap 7 bitand >bignum shift ] final-classes
] unit-test

32-bit? [
    [ V{ integer } ] [
        [ { fixnum } declare 1 swap 31 bitand shift ]
        final-classes
    ] unit-test
] when

! Array length propagation
{ V{ t } } [ [ 10 f <array> length 10 = ] final-literals ] unit-test

{ V{ t } } [ [ [ 10 f <array> length ] [ 10 <byte-array> length ] if 10 = ] final-literals ] unit-test

{ V{ t } } [ [ [ 1 f <array> ] [ 2 f <array> ] if length 3 < ] final-literals ] unit-test

{ V{ 10 } } [
    [ { fixnum } declare dup 10 eq? [ "A" throw ] unless ] final-literals
] unit-test

{ V{ 3 } } [ [ [ { 1 2 3 } ] [ { 4 5 6 } ] if length ] final-literals ] unit-test

{ V{ 3 } } [ [ [ B{ 1 2 3 } ] [ B{ 4 5 6 } ] if length ] final-literals ] unit-test

{ V{ 3 } } [ [ [ "yay" ] [ "hah" ] if length ] final-literals ] unit-test



! Slot propagation
TUPLE: prop-test-tuple { x integer } ;

{ V{ integer } } [ [ { prop-test-tuple } declare x>> ] final-classes ] unit-test

TUPLE: fold-boa-test-tuple { x read-only } { y read-only } { z read-only } ;

{ V{ T{ fold-boa-test-tuple f 1 2 3 } } }
[ [ 1 2 3 fold-boa-test-tuple boa ] final-literals ]
unit-test

TUPLE: don't-fold-boa-test-tuple < identity-tuple ;

{ V{ f } }
[ [ don't-fold-boa-test-tuple boa ] final-literals ]
unit-test

TUPLE: immutable-prop-test-tuple { x sequence read-only } ;

{ V{ T{ immutable-prop-test-tuple f "hey" } } } [
    [ "hey" immutable-prop-test-tuple boa ] final-literals
] unit-test

{ V{ { 1 2 } } } [
    [ { 1 2 } immutable-prop-test-tuple boa x>> ] final-literals
] unit-test

{ V{ array } } [
    [ { array } declare immutable-prop-test-tuple boa x>> ] final-classes
] unit-test

{ V{ complex } } [
    [ complex boa ] final-classes
] unit-test

{ V{ complex } } [
    [ { float float } declare dup 0.0 <= [ "Oops" throw ] [ rect> ] if ] final-classes
] unit-test

{ V{ float float } } [
    [
        { float float } declare
        dup 0.0 <= [ "Oops" throw ] when rect>
        [ real>> ] [ imaginary>> ] bi
    ] final-classes
] unit-test

{ V{ complex } } [
    [
        { float float object } declare
        [ "Oops" throw ] [ complex boa ] if
    ] final-classes
] unit-test

[ [ dup 3 slot swap 4 slot dup 3 slot swap 4 slot ] final-info ] must-not-fail

{ V{ number } } [ [ [ "Oops" throw ] [ 2 + ] if ] final-classes ] unit-test
{ V{ number } } [ [ [ 2 + ] [ "Oops" throw ] if ] final-classes ] unit-test

{ V{ POSTPONE: f } } [
    [ dup 1.0 <= [ drop f ] [ 0 number= ] if ] final-classes
] unit-test

! Don't fold this
TUPLE: mutable-tuple-test { x sequence } ;

{ V{ sequence } } [
    [ "hey" mutable-tuple-test boa x>> ] final-classes
] unit-test

{ V{ sequence } } [
    [ T{ mutable-tuple-test f "hey" } x>> ] final-classes
] unit-test

{ V{ array } } [
    [ T{ mutable-tuple-test f "hey" } layout-of ] final-classes
] unit-test

! Mixed mutable and immutable slots
TUPLE: mixed-mutable-immutable { x integer } { y sequence read-only } ;

{ V{ integer array } } [
    [
        3 { 2 1 } mixed-mutable-immutable boa [ x>> ] [ y>> ] bi
    ] final-classes
] unit-test

{ V{ array integer } } [
    [
        3 { 2 1 } mixed-mutable-immutable boa [ y>> ] [ x>> ] bi
    ] final-classes
] unit-test

{ V{ integer array } } [
    [
        [ 2drop T{ mixed-mutable-immutable f 3 { } } ]
        [ { array } declare mixed-mutable-immutable boa ] if
        [ x>> ] [ y>> ] bi
    ] final-classes
] unit-test

{ V{ f { } } } [
    [
        T{ mixed-mutable-immutable f 3 { } }
        [ x>> ] [ y>> ] bi
    ] final-literals
] unit-test

! Recursive propagation
: recursive-test-1 ( a -- b ) recursive-test-1 ; inline recursive

{ V{ null } } [ [ recursive-test-1 ] final-classes ] unit-test

: recursive-test-2 ( a -- b ) dup 10 < [ recursive-test-2 ] when ; inline recursive

{ V{ real } } [ [ recursive-test-2 ] final-classes ] unit-test

: recursive-test-3 ( a -- b ) dup 10 < drop ; inline recursive

{ V{ real } } [ [ recursive-test-3 ] final-classes ] unit-test

{ V{ real } } [ [ [ dup 10 < ] [ ] while ] final-classes ] unit-test

{ V{ float } } [
    [ { float } declare 10 [ 2.3 * ] times ] final-classes
] unit-test

{ V{ fixnum } } [
    [ 0 10 [ nip ] each-integer ] final-classes
] unit-test

{ V{ t } } [
    [ t 10 [ nip 0 >= ] each-integer ] final-literals
] unit-test

: recursive-test-4 ( i n -- )
    2dup < [ [ 1 + ] dip recursive-test-4 ] [ 2drop ] if ; inline recursive

[ [ recursive-test-4 ] final-info ] must-not-fail

: recursive-test-5 ( a -- b )
    dup 1 <= [ drop 1 ] [ dup 1 - recursive-test-5 * ] if ; inline recursive

{ V{ integer } } [ [ { integer } declare recursive-test-5 ] final-classes ] unit-test

: recursive-test-6 ( a -- b )
    dup 1 <= [ drop 1 ] [ dup 1 - recursive-test-6 swap 2 - recursive-test-6 + ] if ; inline recursive

{ V{ integer } } [ [ { fixnum } declare recursive-test-6 ] final-classes ] unit-test

: recursive-test-7 ( a -- b )
    dup 10 < [ 1 + recursive-test-7 ] when ; inline recursive

{ V{ fixnum } } [ [ 0 recursive-test-7 ] final-classes ] unit-test

{ V{ fixnum } } [ [ 1 10 [ dup 10 < [ 2 * ] when ] times ] final-classes ] unit-test

{ V{ integer } } [ [ 0 2 100 ^ [ nip ] each-integer ] final-classes ] unit-test

[ [ [ ] [ ] compose curry call ] final-info ] must-not-fail

{ V{ } } [
    [ [ drop ] [ drop ] compose curry each-integer-from ] final-classes
] unit-test

GENERIC: iterate ( obj -- next-obj ? )
M: fixnum iterate f ; inline
M: array iterate first t ; inline

: dead-loop ( obj -- final-obj )
    iterate [ dead-loop ] when ; inline recursive

{ V{ fixnum } } [ [ { fixnum } declare dead-loop ] final-classes ] unit-test

: hang-1 ( m -- x )
    dup 0 number= [ hang-1 ] unless ; inline recursive

[ [ 3 hang-1 ] final-info ] must-not-fail

: hang-2 ( m n -- x )
    over 0 number= [
        nip
    ] [
        dup [
            drop 1 hang-2
        ] [
            dupd hang-2 hang-2
        ] if
    ] if ; inline recursive

[ [ 3 over hang-2 ] final-info ] must-not-fail

{ } [
    [
        dup fixnum? [ 3 over hang-2 ] [ 3 over hang-2 ] if
    ] final-info drop
] unit-test

{ V{ t } } [
    [ { hashtable } declare hashtable instance? ] final-classes
] unit-test

{ V{ POSTPONE: f } } [
    [ { vector } declare hashtable instance? ] final-classes
] unit-test

{ V{ object } } [
    [ { assoc } declare hashtable instance? ] final-classes
] unit-test

{ V{ POSTPONE: f } } [
    [ 3 string? ] final-classes
] unit-test

{ V{ fixnum } } [
    [ { fixnum } declare [ ] curry obj>> ] final-classes
] unit-test

{ V{ f } } [
    [ 10 eq? [ drop 3 ] unless ] final-literals
] unit-test

GENERIC: bad-generic ( a -- b )
M: fixnum bad-generic 1 fixnum+fast ; inline
: bad-behavior ( -- b ) 4 bad-generic ; inline recursive

{ V{ fixnum } } [ [ bad-behavior ] final-classes ] unit-test

{ V{ number } } [
    [
        0 10 [ bad-generic dup 123 bitand drop bad-generic 1 + ] times
    ] final-classes
] unit-test

GENERIC: infinite-loop ( a -- b )
M: integer infinite-loop infinite-loop ;

[ [ { integer } declare infinite-loop ] final-classes ] must-not-fail

{ V{ tuple } } [ [ tuple-layout <tuple> ] final-classes ] unit-test

[ [ instance? ] final-classes ] must-not-fail

{ f } [ [ V{ } clone ] final-info first literal?>> ] unit-test

: fold-throw-test ( a -- b ) "A" throw ; foldable

[ [ 0 fold-throw-test ] final-info ] must-not-fail

: too-deep ( a b -- c )
    dup [ drop ] [ 2dup too-deep too-deep * ] if ; inline recursive

[ [ too-deep ] final-info ] must-not-fail

[ [ reversed boa slice boa nth-unsafe * ] final-info ] must-not-fail

MIXIN: empty-mixin

[ [ { empty-mixin } declare empty-mixin? ] final-info ] must-not-fail

{ V{ fixnum } } [ [ [ bignum-shift drop ] keep ] final-classes ] unit-test

{ V{ float } } [
    [
        [ { float float } declare complex boa ]
        [ 2drop C{ 0.0 0.0 } ]
        if real-part
    ] final-classes
] unit-test

{ V{ POSTPONE: f } } [
    [ { float } declare 0 eq? ] final-classes
] unit-test

{
    { fixnum integer integer fixnum }
} [
    {
        { integer fixnum }
        ! These two are tricky. Possibly, they will always be
        ! fixnums. But that requires a better interval-mod.
        { fixnum integer }
        { fixnum bignum }
        { bignum fixnum }
    } [ '[ _ declare mod ] final-classes first ] map
] unit-test

! Due to downpromotion, we lose the type here.
{ V{ integer } } [
    [ { bignum bignum } declare bignum-mod ] final-classes
] unit-test

! And here
{ V{ bignum integer } } [
    [ { bignum bignum } declare /mod ] final-classes
] unit-test

! So this code gets worse than it was.
{
    [
        bignum-mod 20 over tag 0 eq?
        [ fixnum+ ] [ fixnum>bignum bignum+ ] if
    ]
} [
    [ { bignum bignum } declare bignum-mod 20 + ]
    build-tree optimize-tree nodes>quot
] unit-test

{ V{ fixnum } } [
    [ fixnum-mod ] final-classes
] unit-test

{ V{ integer } } [
    [ { fixnum integer } declare bitand ] final-classes
] unit-test

{ V{ double-array } } [ [| | double-array{ } ] final-classes ] unit-test

{ V{ t } } [ [ macos unix? ] final-literals ] unit-test

{ V{ array } } [ [ [ <=> ] sort-with [ <=> ] sort-with ] final-classes ] unit-test

{ V{ float } } [ [ fsqrt ] final-classes ] unit-test

{ V{ t } } [ [ { fixnum } declare 10 mod >float -20 > ] final-literals ] unit-test

{ T{ interval f { 0 t } { 127 t } } } [
    [ { integer } declare 127 bitand ] final-info first interval>>
] unit-test

{ V{ t } } [
    [ [ 123 bitand ] [ drop f ] if dup [ 0 >= ] [ not ] if ] final-literals
] unit-test

{ V{ bignum } } [
    [ { bignum } declare dup 1 - bitxor ] final-classes
] unit-test

{ V{ bignum integer } } [
    [ { bignum integer } declare [ shift ] keep ] final-classes
] unit-test

{ V{ fixnum } } [ [ >fixnum 15 bitand 1 swap shift ] final-classes ] unit-test

{ V{ fixnum } } [ [ 15 bitand 1 swap shift ] final-classes ] unit-test

{ V{ fixnum } } [
    [ { fixnum } declare log2 ] final-classes
] unit-test

{ V{ t } } [
    [ { fixnum } declare log2 0 >= ] final-classes
] unit-test

{ V{ POSTPONE: f } } [
    [ { word object } declare equal? ] final-classes
] unit-test

{ t } [ [ dup t xor or ] final-classes first true-class? ] unit-test

{ t } [ [ dup t xor swap or ] final-classes first true-class? ] unit-test

{ t } [ [ dup t xor and ] final-classes first false-class? ] unit-test

{ t } [ [ dup t xor swap and ] final-classes first false-class? ] unit-test

! generalize-counter-interval wasn't being called in all the right places.
! bug found by littledan

TUPLE: littledan-1 { a read-only } ;

: (littledan-1-test) ( a -- ) a>> 1 + littledan-1 boa (littledan-1-test) ; inline recursive

: littledan-1-test ( -- ) 0 littledan-1 boa (littledan-1-test) ; inline

[ [ littledan-1-test ] final-classes ] must-not-fail

TUPLE: littledan-2 { from read-only } { to read-only } ;

: (littledan-2-test) ( x -- i elt )
    [ from>> ] [ to>> ] bi + dup littledan-2 boa (littledan-2-test) ; inline recursive

: littledan-2-test ( x -- i elt )
    [ 0 ] dip { array-capacity } declare littledan-2 boa (littledan-2-test) ; inline

[ [ littledan-2-test ] final-classes ] must-not-fail

: (littledan-3-test) ( x -- )
    length 1 + f <array> (littledan-3-test) ; inline recursive

: littledan-3-test ( -- )
    0 f <array> (littledan-3-test) ; inline

[ [ littledan-3-test ] final-classes ] must-not-fail

{ V{ 0 } } [ [ { } length ] final-literals ] unit-test

{ V{ 1 } } [ [ { } length 1 + f <array> length ] final-literals ] unit-test

! generalize-counter is not tight enough
{ V{ fixnum } } [ [ 0 10 [ 1 + >fixnum ] times ] final-classes ] unit-test

{ V{ fixnum } } [ [ 0 10 [ 1 + >fixnum ] times 0 + ] final-classes ] unit-test

! Coercions need to update intervals
{ V{ f } } [ [ 1 2 ? 100 shift >fixnum 1 = ] final-literals ] unit-test

{ V{ t } } [ [ >fixnum 1 + >fixnum most-positive-fixnum <= ] final-literals ] unit-test

{ V{ t } } [ [ >fixnum 1 + >fixnum most-negative-fixnum >= ] final-literals ] unit-test

{ V{ f } } [ [ >fixnum 1 + >fixnum most-negative-fixnum > ] final-literals ] unit-test

! Mutable tuples with circularity should not cause problems
TUPLE: circle me ;

[ circle new dup >>me 1quotation final-info ] must-not-fail

! Joe found an oversight
{ V{ integer } } [ [ >integer ] final-classes ] unit-test

TUPLE: foo bar ;

{ t } [ [ foo new ] { new } inlined? ] unit-test

GENERIC: whatever ( x -- y )
M: number whatever drop foo ; inline

{ t } [ [ 1 whatever new ] { new } inlined? ] unit-test

: that-thing ( -- class ) foo ;

{ f } [ [ that-thing new ] { new } inlined? ] unit-test

GENERIC: whatever2 ( x -- y )
M: number whatever2 drop H{ { 1 1 } { 2 2 } { 3 3 } { 4 4 } { 5 6 } } ; inline
M: f whatever2 ; inline

{ t } [ [ 1 whatever2 at ] { at* hashcode* } inlined? ] unit-test
{ f } [ [ whatever2 at ] { at* hashcode* } inlined? ] unit-test

SYMBOL: not-an-assoc

{ f } [ [ not-an-assoc at ] { at* } inlined? ] unit-test

{ t } [ [ { 1 2 3 } member? ] { member? } inlined? ] unit-test
{ f } [ [ { 1 2 3 } swap member? ] { member? } inlined? ] unit-test

{ t } [ [ { 1 2 3 } member-eq? ] { member-eq? } inlined? ] unit-test
{ f } [ [ { 1 2 3 } swap member-eq? ] { member-eq? } inlined? ] unit-test

{ t } [ [ V{ } clone ] { clone (clone) } inlined? ] unit-test
{ f } [ [ { } clone ] { clone (clone) } inlined? ] unit-test

{ f } [ [ instance? ] { instance? } inlined? ] unit-test
{ f } [ [ 5 instance? ] { instance? } inlined? ] unit-test
{ t } [ [ array instance? ] { instance? } inlined? ] unit-test

{ t } [ [ ( a b c -- c b a ) shuffle ] { shuffle } inlined? ] unit-test
{ f } [ [ { 1 2 3 } swap shuffle ] { shuffle } inlined? ] unit-test

! Type function for 'clone' had a subtle issue
TUPLE: tuple-with-read-only-slot { x read-only } ;

M: tuple-with-read-only-slot clone
    x>> clone tuple-with-read-only-slot boa ; inline

{ V{ object } } [
    [ { 1 2 3 } dup tuple-with-read-only-slot boa clone x>> eq? ] final-classes
] unit-test

! alien-cell outputs a alien or f
{ t } [
    [ { byte-array fixnum } declare alien-cell dup [ "OOPS" throw ] unless ] final-classes
    first alien class=
] unit-test

! Don't crash if bad literal inputs are passed to unsafe words
{ f } [ [ { } 1 fixnum+fast ] final-info first literal?>> ] unit-test

! Converting /i to shift
{ t } [ [ >fixnum dup 0 >= [ 16 /i ] when ] { /i fixnum/i fixnum/i-fast } inlined? ] unit-test
{ f } [ [ >fixnum dup 0 >= [ 16 /i ] when ] { fixnum-shift-fast } inlined? ] unit-test
{ f } [ [ >float dup 0 >= [ 16 /i ] when ] { /i float/f } inlined? ] unit-test

! We want this to inline
{ t } [ [ void* <c-direct-array> ] { <c-direct-array> } inlined? ] unit-test
{ V{ void*-array } } [ [ void* <c-direct-array> ] final-classes ] unit-test

! bitand identities
{ t } [ [ alien-unsigned-1 255 bitand ] { bitand fixnum-bitand } inlined? ] unit-test
{ t } [ [ alien-unsigned-1 255 swap bitand ] { bitand fixnum-bitand } inlined? ] unit-test

{ t } [ [ { fixnum } declare 256 rem -256 bitand ] { fixnum-bitand } inlined? ] unit-test
{ t } [ [ { fixnum } declare 250 rem -256 bitand ] { fixnum-bitand } inlined? ] unit-test
{ f } [ [ { fixnum } declare 257 rem -256 bitand ] { fixnum-bitand } inlined? ] unit-test

{ V{ fixnum } } [ [ >bignum 10 mod 2^ ] final-classes ] unit-test
{ V{ bignum } } [ [ >bignum 10 bitand ] final-classes ] unit-test
{ V{ bignum } } [ [ >bignum 10 >bignum bitand ] final-classes ] unit-test
{ V{ fixnum } } [ [ >bignum 10 mod ] final-classes ] unit-test
{ V{ bignum } } [ [ { fixnum } declare -1 >bignum bitand ] final-classes ] unit-test
{ V{ bignum } } [ [ { fixnum } declare -1 >bignum swap bitand ] final-classes ] unit-test

! Could be bignum not integer but who cares
{ V{ integer } } [ [ 10 >bignum bitand ] final-classes ] unit-test
{ V{ bignum } } [ [ { fixnum } declare 10 >bignum bitand ] final-classes ] unit-test
{ V{ bignum } } [ [ { integer } declare 10 >bignum bitand ] final-classes ] unit-test

{ t } [ [ { fixnum fixnum } declare min ] { min } inlined? ] unit-test
{ f } [ [ { fixnum fixnum } declare min ] { fixnum-min } inlined? ] unit-test

{ t } [ [ { float float } declare min ] { min } inlined? ] unit-test
{ f } [ [ { float float } declare min ] { float-min } inlined? ] unit-test

{ t } [ [ { fixnum fixnum } declare max ] { max } inlined? ] unit-test
{ f } [ [ { fixnum fixnum } declare max ] { fixnum-max } inlined? ] unit-test

{ t } [ [ { float float } declare max ] { max } inlined? ] unit-test
{ f } [ [ { float float } declare max ] { float-max } inlined? ] unit-test

! Propagation should not call equal?, hashcode, etc on literals in user code
{ V{ } } [ [ 4 <reversed> [ 2drop ] with each ] final-info ] unit-test

! Reduction
{ 1 } [ [ 4 <reversed> [ nth-unsafe ] [ ] unless ] final-info length ] unit-test

! Optimization on bit?
{ t } [ [ 3 bit? ] { bit? } inlined? ] unit-test
{ f } [ [ 500 bit? ] { bit? } inlined? ] unit-test

{ t } [ [ { 1 } intersect ] { intersect } inlined? ] unit-test
{ f } [ [ { 1 } swap intersect ] { intersect } inlined? ] unit-test ! We could do this

{ t } [ [ { 1 } intersects? ] { intersects? } inlined? ] unit-test
{ f } [ [ { 1 } swap intersects? ] { intersects? } inlined? ] unit-test ! We could do this

{ t } [ [ { 1 } diff ] { diff } inlined? ] unit-test
{ f } [ [ { 1 } swap diff ] { diff } inlined? ] unit-test ! We could do this

! Output range for string-nth now that string-nth is a library word and
! not a primitive
{ t } [
    [ string-nth ] final-info first interval>> 0 23 2^ 1 - [a,b] =
] unit-test

! Non-zero displacement for <displaced-alien> restricts the output type
{ t } [
    [ { byte-array } declare <displaced-alien> ] final-classes
    first byte-array alien class-or class=
] unit-test

{ V{ alien } } [
    [ { alien } declare <displaced-alien> ] final-classes
] unit-test

{ t } [
    [ { POSTPONE: f } declare <displaced-alien> ] final-classes
    first \ f alien class-or class=
] unit-test

{ V{ alien } } [
    [ { byte-array } declare [ 10 bitand 2 + ] dip <displaced-alien> ] final-classes
] unit-test

! 'tag' should have a declared output interval
{ V{ t } } [
    [ tag 0 15 between? ] final-literals
] unit-test

{ t } [
    [ maybe{ integer } instance? ] { instance? } inlined?
] unit-test

TUPLE: inline-please a ;
{ t } [
    [ maybe{ inline-please } instance? ] { instance? } inlined?
] unit-test

GENERIC: derp ( obj -- obj' )

M: integer derp 5 + ;
M: f derp drop t ;

{ t }
[
    [ dup maybe{ integer } instance? [ derp ] when ] { instance? } inlined?
] unit-test

! Type-check ratios with bitand operators

: bitand-ratio0 ( x -- y )
    1 bitand zero? ;

: bitand-ratio1 ( x -- y )
    1 swap bitand zero? ;

[ 2+1/2 bitand-ratio0 ] [ no-method? ] must-fail-with
[ 2+1/2 bitand-ratio1 ] [ no-method? ] must-fail-with

: shift-test0 ( x -- y )
    4.3 shift ;

[ 1 shift-test0 ] [ no-method? ] must-fail-with

! Test for the #1370 bug
STRUCT: bar { s bar* } ;

{ t } [
    [ bar <struct> [ s>> ] follow ] build-tree optimize-tree
    [ #recursive? ] find nip
    child>> [ { [ #call? ] [ word>> \ alien-cell = ] } 1&& ] find nip
    >boolean
] unit-test
