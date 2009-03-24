USING: http http.server http.client http.client.private tools.test multiline
io.streams.string io.encodings.utf8 io.encodings.8-bit
io.encodings.binary io.encodings.string kernel arrays splitting
sequences assocs io.sockets db db.sqlite continuations urls
hashtables accessors namespaces xml.data ;
IN: http.tests

[ "text/plain" latin1 ] [ "text/plain" parse-content-type ] unit-test

[ "text/html" utf8 ] [ "text/html;  charset=UTF-8" parse-content-type ] unit-test

[ "text/html" utf8 ] [ "text/html; charset=\"utf-8\"" parse-content-type ] unit-test

[ "application/octet-stream" binary ] [ "application/octet-stream" parse-content-type ] unit-test

: lf>crlf ( string -- string' ) "\n" split "\r\n" join ;

STRING: read-request-test-1
POST /bar HTTP/1.1
Some-Header: 1
Some-Header: 2
Content-Length: 4
Content-type: application/octet-stream

blah
;

[
    T{ request
        { url T{ url { path "/bar" } } }
        { method "POST" }
        { version "1.1" }
        { header H{ { "some-header" "1; 2" } { "content-length" "4" } { "content-type" "application/octet-stream" } } }
        { post-data T{ post-data { data "blah" } { content-type "application/octet-stream" } } }
        { cookies V{ } }
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
    T{ request
        { url T{ url { host "www.sex.com" } { path "/bar" } } }
        { method "HEAD" }
        { version "1.1" }
        { header H{ { "host" "www.sex.com" } } }
        { cookies V{ } }
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
    T{ response
        { version "1.1" }
        { code 404 }
        { message "not found" }
        { header H{ { "content-type" "text/html; charset=UTF-8" } } }
        { cookies { } }
        { content-type "text/html" }
        { content-charset utf8 }
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
    URL" http://localhost/" url set
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
io.servers.connection io.files io.files.temp io.directories io io.encodings.ascii
accessors namespaces threads
http.server.responses http.server.redirection furnace.redirection
http.server.dispatchers db.tuples ;

: add-quit-action ( responder -- responder )
    <action>
        [ stop-this-server "Goodbye" "text/html" <content> ] >>display
    "quit" add-responder ;

: test-db-file ( -- path ) "test.db" temp-file ;

: test-db ( -- db ) test-db-file <sqlite-db> ;

[ test-db-file delete-file ] ignore-errors

test-db [
    init-furnace-tables
] with-db

: test-httpd ( responder -- )
    [
        main-responder set
        <http-server>
            0 >>insecure
            f >>secure
        dup start-server*
        sockets>> first addr>> port>>
    ] with-scope "port" set ;

[ ] [
    <dispatcher>
        add-quit-action
        <dispatcher>
            "vocab:http/test" <static> >>default
        "nested" add-responder
        <action>
            [ URL" redirect-loop" <temporary-redirect> ] >>display
        "redirect-loop" add-responder

    test-httpd
] unit-test

: add-port ( url -- url' )
    >url clone "port" get >>port ;

[ t ] [
    "vocab:http/test/foo.html" ascii file-contents
    "http://localhost/nested/foo.html" add-port http-get nip =
] unit-test

[ "http://localhost/redirect-loop" add-port http-get nip ]
[ too-many-redirects? ] must-fail-with

[ "Goodbye" ] [
    "http://localhost/quit" add-port http-get nip
] unit-test

! HTTP client redirect bug
[ ] [
    <dispatcher>
        add-quit-action
        <action> [ "quit" <temporary-redirect> ] >>display
        "redirect" add-responder

    test-httpd
] unit-test

[ "Goodbye" ] [
    "http://localhost/redirect" add-port http-get nip
] unit-test


[ ] [
    [ "http://localhost/quit" add-port http-get 2drop ] ignore-errors
] unit-test

! Dispatcher bugs
[ ] [
    <dispatcher>
        <action> <protected>
        "Test" <login-realm>
        <sessions>
        "" add-responder
        add-quit-action
        <dispatcher>
            <action> "" add-responder
        "d" add-responder
    test-db <db-persistence>

    test-httpd
] unit-test

: 404? ( response -- ? ) [ download-failed? ] [ response>> code>> 404 = ] bi and ;

! This should give a 404 not an infinite redirect loop
[ "http://localhost/d/blah" add-port http-get nip ] [ 404? ] must-fail-with

! This should give a 404 not an infinite redirect loop
[ "http://localhost/blah/" add-port http-get nip ] [ 404? ] must-fail-with

[ "Goodbye" ] [ "http://localhost/quit" add-port http-get nip ] unit-test

[ ] [
    <dispatcher>
        <action> [ [ "Hi" write ] "text/plain" <content> ] >>display
        "Test" <login-realm>
        <sessions>
        "" add-responder
        add-quit-action
    test-db <db-persistence>

    test-httpd
] unit-test

[ "Hi" ] [ "http://localhost/" add-port http-get nip ] unit-test

[ "Goodbye" ] [ "http://localhost/quit" add-port http-get nip ] unit-test

USING: html.components html.forms
xml xml.traversal validators
furnace furnace.conversations ;

SYMBOL: a

[ ] [
    <dispatcher>
        <action>
            [ a get-global "a" set-value ] >>init
            [ [ "<html>" write "a" <field> render "</html>" write ] "text/html" <content> ] >>display
            [ { { "a" [ v-integer ] } } validate-params ] >>validate
            [ "a" value a set-global URL" " <redirect> ] >>submit
        <conversations>
        <sessions>
        >>default
        add-quit-action
    test-db <db-persistence>

    test-httpd
] unit-test

3 a set-global

: test-a ( xml -- value )
    string>xml body>> "input" deep-tag-named "value" attr ;

[ "3" ] [
    "http://localhost/" add-port http-get
    swap dup cookies>> "cookies" set session-id-key get-cookie
    value>> "session-id" set test-a
] unit-test

[ "4" ] [
    [
        "4" "a" set
        "http://localhost" add-port "__u" set
        "session-id" get session-id-key set
    ] H{ } make-assoc
    "http://localhost/" add-port <post-request> "cookies" get >>cookies http-request nip test-a
] unit-test

[ 4 ] [ a get-global ] unit-test

! Test flash scope
[ "xyz" ] [
    [
        "xyz" "a" set
        "http://localhost" add-port "__u" set
        "session-id" get session-id-key set
    ] H{ } make-assoc
    "http://localhost/" add-port <post-request> "cookies" get >>cookies http-request nip test-a
] unit-test

[ 4 ] [ a get-global ] unit-test

[ "Goodbye" ] [ "http://localhost/quit" add-port http-get nip ] unit-test

! Test cloning
[ f ] [ <404> dup clone "b" "a" set-header drop "a" header ] unit-test
[ f ] [ <404> dup clone "b" "a" <cookie> put-cookie drop "a" get-cookie ] unit-test

! Test basic auth
[ "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==" ] [ <request> "Aladdin" "open sesame" set-basic-auth "Authorization" header ] unit-test


