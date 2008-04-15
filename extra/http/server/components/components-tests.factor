IN: http.server.components.tests
USING: http.server.components http.server.forms
http.server.validators namespaces tools.test kernel accessors
tuple-syntax mirrors http.server.actions
http.server.templating.fhtml
io.streams.string io.streams.null ;

\ render-edit must-infer

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

: <test-tuple> test-tuple new ;

: <test-form> ( -- form )
    "test" <form>
        "resource:extra/http/server/components/test/form.fhtml" <fhtml> >>view-template
        "resource:extra/http/server/components/test/form.fhtml" <fhtml> >>edit-template
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
    
    [ ] [ "i" <integer> "i" set ] unit-test

    [ 3 ] [
        "3" "i" get validate
    ] unit-test
    
    [ t ] [
        "3.9" "i" get validate validation-error?
    ] unit-test

    H{ } clone values set

    [ ] [ 3 "i" set-value ] unit-test

    [ "3" ] [ [ "i" get render-view ] with-string-writer ] unit-test

    [ ] [ [ "i" get render-edit ] with-null-stream ] unit-test

    [ ] [ "t" <text> "t" set ] unit-test

    [ ] [ "hello world" "t" set-value ] unit-test

    [ ] [ [ "t" get render-edit ] with-null-stream ] unit-test
] with-scope

[ t ] [ "wake up sheeple" dup "n" <text> validate = ] unit-test

[ ] [ "password" <password> "p" set ] unit-test
