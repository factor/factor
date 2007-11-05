! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces continuations.private kernel.private init
assocs kernel vocabs words sequences memory io system arrays
continuations math definitions mirrors splitting parser classes
inspector layouts vocabs.loader prettyprint.config prettyprint
debugger io.streams.c io.streams.duplex io.files io.backend
quotations io.launcher words.private tools.deploy.config
bootstrap.image ;
IN: tools.deploy

<PRIVATE

: boot-image-name ( -- string )
    "boot." my-arch ".image" 3append ;

: stage1 ( -- )
    #! If stage1 image doesn't exist, create one.
    boot-image-name resource-path exists?
    [ my-arch make-image ] unless ;

: (copy-lines) ( stream -- stream )
    dup stream-readln [ print flush (copy-lines) ] when* ;

: copy-lines ( stream -- )
    [ (copy-lines) ] [ stream-close ] [ ] cleanup ;

: stage2 ( vm flags -- )
	[
        "\"" % swap % "\" -i=" %
        boot-image-name %
        [ " " % % ] each
    ] "" make
    dup print <process-stream>
    dup duplex-stream-out stream-close
    copy-lines ;

: ?append swap [ append ] [ drop ] if ;

: profile-string ( config -- string )
    [
        ""
        deploy-math? get " math" ?append
        deploy-compiler? get " compiler" ?append
        deploy-ui? get " ui" ?append
        native-io? " io" ?append
    ] bind ;

: deploy-command-line ( vm image vocab config -- vm flags )
    [
        "\"-include=" swap profile-string "\"" 3append ,

        "-deploy-vocab=" swap append ,

        "\"-output-image=" swap "\"" 3append ,

        "-no-stack-traces" ,
        
        "-no-user-init" ,
    ] { } make ;

PRIVATE>

: deploy* ( vm image vocab config -- )
    stage1 deploy-command-line stage2 ;

SYMBOL: deploy-implementation

HOOK: deploy deploy-implementation ( vocab -- )

USE-IF: macosx? tools.deploy.macosx

USE-IF: winnt? tools.deploy.windows
