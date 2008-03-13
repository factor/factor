! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces continuations.private kernel.private init
assocs kernel vocabs words sequences memory io system arrays
continuations math definitions mirrors splitting parser classes
inspector layouts vocabs.loader prettyprint.config prettyprint
debugger io.streams.c io.streams.duplex io.files io.backend
quotations io.launcher words.private tools.deploy.config
bootstrap.image io.encodings.utf8 accessors ;
IN: tools.deploy.backend

: (copy-lines) ( stream -- )
    dup stream-readln dup
    [ print flush (copy-lines) ] [ 2drop ] if ;

: copy-lines ( stream -- )
    [ (copy-lines) ] with-disposal ;

: run-with-output ( arguments -- )
    <process>
        swap >>command
        +stdout+ >>stderr
        +closed+ >>stdin
    utf8 <process-stream>
    dup copy-lines
    process>> wait-for-process zero? [
        "Deployment failed" throw
    ] unless ;

: make-boot-image ( -- )
    #! If stage1 image doesn't exist, create one.
    my-boot-image-name resource-path exists?
    [ my-arch make-image ] unless ;

: ?, [ , ] [ drop ] if ;

: bootstrap-profile ( -- profile )
    [
        "math" deploy-math? get ?,
        "compiler" deploy-compiler? get ?,
        "ui" deploy-ui? get ?,
        "io" native-io? ?,
    ] { } make ;

: staging-image-name ( -- name )
    "staging."
    bootstrap-profile strip-word-names? [ "strip" add ] when
    "-" join ".image" 3append ;

: staging-command-line ( config -- flags )
    [
        [
            "-i=" my-boot-image-name append ,

            "-output-image=" staging-image-name append ,

            "-include=" bootstrap-profile " " join append ,

            strip-word-names? [ "-no-stack-traces" , ] when

            "-no-user-init" ,
        ] { } make
    ] bind ;

: run-factor ( vm flags -- )
    swap add* dup . run-with-output ; inline

: make-staging-image ( vm config -- )
    staging-command-line run-factor ;

: deploy-command-line ( image vocab config -- flags )
    [
        [
            "-i=" staging-image-name append ,

            "-run=tools.deploy.shaker" ,

            "-deploy-vocab=" swap append ,

            "-output-image=" swap append ,

            strip-word-names? [ "-no-stack-traces" , ] when
        ] { } make
    ] bind ;

: make-deploy-image ( vm image vocab config -- )
    make-boot-image
    dup staging-image-name exists? [
        >r pick r> tuck make-staging-image
    ] unless
    deploy-command-line run-factor ;

SYMBOL: deploy-implementation

HOOK: deploy* deploy-implementation ( vocab -- )
