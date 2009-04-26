USING: kernel compiler.tree.builder compiler.tree
compiler.tree.propagation compiler.tree.recursive
compiler.tree.normalization tools.test math math.order
accessors sequences arrays kernel.private vectors
alien.accessors alien.c-types sequences.private
byte-arrays classes.algebra classes.tuple.private
math.functions math.private strings layouts
compiler.tree.propagation.info compiler.tree.def-use
compiler.tree.debugger compiler.tree.checker
slots.private words hashtables classes assocs locals
specialized-arrays.double system sorting math.libm
math.intervals ;
IN: compiler.tree.propagation.tests

[ V{ } ] [ [ ] final-classes ] unit-test

[ V{ fixnum } ] [ [ 1 ] final-classes ] unit-test

[ V{ fixnum } ] [ [ 1 [ ] dip ] final-classes ] unit-test

[ V{ fixnum object } ] [ [ 1 swap ] final-classes ] unit-test

[ V{ array } ] [ [ 10 f <array> ] final-classes ] unit-test

[ V{ array } ] [ [ { array } declare ] final-classes ] unit-test

[ V{ array } ] [ [ 10 f <array> swap [ ] [ ] if ] final-classes ] unit-test

[ V{ fixnum } ] [ [ dup fixnum? [ ] [ drop 3 ] if ] final-classes ] unit-test

[ V{ 69 } ] [ [ [ 69 ] [ 69 ] if ] final-literals ] unit-test

[ V{ fixnum } ] [ [ { fixnum } declare bitnot ] final-classes ] unit-test

! Test type propagation for math ops
: cleanup-math-class ( obj -- class )
    { null fixnum bignum integer ratio rational float real complex number }
    [ class= ] with find nip ;

: final-math-class ( quot -- class )
    final-classes first cleanup-math-class ;

[ number ] [ [ + ] final-math-class ] unit-test

[ bignum ] [ [ { fixnum bignum } declare + ] final-math-class ] unit-test

[ integer ] [ [ { fixnum integer } declare + ] final-math-class ] unit-test

[ bignum ] [ [ { integer bignum } declare + ] final-math-class ] unit-test

[ integer ] [ [ { fixnum fixnum } declare + ] final-math-class ] unit-test

[ float ] [ [ { float integer } declare + ] final-math-class ] unit-test

[ float ] [ [ { real float } declare + ] final-math-class ] unit-test

[ float ] [ [ { float real } declare + ] final-math-class ] unit-test

[ rational ] [ [ { ratio ratio } declare + ] final-math-class ] unit-test

[ rational ] [ [ { rational ratio } declare + ] final-math-class ] unit-test

[ number ] [ [ { complex complex } declare + ] final-math-class ] unit-test

[ float ] [ [ /f ] final-math-class ] unit-test

[ float ] [ [ { real real } declare /f ] final-math-class ] unit-test

[ integer ] [ [ /i ] final-math-class ] unit-test

[ integer ] [ [ { integer float } declare /i ] final-math-class ] unit-test

[ integer ] [ [ { float float } declare /i ] final-math-class ] unit-test

[ integer ] [ [ { integer } declare bitnot ] final-math-class ] unit-test

[ null ] [ [ { null null } declare + ] final-math-class ] unit-test

[ null ] [ [ { null fixnum } declare + ] final-math-class ] unit-test

[ float ] [ [ { float fixnum } declare + ] final-math-class ] unit-test

[ bignum ] [ [ { bignum bignum } declare bitxor ] final-math-class ] unit-test

[ float ] [ [ { float float } declare mod ] final-math-class ] unit-test

[ V{ integer } ] [ [ 255 bitand ] final-classes ] unit-test

[ V{ integer } ] [
    [ [ 255 bitand ] [ 65535 bitand ] bi + ] final-classes
] unit-test

[ V{ fixnum } ] [
    [
        { fixnum } declare [ 255 bitand ] [ 65535 bitand ] bi +
    ] final-classes
] unit-test

[ V{ integer } ] [
    [ { fixnum } declare [ 255 bitand ] keep + ] final-classes
] unit-test

[ V{ integer } ] [
    [ { fixnum } declare 615949 * ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ 255 bitand >fixnum 3 bitor ] final-classes
] unit-test

[ V{ 0 } ] [
    [ >fixnum 1 mod ] final-literals
] unit-test

[ V{ 69 } ] [
    [ >fixnum swap [ 1 mod 69 + ] [ drop 69 ] if ] final-literals
] unit-test

[ V{ fixnum } ] [
    [ >fixnum dup 10 > [ 1 - ] when ] final-classes
] unit-test

[ V{ integer } ] [ [ >fixnum 2 * ] final-classes ] unit-test

[ V{ integer } ] [
    [ >fixnum dup 10 < drop 2 * ] final-classes
] unit-test

[ V{ integer } ] [
    [ >fixnum dup 10 < [ 2 * ] when ] final-classes
] unit-test

[ V{ integer } ] [
    [ >fixnum dup 10 < [ 2 * ] [ 2 * ] if ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ >fixnum dup 10 < [ dup -10 > [ 2 * ] when ] when ] final-classes
] unit-test

[ V{ f } ] [
    [ dup 10 < [ dup 8 > [ drop 9 ] unless ] [ drop 9 ] if ] final-literals
] unit-test

[ V{ 9 } ] [
    [
        123 bitand
        dup 10 < [ dup 8 > [ drop 9 ] unless ] [ drop 9 ] if
    ] final-literals
] unit-test

[ V{ string } ] [
    [ dup string? not [ "Oops" throw ] [ ] if ] final-classes
] unit-test

[ V{ string } ] [
    [ dup string? not not >boolean [ ] [ "Oops" throw ] if ] final-classes
] unit-test

[ f ] [ [ t xor ] final-classes first null-class? ] unit-test

[ t ] [ [ t or ] final-classes first true-class? ] unit-test

[ t ] [ [ t swap or ] final-classes first true-class? ] unit-test

[ t ] [ [ f and ] final-classes first false-class? ] unit-test

[ t ] [ [ f swap and ] final-classes first false-class? ] unit-test

[ t ] [ [ dup not or ] final-classes first true-class? ] unit-test

[ t ] [ [ dup not swap or ] final-classes first true-class? ] unit-test

[ t ] [ [ dup not and ] final-classes first false-class? ] unit-test

[ t ] [ [ dup not swap and ] final-classes first false-class? ] unit-test

[ t ] [ [ over [ drop f ] when [ "A" throw ] unless ] final-classes first false-class? ] unit-test

[ V{ fixnum } ] [
    [
        >fixnum
        dup [ 10 < ] [ -10 > ] bi and not [ 2 * ] unless
    ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum } declare (clone) ] final-classes
] unit-test

[ V{ vector } ] [
    [ vector new ] final-classes
] unit-test

[ V{ fixnum } ] [
    [
        { fixnum byte-array } declare
        [ nth-unsafe ] 2keep [ nth-unsafe ] 2keep nth-unsafe
        [ [ 298 * ] dip 100 * - ] dip 208 * - 128 + -8 shift
        255 min 0 max
    ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ 0 dup 10 > [ 2 * ] when ] final-classes
] unit-test

[ V{ f } ] [
    [ [ 0.0 ] [ -0.0 ] if ] final-literals
] unit-test

[ V{ 1.5 } ] [
    [ /f 1.5 min 1.5 max ] final-literals
] unit-test

[ V{ 1.5 } ] [
    [
        /f
        dup 1.5 <= [ dup 1.5 >= [ ] [ drop 1.5 ] if ] [ drop 1.5 ] if
    ] final-literals
] unit-test

[ V{ 1.5 } ] [
    [
        /f
        dup 1.5 <= [ dup 10 >= [ ] [ drop 1.5 ] if ] [ drop 1.5 ] if
    ] final-literals
] unit-test

[ V{ f } ] [
    [
        /f
        dup 0.0 <= [ dup 0.0 >= [ drop 0.0 ] unless ] [ drop 0.0 ] if
    ] final-literals
] unit-test

[ V{ fixnum } ] [
    [ 0 dup 10 > [ 100 * ] when ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ 0 dup 10 > [ drop "foo" ] when ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum } declare 3 3 - + ] final-classes
] unit-test

[ V{ t } ] [
    [ dup 10 < [ 3 * 30 < ] [ drop t ] if ] final-literals
] unit-test

[ V{ "d" } ] [
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

[ V{ "hi" } ] [
    [ [ "hi" ] [ 123 3 throw ] if ] final-literals
] unit-test

[ V{ fixnum } ] [
    [ >fixnum dup 100 < [ 1+ ] [ "Oops" throw ] if ] final-classes
] unit-test

[ V{ -1 } ] [
    [ 0 dup 100 < not [ 1+ ] [ 1- ] if ] final-literals
] unit-test

[ V{ 2 } ] [
    [ [ 1 ] [ 1 ] if 1 + ] final-literals
] unit-test

[ V{ object } ] [
    [ 0 * 10 < ] final-classes
] unit-test

[ V{ 27 } ] [
    [
        123 bitand dup 10 < over 8 > and [ 3 * ] [ "B" throw ] if
    ] final-literals
] unit-test

[ V{ 27 } ] [
    [
        dup number? over sequence? and [
            dup 10 < over 8 <= not and [ 3 * ] [ "A" throw ] if
        ] [ "B" throw ] if
    ] final-literals
] unit-test

[ V{ string string } ] [
    [
        2dup [ dup string? [ "Oops" throw ] unless ] bi@ 2drop
    ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum fixnum } declare 7 bitand neg shift ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum } declare 1 swap 7 bitand shift ] final-classes
] unit-test

cell-bits 32 = [
    [ V{ integer } ] [
        [ { fixnum } declare 1 swap 31 bitand shift ]
        final-classes
    ] unit-test
] when

! Array length propagation
[ V{ t } ] [ [ 10 f <array> length 10 = ] final-literals ] unit-test

[ V{ t } ] [ [ [ 10 f <array> length ] [ 10 <byte-array> length ] if 10 = ] final-literals ] unit-test

[ V{ t } ] [ [ [ 1 f <array> ] [ 2 f <array> ] if length 3 < ] final-literals ] unit-test

[ V{ 10 } ] [
    [ { fixnum } declare dup 10 eq? [ "A" throw ] unless ] final-literals
] unit-test

! Slot propagation
TUPLE: prop-test-tuple { x integer } ;

[ V{ integer } ] [ [ { prop-test-tuple } declare x>> ] final-classes ] unit-test

TUPLE: fold-boa-test-tuple { x read-only } { y read-only } { z read-only } ;

[ V{ T{ fold-boa-test-tuple f 1 2 3 } } ]
[ [ 1 2 3 fold-boa-test-tuple boa ] final-literals ]
unit-test

TUPLE: immutable-prop-test-tuple { x sequence read-only } ;

[ V{ T{ immutable-prop-test-tuple f "hey" } } ] [
    [ "hey" immutable-prop-test-tuple boa ] final-literals
] unit-test

[ V{ { 1 2 } } ] [
    [ { 1 2 } immutable-prop-test-tuple boa x>> ] final-literals
] unit-test

[ V{ array } ] [
    [ { array } declare immutable-prop-test-tuple boa x>> ] final-classes
] unit-test

[ V{ complex } ] [
    [ <complex> ] final-classes
] unit-test

[ V{ complex } ] [
    [ { float float } declare dup 0.0 <= [ "Oops" throw ] [ rect> ] if ] final-classes
] unit-test

[ V{ float float } ] [
    [
        { float float } declare
        dup 0.0 <= [ "Oops" throw ] when rect>
        [ real>> ] [ imaginary>> ] bi
    ] final-classes
] unit-test

[ V{ complex } ] [
    [
        { float float object } declare
        [ "Oops" throw ] [ <complex> ] if
    ] final-classes
] unit-test

[ ] [ [ dup 3 slot swap 4 slot dup 3 slot swap 4 slot ] final-info drop ] unit-test

[ V{ number } ] [ [ [ "Oops" throw ] [ 2 + ] if ] final-classes ] unit-test
[ V{ number } ] [ [ [ 2 + ] [ "Oops" throw ] if ] final-classes ] unit-test

[ V{ POSTPONE: f } ] [
    [ dup 1.0 <= [ drop f ] [ 0 number= ] if ] final-classes
] unit-test

! Don't fold this
TUPLE: mutable-tuple-test { x sequence } ;

[ V{ sequence } ] [
    [ "hey" mutable-tuple-test boa x>> ] final-classes
] unit-test

[ V{ sequence } ] [
    [ T{ mutable-tuple-test f "hey" } x>> ] final-classes
] unit-test

[ V{ array } ] [
    [ T{ mutable-tuple-test f "hey" } layout-of ] final-classes
] unit-test

! Mixed mutable and immutable slots
TUPLE: mixed-mutable-immutable { x integer } { y sequence read-only } ;

[ V{ integer array } ] [
    [
        3 { 2 1 } mixed-mutable-immutable boa [ x>> ] [ y>> ] bi
    ] final-classes
] unit-test

[ V{ array integer } ] [
    [
        3 { 2 1 } mixed-mutable-immutable boa [ y>> ] [ x>> ] bi
    ] final-classes
] unit-test

[ V{ integer array } ] [
    [
        [ 2drop T{ mixed-mutable-immutable f 3 { } } ]
        [ { array } declare mixed-mutable-immutable boa ] if
        [ x>> ] [ y>> ] bi
    ] final-classes
] unit-test

! Recursive propagation
: recursive-test-1 ( a -- b ) recursive-test-1 ; inline recursive

[ V{ null } ] [ [ recursive-test-1 ] final-classes ] unit-test

: recursive-test-2 ( a -- b ) dup 10 < [ recursive-test-2 ] when ; inline recursive

[ V{ real } ] [ [ recursive-test-2 ] final-classes ] unit-test

: recursive-test-3 ( a -- b ) dup 10 < drop ; inline recursive

[ V{ real } ] [ [ recursive-test-3 ] final-classes ] unit-test

[ V{ real } ] [ [ [ dup 10 < ] [ ] while ] final-classes ] unit-test

[ V{ float } ] [
    [ { float } declare 10 [ 2.3 * ] times ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ 0 10 [ nip ] each-integer ] final-classes
] unit-test

[ V{ t } ] [
    [ t 10 [ nip 0 >= ] each-integer ] final-literals
] unit-test

: recursive-test-4 ( i n -- )
    2dup < [ [ 1+ ] dip recursive-test-4 ] [ 2drop ] if ; inline recursive

[ ] [ [ recursive-test-4 ] final-info drop ] unit-test

: recursive-test-5 ( a -- b )
    dup 1 <= [ drop 1 ] [ dup 1 - recursive-test-5 * ] if ; inline recursive

[ V{ integer } ] [ [ { integer } declare recursive-test-5 ] final-classes ] unit-test

: recursive-test-6 ( a -- b )
    dup 1 <= [ drop 1 ] [ dup 1 - recursive-test-6 swap 2 - recursive-test-6 + ] if ; inline recursive

[ V{ integer } ] [ [ { fixnum } declare recursive-test-6 ] final-classes ] unit-test

: recursive-test-7 ( a -- b )
    dup 10 < [ 1+ recursive-test-7 ] when ; inline recursive

[ V{ fixnum } ] [ [ 0 recursive-test-7 ] final-classes ] unit-test

[ V{ fixnum } ] [ [ 1 10 [ dup 10 < [ 2 * ] when ] times ] final-classes ] unit-test

[ V{ integer } ] [ [ 0 2 100 ^ [ nip ] each-integer ] final-classes ] unit-test

[ ] [ [ [ ] [ ] compose curry call ] final-info drop ] unit-test

[ V{ } ] [
    [ [ drop ] [ drop ] compose curry (each-integer) ] final-classes
] unit-test

GENERIC: iterate ( obj -- next-obj ? )
M: fixnum iterate f ;
M: array iterate first t ;

: dead-loop ( obj -- final-obj )
    iterate [ dead-loop ] when ; inline recursive

[ V{ fixnum } ] [ [ { fixnum } declare dead-loop ] final-classes ] unit-test

: hang-1 ( m -- x )
    dup 0 number= [ hang-1 ] unless ; inline recursive

[ ] [ [ 3 hang-1 ] final-info drop ] unit-test

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

[ ] [ [ 3 over hang-2 ] final-info drop ] unit-test

[ ] [
    [
        dup fixnum? [ 3 over hang-2 ] [ 3 over hang-2 ] if
    ] final-info drop
] unit-test

[ V{ word } ] [
    [ { hashtable } declare hashtable instance? ] final-classes
] unit-test

[ V{ POSTPONE: f } ] [
    [ { vector } declare hashtable instance? ] final-classes
] unit-test

[ V{ object } ] [
    [ { assoc } declare hashtable instance? ] final-classes
] unit-test

[ V{ word } ] [
    [ { string } declare string? ] final-classes
] unit-test

[ V{ POSTPONE: f } ] [
    [ 3 string? ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum } declare [ ] curry obj>> ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum fixnum } declare [ nth-unsafe ] curry call ] final-classes
] unit-test

[ V{ f } ] [
    [ 10 eq? [ drop 3 ] unless ] final-literals
] unit-test

GENERIC: bad-generic ( a -- b )
M: fixnum bad-generic 1 fixnum+fast ;
: bad-behavior ( -- b ) 4 bad-generic ; inline recursive

[ V{ fixnum } ] [ [ bad-behavior ] final-classes ] unit-test

[ V{ number } ] [
    [
        0 10 [ bad-generic dup 123 bitand drop bad-generic 1 + ] times
    ] final-classes
] unit-test

GENERIC: infinite-loop ( a -- b )
M: integer infinite-loop infinite-loop ;

[ ] [ [ { integer } declare infinite-loop ] final-classes drop ] unit-test

[ V{ tuple } ] [ [ tuple-layout <tuple> ] final-classes ] unit-test

[ ] [ [ instance? ] final-classes drop ] unit-test

[ f ] [ [ V{ } clone ] final-info first literal?>> ] unit-test

: fold-throw-test ( a -- b ) "A" throw ; foldable

[ ] [ [ 0 fold-throw-test ] final-info drop ] unit-test

: too-deep ( a b -- c )
    dup [ drop ] [ 2dup too-deep too-deep * ] if ; inline recursive

[ ] [ [ too-deep ] final-info drop ] unit-test

[ ] [ [ reversed boa slice boa nth-unsafe * ] final-info drop ] unit-test

MIXIN: empty-mixin

[ ] [ [ { empty-mixin } declare empty-mixin? ] final-info drop ] unit-test

[ V{ fixnum } ] [ [ [ bignum-shift drop ] keep ] final-classes ] unit-test

[ V{ float } ] [
    [
        [ { float float } declare <complex> ]
        [ 2drop C{ 0.0 0.0 } ]
        if real-part
    ] final-classes
] unit-test

[ V{ POSTPONE: f } ] [
    [ { float } declare 0 eq? ] final-classes
] unit-test

[ V{ integer } ] [
    [ { integer fixnum } declare mod ] final-classes
] unit-test

[ V{ integer } ] [
    [ { fixnum integer } declare bitand ] final-classes
] unit-test

[ V{ double-array } ] [ [| | double-array{ } ] final-classes ] unit-test

[ V{ t } ] [ [ netbsd unix? ] final-literals ] unit-test

[ V{ array } ] [ [ [ <=> ] sort [ <=> ] sort ] final-classes ] unit-test

[ V{ float } ] [ [ fsqrt ] final-classes ] unit-test

[ V{ t } ] [ [ { fixnum } declare 10 mod >float -20 > ] final-literals ] unit-test

[ T{ interval f { 0 t } { 127 t } } ] [
    [ { integer } declare 127 bitand ] final-info first interval>>
] unit-test

[ V{ bignum } ] [
    [ { bignum } declare dup 1- bitxor ] final-classes
] unit-test

[ V{ bignum integer } ] [
    [ { bignum integer } declare [ shift ] keep ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum } declare log2 ] final-classes
] unit-test

[ V{ word } ] [
    [ { fixnum } declare log2 0 >= ] final-classes
] unit-test

[ V{ POSTPONE: f } ] [
    [ { word object } declare equal? ] final-classes
] unit-test

! [ V{ string } ] [
!     [ dup string? t xor [ "A" throw ] [ ] if ] final-classes
! ] unit-test

! [ t ] [ [ dup t xor or ] final-classes first true-class? ] unit-test

! [ t ] [ [ dup t xor swap or ] final-classes first true-class? ] unit-test

! [ t ] [ [ dup t xor and ] final-classes first false-class? ] unit-test

! [ t ] [ [ dup t xor swap and ] final-classes first false-class? ] unit-test

! generalize-counter-interval wasn't being called in all the right places.
! bug found by littledan

TUPLE: littledan-1 { a read-only } ;

: (littledan-1-test) ( a -- ) a>> 1+ littledan-1 boa (littledan-1-test) ; inline recursive

: littledan-1-test ( -- ) 0 littledan-1 boa (littledan-1-test) ; inline

[ ] [ [ littledan-1-test ] final-classes drop ] unit-test

TUPLE: littledan-2 { from read-only } { to read-only } ;

: (littledan-2-test) ( x -- i elt )
    [ from>> ] [ to>> ] bi + dup littledan-2 boa (littledan-2-test) ; inline recursive

: littledan-2-test ( x -- i elt )
    [ 0 ] dip { array-capacity } declare littledan-2 boa (littledan-2-test) ; inline

[ ] [ [ littledan-2-test ] final-classes drop ] unit-test

: (littledan-3-test) ( x -- )
    length 1+ f <array> (littledan-3-test) ; inline recursive

: littledan-3-test ( -- )
    0 f <array> (littledan-3-test) ; inline

[ ] [ [ littledan-3-test ] final-classes drop ] unit-test

[ V{ 0 } ] [ [ { } length ] final-literals ] unit-test

[ V{ 1 } ] [ [ { } length 1+ f <array> length ] final-literals ] unit-test
