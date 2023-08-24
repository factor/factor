USING: assocs classes classes.private compiler.units definitions
eval generic io.streams.string kernel math multiline namespaces
parser sequences sets sorting tools.test vocabs words ;
IN: classes.tests

{ t } [ 3 object instance? ] unit-test
{ t } [ 3 fixnum instance? ] unit-test
{ f } [ 3 float instance? ] unit-test
{ t } [ 3 number instance? ] unit-test
{ f } [ 3 null instance? ] unit-test

! Regression
GENERIC: method-forget-test ( obj -- obj )
TUPLE: method-forget-class ;
M: method-forget-class method-forget-test ;

{ f } [ \ method-forget-test "methods" word-prop assoc-empty? ] unit-test
{ } [ [ \ method-forget-class forget ] with-compilation-unit ] unit-test
{ t } [ \ method-forget-test "methods" word-prop assoc-empty? ] unit-test

{ { } { } } [
    all-words [ class? ] filter
    implementors-map get keys
    [ sort ] bi@
    [ diff ] [ swap diff ] 2bi
] unit-test

! Long-standing problem
USE: multiline

! So the user has some code...
{ } [
    "IN: classes.test.a
    GENERIC: g ( a -- b )
    TUPLE: x ;
    M: x g ;
    TUPLE: z < x ;" <string-reader>
    "class-intersect-no-method-a" parse-stream drop
] unit-test

! Note that q inlines M: x g ;
{ } [
    "IN: classes.test.b
    USE: classes.test.a
    USE: kernel
    : q ( -- b ) z new g ;" <string-reader>
    "class-intersect-no-method-b" parse-stream drop
] unit-test

! Now, the user removes the z class and adds a method,
{ } [
    "IN: classes.test.a
    GENERIC: g ( a -- b )
    TUPLE: x ;
    M: x g ;
    TUPLE: j ;
    M: j g ;" <string-reader>
    "class-intersect-no-method-a" parse-stream drop
] unit-test

! And changes the definition of q
{ } [
    "IN: classes.test.b
    USE: classes.test.a
    USE: kernel
    : q ( -- b ) j new g ;" <string-reader>
    "class-intersect-no-method-b" parse-stream drop
] unit-test

! Similar problem, but with anonymous classes
{ } [
    "IN: classes.test.c
    USE: kernel
    GENERIC: g ( a -- b )
    M: object g ;
    TUPLE: z ;" <string-reader>
    "class-intersect-no-method-c" parse-stream drop
] unit-test

{ } [
    "IN: classes.test.d
    USE: classes.test.c
    USE: kernel
    : q ( a -- b ) dup z? [ g ] unless ;" <string-reader>
    "class-intersect-no-method-d" parse-stream drop
] unit-test

! Now, the user removes the z class and adds a method,
{ } [
    "IN: classes.test.c
    USE: kernel
    GENERIC: g ( a -- b )
    M: object g ;
    TUPLE: j ;
    M: j g ;" <string-reader>
    "class-intersect-no-method-c" parse-stream drop
] unit-test

! Forget the above crap
[
    { "classes.test.a" "classes.test.b" "classes.test.c" "classes.test.d" }
    [ forget-vocab ] each
] with-compilation-unit

TUPLE: forgotten-predicate-test ;

{ } [ [ \ forgotten-predicate-test forget ] with-compilation-unit ] unit-test
{ f } [ \ forgotten-predicate-test? predicate? ] unit-test

GENERIC: generic-predicate? ( a -- b )

{ } [ "IN: classes.tests TUPLE: generic-predicate ;" eval( -- ) ] unit-test

{ f } [ \ generic-predicate? generic? ] unit-test

! all-contained-classes
{
    { maybe{ integer } integer fixnum bignum }
} [
    { maybe{ integer } } all-contained-classes
] unit-test

! contained-classes
{
    { fixnum bignum }
    { integer }
} [
    integer contained-classes
    maybe{ integer } contained-classes
] unit-test

! make-class-props
{
    H{
        { "superclass" f }
        { "members" { fixnum } }
        { "metaclass" f }
        { "participants" { } }
    }
} [
    f { fixnum } { } f  make-class-props
] unit-test

{ "test" } [ "test" sequence check-instance ] unit-test
[ "test" fixnum check-instance ] [ not-an-instance? ] must-fail-with
