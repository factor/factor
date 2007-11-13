USING: webapps.file http.server.responders http
http.server namespaces io tools.test strings io.server ;
IN: temporary

[ ] [ f [ "404 not found" httpd-error ] with-logging ] unit-test

[ "inspect/global" ] [ "/inspect/global" trim-/ ] unit-test

[ ] [
    f [ "unit/test" log-responder ] with-logging
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

[ ] [ f [ "GET ../index.html" parse-request ] with-logging ] unit-test
[ ] [ f [ "POO" parse-request ] with-logging ] unit-test

[ H{ { "Foo" "Bar" } } ] [ "Foo=Bar" query>hash ] unit-test

[ H{ { "Foo" "Bar" } { "Baz" "Quux" } } ]
[ "Foo=Bar&Baz=Quux" query>hash ] unit-test

[ H{ { "Baz" " " } } ]
[ "Baz=%20" query>hash ] unit-test

[ H{ { "Foo" f } } ] [ "Foo" query>hash ] unit-test
