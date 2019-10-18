! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: command-line compiler errors generic help io io-internals
kernel kernel-internals listener math memory modules namespaces
optimizer parser sequences sequences-internals words prettyprint 
;

! Wrap everything in a catch which starts a listener so
! you can see what went wrong, instead of dealing with a
! fep
[
    "Cross-referencing..." print flush
    H{ } clone changed-words set-global
    H{ } clone crossref set-global xref-words
    xref-sources

    cpu "x86" = [
        "core/compiler/x86/cpuid" require
    ] when

    windows? [ "core/windows" require ] when

    "compile" get [
        \ number= compile
        \ + compile
        \ nth compile
        \ set-nth compile
        \ = compile

        ! Load UI backend
        "cocoa" get [ "core/ui/cocoa" require ] when
        "x11" get [ "core/ui/x11" require ] when
        winnt? [ "core/ui/windows" require ] when

        ! Load native I/O code
        "native-io" get [
            unix? [ "core/io/unix" require ] when
            windows? [ "core/io/windows" require ] when
        ] when

        parse-command-line

        compile-all

        "native-io" get [
            "Initializing native I/O..." print flush
            init-io
        ] when

        [ recompile ] parse-hook set-global
    ] when

    [
        boot
        [ run-user-init ] try
        [ "shell" get "shells" lookup execute ] try
        stdio get [ stream-flush ] when*
    ] set-boot

    "Building online help search index..." print
    flush
    H{ } clone help-tree set-global xref-help

    run-bootstrap-init

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
    "Now, you can run ./factor -i=factor.image" print flush

    "factor.image" resource-path save-image
] [ error-hook get call listener ] recover

0 exit
