IN: validators.tests
USING: kernel sequences tools.test validators accessors ;

[ "foo" v-number ] must-fail
[ 123 ] [ "123" v-number ] unit-test

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

[ 14 V{ } ] [
    [
        "14" "age" [ drop v-number 13 v-min-value 100 v-max-value ] validate
    ] with-validation
] unit-test

[ f t ] [
    [
        "140" "age" [ drop v-number 13 v-min-value 100 v-max-value ] validate
    ] with-validation first
    [ first "age" = ]
    [ second validation-error? ]
    [ second value>> "140" = ]
    tri and and
] unit-test

TUPLE: person name age ;

person {
    { "name" [ v-required ] }
    { "age" [ v-number 13 v-min-value 100 v-max-value ] }
} define-validators

[ 14 V{ } ] [
    [
        person new dup
        { { "age" "14" } }
        deposit-slots
        age>>
    ] with-validation
] unit-test

[ t ] [
    [
        { { "age" "" } } required-values
    ] with-validation first
    [ first "age" = ]
    [ second validation-error? ]
    [ second message>> "required" = ]
    tri and and
] unit-test
