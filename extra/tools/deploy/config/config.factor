! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: vocabs.loader io.files io kernel sequences assocs
splitting parser prettyprint namespaces math ;
IN: tools.deploy.config

SYMBOL: deploy-ui?
SYMBOL: deploy-compiler?
SYMBOL: deploy-math?

SYMBOL: deploy-io

: deploy-io-options
    {
        { 1 "Level 1 - No input/output" }
        { 2 "Level 2 - Basic ANSI C streams" }
        { 3 "Level 3 - Non-blocking streams and networking" }
    } ;

: strip-io? deploy-io get 1 = ;

: native-io? deploy-io get 3 = ;

SYMBOL: deploy-reflection

: deploy-reflection-options
    {
        { 1 "Level 1 - No reflection" }
        { 2 "Level 2 - Retain word names" }
        { 3 "Level 3 - Prettyprinter" }
        { 4 "Level 4 - Debugger" }
        { 5 "Level 5 - Parser" }
        { 6 "Level 6 - Full environment" }
    } ;

: strip-word-names? deploy-reflection get 2 < ;
: strip-prettyprint? deploy-reflection get 3 < ;
: strip-debugger? deploy-reflection get 4 < ;
: strip-dictionary? deploy-reflection get 5 < ;
: strip-globals? deploy-reflection get 6 < ;

SYMBOL: deploy-word-props?
SYMBOL: deploy-c-types?

SYMBOL: deploy-vm
SYMBOL: deploy-image

: default-config ( -- assoc )
    V{
        { deploy-ui?                f }
        { deploy-io                 2 }
        { deploy-reflection         1 }
        { deploy-compiler?          t }
        { deploy-math?              t }
        { deploy-word-props?        f }
        { deploy-c-types?           f }
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
