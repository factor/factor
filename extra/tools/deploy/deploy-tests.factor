IN: tools.deploy.tests
USING: tools.test system io.files kernel tools.deploy.config
tools.deploy.backend math sequences io.launcher arrays
namespaces continuations layouts accessors ;

: shake-and-bake ( vocab -- )
    [ "test.image" temp-file delete-file ] ignore-errors
    "resource:" [
        >r vm
        "test.image" temp-file
        r> dup deploy-config make-deploy-image
    ] with-directory ;

: small-enough? ( n -- ? )
    >r "test.image" temp-file file-info size>> r> cell 4 / * <= ;

[ ] [ "hello-world" shake-and-bake ] unit-test

[ t ] [ 500000 small-enough? ] unit-test

[ ] [ "sudoku" shake-and-bake ] unit-test

[ t ] [ 800000 small-enough? ] unit-test

[ ] [ "hello-ui" shake-and-bake ] unit-test

[ t ] [ 1300000 small-enough? ] unit-test

[ "staging.math-compiler-ui-strip.image" ] [
    "hello-ui" deploy-config
    [ bootstrap-profile staging-image-name file-name ] bind
] unit-test

[ ] [ "maze" shake-and-bake ] unit-test

[ t ] [ 1200000 small-enough? ] unit-test

[ ] [ "tetris" shake-and-bake ] unit-test

[ t ] [ 1200000 small-enough? ] unit-test

[ ] [ "bunny" shake-and-bake ] unit-test

[ t ] [ 2500000 small-enough? ] unit-test

{
    "tools.deploy.test.1"
    "tools.deploy.test.2"
    "tools.deploy.test.3"
    "tools.deploy.test.4"
} [
    [ ] swap [
        shake-and-bake
        vm
        "-i=" "test.image" temp-file append
        2array try-process
    ] curry unit-test
] each

USING: http.client http.server http.server.dispatchers
http.server.responses http.server.static io.servers.connection ;

SINGLETON: quit-responder

M: quit-responder call-responder*
    2drop stop-server "Goodbye" "text/html" <content> ;

: add-quot-responder ( responder -- responder )
    quit-responder "quit" add-responder ;

: test-httpd ( -- )
    #! Return as soon as server is running.
    <http-server>
        1237 >>insecure
        f >>secure
    start-server* ;

[ ] [
    [
        <dispatcher>
            add-quot-responder
            "resource:extra/http/test" <static> >>default
        main-responder set

        test-httpd
    ] with-scope
] unit-test

[ ] [
    "tools.deploy.test.5" shake-and-bake
    vm
    "-i=" "test.image" temp-file append
    2array try-process
] unit-test

[ ] [ "http://localhost:1237/quit" http-get 2drop ] unit-test
