IN: classes.algebra.tests
USING: alien arrays definitions generic assocs hashtables io
kernel math namespaces parser prettyprint sequences strings
tools.test vectors words quotations classes classes.algebra
classes.private classes.union classes.mixin classes.predicate
vectors definitions source-files compiler.units growable
random inference effects ;

: class= [ class< ] 2keep swap class< and ;

: class-and* >r class-and r> class= ;

: class-or* >r class-or r> class= ;

[ t ] [ object  object  object class-and* ] unit-test
[ t ] [ fixnum  object  fixnum class-and* ] unit-test
[ t ] [ object  fixnum  fixnum class-and* ] unit-test
[ t ] [ fixnum  fixnum  fixnum class-and* ] unit-test
[ t ] [ fixnum  integer fixnum class-and* ] unit-test
[ t ] [ integer fixnum  fixnum class-and* ] unit-test

[ t ] [ vector    fixnum   null   class-and* ] unit-test
[ t ] [ number    object   number class-and* ] unit-test
[ t ] [ object    number   number class-and* ] unit-test
[ t ] [ slice     reversed null   class-and* ] unit-test
[ t ] [ general-t \ f      null   class-and* ] unit-test
[ t ] [ general-t \ f      object class-or*  ] unit-test

TUPLE: first-one ;
TUPLE: second-one ;
UNION: both first-one union-class ;

[ t ] [ both tuple classes-intersect? ] unit-test
[ t ] [ vector virtual-sequence null class-and* ] unit-test
[ f ] [ vector virtual-sequence classes-intersect? ] unit-test

[ t ] [ number vector class-or sequence classes-intersect? ] unit-test

[ f ] [ number vector class-and sequence classes-intersect? ] unit-test

[ t ] [ \ fixnum \ integer class< ] unit-test
[ t ] [ \ fixnum \ fixnum class< ] unit-test
[ f ] [ \ integer \ fixnum class< ] unit-test
[ t ] [ \ integer \ object class< ] unit-test
[ f ] [ \ integer \ null class< ] unit-test
[ t ] [ \ null \ object class< ] unit-test

[ t ] [ \ generic \ word class< ] unit-test
[ f ] [ \ word \ generic class< ] unit-test

[ f ] [ \ reversed \ slice class< ] unit-test
[ f ] [ \ slice \ reversed class< ] unit-test

PREDICATE: no-docs < word "documentation" word-prop not ;

UNION: no-docs-union no-docs integer ;

[ t ] [ no-docs no-docs-union class< ] unit-test
[ f ] [ no-docs-union no-docs class< ] unit-test

TUPLE: a ;
TUPLE: b ;
UNION: c a b ;

[ t ] [ \ c \ tuple class< ] unit-test
[ f ] [ \ tuple \ c class< ] unit-test

[ t ] [ \ tuple-class \ class class< ] unit-test
[ f ] [ \ class \ tuple-class class< ] unit-test

TUPLE: delegate-clone ;

[ t ] [ \ null \ delegate-clone class< ] unit-test
[ f ] [ \ object \ delegate-clone class< ] unit-test
[ f ] [ \ object \ delegate-clone class< ] unit-test
[ t ] [ \ delegate-clone \ tuple class< ] unit-test
[ f ] [ \ tuple \ delegate-clone class< ] unit-test

TUPLE: a1 ;
TUPLE: b1 ;
TUPLE: c1 ;

UNION: x1 a1 b1 ;
UNION: y1 a1 c1 ;
UNION: z1 b1 c1 ;

[ f ] [ z1 x1 y1 class-and class< ] unit-test

[ t ] [ x1 y1 class-and a1 class< ] unit-test

[ f ] [ y1 z1 class-and x1 classes-intersect? ] unit-test

[ f ] [ b1 c1 class-or a1 b1 class-or a1 c1 class-and class-and class< ] unit-test

[ t ] [ a1 b1 class-or a1 c1 class-or class-and a1 class< ] unit-test

[ f ] [ a1 c1 class-or b1 c1 class-or class-and a1 b1 class-or classes-intersect? ] unit-test

[ f ] [ growable hi-tag classes-intersect? ] unit-test

[ t ] [
    growable tuple sequence class-and class<
] unit-test

[ t ] [
    growable assoc class-and tuple class<
] unit-test

[ t ] [ object \ f \ f class-not class-or class< ] unit-test

[ t ] [ fixnum class-not integer class-and bignum class= ] unit-test

[ f ] [ integer integer class-not classes-intersect? ] unit-test

[ t ] [ array number class-not class< ] unit-test

[ f ] [ bignum number class-not class< ] unit-test

[ vector ] [ vector class-not class-not ] unit-test

[ t ] [ fixnum fixnum bignum class-or class< ] unit-test

[ f ] [ fixnum class-not integer class-and array class< ] unit-test

[ f ] [ fixnum class-not integer class< ] unit-test

[ f ] [ number class-not array class< ] unit-test

[ f ] [ fixnum class-not array class< ] unit-test

[ t ] [ number class-not integer class-not class< ] unit-test

[ t ] [ vector array class-not class-and vector class= ] unit-test

[ f ] [ fixnum class-not number class-and array classes-intersect? ] unit-test

[ f ] [ fixnum class-not integer class< ] unit-test

[ t ] [ null class-not object class= ] unit-test

[ t ] [ object class-not null class= ] unit-test

[ f ] [ object class-not object class= ] unit-test

[ f ] [ null class-not null class= ] unit-test

! Test for hangs?
: random-class classes random ;

: random-op
    {
        class-and
        class-or
        class-not
    } random ;

10 [
    [ ] [
        20 [ drop random-op ] map >quotation
        [ infer effect-in [ random-class ] times ] keep
        call
        drop
    ] unit-test
] times

: random-boolean
    { t f } random ;

: boolean>class
    object null ? ;

: random-boolean-op
    {
        and
        or
        not
        xor
    } random ;

: class-xor [ class-or ] 2keep class-and class-not class-and ;

: boolean-op>class-op
    {
        { and class-and }
        { or class-or }
        { not class-not }
        { xor class-xor }
    } at ;

20 [
    [ t ] [
        20 [ drop random-boolean-op ] [ ] map-as dup .
        [ infer effect-in [ drop random-boolean ] map dup . ] keep
        
        [ >r [ ] each r> call ] 2keep
        
        >r [ boolean>class ] each r> [ boolean-op>class-op ] map call object class=
        
        =
    ] unit-test
] times
