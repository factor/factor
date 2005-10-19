! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien assembler compiler compiler-backend
errors generic hashtables io io-internals kernel
kernel-internals lists math memory namespaces optimizer parser
sequences sequences-internals words ;

: pull-in ( ? list -- )
    swap [ [ dup print run-resource ] each ] [ drop ] if ;

"Loading compiler backend..." print

cpu "x86" = [
    "/library/compiler/x86/load.factor"
    "/library/alien/primitive-types.factor"
] pull-in

cpu "ppc" = [
    "/library/compiler/ppc/load.factor"
    "/library/alien/primitive-types.factor"
] pull-in

"Loading more library code..." print

t [
    "/library/alien/malloc.factor"
    "/library/io/buffer.factor"

    "/library/httpd/load.factor"
    "/library/sdl/load.factor"
    "/library/opengl/load.factor"
    "/library/freetype/load.factor"
    "/library/ui/load.factor"
    "/library/help/tutorial.factor"
] pull-in

! Handle -libraries:... overrides
parse-command-line

: compile? "compile" get supported-cpu? and ;

compile? [
    "Compiling base..." print

    {
        uncons 1+ 1- + <= > >= mod length
        nth-unsafe set-nth-unsafe
        = string>number number>string scan solve-recursion
        kill-set kill-node (generate)
    } [ compile ] each
] when

compile? [
    unix? [
        "/library/unix/load.factor"
    ] pull-in
    
    os "win32" = [
        "/library/win32/load.factor"
    ] pull-in
] when

"Building cross-reference database..." print
recrossref

compile? [
    "Compiling system..." print
    compile-all
    terpri
    "Unless you're working on the compiler, ignore the errors above." print
    "Not every word compiles, by design." print
    terpri
    "Initializing native I/O..." print
    init-io
] when

[
    boot
    run-user-init
    "shell" get [ "shells" ] search execute
    0 exit
] set-boot

0 [ compiled? [ 1+ ] when ] each-word
number>string write " words compiled" print

0 [ drop 1+ ] each-word
number>string write " words total" print 

"Total bootstrap GC time: " write gc-time
number>string write " ms" print

"Bootstrapping is complete." print
"Now, you can run ./f factor.image" print

"factor.image" save-image
0 exit

FORGET: pull-in
FORGET: compile?
