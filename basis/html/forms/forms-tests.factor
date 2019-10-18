USING: kernel sequences tools.test assocs html.forms validators accessors
namespaces ;
FROM: html.forms => values ;
IN: html.forms.tests

: with-validation ( quot -- messages )
    [
        begin-form
        call
    ] with-scope ; inline

{ 14 } [
    [
        "14" [ v-number 13 v-min-value 100 v-max-value ] validate
    ] with-validation
] unit-test

{ t } [
    [
        "140" [ v-number 13 v-min-value 100 v-max-value ] validate
        [ validation-error-state? ]
        [ value>> "140" = ]
        bi and
    ] with-validation
] unit-test

TUPLE: person name age ;

person {
    { "name" [ ] }
    { "age" [ v-number 13 v-min-value 100 v-max-value ] }
} define-validators

{ t t } [
    [
        { { "age" "" } }
        { { "age" [ v-required ] } }
        validate-values
        validation-failed?
        "age" value
        [ validation-error-state? ]
        [ message>> "required" = ]
        bi and
    ] with-validation
] unit-test

{ H{ { "a" 123 } } f } [
    [
        H{
            { "a" "123" }
            { "b" "c" }
            { "c" "d" }
        }
        H{
            { "a" [ v-integer ] }
        } validate-values
        values
        validation-failed?
    ] with-validation
] unit-test

{ t "foo" } [
    [
        "foo" validation-error
        validation-failed?
        form get errors>> first
    ] with-validation
] unit-test
