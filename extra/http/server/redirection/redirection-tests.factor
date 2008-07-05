IN: http.server.redirection.tests
USING: http http.server.redirection urls accessors
namespaces tools.test present ;

\ relative-to-request must-infer

[
    <request>
        <url>
            "http" >>protocol
            "www.apple.com" >>host
            "/xxx/bar" >>path
            { { "a" "b" } } >>query
        >>url
    request set

    [ "http://www.apple.com:80/xxx/bar" ] [ 
        <url> relative-to-request present 
    ] unit-test

    [ "http://www.apple.com:80/xxx/baz" ] [
        <url> "baz" >>path relative-to-request present
    ] unit-test
    
    [ "http://www.apple.com:80/xxx/baz?c=d" ] [
        <url> "baz" >>path { { "c" "d" } } >>query relative-to-request present
    ] unit-test
    
    [ "http://www.apple.com:80/xxx/bar?c=d" ] [
        <url> { { "c" "d" } } >>query relative-to-request present
    ] unit-test
    
    [ "http://www.apple.com:80/flip" ] [
        <url> "/flip" >>path relative-to-request present
    ] unit-test
    
    [ "http://www.apple.com:80/flip?c=d" ] [
        <url> "/flip" >>path { { "c" "d" } } >>query relative-to-request present
    ] unit-test
    
    [ "http://www.jedit.org:80/" ] [
        "http://www.jedit.org" >url relative-to-request present
    ] unit-test
    
    [ "http://www.jedit.org:80/?a=b" ] [
        "http://www.jedit.org" >url { { "a" "b" } } >>query relative-to-request present
    ] unit-test
] with-scope
