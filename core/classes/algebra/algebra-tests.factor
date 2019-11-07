USING: accessors arrays assocs classes classes.algebra
classes.tuple classes.union generic generic.private growable
kernel math prettyprint quotations random sbufs sequences
stack-checker strings tools.test vectors words ;
IN: classes.algebra.tests

TUPLE: first-one ;
TUPLE: second-one ;
UNION: both first-one union-class ;

PREDICATE: no-docs < word "documentation" word-prop not ;

UNION: no-docs-union no-docs integer ;

TUPLE: a ;
TUPLE: b ;
UNION: c a b ;

TUPLE: tuple-example ;

TUPLE: a1 ;
TUPLE: b1 ;
TUPLE: c1 ;

UNION: x1 a1 b1 ;
UNION: y1 a1 c1 ;
UNION: z1 b1 c1 ;

SINGLETON: sa
SINGLETON: sb
SINGLETON: sc

INTERSECTION: empty-intersection ;

INTERSECTION: generic-class generic class ;

UNION: union-with-one-member a ;

MIXIN: mixin-with-one-member
INSTANCE: union-with-one-member mixin-with-one-member

! class<=
{ t } [ \ fixnum \ integer class<= ] unit-test
{ t } [ \ fixnum \ fixnum class<= ] unit-test
{ f } [ \ integer \ fixnum class<= ] unit-test
{ t } [ \ integer \ object class<= ] unit-test
{ f } [ \ integer \ null class<= ] unit-test
{ t } [ \ null \ object class<= ] unit-test

{ t } [ \ generic \ word class<= ] unit-test
{ f } [ \ word \ generic class<= ] unit-test

{ f } [ \ reversed \ slice class<= ] unit-test
{ f } [ \ slice \ reversed class<= ] unit-test

{ t } [ no-docs no-docs-union class<= ] unit-test
{ f } [ no-docs-union no-docs class<= ] unit-test

{ t } [ \ c \ tuple class<= ] unit-test
{ f } [ \ tuple \ c class<= ] unit-test

{ t } [ \ tuple-class \ class class<= ] unit-test
{ f } [ \ class \ tuple-class class<= ] unit-test

{ t } [ \ null \ tuple-example class<= ] unit-test
{ f } [ \ object \ tuple-example class<= ] unit-test
{ f } [ \ object \ tuple-example class<= ] unit-test
{ t } [ \ tuple-example \ tuple class<= ] unit-test
{ f } [ \ tuple \ tuple-example class<= ] unit-test

{ f } [ z1 x1 y1 class-and class<= ] unit-test

{ t } [ x1 y1 class-and a1 class<= ] unit-test

{ f } [ b1 c1 class-or a1 b1 class-or a1 c1 class-and class-and class<= ] unit-test

{ t } [ a1 b1 class-or a1 c1 class-or class-and a1 class<= ] unit-test

{ f } [ growable tuple sequence class-and class<= ] unit-test

{ f } [ growable assoc class-and tuple class<= ] unit-test

{ t } [ object \ f \ f class-not class-or class<= ] unit-test

{ t } [ fixnum class-not integer class-and bignum class= ] unit-test

{ t } [ array number class-not class<= ] unit-test

{ f } [ bignum number class-not class<= ] unit-test

{ t } [ fixnum fixnum bignum class-or class<= ] unit-test

{ f } [ fixnum class-not integer class-and array class<= ] unit-test

{ f } [ fixnum class-not integer class<= ] unit-test

{ f } [ number class-not array class<= ] unit-test

{ f } [ fixnum class-not array class<= ] unit-test

{ t } [ number class-not integer class-not class<= ] unit-test

{ f } [ fixnum class-not integer class<= ] unit-test

{ t } [ object empty-intersection class<= ] unit-test
{ t } [ empty-intersection object class<= ] unit-test
{ t } [ \ f class-not empty-intersection class<= ] unit-test
{ f } [ empty-intersection \ f class-not class<= ] unit-test
{ t } [ \ number empty-intersection class<= ] unit-test
{ t } [ empty-intersection class-not null class<= ] unit-test
{ t } [ null empty-intersection class-not class<= ] unit-test

{ t } [ \ f class-not \ f class-or empty-intersection class<= ] unit-test
{ t } [ empty-intersection \ f class-not \ f class-or class<= ] unit-test

{ t } [ object \ f class-not \ f class-or class<= ] unit-test

{ t } [
    fixnum class-not
    fixnum fixnum class-not class-or
    class<=
] unit-test

{ t } [ generic-class generic class<= ] unit-test
{ t } [ generic-class \ class class<= ] unit-test

{ t } [ a union-with-one-member class<= ] unit-test
{ f } [ union-with-one-member class-not integer class<= ] unit-test

MIXIN: empty-mixin

{ f } [ empty-mixin class-not null class<= ] unit-test
{ f } [ empty-mixin null class<= ] unit-test

{ t } [ empty-mixin class-not object class<= ] unit-test
{ t } [ empty-mixin object class<= ] unit-test

{ t } [ empty-mixin class-not object class<= ] unit-test
{ t } [ empty-mixin object class<= ] unit-test

{ t } [ object empty-mixin class-not class<= ] unit-test

{ t } [ array sequence vector class-not class-and class<= ] unit-test
{ f } [ vector sequence vector class-not class-and class<= ] unit-test

! class-and
: class-and* ( cls1 cls2 cls3 -- ? ) [ class-and ] dip class= ;

{ t } [ object  object  object class-and* ] unit-test
{ t } [ fixnum  object  fixnum class-and* ] unit-test
{ t } [ object  fixnum  fixnum class-and* ] unit-test
{ t } [ fixnum  fixnum  fixnum class-and* ] unit-test
{ t } [ fixnum  integer fixnum class-and* ] unit-test
{ t } [ integer fixnum  fixnum class-and* ] unit-test

{ t } [ vector    fixnum   null   class-and* ] unit-test
{ t } [ number    object   number class-and* ] unit-test
{ t } [ object    number   number class-and* ] unit-test
{ t } [ slice     reversed null   class-and* ] unit-test
{ t } [ \ f class-not \ f      null   class-and* ] unit-test

{ t } [ vector array class-not vector class-and* ] unit-test

{ object } [ object empty-mixin class-not class-and ] unit-test
{ object } [ empty-mixin class-not object class-and ] unit-test

! class-or
: class-or* ( cls1 cls2 cls3 -- ? ) [ class-or ] dip class= ;

{ t } [ \ f class-not \ f      object class-or*  ] unit-test

{ object } [ object empty-mixin class-not class-or ] unit-test
{ object } [ empty-mixin class-not object class-or ] unit-test

! class-not
{ vector } [ vector class-not class-not ] unit-test

! classes-intersect?
{ t } [ both tuple classes-intersect? ] unit-test
{ t } [ tuple both classes-intersect? ] unit-test

{ f } [ vector virtual-sequence classes-intersect? ] unit-test
{ f } [ virtual-sequence vector classes-intersect? ] unit-test

{ t } [ number vector class-or sequence classes-intersect? ] unit-test
{ t } [ sequence number vector class-or classes-intersect? ] unit-test

{ f } [ number vector class-and sequence classes-intersect? ] unit-test
{ f } [ sequence number vector class-and classes-intersect? ] unit-test

{ f } [ y1 z1 class-and x1 classes-intersect? ] unit-test
{ f } [ x1 y1 z1 class-and classes-intersect? ] unit-test

{ f } [ a1 c1 class-or b1 c1 class-or class-and a1 b1 class-or classes-intersect? ] unit-test
{ f } [ a1 b1 class-or a1 c1 class-or b1 c1 class-or class-and classes-intersect? ] unit-test

{ f } [ integer integer class-not classes-intersect? ] unit-test
{ f } [ integer class-not integer classes-intersect? ] unit-test

{ f } [ fixnum class-not number class-and array classes-intersect? ] unit-test
{ f } [ array fixnum class-not number class-and classes-intersect? ] unit-test

{ t } [ \ word generic-class classes-intersect? ] unit-test
{ t } [ generic-class \ word classes-intersect? ] unit-test
{ f } [ number generic-class classes-intersect? ] unit-test
{ f } [ generic-class number classes-intersect? ] unit-test

{ f } [ sa sb classes-intersect? ] unit-test
{ f } [ sb sa classes-intersect? ] unit-test

{ t } [ a union-with-one-member classes-intersect? ] unit-test
{ f } [ fixnum union-with-one-member classes-intersect? ] unit-test
{ t } [ object union-with-one-member classes-intersect? ] unit-test

{ t } [ union-with-one-member a classes-intersect? ] unit-test
{ f } [ union-with-one-member fixnum classes-intersect? ] unit-test
{ t } [ union-with-one-member object classes-intersect? ] unit-test

{ t } [ a mixin-with-one-member classes-intersect? ] unit-test
{ f } [ fixnum mixin-with-one-member classes-intersect? ] unit-test
{ t } [ object mixin-with-one-member classes-intersect? ] unit-test

{ t } [ mixin-with-one-member a classes-intersect? ] unit-test
{ f } [ mixin-with-one-member fixnum classes-intersect? ] unit-test
{ t } [ mixin-with-one-member object classes-intersect? ] unit-test

{ f } [ null object classes-intersect? ] unit-test
{ f } [ object null classes-intersect? ] unit-test

{ t } [ null class-not object class= ] unit-test

{ t } [ object class-not null class= ] unit-test

{ f } [ object class-not object class= ] unit-test

{ f } [ null class-not null class= ] unit-test

! smallest-class etc
{ real } [ { real sequence } smallest-class ] unit-test
{ real } [ { sequence real } smallest-class ] unit-test

: min-class ( class classes -- class/f )
    interesting-classes smallest-class ;

{ f } [ fixnum { } min-class ] unit-test

{ string } [
    \ string
    [ integer string array reversed sbuf
    slice vector quotation ]
    sort-classes min-class
] unit-test

{ fixnum } [
    \ fixnum
    [ fixnum integer object ]
    sort-classes min-class
] unit-test

{ integer } [
    \ fixnum
    [ integer float object ]
    sort-classes min-class
] unit-test

{ object } [
    \ word
    [ integer float object ]
    sort-classes min-class
] unit-test

{ reversed } [
    \ reversed
    [ integer reversed slice ]
    sort-classes min-class
] unit-test

{ f } [ null { number fixnum null } min-class ] unit-test

! Test for hangs?
: random-class ( -- class ) classes random ;

: random-op ( -- word )
    {
        class-and
        class-or
        class-not
    } random ;

10 [
    [ ] [
        20 [ random-op ] [ ] replicate-as
        [ infer in>> length [ random-class ] times ] keep
        call
        drop
    ] unit-test
] times

: random-boolean ( -- ? )
    { t f } random ;

: boolean>class ( ? -- class )
    object null ? ;

: random-boolean-op ( -- word )
    {
        and
        or
        not
        xor
    } random ;

: class-xor ( cls1 cls2 -- cls3 )
    [ class-or ] 2keep class-and class-not class-and ;

: boolean-op>class-op ( word -- word' )
    {
        { and class-and }
        { or class-or }
        { not class-not }
        { xor class-xor }
    } at ;

20 [
    [ t ] [
        20 [ random-boolean-op ] [ ] replicate-as dup .
        [ infer in>> length [ random-boolean ] replicate dup . ] keep

        [ [ [ ] each ] dip call ] 2keep

        [ [ boolean>class ] each ] dip [ boolean-op>class-op ] map call object class=

        =
    ] unit-test
] times

SINGLETON: xxx
UNION: yyy xxx ;

{ { yyy xxx } } [ { xxx yyy } sort-classes ] unit-test
{ { yyy xxx } } [ { yyy xxx } sort-classes ] unit-test

{ { number ratio integer } } [ { ratio number integer } sort-classes ] unit-test
{ { sequence number ratio } } [ { ratio number sequence } sort-classes ] unit-test

TUPLE: xa ;
TUPLE: xb ;
TUPLE: xc < xa ;
TUPLE: xd < xb ;
TUPLE: xe ;
TUPLE: xf < xb ;
TUPLE: xg < xb ;
TUPLE: xh < xb ;

{ t } [ { xa xb xc xd xe xf xg xh } sort-classes dup sort-classes = ] unit-test

{ { word } } [
    generic-class flatten-class
] unit-test

{ sa } [ sa { sa sb sc } min-class ] unit-test

[ \ + flatten-class ] must-fail
