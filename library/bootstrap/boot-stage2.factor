! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien assembler compiler compiler-backend
errors generic hashtables io io-internals kernel
kernel-internals lists math memory namespaces optimizer parser
sequences sequences-internals words ;

"Loading compiler backend..." print

cpu "x86" = [
    "/library/compiler/x86/load.factor" run-resource
] when

cpu "ppc" = [
    "/library/compiler/ppc/load.factor" run-resource
] when

cpu "amd64" = [
    "/library/compiler/amd64/load.factor" run-resource
] when

"Loading more library code..." print

[
    "/library/alien/malloc.factor"
    "/library/io/buffer.factor"

    "/library/sdl/load.factor"
    "/library/opengl/load.factor"
    "/library/freetype/load.factor"
    "/library/ui/load.factor"
    "/library/help/load.factor"
] [
    dup print run-resource
] each

! Handle -libraries:... overrides
parse-command-line

"compile" get supported-cpu? and [
    "native-io" get [
        unix? [
            "/library/unix/load.factor" run-resource
        ] when

        os "win32" = [
            "/library/win32/load.factor" run-resource
        ] when
    ] when

    "Compiling base..." print

    {
        uncons 1+ 1- + <= > >= mod length
        nth-unsafe set-nth-unsafe
        = string>number number>string scan
        kill-set kill-node (generate)
    } [ compile ] each

    "Compiling system..." print
    compile-all
    
    terpri
    "Unless you're working on the compiler, ignore the errors above." print
    "Not every word compiles, by design." print
    terpri
    
    "Initializing native I/O..." print
    "native-io" get [ init-io ] when
] when

[
    boot
    run-user-init
    "shell" get [ "shells" ] search execute
    0 exit
] set-boot

"Building cross-reference database..." print
recrossref

[ compiled? ] word-subset length
number>string write " compiled words" print

[ symbol? ] word-subset length
number>string write " symbol words" print

all-words length
number>string write " words total" print 

"Total bootstrap GC time: " write gc-time
number>string write " ms" print

"Bootstrapping is complete." print
"Now, you can run ./f factor.image" print

"factor.image" save-image
0 exit
