! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors init namespaces words words.symbol io
kernel.private math memory continuations kernel io.files
io.pathnames io.backend system parser vocabs sequences
vocabs.loader combinators splitting source-files strings
definitions assocs compiler.units math.parser
generic sets command-line ;
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

: print-time ( ms -- )
    1000 /i
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
    error-continuation get-global
    [ call ] 2dip
    error-continuation set-global
    error set-global ; inline

[
    ! We time bootstrap
    millis

    default-image-name "output-image" set-global

    "math compiler threads help io tools ui ui.tools unicode handbook" "include" set-global
    "" "exclude" set-global

    strip-encodings

    (command-line) parse-command-line

    ! Set dll paths
    os wince? [ "windows.ce" require ] when
    os winnt? [ "windows.nt" require ] when

    "staging" get "deploy-vocab" get or [
        "stage2: deployment mode" print
    ] [
        "debugger" require
        "inspector" require
        "tools.errors" require
        "listener" require
        "none" require
    ] if

    load-components

    millis over - core-bootstrap-time set-global

    run-bootstrap-init

    f error set-global
    f error-continuation set-global

    millis swap - bootstrap-time set-global
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
