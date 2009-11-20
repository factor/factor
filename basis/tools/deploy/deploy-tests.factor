USING: tools.test system io io.encodings.ascii io.pathnames
io.files io.files.info io.files.temp kernel tools.deploy.config
tools.deploy.config.editor tools.deploy.backend math sequences
io.launcher arrays namespaces continuations layouts accessors
urls math.parser io.directories tools.deploy.test ;
IN: tools.deploy.tests

[ ] [ "hello-world" shake-and-bake 500000 small-enough? ] unit-test

[ ] [ "sudoku" shake-and-bake 800000 small-enough? ] unit-test

[ ] [ "hello-ui" shake-and-bake 1300000 small-enough? ] unit-test

[ "staging.math-threads-compiler-ui.image" ] [
    "hello-ui" deploy-config
    [ bootstrap-profile staging-image-name file-name ] bind
] unit-test

[ ] [ "maze" shake-and-bake 1200000 small-enough? ] unit-test

[ ] [ "tetris" shake-and-bake 1500000 small-enough? ] unit-test

[ ] [ "spheres" shake-and-bake 1500000 small-enough? ] unit-test

[ ] [ "terrain" shake-and-bake 1700000 small-enough? ] unit-test

[ ] [ "bunny" shake-and-bake 2500000 small-enough? ] unit-test

os macosx? [
    [ ] [ "webkit-demo" shake-and-bake 500000 small-enough? ] unit-test
] when

[ ] [ "benchmark.regex-dna" shake-and-bake 900000 small-enough? ] unit-test

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
        "vocab:http/test" <static> >>default

    test-httpd
] unit-test

[ ] [
    "tools.deploy.test.5" shake-and-bake
    run-temp-image
] unit-test

: add-port ( url -- url' )
    >url clone "port" get >>port ;

[ ] [ "http://localhost/quit" add-port http-get 2drop ] unit-test

{
    "tools.deploy.test.6"
    "tools.deploy.test.7"
    "tools.deploy.test.9"
    "tools.deploy.test.10"
    "tools.deploy.test.11"
    "tools.deploy.test.12"
} [
    [ ] swap [
        shake-and-bake
        run-temp-image
    ] curry unit-test
] each

os windows? os macosx? or [
    [ ] [ "tools.deploy.test.8" shake-and-bake run-temp-image ] unit-test
] when

os macosx? [
    [ ] [ "tools.deploy.test.14" shake-and-bake run-temp-image ] unit-test
] when

[ { "a" "b" "c" } ] [
    "tools.deploy.test.15" shake-and-bake deploy-test-command
    { "a" "b" "c" } append
    ascii [ lines ] with-process-reader
    rest
] unit-test

[ ] [ "tools.deploy.test.16" shake-and-bake run-temp-image ] unit-test

[ ] [ "tools.deploy.test.17" shake-and-bake run-temp-image ] unit-test
