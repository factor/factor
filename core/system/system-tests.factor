USING: accessors arrays calendar io.encodings.utf8 io.files
io.launcher io.pathnames kernel locals make sequences system tools.test ;
IN: system.tests

{ { t t t } } [
    vm-info
    vm-version vm-compiler vm-compile-time 3array
    [ subseq-of? ] with map
] unit-test

:: run-exit-test ( code -- stdout stderr status )
    vm-path :> executable
    image-path absolute-path :> image
    "" resource-path :> resources
    [
        <process>
            [
                executable , image "-i=" prepend ,
                resources "-resource-path=" prepend , "-no-user-init" ,
                "-e=USING: vocabs.loader ; \"system\" reload " code append ,
            ] { } make >>command
            "stdout" >>stdout "stderr" >>stderr +closed+ >>stdin
            10 seconds >>timeout
        run-process wait-for-process
        [ "stdout" utf8 file-contents "stderr" utf8 file-contents ] dip
    ] with-test-directory ;

{ "stdout" "stderr" 7 } [
    "USING: io system ; \"stdout\" write [ \"stderr\" write ] with-output>error 7 exit"
    run-exit-test
] unit-test

{ "beforeafter" "hook error output" 0 } [
    "USING: init io system ;
     [ \"after\" write [ \"hook error output\" write ] with-output>error ]
     \"exit-test\" add-shutdown-hook \"before\" write 0 exit"
    run-exit-test
] unit-test

! An unavailable local stream must not suppress global output or stderr.
{ "global output" "stderr" 13 } [
    "USING: io kernel namespaces system ; IN: system.exit-test
     TUPLE: broken-output ;
     M: broken-output stream-flush drop \"flush failed\" throw ;
     \"global output\" write [ \"stderr\" write ] with-output>error
     broken-output new output-stream [ 13 exit ] with-variable"
    run-exit-test
] unit-test

{ "global output" "local error output" 0 } [
    "USING: io system ; \"global output\" write
     [ \"local error output\" write 0 exit ] with-output>error"
    run-exit-test
] unit-test
