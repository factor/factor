! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler errors generic help io io-internals kernel
kernel-internals listener math memory namespaces optimizer
parser sequences sequences-internals words ;

! Wrap everything in a catch which starts a listener so you can
! see what went wrong, instead of dealing with a fep
[
    "Cross-referencing..." print flush
    H{ } clone crossref set-global xref-words

    cpu "x86" = [
        macosx?
        "/library/compiler/x86/alien-macosx.factor"
        "/library/compiler/x86/alien.factor"
        ? run-resource
    ] when

    "compile" get [
        "native-io" get [
            unix? [
                "/library/io/unix/load.factor" run-resource
            ] when
        ] when

        windows? [
            "/library/windows/load.factor" run-resource
        ] when

        parse-command-line

        "Compiling base..." print flush

        [
            \ + compile
            \ = compile
            { "kernel" "sequences" "assembler" } compile-vocabs

            "Compiling system..." print flush
            compile-all
        ] with-class<cache

        terpri
        "Unless you're working on the compiler, ignore the errors above." print
        "Not every word compiles, by design." print
        terpri flush

        "Initializing native I/O..." print flush
        "native-io" get [ init-io ] when

        "cocoa" get [
            "/library/compiler/alien/objc/load.factor" run-resource
            "/library/ui/cocoa/load.factor" run-resource
        ] when

        "x11" get [
            "/library/ui/x11/load.factor" run-resource
        ] when

        windows? "native-io" get and [
            "/library/windows/ui.factor" run-resource
            "/library/windows/clipboard.factor" run-resource
            compile-all
        ] when
    ] when

    "Building online help search index..." print flush
    H{ } clone parent-graph set-global xref-help
    H{ } clone term-index set-global index-help

    [
        boot
        run-user-init
        "shell" get "shells" lookup execute
        0 exit
    ] set-boot

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
] [ print-error listener ] recover

0 exit
