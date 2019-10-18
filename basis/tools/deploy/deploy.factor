! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.deploy.backend system vocabs vocabs.loader kernel
combinators tools.deploy.config.editor ;
IN: tools.deploy

ERROR: no-vocab-main vocab ;

: check-vocab-main ( vocab -- vocab )
    [ require ] keep dup vocab-main [ no-vocab-main ] unless ;

: deploy ( vocab -- )
    dup find-vocab-root [ check-vocab-main deploy* ] [ no-vocab ] if ;

: deploy-image-only ( vocab image -- ) 
    [ vm ] 2dip
    swap dup deploy-config make-deploy-image drop ;

{
    { [ os macosx? ] [ "tools.deploy.macosx" ] }
    { [ os windows? ] [ "tools.deploy.windows" ] }
    { [ os unix? ] [ "tools.deploy.unix" ] }
} cond require
