IN: validators.tests
USING: kernel sequences tools.test validators accessors
namespaces assocs ;

: with-validation ( quot -- messages )
    [
        init-validation
        call
        validation-messages get
        named-validation-messages get >alist append
    ] with-scope ; inline

[ "" v-one-line ] must-fail
[ "hello world" ] [ "hello world" v-one-line ] unit-test
[ "hello\nworld" v-one-line ] must-fail

[ "" v-one-word ] must-fail
[ "hello" ] [ "hello" v-one-word ] unit-test
[ "hello world" v-one-word ] must-fail

[ "foo" v-number ] must-fail
[ 123 ] [ "123" v-number ] unit-test
[ 123 ] [ "123" v-integer ] unit-test

[ "1.0" v-integer ] [ "must be an integer" = ] must-fail-with

[ "slava@factorcode.org" ] [
    "slava@factorcode.org" v-email
] unit-test

[ "slava+foo@factorcode.org" ] [
    "slava+foo@factorcode.org" v-email
] unit-test

[ "slava@factorcode.o" v-email ]
[ "invalid e-mail" = ] must-fail-with

[ "sla@@factorcode.o" v-email ]
[ "invalid e-mail" = ] must-fail-with

[ "slava@factorcodeorg" v-email ]
[ "invalid e-mail" = ] must-fail-with

[ "http://www.factorcode.org" ]
[ "http://www.factorcode.org" v-url ] unit-test

[ "http:/www.factorcode.org" v-url ]
[ "invalid URL" = ] must-fail-with

[ 4561261212345467 ] [ "4561261212345467" v-credit-card ] unit-test

[ 4561261212345467 ] [ "4561-2612-1234-5467" v-credit-card ] unit-test

[ 0 ] [ "0000000000000000" v-credit-card ] unit-test

[ "000000000" v-credit-card ] must-fail

[ "0000000000000000000000000" v-credit-card ] must-fail

[ "4561_2612_1234_5467" v-credit-card ] must-fail

[ "4561-2621-1234-5467" v-credit-card ] must-fail


[ 14 V{ } ] [
    [
        "14" "age" [ v-number 13 v-min-value 100 v-max-value ] validate
    ] with-validation
] unit-test

[ f t ] [
    [
        "140" "age" [ v-number 13 v-min-value 100 v-max-value ] validate
    ] with-validation first
    [ first "age" = ]
    [ second validation-error? ]
    [ second value>> "140" = ]
    tri and and
] unit-test

TUPLE: person name age ;

person {
    { "name" [ ] }
    { "age" [ v-number 13 v-min-value 100 v-max-value ] }
} define-validators

[ t t ] [
    [
        { { "age" "" } } required-values
        validation-failed?
    ] with-validation first
    [ first "age" = ]
    [ second validation-error? ]
    [ second message>> "required" = ]
    tri and and
] unit-test

[ H{ { "a" 123 } } f V{ } ] [
    [
        H{
            { "a" "123" }
            { "b" "c" }
            { "c" "d" }
        }
        H{
            { "a" [ v-integer ] }
        } validate-values
        validation-failed?
    ] with-validation
] unit-test

[ t "foo" ] [
    [
        "foo" validation-error
        validation-failed?
    ] with-validation first message>>
] unit-test
