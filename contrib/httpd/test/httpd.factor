IN: temporary
USE: file-responder
USE: http
USE: httpd
USE: namespaces
USE: io
USE: test
USE: strings

[ ] [ "404 not found" httpd-error ] unit-test

[ "inspect/global" ] [ "/inspect/global" trim-/ ] unit-test

[ ] [
    "unit/test" log-responder
] unit-test

[ "index.html" ]
[ "http://www.jedit.org/index.html" url>path ] unit-test

[ "foo/bar" ]
[ "http://www.jedit.org/foo/bar" url>path ] unit-test

[ "" ]
[ "http://www.jedit.org/" url>path ] unit-test

[ "" ]
[ "http://www.jedit.org" url>path ] unit-test

[ "foobar" ]
[ "foobar" secure-path ] unit-test

[ f ]
[ "foobar/../baz" secure-path ] unit-test

[ ] [ "GET ../index.html" parse-request ] unit-test
[ ] [ "POO" parse-request ] unit-test

[ H{ { "Foo" "Bar" } } ] [ "Foo=Bar" query>hash ] unit-test

[ H{ { "Foo" "Bar" } { "Baz" "Quux" } } ]
[ "Foo=Bar&Baz=Quux" query>hash ] unit-test

[ H{ { "Baz" " " } } ]
[ "Baz=%20" query>hash ] unit-test

[ H{ { "Foo" f } } ] [ "Foo" query>hash ] unit-test
