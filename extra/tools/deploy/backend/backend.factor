! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces continuations.private kernel.private init
assocs kernel vocabs words sequences memory io system arrays
continuations math definitions mirrors splitting parser classes
inspector layouts vocabs.loader prettyprint.config prettyprint
debugger io.streams.c io.streams.duplex io.files io.backend
quotations io.launcher words.private tools.deploy.config
bootstrap.image ;
IN: tools.deploy.backend

: (copy-lines) ( stream -- stream )
    dup stream-readln [ print flush (copy-lines) ] when* ;

: copy-lines ( stream -- )
    [ (copy-lines) ] [ stream-close ] [ ] cleanup ;

: run-with-output ( descriptor -- )
    <process-stream>
    dup duplex-stream-out stream-close
    copy-lines ;

: boot-image-name ( -- string )
    "boot." my-arch ".image" 3append ;

: make-boot-image ( -- )
    #! If stage1 image doesn't exist, create one.
    boot-image-name resource-path exists?
    [ my-arch make-image ] unless ;

: ?, [ , ] [ drop ] if ;

: bootstrap-profile ( config -- profile )
    [
        [
            "math" deploy-math? get ?,
            "compiler" deploy-compiler? get ?,
            "ui" deploy-ui? get ?,
            "io" native-io? ?,
        ] { } make
    ] bind ;

: staging-image-name ( profile -- name )
    "staging." swap bootstrap-profile "-" join ".image" 3append ;

: staging-command-line ( config -- flags )
    [
        "-i=" boot-image-name append ,

        "-output-image=" over staging-image-name append ,

        "-include=" swap bootstrap-profile " " join append ,

        "-no-stack-traces" ,

        "-no-user-init" ,
    ] { } make ;

: run-factor ( vm flags -- )
    dup . swap add* run-with-output ; inline

: make-staging-image ( vm config -- )
    staging-command-line run-factor ;

: deploy-command-line ( image vocab config -- flags )
    [
        "-i=" swap staging-image-name append ,

        "-run=tools.deploy.shaker" ,

        "-deploy-vocab=" swap append ,

        "-output-image=" swap append ,

        "-no-stack-traces" ,
    ] { } make ;

: make-deploy-image ( vm image vocab config -- )
    dup staging-image-name exists? [
        >r pick r> tuck make-staging-image
    ] unless
    deploy-command-line run-factor ;

SYMBOL: deploy-implementation

HOOK: deploy* deploy-implementation ( vocab -- )
