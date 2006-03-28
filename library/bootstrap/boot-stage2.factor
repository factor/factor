! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler compiler-backend help io io-internals kernel
kernel-internals lists math memory namespaces optimizer parser
sequences sequences-internals words ;

"Cross-referencing..." print
xref-words
xref-articles

"compile" get [
    "native-io" get [
        unix? [
            "/library/unix/load.factor" run-resource
        ] when

    ] when
    windows? [
        "/library/windows/load.factor" run-resource
    ] when
    
    parse-command-line

    "Compiling base..." print flush

    {
        uncons 1+ 1- + <= > >= mod length
        nth-unsafe set-nth-unsafe
        = string>number number>string scan
        kill-values (generate)
    } [ compile ] each

    "Compiling system..." print flush
    compile-all
    
    terpri
    "Unless you're working on the compiler, ignore the errors above." print
    "Not every word compiles, by design." print
    terpri flush
    
    "Initializing native I/O..." print flush
    "native-io" get [ init-io ] when
    
    "cocoa" get [
        "/library/cocoa/load.factor" run-resource
    ] when
    
    "x11" get [
        "/library/x11/load.factor" run-resource
    ] when

    windows? "native-io" get and [
        "/library/windows/ui.factor" run-resource
        "/library/windows/clipboard.factor" run-resource
        compile-all
    ] when
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

"factor.image" save-image
0 exit
