USING: accessors http http.server.redirection io.sockets kernel
namespaces present tools.test urls ;
IN: http.server.redirection.tests

[
    <request>
        <url>
            "http" >>protocol
            T{ inet f "www.apple.com" } >>addr
            "/xxx/bar" >>path
            { { "a" "b" } } >>query
        dup url set
        >>url
    request set

    [ "http://www.apple.com/xxx/bar" ] [ 
        <url> relative-to-request present 
    ] unit-test

    [ "http://www.apple.com/xxx/baz" ] [
        <url> "baz" >>path relative-to-request present
    ] unit-test
    
    [ "http://www.apple.com/xxx/baz?c=d" ] [
        <url> "baz" >>path { { "c" "d" } } >>query relative-to-request present
    ] unit-test
    
    [ "http://www.apple.com/xxx/bar?c=d" ] [
        <url> { { "c" "d" } } >>query relative-to-request present
    ] unit-test
    
    [ "http://www.apple.com/flip" ] [
        <url> "/flip" >>path relative-to-request present
    ] unit-test
    
    [ "http://www.apple.com/flip?c=d" ] [
        <url> "/flip" >>path { { "c" "d" } } >>query relative-to-request present
    ] unit-test
    
    [ "http://www.jedit.org/" ] [
        "http://www.jedit.org" >url relative-to-request present
    ] unit-test
    
    [ "http://www.jedit.org/?a=b" ] [
        "http://www.jedit.org" >url { { "a" "b" } } >>query relative-to-request present
    ] unit-test
    
    [ "http://www.jedit.org:1234/?a=b" ] [
        "http://www.jedit.org:1234" >url { { "a" "b" } } >>query relative-to-request present
    ] unit-test
] with-scope
