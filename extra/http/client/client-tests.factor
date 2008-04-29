USING: http.client http.client.private http tools.test
tuple-syntax namespaces ;
[ "localhost" 80 ] [ "localhost" parse-host ] unit-test
[ "localhost" 8888 ] [ "localhost:8888" parse-host ] unit-test
[ "/foo" "localhost" 8888 ] [ "http://localhost:8888/foo" parse-url ] unit-test
[ "/" "localhost" 8888 ] [ "http://localhost:8888" parse-url ] unit-test

[ "foo.txt" ] [ "http://www.paulgraham.com/foo.txt" download-name ] unit-test
[ "foo.txt" ] [ "http://www.arc.com/foo.txt?xxx" download-name ] unit-test
[ "foo.txt" ] [ "http://www.arc.com/foo.txt/" download-name ] unit-test
[ "www.arc.com" ] [ "http://www.arc.com////" download-name ] unit-test

[
    TUPLE{ request
        method: "GET"
        host: "www.apple.com"
        path: "/index.html"
        port: 80
        version: "1.1"
        cookies: V{ }
        header: H{ { "connection" "close" } }
    }
] [
    [
        "http://www.apple.com/index.html"
        <get-request>
    ] with-scope
] unit-test
