! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel parser prettyprint prettyprint.config
sequences splitting tools.deploy.config vocabs.metadata ;
IN: tools.deploy.config.editor

: deploy-config-path ( vocab -- path/f )
    "deploy.factor" vocab-file-path ;

: deploy-config ( vocab -- assoc )
    [ default-config ] keep
    "deploy.factor" vocab-file-lines
    parse-fresh [ first assoc-union ] unless-empty ;

: set-deploy-config ( assoc vocab -- )
    [ [ unparse-use ] without-limits split-lines ] dip
    "deploy.factor" set-vocab-file-lines ;

: set-deploy-flag ( value key vocab -- )
    [ deploy-config [ set-at ] keep ] keep set-deploy-config ;
