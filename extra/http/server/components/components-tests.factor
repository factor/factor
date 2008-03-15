IN: http.server.components.tests
USING: http.server.components http.server.validators
namespaces tools.test kernel accessors new-slots
tuple-syntax mirrors http.server.actions ;

validation-failed? off

[ 3 ] [ "3" "n" <number> validate ] unit-test

[ 123 ] [
    ""
    "n" <number>
        123 >>default
    validate
] unit-test

[ f ] [ validation-failed? get ] unit-test

[ t ] [ "3x" "n" <number> validate validation-error? ] unit-test

[ t ] [ validation-failed? get ] unit-test

[ "" ] [ "" "email" <email> validate ] unit-test

[ "slava@jedit.org" ] [ "slava@jedit.org" "email" <email> validate ] unit-test

[ "slava@jedit.org" ] [
    "slava@jedit.org"
    "email" <email>
        t >>required
    validate
] unit-test

[ t ] [
    "a"
    "email" <email>
        t >>required
    validate validation-error?
] unit-test

[ t ] [ "a" "email" <email> validate validation-error? ] unit-test

TUPLE: test-tuple text number more-text ;

: <test-tuple> test-tuple construct-empty ;

: <test-form> ( -- form )
    "test" <form>
        "resource:extra/http/server/components/test/form.fhtml" >>view-template
        "resource:extra/http/server/components/test/form.fhtml" >>edit-template
        "text" <string>
            t >>required
            add-field
        "number" <number>
            123 >>default
            t >>required
            0 >>min-value
            10 >>max-value
            add-field
        "more-text" <text>
            "hi" >>default
            add-field ;

[ ] [ <test-tuple> <mirror> values set <test-form> view-form ] unit-test

[ ] [ <test-tuple> <mirror> values set <test-form> edit-form ] unit-test

[ TUPLE{ test-tuple number: 123 more-text: "hi" } ] [
    <test-tuple> from-tuple
    <test-form> set-defaults
    values-tuple
] unit-test

[
    H{
        { "text" "fdafsa" }
        { "number" "xxx" }
        { "more-text" "" }
    } params set

    H{ } clone values set

    [ t ] [ <test-form> (validate-form) ] unit-test

    [ "fdafsa" ] [ "text" value ] unit-test

    [ t ] [ "number" value validation-error? ] unit-test
] with-scope

[
    [ ] [
        "n" <number>
            0 >>min-value
            10 >>max-value
        "n" set
    ] unit-test

    [ "123" ] [
        "123" "n" get validate value>>
    ] unit-test
] with-scope
