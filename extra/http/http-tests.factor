USING: http http.server http.client tools.test multiline
tuple-syntax io.streams.string io.encodings.utf8
io.encodings.8-bit io.encodings.binary io.encodings.string
kernel arrays splitting sequences assocs io.sockets db db.sqlite
continuations urls hashtables accessors ;
IN: http.tests

[ "text/plain" latin1 ] [ "text/plain" parse-content-type ] unit-test

[ "text/html" utf8 ] [ "text/html;  charset=UTF-8" parse-content-type ] unit-test

[ "application/octet-stream" binary ] [ "application/octet-stream" parse-content-type ] unit-test

: lf>crlf "\n" split "\r\n" join ;

STRING: read-request-test-1
POST /bar HTTP/1.1
Some-Header: 1
Some-Header: 2
Content-Length: 4
Content-type: application/octet-stream

blah
;

[
    TUPLE{ request
        url: TUPLE{ url path: "/bar" }
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
HEAD  /bar   HTTP/1.1
Host: www.sex.com

;

[
    TUPLE{ request
        url: TUPLE{ url host: "www.sex.com" path: "/bar" }
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

[ read-request-test-3 lf>crlf [ read-request ] with-string-reader ]
[ "Bad request: URL" = ]
must-fail-with

STRING: read-request-test-4
GET /blah HTTP/1.0
Host: "www.amazon.com"
;

[ "www.amazon.com" ]
[
    read-request-test-4 lf>crlf [ read-request ] with-string-reader
    "host" header
] unit-test

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
    dup parse-set-cookie first unparse-set-cookie =
] unit-test

[ t ] [
    "a="
    dup parse-set-cookie first unparse-set-cookie =
] unit-test

STRING: read-response-test-2
HTTP/1.1 200 Content follows
Set-Cookie: oo="bar; a=b"; httponly=yes; sid=123456


;

[ 2 ] [
    read-response-test-2 lf>crlf
    [ read-response ] with-string-reader
    cookies>> length
] unit-test

STRING: read-response-test-3
HTTP/1.1 200 Content follows
Set-Cookie: oo="bar; a=b"; comment="your mom"; httponly=yes


;

[ 1 ] [
    read-response-test-3 lf>crlf
    [ read-response ] with-string-reader
    cookies>> length
] unit-test

! Live-fire exercise
USING: http.server http.server.static furnace.sessions furnace.alloy
furnace.actions furnace.auth furnace.auth.login furnace.db http.client
io.servers.connection io.files io io.encodings.ascii
accessors namespaces threads
http.server.responses http.server.redirection furnace.redirection
http.server.dispatchers db.tuples ;

: add-quit-action
    <action>
        [ stop-server "Goodbye" "text/html" <content> ] >>display
    "quit" add-responder ;

: test-db "test.db" temp-file sqlite-db ;

[ test-db drop delete-file ] ignore-errors

test-db [
    init-furnace-tables
] with-db

: test-httpd ( -- )
    #! Return as soon as server is running.
    <http-server>
        1237 >>insecure
        f >>secure
    start-server* ;

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

        test-httpd
    ] with-scope
] unit-test

[ t ] [
    "resource:extra/http/test/foo.html" ascii file-contents
    "http://localhost:1237/nested/foo.html" http-get nip =
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
            "Test" <login-realm>
            <sessions>
            "" add-responder
            add-quit-action
            <dispatcher>
                <action> "a" add-main-responder
            "d" add-responder
        test-db <db-persistence>
        main-responder set

        test-httpd
    ] with-scope
] unit-test

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
            "Test" <login-realm>
            <sessions>
            "" add-responder
            add-quit-action
        test-db <db-persistence>
        main-responder set

        test-httpd
    ] with-scope
] unit-test

[ "Hi" ] [ "http://localhost:1237/" http-get nip ] unit-test

[ "Goodbye" ] [ "http://localhost:1237/quit" http-get nip ] unit-test

USING: html.components html.elements html.forms
xml xml.utilities validators
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

        test-httpd
    ] with-scope
] unit-test

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

! Test cloning
[ f ] [ <404> dup clone "b" "a" set-header drop "a" header ] unit-test
[ f ] [ <404> dup clone "b" "a" <cookie> put-cookie drop "a" get-cookie ] unit-test
