IN: urls.tests
USING: io.sockets io.sockets.secure urls urls.private tools.test prettyprint
arrays kernel assocs present accessors ;

CONSTANT: urls
    {
        {
            T{ url
                { protocol "http" }
                { host "www.apple.com" }
                { port 1234 }
                { path "/a/path" }
                { query H{ { "a" "b" } } }
                { anchor "foo" }
            }
            "http://www.apple.com:1234/a/path?a=b#foo"
        }
        {
            T{ url
                { protocol "http" }
                { host "www.apple.com" }
                { path "/a/path" }
                { query H{ { "a" "b" } } }
                { anchor "foo" }
            }
            "http://www.apple.com/a/path?a=b#foo"
        }
        {
            T{ url
                { protocol "http" }
                { host "www.apple.com" }
                { port 1234 }
                { path "/another/fine/path" }
                { anchor "foo" }
            }
            "http://www.apple.com:1234/another/fine/path#foo"
        }
        {
            T{ url
                { path "/a/relative/path" }
                { anchor "foo" }
            }
            "/a/relative/path#foo"
        }
        {
            T{ url
                { path "/a/relative/path" }
            }
            "/a/relative/path"
        }
        {
            T{ url
                { path "a/relative/path" }
            }
            "a/relative/path"
        }
        {
            T{ url
                { path "bar" }
                { query H{ { "a" "b" } } }
            }
            "bar?a=b"
        }
        {
            T{ url
                { protocol "ftp" }
                { host "ftp.kernel.org" }
                { username "slava" }
                { path "/" }
            }
            "ftp://slava@ftp.kernel.org/"
        }
        {
            T{ url
                { protocol "ftp" }
                { host "ftp.kernel.org" }
                { username "slava" }
                { password "secret" }
                { path "/" }
            }
            "ftp://slava:secret@ftp.kernel.org/"
        }
        {
            T{ url
               { protocol "http" }
               { host "foo.com" }
               { path "/" }
               { query H{ { "a" f } } }
            }
            "http://foo.com/?a"
        }
    }

urls [
    [ 1array ] [ [ >url ] curry ] bi* unit-test
] assoc-each

urls [
    swap [ 1array ] [ [ present ] curry ] bi* unit-test
] assoc-each

{ "b" } [ "a" "b" url-append-path ] unit-test

{ "a/b" } [ "a/c" "b" url-append-path ] unit-test

{ "a/b" } [ "a/" "b" url-append-path ] unit-test

{ "/b" } [ "a" "/b" url-append-path ] unit-test

{ "/b" } [ "a/b/" "/b" url-append-path ] unit-test

{ "/xxx/bar" } [ "/xxx/baz" "bar" url-append-path ] unit-test

{
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { port 1234 }
        { path "/a/path" }
    }
} [
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { port 1234 }
        { path "/foo" }
    }

    T{ url
        { path "/a/path" }
    }

    derive-url
] unit-test

{
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { port 1234 }
        { path "/a/path/relative/path" }
        { query H{ { "a" "b" } } }
        { anchor "foo" }
    }
} [
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { port 1234 }
        { path "/a/path/" }
    }

    T{ url
        { path "relative/path" }
        { query H{ { "a" "b" } } }
        { anchor "foo" }
    }

    derive-url
] unit-test

{
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { port 1234 }
        { path "/a/path/relative/path" }
        { query H{ { "a" "b" } } }
        { anchor "foo" }
    }
} [
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { port 1234 }
        { path "/a/path/" }
    }

    T{ url
        { path "relative/path" }
        { query H{ { "a" "b" } } }
        { anchor "foo" }
    }

    derive-url
] unit-test

{
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { path "/xxx/baz" }
    }
} [
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { path "/xxx/bar" }
    }

    T{ url
        { path "baz" }
    }

    derive-url
] unit-test

{
    T{ url
        { protocol "https" }
        { host "www.apple.com" }
    }
} [
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { port 80 }
    }

    T{ url
        { protocol "https" }
        { host "www.apple.com" }
    }

    derive-url
] unit-test

! Support //foo.com, which has the same protocol as the url we derive from
{ URL" http://foo.com" }
[ URL" http://google.com" URL" //foo.com" derive-url ] unit-test

{ URL" https://foo.com" }
[ URL" https://google.com" URL" //foo.com" derive-url ] unit-test

{ "a" } [
    <url> "a" "b" set-query-param "b" query-param
] unit-test

{ "foo#3" } [ URL" foo" clone 3 >>anchor present ] unit-test

{ "http://www.foo.com/" } [ "http://www.foo.com:80" >url present ] unit-test

{ f } [ URL" /gp/redirect.html/002-7009742-0004012?location=http://advantage.amazon.com/gp/vendor/public/join%26token%3d77E3769AB3A5B6CF611699E150DC33010761CE12" protocol>> ] unit-test

{
    T{ url
        { protocol "http" }
        { host "localhost" }
        { query H{ { "foo" "bar" } } }
        { path "/" }
    }
}
[ "http://localhost?foo=bar" >url ] unit-test

{
    T{ url
        { protocol "http" }
        { host "localhost" }
        { query H{ { "foo" "bar" } } }
        { path "/" }
    }
}
[ "http://localhost/?foo=bar" >url ] unit-test

{ "/" } [ "http://www.jedit.org" >url path>> ] unit-test

{ "USING: urls ;\nURL\" foo\"" } [ URL" foo" unparse-use ] unit-test

{ T{ inet { host "google.com" } { port 80 } } }
[ URL" http://google.com/" url-addr ] unit-test

{
    T{ secure
       { addrspec T{ inet { host "google.com" } { port 443 } } }
    }
}
[ URL" https://google.com/" url-addr ] unit-test

{ "git+https" }
[ URL" git+https://google.com/git/factor.git" >url protocol>> ] unit-test
