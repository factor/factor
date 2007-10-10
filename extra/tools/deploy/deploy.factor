! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces continuations.private kernel.private init
assocs kernel vocabs words sequences memory io system arrays
continuations math definitions mirrors splitting parser classes
inspector layouts vocabs.loader prettyprint.config prettyprint
debugger io.streams.c io.streams.duplex io.files io.backend
quotations io.launcher words.private tools.deploy.config ;
IN: tools.deploy

<PRIVATE

: (copy-lines) ( stream -- stream )
    dup stream-readln [ print flush (copy-lines) ] when* ;

: copy-lines ( stream -- )
    [ (copy-lines) ] [ stream-close ] [ ] cleanup ;

: boot-image-name ( -- string )
    cpu dup "ppc" = [ os "-" rot 3append ] when ;

: stage2 ( vm flags -- )
	[
        "\"" % swap % "\" -i=boot." %
        boot-image-name
        % ".image" %
        [ " " % % ] each
    ] "" make
    dup print <process-stream>
    dup duplex-stream-out stream-close
    copy-lines ;

: profile-string ( config -- string )
    {
        { deploy-math? "math" }
        { deploy-compiled? "compiler" }
        { deploy-ui? "ui" }
        { deploy-io? "io" }
    } swap [ nip at ] curry assoc-subset values " " join ;

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
    deploy-command-line stage2 ;

: deploy ( vocab -- )
    "" resource-path cd
    vm over ".image" append rot dup deploy-config deploy* ;
