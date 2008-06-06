IN: urls.tests
USING: urls urls.private tools.test
tuple-syntax arrays kernel assocs
present ;

[ "hello%20world" ] [ "hello world" url-encode ] unit-test
[ "hello world" ] [ "hello%20world" url-decode ] unit-test
[ "~hello world" ] [ "%7ehello+world" url-decode ] unit-test
[ f ] [ "%XX%XX%XX" url-decode ] unit-test
[ f ] [ "%XX%XX%X" url-decode ] unit-test

[ "hello world"   ] [ "hello+world"    url-decode ] unit-test
[ "hello world"   ] [ "hello%20world"  url-decode ] unit-test
[ " ! "           ] [ "%20%21%20"      url-decode ] unit-test
[ "hello world"   ] [ "hello world%"   url-decode ] unit-test
[ "hello world"   ] [ "hello world%x"  url-decode ] unit-test
[ "hello%20world" ] [ "hello world"    url-encode ] unit-test
[ "%20%21%20"     ] [ " ! "            url-encode ] unit-test

[ "\u001234hi\u002045" ] [ "\u001234hi\u002045" url-encode url-decode ] unit-test

[ "a=b&a=c" ] [ { { "a" { "b" "c" } } } assoc>query ] unit-test

[ H{ { "a" "b" } } ] [ "a=b" query>assoc ] unit-test

[ H{ { "a" { "b" "c" } } } ] [ "a=b&a=c" query>assoc ] unit-test

[ "a=3" ] [ { { "a" 3 } } assoc>query ] unit-test

: urls
    {
        {
            TUPLE{ url
                protocol: "http"
                host: "www.apple.com"
                port: 1234
                path: "/a/path"
                query: H{ { "a" "b" } }
                anchor: "foo"
            }
            "http://www.apple.com:1234/a/path?a=b#foo"
        }
        {
            TUPLE{ url
                protocol: "http"
                host: "www.apple.com"
                path: "/a/path"
                query: H{ { "a" "b" } }
                anchor: "foo"
            }
            "http://www.apple.com/a/path?a=b#foo"
        }
        {
            TUPLE{ url
                protocol: "http"
                host: "www.apple.com"
                port: 1234
                path: "/another/fine/path"
                anchor: "foo"
            }
            "http://www.apple.com:1234/another/fine/path#foo"
        }
        {
            TUPLE{ url
                path: "/a/relative/path"
                anchor: "foo"
            }
            "/a/relative/path#foo"
        }
        {
            TUPLE{ url
                path: "/a/relative/path"
            }
            "/a/relative/path"
        }
        {
            TUPLE{ url
                path: "a/relative/path"
            }
            "a/relative/path"
        }
        {
            TUPLE{ url
                path: "bar"
                query: H{ { "a" "b" } }
            }
            "bar?a=b"
        }
        {
            TUPLE{ url
                protocol: "ftp"
                host: "ftp.kernel.org"
                username: "slava"
                path: "/"
            }
            "ftp://slava@ftp.kernel.org/"
        }
        {
            TUPLE{ url
                protocol: "ftp"
                host: "ftp.kernel.org"
                username: "slava"
                password: "secret"
                path: "/"
            }
            "ftp://slava:secret@ftp.kernel.org/"
        }
    } ;

urls [
    [ 1array ] [ [ >url ] curry ] bi* unit-test
] assoc-each

urls [
    swap [ 1array ] [ [ present ] curry ] bi* unit-test
] assoc-each

[ "b" ] [ "a" "b" url-append-path ] unit-test

[ "a/b" ] [ "a/c" "b" url-append-path ] unit-test

[ "a/b" ] [ "a/" "b" url-append-path ] unit-test

[ "/b" ] [ "a" "/b" url-append-path ] unit-test

[ "/b" ] [ "a/b/" "/b" url-append-path ] unit-test

[ "/xxx/bar" ] [ "/xxx/baz" "bar" url-append-path ] unit-test

[
    TUPLE{ url
        protocol: "http"
        host: "www.apple.com"
        port: 1234
        path: "/a/path"
    }
] [
    TUPLE{ url
        protocol: "http"
        host: "www.apple.com"
        port: 1234
        path: "/foo"
    }

    TUPLE{ url
        path: "/a/path"
    }

    derive-url
] unit-test

[
    TUPLE{ url
        protocol: "http"
        host: "www.apple.com"
        port: 1234
        path: "/a/path/relative/path"
        query: H{ { "a" "b" } }
        anchor: "foo"
    }
] [
    TUPLE{ url
        protocol: "http"
        host: "www.apple.com"
        port: 1234
        path: "/a/path/"
    }

    TUPLE{ url
        path: "relative/path"
        query: H{ { "a" "b" } }
        anchor: "foo"
    }

    derive-url
] unit-test

[
    TUPLE{ url
        protocol: "http"
        host: "www.apple.com"
        port: 1234
        path: "/a/path/relative/path"
        query: H{ { "a" "b" } }
        anchor: "foo"
    }
] [
    TUPLE{ url
        protocol: "http"
        host: "www.apple.com"
        port: 1234
        path: "/a/path/"
    }

    TUPLE{ url
        path: "relative/path"
        query: H{ { "a" "b" } }
        anchor: "foo"
    }

    derive-url
] unit-test

[
    TUPLE{ url
        protocol: "http"
        host: "www.apple.com"
        path: "/xxx/baz"
    }
] [
    TUPLE{ url
        protocol: "http"
        host: "www.apple.com"
        path: "/xxx/bar"
    }

    TUPLE{ url
        path: "baz"
    }

    derive-url
] unit-test

[ "a" ] [
    <url> "a" "b" set-query-param "b" query-param
] unit-test
