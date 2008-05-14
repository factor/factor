USING: http.client http.client.private http tools.test
tuple-syntax namespaces ;
[ "localhost" f ] [ "localhost" parse-host ] unit-test
[ "localhost" 8888 ] [ "localhost:8888" parse-host ] unit-test

[ "foo.txt" ] [ "http://www.paulgraham.com/foo.txt" download-name ] unit-test
[ "foo.txt" ] [ "http://www.arc.com/foo.txt?xxx" download-name ] unit-test
[ "foo.txt" ] [ "http://www.arc.com/foo.txt/" download-name ] unit-test
[ "www.arc.com" ] [ "http://www.arc.com////" download-name ] unit-test

[
    TUPLE{ request
        protocol: http
        method: "GET"
        host: "www.apple.com"
        port: 80
        path: "/index.html"
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

[
    TUPLE{ request
        protocol: https
        method: "GET"
        host: "www.amazon.com"
        port: 443
        path: "/index.html"
        version: "1.1"
        cookies: V{ }
        header: H{ { "connection" "close" } }
    }
] [
    [
        "https://www.amazon.com/index.html"
        <get-request>
    ] with-scope
] unit-test
