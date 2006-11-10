! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: command-line compiler errors generic help io io-internals
kernel kernel-internals listener math memory modules namespaces
optimizer parser sequences sequences-internals words ;

[
    print-warnings off

    [
        ! Wrap everything in a catch which starts a listener so
        ! you can see what went wrong, instead of dealing with a
        ! fep
        [
            "Cross-referencing..." print flush
            H{ } clone changed-words set-global
            H{ } clone crossref set-global xref-words

            cpu "x86" = [
                macosx?
                "resource:/library/compiler/x86/alien-macosx.factor"
                "resource:/library/compiler/x86/alien.factor"
                ? run-file
            ] when

            "compile" get [
                windows? [
                    "resource:/library/windows/dlls.factor"
                    run-file
                ] when

                \ number= compile
                \ + compile
                \ nth compile
                \ set-nth compile
                \ = compile

                ! Load UI backend
                "cocoa" get [
                    "library/ui/cocoa" require
                ] when

                "x11" get [
                    "library/ui/x11" require
                ] when

                windows? [
                    "library/ui/windows" require
                ] when

                ! Load native I/O code
                "native-io" get [
                    unix? [
                        "library/io/unix" require
                    ] when
                    windows? [
                        "library/io/windows" require
                    ] when
                ] when

                parse-command-line

                compile-all

                "Initializing native I/O..." print flush
                "native-io" get [ init-io ] when

                ! We only do this if we are compiled, otherwise
                ! it takes too long.
                "Building online help search index..." print
                flush
                H{ } clone parent-graph set-global xref-help
                H{ } clone term-index set-global index-help
            ] when
        ] no-parse-hook

        run-bootstrap-init

        [
            boot
            run-user-init
            "shell" get "shells" lookup execute
            0 exit
        ] set-boot

        f error set-global
        f error-continuation set-global

        [ compiled? ] word-subset length
        number>string write " compiled words" print

        [ symbol? ] word-subset length
        number>string write " symbol words" print

        all-words length
        number>string write " words total" print

        "Total bootstrap GC time: " write gc-time
        number>string write " ms" print

        "Bootstrapping is complete." print
        "Now, you can run ./f factor.image" print flush

        "factor.image" resource-path save-image
    ] [ print-error :c ] recover
] with-scope

0 exit
