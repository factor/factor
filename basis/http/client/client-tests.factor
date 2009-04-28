USING: http.client http.client.private http tools.test
namespaces urls ;

[ "localhost" f ] [ "localhost" parse-host ] unit-test
[ "localhost" 8888 ] [ "localhost:8888" parse-host ] unit-test

[ "foo.txt" ] [ "http://www.paulgraham.com/foo.txt" download-name ] unit-test
[ "foo.txt" ] [ "http://www.arc.com/foo.txt?xxx" download-name ] unit-test
[ "foo.txt" ] [ "http://www.arc.com/foo.txt/" download-name ] unit-test
[ "www.arc.com" ] [ "http://www.arc.com////" download-name ] unit-test

[
    T{ request
        { url T{ url { protocol "http" } { host "www.apple.com" } { port 80 } { path "/index.html" } } }
        { method "GET" }
        { version "1.1" }
        { cookies V{ } }
        { header H{ { "connection" "close" } { "user-agent" "Factor http.client" } } }
    }
] [
    "http://www.apple.com/index.html"
    <get-request>
] unit-test

[
    T{ request
        { url T{ url { protocol "https" } { host "www.amazon.com" } { port 443 } { path "/index.html" } } }
        { method "GET" }
        { version "1.1" }
        { cookies V{ } }
        { header H{ { "connection" "close" } { "user-agent" "Factor http.client" } } }
    }
] [
    "https://www.amazon.com/index.html"
    <get-request>
] unit-test
