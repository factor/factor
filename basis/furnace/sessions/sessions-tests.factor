IN: furnace.sessions.tests
USING: tools.test http furnace.sessions furnace.actions
http.server http.server.responses math namespaces make kernel
accessors io.sockets io.servers.connection prettyprint
io.streams.string io.files io.files.temp io.directories
splitting destructors sequences db db.tuples db.sqlite
continuations urls math.parser furnace furnace.utilities ;

: with-session ( session quot -- )
    [
        [ [ save-session-after ] [ session set ] bi ] dip call
    ] with-destructors ; inline

TUPLE: foo ;

C: <foo> foo

M: foo init-session* drop 0 "x" sset ;

M: foo call-responder*
    2drop
    "x" [ 1+ ] schange
    "x" sget number>string "text/html" <content> ;

: url-responder-mock-test ( -- )
    [
        <request>
            "GET" >>method
            dup url>>
                "id" get session-id-key set-query-param
                "/" >>path drop
        init-request
        { } sessions get call-responder
        [ write-response-body drop ] with-string-writer
    ] with-destructors ;

: sessions-mock-test ( -- )
    [
        <request>
            "GET" >>method
            "cookies" get >>cookies
            dup url>> "/" >>path drop
        init-request
        { } sessions get call-responder
        [ write-response-body drop ] with-string-writer
    ] with-destructors ;

: <exiting-action> ( -- action )
    <action>
        [ [ ] "text/plain" <content> exit-with ] >>display ;

[ "auth-test.db" temp-file delete-file ] ignore-errors

"auth-test.db" temp-file <sqlite-db> [

    <request> init-request
    session ensure-table

    "127.0.0.1" 1234 <inet4> remote-address set

    [ ] [
        <foo> <sessions>
        sessions set
    ] unit-test

    [
        [ ] [
            empty-session
                123 >>id session set
        ] unit-test

        [ ] [ 3 "x" sset ] unit-test

        [ 9 ] [ "x" sget sq ] unit-test

        [ ] [ "x" [ 1- ] schange ] unit-test

        [ 4 ] [ "x" sget sq ] unit-test

        [ t ] [ session get changed?>> ] unit-test
    ] with-scope

    [ t ] [
        begin-session id>>
        get-session session?
    ] unit-test

    [ { 5 0 } ] [
        [
            begin-session
            dup [ 5 "a" sset ] with-session
            dup [ "a" sget , ] with-session
            dup [ "x" sget , ] with-session
            drop
        ] { } make
    ] unit-test

    [ 0 ] [
        begin-session id>>
        get-session [ "x" sget ] with-session
    ] unit-test

    [ { 5 0 } ] [
        [
            begin-session id>>
            dup get-session [ 5 "a" sset ] with-session
            dup get-session [ "a" sget , ] with-session
            dup get-session [ "x" sget , ] with-session
            drop
        ] { } make
    ] unit-test

    [ ] [
        <foo> <sessions>
        sessions set
    ] unit-test

    [
        <request>
            "GET" >>method
            dup url>> "/" >>path drop
        request set
        { "etc" } sessions get call-responder response set
        [ "1" ] [ [ response get write-response-body drop ] with-string-writer ] unit-test
        response get
    ] with-destructors
    response set

    [ ] [ response get cookies>> "cookies" set ] unit-test

    [ "2" ] [ sessions-mock-test ] unit-test
    [ "3" ] [ sessions-mock-test ] unit-test
    [ "4" ] [ sessions-mock-test ] unit-test

    [
        [ ] [
            <request>
                "GET" >>method
                dup url>>
                    "id" get session-id-key set-query-param
                    "/" >>path drop
            request set

            [
                { } <exiting-action> <sessions>
                call-responder
            ] with-destructors response set
        ] unit-test

        [ "text/plain" ] [ response get content-type>> ] unit-test

        [ f ] [ response get cookies>> empty? ] unit-test
    ] with-scope
] with-db
