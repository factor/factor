USING: accessors calendar combinators.short-circuit
continuations db db.sqlite destructors furnace.actions
furnace.alloy furnace.auth furnace.auth.login
furnace.conversations furnace.db furnace.redirection
furnace.sessions html.components html.forms http http.client
http.client.private http.download http.server
http.server.dispatchers http.server.redirection
http.server.requests http.server.responses http.server.static io
io.crlf io.directories io.encodings.ascii io.encodings.binary
io.encodings.utf8 io.files io.files.temp io.servers io.sockets
io.streams.string kernel literals make multiline namespaces
random sequences splitting tools.test urls validators xml
xml.data xml.traversal ;
IN: http.tests

{ "text/plain" "UTF-8" } [ "text/plain" parse-content-type ] unit-test

{ "text/html" "ASCII" } [ "text/html;  charset=ASCII" parse-content-type ] unit-test

{ "text/html" "utf-8" } [ "text/html; charset=\"utf-8\"" parse-content-type ] unit-test

{ "application/octet-stream" f } [ "application/octet-stream" parse-content-type ] unit-test

{ "localhost" f } [ "localhost" parse-host ] unit-test
{ "localhost" 8888 } [ "localhost:8888" parse-host ] unit-test
{ "::1" 8888 } [ "::1:8888" parse-host ] unit-test
{ "127.0.0.1" 8888 } [ "127.0.0.1:8888" parse-host ] unit-test

{ "localhost" } [ T{ url { protocol "http" } { host "localhost" } } unparse-host ] unit-test
{ "localhost" } [ T{ url { protocol "http" } { host "localhost" } { port 80 } } unparse-host ] unit-test
{ "localhost" } [ T{ url { protocol "https" } { host "localhost" } { port 443 } } unparse-host ] unit-test
{ "localhost:8080" } [ T{ url { protocol "http" } { host "localhost" } { port 8080 } } unparse-host ] unit-test
{ "localhost:8443" } [ T{ url { protocol "https" } { host "localhost" } { port 8443 } } unparse-host ] unit-test

STRING: read-request-test-1
POST /bar HTTP/1.1
Some-Header: 1
Some-Header: 2
Content-Length: 4
Content-type: application/octet-stream

blah
;

{
    T{ request
        { url T{ url { path "/bar" } } }
        { proxy-url T{ url } }
        { method "POST" }
        { version "1.1" }
        { header H{ { "some-header" "1; 2" } { "content-length" "4" } { "content-type" "application/octet-stream" } } }
        { data T{ post-data { data "blah" } { content-type "application/octet-stream" } } }
        { cookies V{ } }
        { redirects 10 }
    }
} [
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

${ read-request-test-1' } [
    read-request-test-1 lf>crlf
    [ read-request ] with-string-reader
    [ write-request ] with-string-writer
    ! normalize crlf
    split-lines join-lines
] unit-test

STRING: read-request-test-2
HEAD  /bar   HTTP/1.1
Host: www.sex.com

;

{
    T{ request
        { url T{ url { host "www.sex.com" } { path "/bar" } } }
        { proxy-url T{ url } }
        { method "HEAD" }
        { version "1.1" }
        { header H{ { "host" "www.sex.com" } } }
        { cookies V{ } }
        { redirects 10 }
    }
} [
    read-request-test-2 lf>crlf [
        read-request
    ] with-string-reader
] unit-test

STRING: read-request-test-2'
HEAD  /bar   HTTP/1.1
Host: www.sex.com:101

;

{
    T{ request
        { url T{ url { host "www.sex.com" } { port 101 } { path "/bar" } } }
        { proxy-url T{ url } }
        { method "HEAD" }
        { version "1.1" }
        { header H{ { "host" "www.sex.com:101" } } }
        { cookies V{ } }
        { redirects 10 }
    }
} [
    read-request-test-2' lf>crlf [
        read-request
    ] with-string-reader
] unit-test

STRING: read-request-test-3
GET nested HTTP/1.0

;

STRING: read-request-test-4
GET /blah HTTP/1.0
Host: "www.amazon.com"
;

{ "www.amazon.com" }
[
    read-request-test-4 lf>crlf [ read-request ] with-string-reader
    "host" header
] unit-test

STRING: read-response-test-1
HTTP/1.1 404 not found
Content-Type: text/html; charset=UTF-8

blah
;

{
    T{ response
        { version "1.1" }
        { code 404 }
        { message "not found" }
        { header H{ { "content-type" "text/html; charset=UTF-8" } } }
        { cookies { } }
        { content-type "text/html" }
        { content-charset "UTF-8" }
        { content-encoding utf8 }
    }
} [
    read-response-test-1 lf>crlf
    [ read-response ] with-string-reader
] unit-test


STRING: read-response-test-1'
HTTP/1.1 404 not found
content-type: text/html; charset=UTF-8

;

${ read-response-test-1' } [
    URL" http://localhost/" url set
    read-response-test-1 lf>crlf
    [ read-response ] with-string-reader
    [ write-response ] with-string-writer
    ! normalize crlf
    split-lines join-lines
] unit-test

{ t } [
    "rmid=732423sdfs73242; path=/; domain=.example.net; expires=Fri, 31-Dec-2010 23:59:59 GMT"
    dup parse-set-cookie first unparse-set-cookie =
] unit-test

! Test `priority` and `samesite` cookie attributes
{
    {
        T{ cookie
            { name "__Secure-3PSIDCC" }
            { value
                "AKEyXzVzit6DPX4hTh2K1BGVcH0nEbGhHeomHuFtM9XxKZ8nN61hx0n3"
            }
            { path "/" }
            { domain ".google.com" }
            { expires
                T{ timestamp
                    { year 2025 }
                    { month 8 }
                    { day 21 }
                    { hour 2 }
                    { minute 20 }
                    { second 50 }
                }
            }
            { http-only t }
            { secure t }
            { priority "high" }
            { samesite "none" }
        }
    }
} [
    "__Secure-3PSIDCC=AKEyXzVzit6DPX4hTh2K1BGVcH0nEbGhHeomHuFtM9XxKZ8nN61hx0n3; expires=Thu, 21-Aug-2025 02:20:50 GMT; path=/; domain=.google.com; Secure; HttpOnly; priority=high; SameSite=none" parse-set-cookie
] unit-test

! Test cookie round trip
{ t } [
    "__Secure-3PSIDCC=AKEyXzVzit6DPX4hTh2K1BGVcH0nEbGhHeomHuFtM9XxKZ8nN61hx0n3; expires=Thu, 21-Aug-2025 02:20:50 GMT; path=/; domain=.google.com; Secure; HttpOnly; priority=high; SameSite=none"
    dup parse-set-cookie first unparse-set-cookie
    [ parse-set-cookie ] bi@ =
] unit-test


{
    {
        T{ cookie
            { name "lang" }
            { value "en-US" }
            { path "/" }
            { domain "example.com" }
        }
    }
} [ "lang=en-US; Path=/; Domain=example.com" parse-set-cookie ] unit-test

{ t } [
    "a="
    dup parse-set-cookie first unparse-set-cookie =
] unit-test

STRING: read-response-test-2
HTTP/1.1 200 Content follows
Set-Cookie: oo="bar; a=b"; httponly=yes; sid=123456


;

{ 2 } [
    read-response-test-2 lf>crlf
    [ read-response ] with-string-reader
    cookies>> length
] unit-test

STRING: read-response-test-3
HTTP/1.1 200 Content follows
Set-Cookie: oo="bar; a=b"; comment="your mom"; httponly=yes


;

{ 1 } [
    read-response-test-3 lf>crlf
    [ read-response ] with-string-reader
    cookies>> length
] unit-test

! Live-fire exercise

: add-quit-action ( responder -- responder )
    <action>
        [ stop-this-server "Goodbye" "text/html" <content> ] >>display
    "quit" add-responder ;

: test-db-file ( -- path ) "test.db" temp-file ;

: test-db ( -- db ) test-db-file <sqlite-db> ;

: add-addr ( url -- url' )
    >url clone "addr" get set-url-addr ;

: stop-test-httpd ( -- )
    "http://localhost/quit" add-addr http-get nip
    "Goodbye" assert= ;

{ } [
    test-db-file ?delete-file

    test-db [
        init-furnace-tables
    ] with-db
] unit-test

: test-with-dispatcher ( dispatcher quot -- )
    [ main-responder ] dip '[
        <http-server> 0 >>insecure f >>secure
        [
            server-addrs random "addr" set @
        ] with-threaded-server
    ] with-variable ; inline

:: test-with-db-persistence ( db-persistence quot -- )
    db-persistence [
        quot test-with-dispatcher
    ] with-disposal ; inline

<dispatcher>
    add-quit-action
    <dispatcher>
        "vocab:http/test" <static> >>default
    "nested" add-responder
    <action>
        [ URL" redirect-loop" <temporary-redirect> ] >>display
    "redirect-loop" add-responder [

    [ t ] [
        "vocab:http/test/foo.html" ascii file-contents
        "http://localhost/nested/foo.html" add-addr http-get nip =
    ] unit-test

    [ "http://localhost/redirect-loop" add-addr http-get nip ]
    [ too-many-redirects? ] must-fail-with

    [ "Goodbye" ] [
        "http://localhost/quit" add-addr http-get nip
    ] unit-test

] test-with-dispatcher

! HTTP client redirect bug
<dispatcher>
    add-quit-action
    <action> [ "quit" <temporary-redirect> ] >>display
    "redirect" add-responder [

    [ "Goodbye" ] [
        "http://localhost/redirect" add-addr http-get nip
    ] unit-test

    [ ] [
        [ stop-test-httpd ] ignore-errors
    ] unit-test

] test-with-dispatcher

! Dispatcher bugs
: 404? ( response -- ? )
    {
        [ download-failed? ]
        [ response>> response? ]
        [ response>> code>> 404 = ]
    } 1&& ;

<dispatcher>
    <action> <protected>
    "Test" <login-realm>
    <sessions>
    "" add-responder
    add-quit-action
    <dispatcher>
        <action> "" add-responder
    "d" add-responder
test-db <db-persistence> [

    ! This should give a 404 not an infinite redirect loop
    [ "http://localhost/d/blah" add-addr http-get nip ] [ 404? ] must-fail-with

    ! This should give a 404 not an infinite redirect loop
    [ "http://localhost/blah/" add-addr http-get nip ] [ 404? ] must-fail-with

    [ "Goodbye" ] [ "http://localhost/quit" add-addr http-get nip ] unit-test

] test-with-db-persistence

<dispatcher>
    <action> [ [ "Hi" write ] "text/plain" <content> ] >>display
    "Test" <login-realm>
    <sessions>
    "" add-responder
    add-quit-action
test-db <db-persistence> [

        [ "Hi" ] [ "http://localhost/" add-addr http-get nip ] unit-test

        [ "Goodbye" ] [ "http://localhost/quit" add-addr http-get nip ] unit-test

] test-with-db-persistence

SYMBOL: a

: test-a ( xml -- value )
    string>xml body>> "input" deep-tag-named "value" attr ;

<dispatcher>
    <action>
        [ a get-global "a" set-value ] >>init
        [ [ "<!DOCTYPE html><html>" write "a" <field> render "</html>" write ] "text/html" <content> ] >>display
        [ { { "a" [ v-integer ] } } validate-params ] >>validate
        [ "a" value a set-global URL" " <redirect> ] >>submit
    <conversations>
    <sessions>
    >>default
    add-quit-action
test-db <db-persistence> [

    3 a set-global

    [ "3" ] [
        "http://localhost/" add-addr http-get
        swap dup cookies>> "cookies" set session-id-key get-cookie
        value>> "session-id" set test-a
    ] unit-test

    [ "4" ] [
        [
            "4" "a" ,,
            "http://localhost" add-addr "__u" ,,
            "session-id" get session-id-key ,,
        ] H{ } make
        "http://localhost/" add-addr <post-request> "cookies" get >>cookies
        http-request nip test-a
    ] unit-test

    [ 4 ] [ a get-global ] unit-test

    ! Test flash scope
    [ "xyz" ] [
        [
            "xyz" "a" ,,
            "http://localhost" add-addr "__u" ,,
            "session-id" get session-id-key ,,
        ] H{ } make
        "http://localhost/" add-addr <post-request> "cookies" get >>cookies
        http-request nip test-a
    ] unit-test

    [ 4 ] [ a get-global ] unit-test

    [ "Goodbye" ] [ "http://localhost/quit" add-addr http-get nip ] unit-test

] test-with-db-persistence

! Test cloning
{ f } [ <404> dup clone "b" "a" set-header drop "a" header ] unit-test
{ f } [ <404> dup clone "b" "a" <cookie> put-cookie drop "a" get-cookie ] unit-test

! Test basic auth
{ "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==" } [
    <request> "Aladdin" "open sesame" set-basic-auth "Authorization" header
] unit-test

! Test a corner case with static responder
<dispatcher>
    add-quit-action
    "vocab:http/test/foo.html" <static> >>default [
    [ t ] [
        "http://localhost/" add-addr http-get nip
        "vocab:http/test/foo.html" ascii file-contents =
    ] unit-test

    [ ] [ stop-test-httpd ] unit-test

] test-with-dispatcher

! Check behavior of 307 redirect (reported by Chris Double)
<dispatcher>
    add-quit-action
    <action>
        [ "b" <temporary-redirect> ] >>submit
    "a" add-responder
    <action>
        [
            request get data>> data>> "data" =
            [ "OK" "text/plain" <content> ] [ "OOPS" throw ] if
        ] >>submit
    "b" add-responder [

    [ "OK" ] [ "data" "http://localhost/a" add-addr http-post nip ] unit-test

    ! Check that download throws errors (reported by Chris Double)
    [
        [
            "http://localhost/tweet_my_twat" add-addr download drop
        ] with-temp-directory
    ] must-fail

    [ ] [ stop-test-httpd ] unit-test

] test-with-dispatcher

! Check that index.fhtml works
<dispatcher>
    "resource:basis/http/test/" <static> enable-fhtml >>default
    add-quit-action [

    [ "OK\n" ] [ "http://localhost/" add-addr http-get nip ] unit-test

    [ ] [ stop-test-httpd ] unit-test

] test-with-dispatcher

! Check that just closing the socket without sending anything works
<dispatcher>
    add-quit-action [
    [ ] [ "addr" get binary [ ] with-client ] unit-test

    [ ] [ stop-test-httpd ] unit-test

] test-with-dispatcher
