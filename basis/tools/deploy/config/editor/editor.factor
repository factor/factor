! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io.pathnames kernel parser prettyprint sequences
splitting tools.deploy.config vocabs.loader vocabs.metadata ;
IN: tools.deploy.config.editor

: deploy-config-path ( vocab -- string )
    vocab-dir "deploy.factor" append-path ;

: deploy-config ( vocab -- assoc )
    dup default-config swap
    dup deploy-config-path vocab-file-contents
    parse-fresh [ first assoc-union ] unless-empty ;

: set-deploy-config ( assoc vocab -- )
    [ unparse-use string-lines ] dip
    dup deploy-config-path set-vocab-file-contents ;

: set-deploy-flag ( value key vocab -- )
    [ deploy-config [ set-at ] keep ] keep set-deploy-config ;
