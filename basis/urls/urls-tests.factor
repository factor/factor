USING: accessors arrays assocs io.sockets io.sockets.secure kernel
linked-assocs present prettyprint sequences tools.test urls ;
IN: urls.tests

{ "localhost" f } [ "localhost" parse-host ] unit-test
{ "localhost" 8888 } [ "localhost:8888" parse-host ] unit-test

CONSTANT: urls {
    {
        T{ url
           { protocol "http" }
           { host "www.apple.com" }
           { port 1234 }
           { path "/a/path" }
           { query LH{ { "a" "b" } } }
           { anchor "foo" }
         }
        "http://www.apple.com:1234/a/path?a=b#foo"
    }
    {
        T{ url
           { protocol "http" }
           { host "www.apple.com" }
           { path "/a/path" }
           { query LH{ { "a" "b" } } }
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
           { query LH{ { "a" "b" } } }
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
           { query LH{ { "a" f } } }
         }
        "http://foo.com/?a"
    }
    ! Capital letters, digits, hyphen, plus and period are allowed
    ! characters in the scheme
    ! part. https://tools.ietf.org/html/rfc1738#section-5
    {
        T{ url
           { protocol "foo.bar" }
           { host "www.google.com" }
           { path "/" }
         }
        "foo.bar://www.google.com/"
    }
    {
        T{ url
           { protocol "foo.-bar" }
           { host "www.google.com" }
           { path "/" }
         }
        "foo.-bar://www.google.com/"
    }
    {
        T{ url
           { protocol "t1000" }
           { host "www.google.com" }
           { path "/" }
         }
        "t1000://www.google.com/"
    }
    {
        T{ url
            { protocol "no-auth" }
            { path "/some/random/path" }
        }
        "no-auth:/some/random/path"
    }
    {
        T{ url
            { protocol "http" }
            { host "example.org" }
            { path "/" }
            { username "user" }
            { password "" }
        }
        "http://user:@example.org/"
    }
    {
        T{ url
            { protocol "http" }
            { host "example.org" }
            { path "/" }
            { username "" }
            { password "pass" }
        }
        "http://:pass@example.org/"
    }
    {
        T{ url
            { protocol "http" }
            { host "example.org" }
            { path "/%2F/" }
        }
        "http://example.org/%2F/"
    }
}

urls [
    [ 1array ] [ [ >url ] curry ] bi* unit-test
] assoc-each

urls [
    swap [ 1array ] [ [ present ] curry ] bi* unit-test
] assoc-each

{ T{ url
    { protocol "http" }
    { username "ш" }
    { password "ш" }
    { host "ш.com" }
    { port 1234 }
    { path "/ш" }
    { query LH{ { "ш" "ш" } } }
    { anchor "ш" }
  } }
[ "http://ш:ш@ш.com:1234/ш?ш=ш#ш" >url ] unit-test

{
    T{ url
        { protocol "http" }
        { username f }
        { password f }
        { host "März.com" }
        { port f }
        { path "/päth" }
        { query LH{ { "query" "Dürst" } } }
        { anchor "☃" }
    }
} [ "http://März.com/päth?query=Dürst#☃" >url ] unit-test

{ T{ url
    { protocol "https" }
    { host "www.google.com" }
    { path "/" }
   } }
[ "https://www.google.com:/" >url ] unit-test

{ "https://www.google.com/" } 
[ T{ url
    { protocol "https" }
    { host "www.google.com" }
    { path "/" }
} present ] unit-test

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
        { query LH{ { "a" "b" } } }
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
        { query LH{ { "a" "b" } } }
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
        { query LH{ { "a" "b" } } }
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
        { query LH{ { "a" "b" } } }
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
        { path "/" }
    }
} [
    T{ url
        { protocol "http" }
        { host "www.apple.com" }
        { port 80 }
        { path "/" }
    }

    T{ url
        { protocol "https" }
        { host "www.apple.com" }
        { path "/" }
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

{ t } [
    URL" http://www.google.com" "foo" "bar" set-query-param
    query>> linked-assoc?
] unit-test

{ "foo#3" } [ URL" foo" clone 3 >>anchor present ] unit-test

{ "http://www.foo.com/" } [ "http://www.foo.com:80" >url present ] unit-test

{ f } [ URL" /gp/redirect.html/002-7009742-0004012?location=http://advantage.amazon.com/gp/vendor/public/join%26token%3d77E3769AB3A5B6CF611699E150DC33010761CE12" protocol>> ] unit-test

{
    T{ url
        { protocol "http" }
        { host "localhost" }
        { query LH{ { "foo" "bar" } } }
        { path "/" }
    }
}
[ "http://localhost?foo=bar" >url ] unit-test

{
    T{ url
        { protocol "http" }
        { host "localhost" }
        { query LH{ { "foo" "bar" } } }
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
        { hostname "google.com" }
    }
}
[ URL" https://google.com/" url-addr ] unit-test

{ "git+https" }
[ URL" git+https://google.com/git/factor.git" >url protocol>> ] unit-test

! Params should be rendered in the order in which they are added.
{ "/?foo=foo&bar=bar&baz=baz" } [
    URL" /"
    "foo" "foo" set-query-param
    "bar" "bar" set-query-param
    "baz" "baz" set-query-param
    present
] unit-test

! Scheme characters are
! case-insensitive. https://tools.ietf.org/html/rfc3986#section-3.1
{ URL" http://www.google.com/" } [
    URL" HTTP://www.google.com/"
] unit-test

{ URL" https://host:1234/path" } [ URL" https://host:1234/path" redacted-url ] unit-test
{ URL" https://user@host:1234/path" } [ URL" https://user@host:1234/path" redacted-url ] unit-test
{ URL" https://user:xxxxx@host:1234/path" } [ URL" https://user:password@host:1234/path" redacted-url ] unit-test

{
    { "/a/b/c"    "./////d"     "/a/b/d"    }
    { "/a/b/c"    "./././././d" "/a/b/d"    }
    { "/a/b/c"    "/d"          "/d"        }
    { "/a/b/c"    "/./d"        "/d"        }
    { "/a/b/c"    "/../d"       "/d"        }
    { "/a/b/c"    "/d"          "/d"        }
    { "/a/b/c"    "d"           "/a/b/d"    }
    { "/a/b/c"    "./d"         "/a/b/d"    }
    { "/a/b/c"    "d/"          "/a/b/d/"   }
    { "/a/b/c"    "."           "/a/b/"     }
    { "/a/b/c"    "./"          "/a/b/"     }
    { "/a/b/c"    ".."          "/a/"       }
    { "/a/b/c"    "../"         "/a/"       }
    { "/a/b/c"    "../d"        "/a/d"      }
    { "/a/b/c"    "../.."       "/"         }
    { "/a/b/c"    "../../"      "/"         }
    { "/a/b/c"    "../../d"     "/d"        }
    { "/a/b/c"    "../../../d"  "/d"        }
    { "/a/b/c"    "d."          "/a/b/d."   }
    { "/a/b/c"    ".d"          "/a/b/.d"   }
    { "/a/b/c"    "d.."         "/a/b/d.."  }
    { "/a/b/c"    "..d"         "/a/b/..d"  }
    { "/a/b/c"    "./../d"      "/a/d"      }
    { "/a/b/c"    "./d/."       "/a/b/d/"   }
    { "/a/b/c"    "d/./e"       "/a/b/d/e"  }
    { "/a/b/c"    "d/../e"      "/a/b/e"    }
    { "/a/b/c/d/" "../../e/f"   "/a/b/e/f"  }
    { "/a/b/c/d"  "../../e/f"   "/a/e/f"    }
    { "/a/b/c/d/" "../../e/f/"  "/a/b/e/f/" }
    { "/a/b/c/d"  "../../e/f/"  "/a/e/f/"   }
    { "/a/b/c/d/" "/../../e/f/" "/e/f/"     }
    { "/a/b/c/d"  "/../../e/f/" "/e/f/"     }
} [
    1 cut* swap first2 '[ _ _ url-append-path ] unit-test
] each

! RFC 3986 1.1.2.  Examples

{
    T{ url
        { protocol "ftp" }
        { host "ftp.is.co.za" }
        { path "/rfc/rfc1808.txt" }
    }
} [ "ftp://ftp.is.co.za/rfc/rfc1808.txt" >url ] unit-test

{
    T{ url
        { protocol "http" }
        { host "www.ietf.org" }
        { path "/rfc/rfc2396.txt" }
    }
} [ "http://www.ietf.org/rfc/rfc2396.txt" >url ] unit-test


{
    T{ url
        { protocol "ldap" }
        { host "[2001:db8::7]" }
        { path "/c=GB" }
        { query LH{ { "objectClass?one" f } } }
    }
} [ "ldap://[2001:db8::7]/c=GB?objectClass?one" >url ] unit-test

{
    T{ url
        { protocol "mailto" }
        { path "John.Doe@example.com" }
    }
} [ "mailto:John.Doe@example.com" >url ] unit-test


{
    T{ url
        { protocol "news" }
        { path "comp.infosystems.www.servers.unix" }
    }
} [ "news:comp.infosystems.www.servers.unix" >url ] unit-test


{
    T{ url
        { protocol "tel" }
        { path "+1-816-555-1212" }
    }
} [ "tel:+1-816-555-1212" >url ] unit-test

{
    T{ url
        { protocol "telnet" }
        { host "192.0.2.16" }
        { port 80 }
        { path "/" }
    }
} [ "telnet://192.0.2.16:80/" >url ] unit-test

{
    T{ url
        { protocol "urn" }
        { path "oasis:names:specification:docbook:dtd:xml:4.1.2" }
    }
} [ "urn:oasis:names:specification:docbook:dtd:xml:4.1.2" >url ] unit-test

! RFC 3986 6.2.2.  Syntax Normalization
{ URL" example://a/b/c/%7Bfoo%7D" } [
    URL" eXAMPLE://a/./b/../b/%63/%7bfoo%7d"
] unit-test

! RFC 3986 6.2.3. Scheme-Based Normalization
{ t } [
    {
      "http://example.com"
      "http://example.com/"
      "http://example.com:/"
      "http://example.com:80/"
    } [ >url present "http://example.com/" = ] all?
] unit-test

