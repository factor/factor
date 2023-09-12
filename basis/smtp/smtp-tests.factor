USING: accessors assocs calendar combinators concurrency.promises
continuations fry io.sockets io.sockets.secure io.streams.string
kernel namespaces sequences smtp smtp.private smtp.server
sorting system tools.test ;
IN: smtp.tests

: with-test-smtp-config ( quot -- )
    [
        <promise> "p" set
        "p" get mock-smtp-server

        default-smtp-config
            "localhost" "p" get 5 seconds ?promise-timeout <inet> >>server
            no-auth >>auth
            os unix? [ t >>tls? ] when
        \ smtp-config
    ] dip with-variable ; inline

{ 0 0 } [ [ ] with-smtp-connection ] must-infer-as

[ "hello\nworld" validate-address ] must-fail

{ "slava@factorcode.org" }
[ "slava@factorcode.org" validate-address ] unit-test

{ "aGVsbG8Kd29ybGQ=\r\n.\r\n" } [
    T{ email { body "hello\nworld" } } [ send-body ] with-string-writer
] unit-test

[ { "500 syntax error" } <response> check-response ]
[ smtp-error? ] must-fail-with

{ } [ { "220 success" } <response> check-response ] unit-test

{ T{ response f 220 { "220 success" } } } [
    "220 success" [ receive-response ] with-string-reader
] unit-test

{
    T{ response f 220 {
        "220-a multiline response"
        "250-another line"
        "220 the end"
    } }
} [
    "220-a multiline response\r\n250-another line\r\n220 the end"
    [ receive-response ] with-string-reader
] unit-test

{ } [
    "220-a multiline response\r\n250-another line\r\n220 the end"
    [ get-ok ] with-string-reader
] unit-test

[
    "Subject:\r\nsecurity hole" validate-header
] must-fail

{
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
} [
    [
        <email>
            "Factor rules" >>subject
            {
                "Slava <slava@factorcode.org>"
                "Ed <dharmatech@factorcode.org>"
            } >>to
            "Doug <erg@factorcode.org>" >>from
        {
            [
                email>headers sort-keys [
                    { "Date" "Message-Id" } member? not
                ] filter-keys
            ]
            [ to>> [ extract-email ] map ]
            [ from>> extract-email ]
            ! To get the smtp server to clean up itself
            [ '[ _ send-email ] ignore-errors ]
        } cleave
    ] with-test-smtp-config
] unit-test

{ } [
    <secure-config> f >>verify [
        [
            <email>
                "Hi guys\nBye guys" >>body
                "Factor rules" >>subject
                {
                    "Slava <slava@factorcode.org>"
                    "Ed <dharmatech@factorcode.org>"
                } >>to
                "Doug <erg@factorcode.org>" >>from
            send-email
        ] with-test-smtp-config
    ] with-secure-context
] unit-test
