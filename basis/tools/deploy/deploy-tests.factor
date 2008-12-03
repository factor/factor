IN: tools.deploy.tests
USING: tools.test system io.files kernel tools.deploy.config
tools.deploy.backend math sequences io.launcher arrays
namespaces continuations layouts accessors io.encodings.ascii
urls math.parser ;

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

[ "staging.math-compiler-threads-ui-strip.image" ] [
    "hello-ui" deploy-config
    [ bootstrap-profile staging-image-name file-name ] bind
] unit-test

[ ] [ "maze" shake-and-bake ] unit-test

[ t ] [ 1200000 small-enough? ] unit-test

[ ] [ "tetris" shake-and-bake ] unit-test

[ t ] [ 1500000 small-enough? ] unit-test

! [ ] [ "bunny" shake-and-bake ] unit-test

! [ t ] [ 2500000 small-enough? ] unit-test

: run-temp-image ( -- )
    vm
    "-i=" "test.image" temp-file append
    2array try-process ;

{
    "tools.deploy.test.1"
    "tools.deploy.test.2"
    "tools.deploy.test.3"
    "tools.deploy.test.4"
} [
    [ ] swap [
        shake-and-bake
        run-temp-image
    ] curry unit-test
] each

USING: http.client http.server http.server.dispatchers
http.server.responses http.server.static io.servers.connection ;

SINGLETON: quit-responder

M: quit-responder call-responder*
    2drop stop-this-server "Goodbye" "text/html" <content> ;

: add-quot-responder ( responder -- responder )
    quit-responder "quit" add-responder ;

: test-httpd ( responder -- )
    [
        main-responder set
        <http-server>
            0 >>insecure
            f >>secure
        dup start-server*
        sockets>> first addr>> port>>
        dup number>string "resource:temp/port-number" ascii set-file-contents
    ] with-scope
    "port" set ;

[ ] [
    <dispatcher>
        add-quot-responder
        "resource:basis/http/test" <static> >>default

    test-httpd
] unit-test

[ ] [
    "tools.deploy.test.5" shake-and-bake
    run-temp-image
] unit-test

: add-port ( url -- url' )
    >url clone "port" get >>port ;

[ ] [ "http://localhost/quit" add-port http-get 2drop ] unit-test

[ ] [
    "tools.deploy.test.6" shake-and-bake
    run-temp-image
] unit-test

[ ] [
    "tools.deploy.test.7" shake-and-bake
    run-temp-image
] unit-test
