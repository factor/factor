! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators command-line io.directories kernel namespaces
sequences system tools.deploy.backend tools.deploy.config
tools.deploy.config.editor vocabs vocabs.loader vocabs.platforms ;
IN: tools.deploy

ERROR: no-vocab-main vocab ;

: check-vocab-main ( vocab -- vocab )
    [ require ] keep dup vocab-main [ no-vocab-main ] unless ;

: deploy ( vocab -- )
    dup find-vocab-root [ no-vocab ] unless
    check-vocab-main
    deploy-directory get [
        dup deploy-config [
            deploy*
        ] with-variables
    ] with-directory ;

: deploy-image-only ( vocab image -- )
    [ vm-path ] 2dip
    swap dup deploy-config make-deploy-image drop ;

USE-MACOSX: tools.deploy.macosx
USE-UNIX: tools.deploy.unix
USE-WINDOWS: tools.deploy.windows

: deploy-main ( -- )
    command-line get [ [ require ] [ deploy ] bi ] each ;

MAIN: deploy-main
