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
        +low-priority+ >>priority
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
        "random" deploy-random? get ?,
    ] { } make ;

: staging-image-name ( profile -- name )
    "staging."
    swap strip-word-names? [ "strip" add ] when
    "-" join ".image" 3append temp-file ;

DEFER: ?make-staging-image

: staging-command-line ( profile -- flags )
    [
        dup empty? [
            "-i=" my-boot-image-name append ,
        ] [
            dup 1 head* ?make-staging-image

            "-resource-path=" "" resource-path append ,

            "-i=" over 1 head* staging-image-name append ,

            "-run=tools.deploy.restage" ,
        ] if

        "-output-image=" over staging-image-name append ,

        "-include=" swap " " join append ,

        strip-word-names? [ "-no-stack-traces" , ] when

        "-no-user-init" ,
    ] { } make ;

: run-factor ( vm flags -- )
    swap add* dup . run-with-output ; inline

: make-staging-image ( profile -- )
    vm swap staging-command-line run-factor ;

: ?make-staging-image ( profile -- )
    dup staging-image-name exists?
    [ drop ] [ make-staging-image ] if ;

: deploy-command-line ( image vocab config -- flags )
    [
        bootstrap-profile ?make-staging-image

        [
            "-i=" bootstrap-profile staging-image-name append ,

            "-resource-path=" "" resource-path append ,

            "-run=tools.deploy.shaker" ,

            "-deploy-vocab=" prepend ,

            "-output-image=" prepend ,

            strip-word-names? [ "-no-stack-traces" , ] when
        ] { } make
    ] bind ;

: make-deploy-image ( vm image vocab config -- )
    make-boot-image
    deploy-command-line run-factor ;

SYMBOL: deploy-implementation

HOOK: deploy* deploy-implementation ( vocab -- )
