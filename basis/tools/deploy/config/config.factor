! Copyright (C) 2007, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs combinators.smart hashtables kernel math
namespaces sequences vocabs ;
IN: tools.deploy.config

SYMBOL: deploy-name

SYMBOL: deploy-ui?
SYMBOL: deploy-console?
SYMBOL: deploy-math?
SYMBOL: deploy-unicode?
SYMBOL: deploy-threads?
SYMBOL: deploy-help?

SYMBOL: deploy-io

CONSTANT: deploy-io-options
    {
        { 1 "Level 1 - No input/output" }
        { 2 "Level 2 - Basic ANSI C streams" }
        { 3 "Level 3 - Non-blocking streams and networking" }
    }

: strip-io? ( -- ? ) deploy-io get 1 = ;

: native-io? ( -- ? ) deploy-io get 3 = ;

SYMBOL: deploy-reflection

CONSTANT: deploy-reflection-options
    {
        { 1 "Level 1 - No reflection" }
        { 2 "Level 2 - Retain word names" }
        { 3 "Level 3 - Prettyprinter" }
        { 4 "Level 4 - Debugger" }
        { 5 "Level 5 - Parser" }
        { 6 "Level 6 - Full environment" }
    }

: strip-word-names? ( -- ? ) deploy-reflection get 2 < ;
: strip-prettyprint? ( -- ? ) deploy-reflection get 3 < ;
: strip-debugger? ( -- ? ) deploy-reflection get 4 < ;
: strip-dictionary? ( -- ? ) deploy-reflection get 5 < ;
: strip-globals? ( -- ? ) deploy-reflection get 6 < ;

SYMBOL: deploy-word-props?
SYMBOL: deploy-word-defs?
SYMBOL: deploy-c-types?

SYMBOL: deploy-vm
SYMBOL: deploy-image

: default-config ( vocab -- assoc )
    vocab-name deploy-name associate H{
        { deploy-ui?                f }
        { deploy-console?           t }
        { deploy-io                 3 }
        { deploy-reflection         1 }
        { deploy-threads?           t }
        { deploy-help?              f }
        { deploy-unicode?           f }
        { deploy-math?              t }
        { deploy-word-props?        f }
        { deploy-word-defs?         f }
        { deploy-c-types?           f }
        ! default value for deploy.macos
        { "stop-after-last-window?" t }
    } assoc-union ;

SYMBOL: deploy-directory
"resource:" deploy-directory set-global

: config>profile ( config -- profile )
    {
        ! The order should be similar to default-components in
        ! bootstrap.stage2.
        [ deploy-math? of "math" f ? ]
        [ deploy-threads? of "threads" f ? ]
        [ drop "compiler" ]
        [ deploy-io of 3 = "io" f ? ]
        [ deploy-ui? of "ui" f ? ]
        [ deploy-unicode? of "unicode" f ? ]
        [ deploy-help? of "help" f ? ]
    } cleave>array sift ;
