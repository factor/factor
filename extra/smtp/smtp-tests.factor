USING: smtp tools.test io.streams.string io.logging threads
smtp.server kernel sequences namespaces ;
IN: temporary

{ 0 0 } [ [ ] with-smtp-connection ] must-infer-as

[ "hello\nworld" validate-address ] must-fail

[ "slava@factorcode.org" ]
[ "slava@factorcode.org" validate-address ] unit-test

[ { "hello" "." "world" } validate-message ] must-fail

[ "hello\r\nworld\r\n.\r\n" ] [
    { "hello" "world" } [ send-body ] string-out
] unit-test

[
    [
        "500 syntax error" check-response
    ] with-log-stdio
] must-fail

[ ] [
    [
        "220 success" check-response
    ] with-log-stdio
] unit-test

[ "220 success" ] [
    "220 success" [ receive-response ] string-in
] unit-test

[ "220 the end" ] [
    [
        "220-a multiline response\r\n250-another line\r\n220 the end"
        [ receive-response ] string-in
    ] with-log-stdio
] unit-test

[ ] [
    [
        "220-a multiline response\r\n250-another line\r\n220 the end"
        [ get-ok ] string-in
    ] with-log-stdio
] unit-test

[
    "Subject:\r\nsecurity hole" validate-header
] must-fail

[
    V{
        { "To" "Slava <slava@factorcode.org>, Ed <dharmatech@factorcode.org>" }
        { "From" "Doug <erg@factorcode.org>" }
        { "Subject" "Factor rules" }
    }
    { "slava@factorcode.org" "dharmatech@factorcode.org" }
    "erg@factorcode.org"
] [
    "Factor rules"
    {
        "Slava <slava@factorcode.org>"
        "Ed <dharmatech@factorcode.org>"
    }
    "Doug <erg@factorcode.org>"
    simple-headers >r >r 2 head* r> r>
] unit-test

[
    {
        "To: Slava <slava@factorcode.org>, Ed <dharmatech@factorcode.org>"
        "From: Doug <erg@factorcode.org>"
        "Subject: Factor rules"
        f
        f
        " "
        "Hi guys"
        "Bye guys"
    }
    { "slava@factorcode.org" "dharmatech@factorcode.org" }
    "erg@factorcode.org"
] [
    "Hi guys\nBye guys"
    "Factor rules"
    {
        "Slava <slava@factorcode.org>"
        "Ed <dharmatech@factorcode.org>"
    }
    "Doug <erg@factorcode.org>"
    prepare-simple-message
    >r >r f 3 pick set-nth f 4 pick set-nth r> r>
] unit-test

[ ] [ [ 4321 smtp-server ] in-thread ] unit-test

[ ] [
    [
        4321 smtp-port set

        "Hi guys\nBye guys"
        "Factor rules"
        {
            "Slava <slava@factorcode.org>"
            "Ed <dharmatech@factorcode.org>"
        }
        "Doug <erg@factorcode.org>"

        send-simple-message
    ] with-scope
] unit-test