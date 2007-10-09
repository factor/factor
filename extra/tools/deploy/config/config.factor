! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: vocabs.loader io.files io kernel sequences assocs
splitting parser prettyprint ;
IN: tools.deploy.config

SYMBOL: strip-globals?
SYMBOL: strip-word-props?
SYMBOL: strip-word-names?
SYMBOL: strip-dictionary?
SYMBOL: strip-debugger?
SYMBOL: strip-prettyprint?
SYMBOL: strip-c-types?

SYMBOL: deploy-math?
SYMBOL: deploy-compiled?
SYMBOL: deploy-io?
SYMBOL: deploy-ui?

SYMBOL: deploy-vm
SYMBOL: deploy-image

: default-config ( -- assoc )
    V{
        { strip-prettyprint? t }
        { strip-globals?     t }
        { strip-word-props?  t }
        { strip-word-names?  t }
        { strip-dictionary?  t }
        { strip-debugger?    t }
        { strip-c-types?     t }
        { deploy-math?       t }
        { deploy-compiled?   t }
        { deploy-io?         f }
        { deploy-ui?         f }
        ! default value for deploy.app
        { "stop-after-last-window?" t }
    } clone ;

: deploy-config-path ( vocab -- string )
    vocab-dir "deploy.factor" path+ ;

: deploy-config ( vocab -- assoc )
    default-config swap
    dup deploy-config-path vocab-file-contents
    parse-fresh dup empty? [ drop ] [ first union ] if ;

: set-deploy-config ( assoc vocab -- )
    >r unparse-use string-lines r>
    dup deploy-config-path set-vocab-file-contents ;

: set-deploy-flag ( value key vocab -- )
    [ deploy-config [ set-at ] keep ] keep set-deploy-config ;
