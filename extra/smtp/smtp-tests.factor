USING: smtp tools.test io.streams.string io.sockets threads
smtp.server kernel sequences namespaces logging accessors
assocs sorting ;
IN: smtp.tests

{ 0 0 } [ [ ] with-smtp-connection ] must-infer-as

[ "hello\nworld" validate-address ] must-fail

[ "slava@factorcode.org" ]
[ "slava@factorcode.org" validate-address ] unit-test

[ { "hello" "." "world" } validate-message ] must-fail

[ "hello\r\nworld\r\n.\r\n" ] [
    "hello\nworld" [ send-body ] with-string-writer
] unit-test

[ "500 syntax error" check-response ] must-fail

[ ] [ "220 success" check-response ] unit-test

[ "220 success" ] [
    "220 success" [ receive-response ] with-string-reader
] unit-test

[ "220 the end" ] [
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
        { "From" "Doug <erg@factorcode.org>" }
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
    prepare
    dup headers>> >alist sort-keys [
        drop { "Date" "Message-Id" } member? not
    ] assoc-subset
    over to>>
    rot from>>
] unit-test

[ ] [ [ 4321 mock-smtp-server ] in-thread ] unit-test

[ ] [
    [
        "localhost" 4321 <inet> smtp-server set

        <email>
            "Hi guys\nBye guys" >>body
            "Factor rules" >>subject
            {
                "Slava <slava@factorcode.org>"
                "Ed <dharmatech@factorcode.org>"
            } >>to
            "Doug <erg@factorcode.org>" >>from
        send-email
    ] with-scope
] unit-test
