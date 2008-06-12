USING: http tools.test multiline tuple-syntax
io.streams.string io.encodings.utf8 io.encodings.string
kernel arrays splitting sequences
assocs io.sockets db db.sqlite continuations urls hashtables ;
IN: http.tests

: lf>crlf "\n" split "\r\n" join ;

STRING: read-request-test-1
POST http://foo/bar HTTP/1.1
Some-Header: 1
Some-Header: 2
Content-Length: 4
Content-type: application/octet-stream

blah
;

[
    TUPLE{ request
        url: TUPLE{ url protocol: "http" port: 80 path: "/bar" }
        method: "POST"
        version: "1.1"
        header: H{ { "some-header" "1; 2" } { "content-length" "4" } { "content-type" "application/octet-stream" } }
        post-data: TUPLE{ post-data content: "blah" raw: "blah" content-type: "application/octet-stream" }
        cookies: V{ }
    }
] [
    read-request-test-1 lf>crlf [
        read-request
    ] with-string-reader
] unit-test

STRING: read-request-test-1'
POST /bar HTTP/1.1
content-length: 4
content-type: application/octet-stream
some-header: 1; 2

blah
;

read-request-test-1' 1array [
    read-request-test-1 lf>crlf
    [ read-request ] with-string-reader
    [ write-request ] with-string-writer
    ! normalize crlf
    string-lines "\n" join
] unit-test

STRING: read-request-test-2
HEAD  http://foo/bar   HTTP/1.1
Host: www.sex.com

;

[
    TUPLE{ request
        url: TUPLE{ url protocol: "http" port: 80 host: "www.sex.com" path: "/bar" }
        method: "HEAD"
        version: "1.1"
        header: H{ { "host" "www.sex.com" } }
        cookies: V{ }
    }
] [
    read-request-test-2 lf>crlf [
        read-request
    ] with-string-reader
] unit-test

STRING: read-request-test-3
GET nested HTTP/1.0

;

[ read-request-test-3 [ read-request ] with-string-reader ]
[ "Bad request: URL" = ]
must-fail-with

STRING: read-response-test-1
HTTP/1.1 404 not found
Content-Type: text/html; charset=UTF-8

blah
;

[
    TUPLE{ response
        version: "1.1"
        code: 404
        message: "not found"
        header: H{ { "content-type" "text/html; charset=UTF-8" } }
        cookies: { }
        content-type: "text/html"
        content-charset: utf8
    }
] [
    read-response-test-1 lf>crlf
    [ read-response ] with-string-reader
] unit-test


STRING: read-response-test-1'
HTTP/1.1 404 not found
content-type: text/html; charset=UTF-8


;

read-response-test-1' 1array [
    read-response-test-1 lf>crlf
    [ read-response ] with-string-reader
    [ write-response ] with-string-writer
    ! normalize crlf
    string-lines "\n" join
] unit-test

[ t ] [
    "rmid=732423sdfs73242; path=/; domain=.example.net; expires=Fri, 31-Dec-2010 23:59:59 GMT"
    dup parse-cookies unparse-cookies =
] unit-test

! Live-fire exercise
USING: http.server http.server.static furnace.sessions
furnace.actions furnace.auth.login furnace.db http.client
io.server io.files io io.encodings.ascii
accessors namespaces threads
http.server.responses http.server.redirection
http.server.dispatchers ;

: add-quit-action
    <action>
        [ stop-server "Goodbye" "text/html" <content> ] >>display
    "quit" add-responder ;

: test-db "test.db" temp-file sqlite-db ;

[ test-db drop delete-file ] ignore-errors

test-db [
    init-sessions-table
] with-db

[ ] [
    [
        <dispatcher>
            add-quit-action
            <dispatcher>
                "resource:extra/http/test" <static> >>default
            "nested" add-responder
            <action>
                [ URL" redirect-loop" <temporary-redirect> ] >>display
            "redirect-loop" add-responder
        main-responder set

        [ 1237 httpd ] "HTTPD test" spawn drop
    ] with-scope
] unit-test

[ ] [ 100 sleep ] unit-test

[ t ] [
    "resource:extra/http/test/foo.html" ascii file-contents
    "http://localhost:1237/nested/foo.html" http-get nip ascii decode =
] unit-test

[ "http://localhost:1237/redirect-loop" http-get nip ]
[ too-many-redirects? ] must-fail-with

[ "Goodbye" ] [
    "http://localhost:1237/quit" http-get nip
] unit-test

! Dispatcher bugs
[ ] [
    [
        <dispatcher>
            <action> <protected>
            <login>
            <sessions>
            "" add-responder
            add-quit-action
            <dispatcher>
                <action> "a" add-main-responder
            "d" add-responder
        test-db <db-persistence>
        main-responder set

        [ 1237 httpd ] "HTTPD test" spawn drop
    ] with-scope
] unit-test

[ ] [ 100 sleep ] unit-test

: 404? [ download-failed? ] [ response>> code>> 404 = ] bi and ;

! This should give a 404 not an infinite redirect loop
[ "http://localhost:1237/d/blah" http-get nip ] [ 404? ] must-fail-with

! This should give a 404 not an infinite redirect loop
[ "http://localhost:1237/blah/" http-get nip ] [ 404? ] must-fail-with

[ "Goodbye" ] [ "http://localhost:1237/quit" http-get nip ] unit-test

[ ] [
    [
        <dispatcher>
            <action> [ [ "Hi" write ] "text/plain" <content> ] >>display
            <login>
            <sessions>
            "" add-responder
            add-quit-action
        test-db <db-persistence>
        main-responder set

        [ 1237 httpd ] "HTTPD test" spawn drop
    ] with-scope
] unit-test

[ ] [ 100 sleep ] unit-test

[ "Hi" ] [ "http://localhost:1237/" http-get nip ] unit-test

[ "Goodbye" ] [ "http://localhost:1237/quit" http-get nip ] unit-test

USING: html.components html.elements xml xml.utilities validators
furnace furnace.flash ;

SYMBOL: a

[ ] [
    [
        <dispatcher>
            <action>
                [ a get-global "a" set-value ] >>init
                [ [ <html> "a" <field> render </html> ] "text/html" <content> ] >>display
                [ { { "a" [ v-integer ] } } validate-params ] >>validate
                [ "a" value a set-global URL" " <redirect> ] >>submit
            <flash-scopes>
            <sessions>
            >>default
            add-quit-action
        test-db <db-persistence>
        main-responder set

        [ 1237 httpd ] "HTTPD test" spawn drop
    ] with-scope
] unit-test

[ ] [ 100 sleep ] unit-test

3 a set-global

: test-a string>xml "input" tag-named "value" swap at ;

[ "3" ] [
    "http://localhost:1237/" http-get
    swap dup cookies>> "cookies" set session-id-key get-cookie
    value>> "session-id" set test-a
] unit-test

[ "4" ] [
    H{ { "a" "4" } { "__u" "http://localhost:1237/" } } "session-id" get session-id-key associate assoc-union
    "http://localhost:1237/" <post-request> "cookies" get >>cookies http-request nip test-a
] unit-test

[ 4 ] [ a get-global ] unit-test

! Test flash scope
[ "xyz" ] [
    H{ { "a" "xyz" } { "__u" "http://localhost:1237/" } } "session-id" get session-id-key associate assoc-union
    "http://localhost:1237/" <post-request> "cookies" get >>cookies http-request nip test-a
] unit-test

[ 4 ] [ a get-global ] unit-test

[ "Goodbye" ] [ "http://localhost:1237/quit" http-get nip ] unit-test
