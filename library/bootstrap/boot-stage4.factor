! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: alien assembler command-line compiler console errors
generic inference kernel-internals listener lists math memory
namespaces parser presentation prettyprint random io
unparser words ;

"Bootstrap stage 4..." print

: warm-boot ( -- )
    #! A fully bootstrapped image has this as the boot
    #! quotation.
    init-assembler
    init-error-handler
    default-cli-args
    parse-command-line
    "null-stdio" get [ << null-stream f >> stdio set ] when ;

: shell ( str -- )
    #! This handles the -shell:<foo> cli argument.
    [ "shells" ] search execute ;

[
    boot
    warm-boot
    run-user-init
    "shell" get shell
    0 exit
] set-boot

warm-boot

terpri
"Unless you're working on the compiler, ignore the errors above." print
"Not every word compiles, by design." print
terpri

0 [ compiled? [ 1 + ] when ] each-word
unparse write " words compiled" print

0 [ drop 1 + ] each-word
unparse write " words total" print 

"Total bootstrap GC time: " write gc-time unparse write " ms" print

"Bootstrapping is complete." print
"Now, you can run ./f factor.image" print

! Save a bit of space
global [ stdio off ] bind

"factor.image" save-image
0 exit
