USING: accessors http http.client http.client.private
io.streams.string kernel namespaces sequences splitting
tools.test urls ;
IN: http.client.tests

{ "foo.txt" } [ "http://www.paulgraham.com/foo.txt" download-name ] unit-test
{ "foo.txt" } [ "http://www.arc.com/foo.txt?xxx" download-name ] unit-test
{ "foo.txt" } [ "http://www.arc.com/foo.txt/" download-name ] unit-test
{ "www.arc.com" } [ "http://www.arc.com////" download-name ] unit-test

{
    T{ request
        { url T{ url { protocol "http" } { host "www.apple.com" } { port 80 } { path "/index.html" } } }
        { proxy-url T{ url } }
        { method "GET" }
        { version "1.1" }
        { cookies V{ } }
        { header H{ { "Connection" "close" } { "User-Agent" "Factor http.client" } } }
        { redirects 10 }
    }
} [
    "http://www.apple.com/index.html"
    <get-request>
] unit-test

{
    T{ request
        { url T{ url { protocol "https" } { host "www.amazon.com" } { port 443 } { path "/index.html" } } }
        { proxy-url T{ url } }
        { method "GET" }
        { version "1.1" }
        { cookies V{ } }
        { header H{ { "Connection" "close" } { "User-Agent" "Factor http.client" } } }
        { redirects 10 }
    }
} [
    "https://www.amazon.com/index.html"
    <get-request>
] unit-test

{ "HEAD" } [ "http://google.com" <head-request> method>> ] unit-test
{ "DELETE" } [ "http://arc.com" <delete-request> method>> ] unit-test
{ "TRACE" } [ "http://concatenative.org" <trace-request> method>> ] unit-test
{ "OPTIONS" } [ "http://factorcode.org" <options-request> method>> ] unit-test

! Do not re-enable this for the test suite.
! We should replace this with a similar test that does not
! hit the velox.ch website.
! { t } [
    ! "https://alice.sni.velox.ch" http-get nip
    ! [ "Great!" subseq-of? ]
    ! [ "TLS SNI Test Site: alice.sni.velox.ch" subseq-of? ] bi and
! ] unit-test

{ t } [
    {
        "HTTP/1.1 200 Document follows"
        "connection: close"
        "content-type: text/html; charset=UTF-8"
        "date: Wed, 12 Oct 2011 18:57:49 GMT"
        "server: Factor http.server"
    } [ join-lines ] [ "\r\n" join ] bi
    [ [ read-response ] with-string-reader ] same?
] unit-test

{ "www.google.com:8080" } [
    URL" http://foo:bar@www.google.com:8080/foo?bar=baz#quux" authority-uri
] unit-test

{ "/index.html?bar=baz" } [
    "http://user:pass@www.apple.com/index.html?bar=baz#foo"
    <get-request>
        f >>proxy-url
    request-uri
] unit-test

{ "/index.html?bar=baz" } [
    "https://user:pass@www.apple.com/index.html?bar=baz#foo"
    <get-request>
        f >>proxy-url
    request-uri
] unit-test

{ "http://www.apple.com/index.html?bar=baz" } [
    "http://user:pass@www.apple.com/index.html?bar=baz#foo"
    <get-request>
        "http://localhost:3128" >>proxy-url
    request-uri
] unit-test

{ "www.apple.com:80" } [
    "http://user:pass@www.apple.com/index.html?bar=baz#foo"
    "CONNECT" <client-request>
        f >>proxy-url
    request-uri
] unit-test

{ "www.apple.com:443" } [
    "https://www.apple.com/index.html"
    "CONNECT" <client-request>
        f >>proxy-url
    request-uri
] unit-test

{ f } [
    "" "no_proxy" [
        "www.google.fr" <get-request> no-proxy?
    ] with-variable
] unit-test

{ f } [
    "," "no_proxy" [
        "www.google.fr" <get-request> no-proxy?
    ] with-variable
] unit-test

{ f } [
    "foo,,bar" "no_proxy" [
        "www.google.fr" <get-request> no-proxy?
    ] with-variable
] unit-test

{ t } [
    "foo,www.google.fr,bar" "no_proxy" [
        "www.google.fr" <get-request> no-proxy?
    ] with-variable
] unit-test

! TODO support 192.168.0.16/4 ?
CONSTANT: classic-proxy-settings H{
    { "http.proxy" "http://proxy.private:3128" }
    { "https.proxy" "http://proxysec.private:3128" }
    { "no_proxy" "localhost,127.0.0.1,.allprivate,.a.subprivate,b.subprivate" }
}

{ f } [
    classic-proxy-settings [
       "localhost" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ f } [
    classic-proxy-settings [
       "127.0.0.1" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ URL" http://proxy.private:3128" } [
    classic-proxy-settings [
       "27.0.0.1" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ f } [
    classic-proxy-settings [
       "foo.allprivate" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ f } [
    classic-proxy-settings [
       "bar.a.subprivate" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ URL" http://proxy.private:3128" } [
    classic-proxy-settings [
       "a.subprivate" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ f } [
    classic-proxy-settings [
       "bar.b.subprivate" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ f } [
    classic-proxy-settings [
       "b.subprivate" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ URL" http://proxy.private:3128" } [
    classic-proxy-settings [
       "bara.subprivate" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ URL" http://proxy.private:3128" } [
    classic-proxy-settings [
       "google.com" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ URL" //localhost:3128" } [
    { { "http.proxy" "//localhost:3128" } } [
       "google.com" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ URL" //localhost:3128" } [
    "google.com" "GET" <client-request>
    URL" //localhost:3128" >>proxy-url ?default-proxy proxy-url>>
] unit-test

{ URL" //localhost:3128" } [
    "google.com" "GET" <client-request>
    "//localhost:3128" >>proxy-url ?default-proxy proxy-url>>
] unit-test

{ URL" http://proxysec.private:3128" } [
    classic-proxy-settings [
       "https://google.com" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

{ URL" http://proxy.private:3128" } [
    classic-proxy-settings [
       "allprivate.google.com" "GET" <client-request> ?default-proxy proxy-url>>
    ] with-variables
] unit-test

[
    <url> 3128 >>port "http.proxy" [
       "http://www.google.com" "GET" <client-request> ?default-proxy
    ] with-variable
] [ invalid-proxy? ] must-fail-with

! This url is misparsed bu request-url can fix it
{ T{ url
    { protocol "http" }
    { host "www.google.com" }
    { path "/" }
    { port 80 }
} } [ "www.google.com" request-url ] unit-test

! This one is not fixable, leave it as it is
{ T{ url } } [ "" request-url ] unit-test
