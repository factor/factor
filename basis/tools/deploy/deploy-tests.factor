USING: bootstrap.image tools.test system io io.encodings.ascii
io.pathnames io.files io.files.info io.files.temp kernel
tools.deploy.config tools.deploy.config.editor literals
tools.deploy.backend math sequences io.launcher arrays
namespaces continuations layouts accessors urls math.parser
io.directories splitting tools.deploy tools.deploy.test vocabs ;

IN: tools.deploy.tests

! Delete all cached staging images in case syntax or
! other core vocabularies have changed and staging
! images are stale.
delete-staging-images

[ "nosuchvocab" deploy ] [ no-vocab? ] must-fail-with

[ "no such vocab, fool!" deploy ] [ bad-vocab-name? ] must-fail-with

! XXX: deploy-path is "resource:" by default, but deploying there in a
! test would pollute the Factor directory, so deploy test to temp.
{ { "Hello world" } } [
    H{
        { open-directory-after-deploy? f }
        { deploy-directory $[ temp-directory ] }
    } [
        "hello-world" deploy
        "hello-world" deploy-path 1array
        ascii [ read-lines ] with-process-reader
    ] with-variables
] long-unit-test

{ "math-threads-compiler-io-ui" } [
    "hello-ui" deploy-config config>profile
    staging-image-name file-name "." split second
] long-unit-test

{ } [ "tools.deploy.test.1" shake-and-bake run-temp-image ] long-unit-test
{ } [ "tools.deploy.test.2" shake-and-bake run-temp-image ] long-unit-test
{ } [ "tools.deploy.test.3" shake-and-bake run-temp-image ] long-unit-test
{ } [ "tools.deploy.test.4" shake-and-bake run-temp-image ] long-unit-test

USING: http.client http.server http.server.dispatchers
http.server.responses http.server.static io.servers ;

SINGLETON: quit-responder

M: quit-responder call-responder*
    2drop stop-this-server "Goodbye" <html-content> ;

: add-quot-responder ( responder -- responder )
    quit-responder "quit" add-responder ;

: test-httpd ( responder -- )
    main-responder [
        <http-server>
            0 >>insecure
            f >>secure
        start-server
        servers>> first addr>> port>>
        dup number>string "port-number" temp-file ascii set-file-contents
    ] with-variable "port" set ;

{ } [
    <dispatcher>
        add-quot-responder
        "vocab:http/test" <static> >>default
    test-httpd
] long-unit-test

{ } [ "tools.deploy.test.5" shake-and-bake run-temp-image ] long-unit-test

{ } [ URL" http://localhost/quit" "port" get >>port http-get 2drop ] long-unit-test

{ } [ "tools.deploy.test.6" shake-and-bake run-temp-image ] long-unit-test
{ } [ "tools.deploy.test.7" shake-and-bake run-temp-image ] long-unit-test

os windows? os macos? or [
    { } [ "tools.deploy.test.8" shake-and-bake run-temp-image ] long-unit-test
] when

{ } [ "tools.deploy.test.9" shake-and-bake run-temp-image ] long-unit-test
{ } [ "tools.deploy.test.10" shake-and-bake run-temp-image ] long-unit-test
{ } [ "tools.deploy.test.11" shake-and-bake run-temp-image ] long-unit-test
{ } [ "tools.deploy.test.12" shake-and-bake run-temp-image ] long-unit-test
{ } [ "tools.deploy.test.13" shake-and-bake run-temp-image ] long-unit-test

os macos? [
    { } [ "tools.deploy.test.14" shake-and-bake run-temp-image ] long-unit-test
] when

{ { "a" "b" "c" } } [
    "tools.deploy.test.15" shake-and-bake deploy-test-command
    { "a" "b" "c" } append
    ascii [ read-lines ] with-process-reader
    rest
] long-unit-test

{ } [ "tools.deploy.test.16" shake-and-bake run-temp-image ] long-unit-test
{ } [ "tools.deploy.test.17" shake-and-bake run-temp-image ] long-unit-test

{ t } [
    "tools.deploy.test.18" shake-and-bake
    deploy-test-command ascii [ readln ] with-process-reader
    test-image-path =
] long-unit-test

{ } [
    "resource:LICENSE.txt" "local-license.txt" temp-file copy-file
    "tools.deploy.test.19" shake-and-bake run-temp-image
] long-unit-test

{ "<?xml version=\"1.0\" encoding=\"UTF-8\"?><foo>Factor</foo>" } [
    "tools.deploy.test.20" shake-and-bake 1363000 small-enough?
    deploy-test-command ascii [ readln ] with-process-reader
] long-unit-test

{ "1 2 3" } [
    "tools.deploy.test.21" shake-and-bake 1260000 small-enough?
    deploy-test-command ascii [ readln ] with-process-reader
] long-unit-test

{ } [ "tools.deploy.test.22" shake-and-bake 800000 small-enough? ] long-unit-test

{ } [ "tools.deploy.test.23" shake-and-bake ] long-unit-test
