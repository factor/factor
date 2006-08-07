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
        windows? [
            "/library/windows/load.factor" run-resource
            "/library/ui/windows/load.factor" run-resource
        ] when

        "native-io" get [
            unix? [
                "/library/io/unix/load.factor" run-resource
            ] when
            windows? [
                "/library/io/windows/load.factor" run-resource
            ] when
        ] when

        parse-command-line

        "Compiling base..." print flush

        [
            \ number= compile
            \ + compile
            \ nth compile
            \ set-nth compile
            \ = compile
            { "kernel" "sequences" "assembler" } compile-vocabs

            "Compiling system..." print flush
            compile-all
        ] with-class<cache

        "Initializing native I/O..." print flush
        "native-io" get [ init-io ] when

        "cocoa" get [
            "/library/compiler/alien/objc/load.factor" run-resource
            "/library/ui/cocoa/load.factor" run-resource
        ] when

        "x11" get [
            "/library/ui/x11/load.factor" run-resource
        ] when
        
        ! We only do this if we are compiled, otherwise it takes
        ! too long.

        "Building online help search index..." print flush
        H{ } clone parent-graph set-global xref-help
        H{ } clone term-index set-global index-help
    ] when

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
] [ print-error :c ] recover

0 exit
