! Copyright (C) 2004, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
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
            P" resource:core/io/encodings/utf16/utf16.factor" forget
            "io.encodings.utf16" loaded-child-vocab-names [ forget-vocab ] each
        ] with-compilation-unit
    ] when ;

: default-image-name ( -- string )
    vm-path file-name os windows? [ "." split1-last drop ] when
    ".image" append resource-path ;

: load-component ( name -- )
    dup "* Loading the " write write " component" print
    "bootstrap." prepend require ;

: load-components ( -- )
    "include" "exclude" [ get-global split-words harvest ] bi@ diff
    [ load-component ] each ;

: print-time ( us -- )
    1,000,000,000 /i
    60 /mod swap
    number>string write
    " minutes and " write number>string write " seconds." print ;

: print-report ( -- )
    "Core bootstrap completed in " write core-bootstrap-time get print-time
    "Total bootstrap completed in " write bootstrap-time get print-time

    "Bootstrapping is complete." print
    "Now, you can run Factor:" print
    vm-path write " -i=" write "output-image" get print flush ;

: save/restore-error ( quot -- )
    error get-global
    original-error get-global
    error-continuation get-global
    [ call ] 3dip
    error-continuation set-global
    original-error set-global
    error set-global ; inline

CONSTANT: default-components
    "math compiler threads io tools ui ui.tools unicode help handbook"

[
    ! We time bootstrap
    nano-count

    ! parser.notes sets this to t in the global namespace.
    ! We have to change it back in finish-bootstrap.factor
    f parser-quiet? set-global

    default-image-name "output-image" set-global

    default-components "include" set-global
    "" "exclude" set-global

    strip-encodings

    (command-line) parse-command-line

    ! Set dll paths
    os windows? [ "windows" require ] when

    "staging" get [
        "stage2: deployment mode" print
    ] [
        "debugger" require
        "listener" require
    ] if

    load-components

    nano-count over - core-bootstrap-time set-global

    run-bootstrap-init

    nano-count swap - bootstrap-time set-global
    print-report

    "staging" get [
        "resource:basis/bootstrap/finish-staging.factor" run-file
    ] [
        "resource:basis/bootstrap/finish-bootstrap.factor" run-file
    ] if

    f error set-global
    f original-error set-global
    f error-continuation set-global
    "output-image" get save-image-and-exit
] [
    drop
    [
        load-help? off
        [ "resource:basis/bootstrap/bootstrap-error.factor" parse-file ] save/restore-error
        call
    ] with-scope
] recover
