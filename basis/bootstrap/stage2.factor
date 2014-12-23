! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: command-line compiler.units continuations definitions io
io.pathnames kernel math math.parser memory namespaces parser
parser.notes sequences sets splitting system
vocabs vocabs.loader ;
IN: bootstrap.stage2

SYMBOL: core-bootstrap-time

SYMBOL: bootstrap-time

: strip-encodings ( -- )
    os unix? [
        [
            P" resource:core/io/encodings/utf16/utf16.factor" 
            P" resource:core/io/encodings/utf16n/utf16n.factor" [ forget ] bi@
            "io.encodings.utf16" 
            "io.encodings.utf16n" [ child-vocabs [ forget-vocab ] each ] bi@
        ] with-compilation-unit
    ] when ;

: default-image-name ( -- string )
    vm file-name os windows? [ "." split1-last drop ] when
    ".image" append resource-path ;

: load-components ( -- )
    "include" "exclude"
    [ get-global " " split harvest ] bi@
    diff
    [ "bootstrap." prepend require ] each ;

: count-words ( pred -- )
    all-words swap count number>string write ; inline

: print-time ( us -- )
    1,000,000,000 /i
    60 /mod swap
    number>string write
    " minutes and " write number>string write " seconds." print ;

: print-report ( -- )
    "Core bootstrap completed in " write core-bootstrap-time get print-time
    "Bootstrap completed in "      write bootstrap-time      get print-time

    "Bootstrapping is complete." print
    "Now, you can run Factor:" print
    vm write " -i=" write "output-image" get print flush ;

: save/restore-error ( quot -- )
    error get-global
    original-error get-global
    error-continuation get-global
    [ call ] 3dip
    error-continuation set-global
    original-error set-global
    error set-global ; inline

[
    ! We time bootstrap
    nano-count

    ! parser.notes sets this to t in the global namespace.
    ! We have to change it back in finish-bootstrap.factor
    f parser-quiet? set-global

    default-image-name "output-image" set-global

    "math compiler threads help io tools ui ui.tools unicode handbook" "include" set-global
    "" "exclude" set-global

    strip-encodings

    (command-line) rest parse-command-line

    ! Set dll paths
    os windows? [ "windows" require ] when

    "staging" get "deploy-vocab" get or [
        "stage2: deployment mode" print
    ] [
        "debugger" require
        "listener" require
        "none" require
    ] if

    load-components

    nano-count over - core-bootstrap-time set-global

    run-bootstrap-init

    f error set-global
    f original-error set-global
    f error-continuation set-global

    nano-count swap - bootstrap-time set-global
    print-report

    "deploy-vocab" get [
        "tools.deploy.shaker" run
    ] [
        "staging" get [
            "vocab:bootstrap/finish-staging.factor" run-file
        ] [
            "vocab:bootstrap/finish-bootstrap.factor" run-file
        ] if

        "output-image" get save-image-and-exit
    ] if
] [
    drop
    [
        load-help? off
        [ "vocab:bootstrap/bootstrap-error.factor" parse-file ] save/restore-error
        call
    ] with-scope
] recover
