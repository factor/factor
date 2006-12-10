! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: command-line compiler errors generic help io io-internals
kernel kernel-internals listener math memory modules namespaces
optimizer parser sequences sequences-internals words prettyprint 
;

! Wrap everything in a scope where we disable print-warnings,
! so that people don't get confused thinking bootstrap failed
! because the compiler prints stuff
[
    print-warnings off

    ! Wrap everything in a catch which starts a listener so
    ! you can see what went wrong, instead of dealing with a
    ! fep
    [
        "Cross-referencing..." print flush
        H{ } clone changed-words set-global
        H{ } clone crossref set-global xref-words

        cpu "x86" = [
            macosx?
            "resource:/core/compiler/x86/alien-macosx.factor"
            "resource:/core/compiler/x86/alien.factor"
            ? run-file
        ] when

        "compile" get [
            windows? [
                "resource:/core/windows/dlls.factor"
                run-file
            ] when

            \ number= compile
            \ + compile
            \ nth compile
            \ set-nth compile
            \ = compile

            ! Load UI backend
            "cocoa" get [
                "core/ui/cocoa" require
            ] when

            "x11" get [
                "core/ui/x11" require
            ] when

            windows? [
                "core/ui/windows" require
            ] when

            ! Load native I/O code
            "native-io" get [
                unix? [
                    "core/io/unix" require
                ] when
                windows? [
                    "core/io/windows" require
                ] when
            ] when

            parse-command-line

            compile-all

            "Initializing native I/O..." print flush
            "native-io" get [ init-io ] when

        ] when

        [
            boot
            [ run-user-init ] try
            [ "shell" get "shells" lookup execute ] try
            0 exit
        ] set-boot

        "compile" get [ 
            [ recompile ] parse-hook set-global
        ] when

        "Building online help search index..." print
        flush
        H{ } clone parent-graph set-global xref-help

        [ run-bootstrap-init ] try

        f error set-global
        f error-continuation set-global

        : count-words all-words swap subset length pprint ;

        [ compiled? ] count-words " compiled words" print
        [ symbol? ] count-words " symbol words" print
        [ ] count-words " words total" print

        FORGET: count-words

        "Total bootstrap GC time: " write gc-time
        number>string write " ms" print

        "Bootstrapping is complete." print
        "Now, you can run ./f factor.image" print flush

        "factor.image" resource-path save-image
    ] [ print-error :c ] recover
] with-scope

0 exit
