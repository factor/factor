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
    >r "test.image" temp-file file-info size>> r> <= ;

[ ] [ "hello-world" shake-and-bake ] unit-test

[ t ] [
    cell 8 = 8 5 ? 100000 * small-enough?
] unit-test

[ ] [ "sudoku" shake-and-bake ] unit-test

[ t ] [
    cell 8 = 20 10 ? 100000 * small-enough?
] unit-test

[ ] [ "hello-ui" shake-and-bake ] unit-test

[ "staging.math-compiler-ui-strip.image" ] [
    "hello-ui" deploy-config
    [ bootstrap-profile staging-image-name file-name ] bind
] unit-test

[ t ] [
    cell 8 = 35 17 ? 100000 * small-enough?
] unit-test

[ ] [ "maze" shake-and-bake ] unit-test

[ t ] [
    cell 8 = 30 15 ? 100000 * small-enough?
] unit-test

[ ] [ "bunny" shake-and-bake ] unit-test

[ t ] [
    cell 8 = 50 30 ? 100000 * small-enough?
] unit-test

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

USING: http.client furnace.actions http.server http.server.dispatchers
http.server.responses http.server.static io.servers.connection ;

: add-quit-action
    <action>
        [ stop-server "Goodbye" "text/html" <content> ] >>display
    "quit" add-responder ;

: test-httpd ( -- )
    #! Return as soon as server is running.
    <http-server>
        1237 >>insecure
        f >>secure
    start-server* ;

[ ] [
    [
        <dispatcher>
            add-quit-action
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
