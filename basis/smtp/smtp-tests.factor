USING: smtp tools.test io.streams.string io.sockets
io.sockets.secure threads smtp.server kernel sequences
namespaces logging accessors assocs sorting smtp.private
concurrency.promises system ;
IN: smtp.tests

\ send-email must-infer

{ 0 0 } [ [ ] with-smtp-connection ] must-infer-as

[ "hello\nworld" validate-address ] must-fail

[ "slava@factorcode.org" ]
[ "slava@factorcode.org" validate-address ] unit-test

[ { "hello" "." "world" } validate-message ] must-fail

[ "aGVsbG8Kd29ybGQ=\r\n.\r\n" ] [
    T{ email { body "hello\nworld" } } [ send-body ] with-string-writer
] unit-test

[ { "500 syntax error" } <response> check-response ]
[ smtp-error? ] must-fail-with

[ ] [ { "220 success" } <response> check-response ] unit-test

[ T{ response f 220 { "220 success" } } ] [
    "220 success" [ receive-response ] with-string-reader
] unit-test

[
    T{ response f 220 {
        "220-a multiline response"
        "250-another line"
        "220 the end"
    } }
] [
    "220-a multiline response\r\n250-another line\r\n220 the end"
    [ receive-response ] with-string-reader
] unit-test

[ ] [
    "220-a multiline response\r\n250-another line\r\n220 the end"
    [ get-ok ] with-string-reader
] unit-test

[
    "Subject:\r\nsecurity hole" validate-header
] must-fail

[
    {
        { "Content-Transfer-Encoding" "base64" }
        { "Content-Type" "text/plain; charset=UTF-8" }
        { "From" "Doug <erg@factorcode.org>" }
        { "MIME-Version" "1.0" }
        { "Subject" "Factor rules" }
        { "To" "Slava <slava@factorcode.org>, Ed <dharmatech@factorcode.org>" }
    }
    { "slava@factorcode.org" "dharmatech@factorcode.org" }
    "erg@factorcode.org"
] [
    <email>
        "Factor rules" >>subject
        {
            "Slava <slava@factorcode.org>"
            "Ed <dharmatech@factorcode.org>"
        } >>to
        "Doug <erg@factorcode.org>" >>from
    [
        email>headers sort-keys [
            drop { "Date" "Message-Id" } member? not
        ] assoc-filter
    ]
    [ to>> [ extract-email ] map ]
    [ from>> extract-email ] tri
] unit-test

<promise> "p" set

[ ] [ "p" get mock-smtp-server ] unit-test

[ ] [
    <secure-config> f >>verify [
        "localhost" "p" get ?promise <inet> smtp-server set
        no-auth smtp-auth set
        os unix? [ smtp-tls? on ] when

        <email>
            "Hi guys\nBye guys" >>body
            "Factor rules" >>subject
            {
                "Slava <slava@factorcode.org>"
                "Ed <dharmatech@factorcode.org>"
            } >>to
            "Doug <erg@factorcode.org>" >>from
        send-email
    ] with-secure-context
] unit-test
