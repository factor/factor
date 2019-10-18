USING: kernel sequences namespaces math tools.test furnace furnace.validator ;
IN: temporary

TUPLE: test-tuple m n ;

[ H{ { "m" 3 } { "n" 2 } } ]
[
    [ T{ test-tuple f 3 2 } explode-tuple ] H{ } make-assoc
] unit-test

[
    { 3 }
] [
    H{ { "n" "3" } } { { "n" v-number } }
    [ action-param drop ] curry* map
] unit-test

: foo ;

\ foo { { "foo" "2" v-default } { "bar" v-required } } define-action

[ t ] [ [ 1 2 foo ] action-call? ] unit-test
[ f ] [ [ 2 + ] action-call? ] unit-test

[
    { "2" "hello" }
] [
    [
        H{
            { "bar" "hello" }
        } \ foo query>quot
    ] with-scope
] unit-test

[
    H{ { "foo" "1" } { "bar" "2" } }
] [
    { "1" "2" } \ foo quot>query
] unit-test

[
    "/responder/temporary/foo?foo=3"
] [
    [
        [ "3" foo ] quot-link
    ] with-scope
] unit-test
