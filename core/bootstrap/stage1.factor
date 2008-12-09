! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays debugger generic hashtables io assocs
kernel.private kernel math memory namespaces make parser
prettyprint sequences vectors words system splitting
init io.files bootstrap.image bootstrap.image.private vocabs
vocabs.loader system debugger continuations ;
IN: bootstrap.stage1

"Bootstrap stage 1..." print flush

"resource:core/bootstrap/primitives.factor" run-file

load-help? off
{ "resource:core" } vocab-roots set

! Create a boot quotation for the target
[
    [
        ! Rehash hashtables, since bootstrap.image creates them
        ! using the host image's hashing algorithms. We don't
        ! use each-object here since the catch stack isn't yet
        ! set up.
        begin-scan
        [ hashtable? ] pusher [ (each-object) ] dip
        end-scan
        [ rehash ] each
        boot
    ] %

    "math.integers" require
    "math.floats" require
    "memory" require
    
    "io.streams.c" require
    "vocabs.loader" require
    
    "syntax" require
    "bootstrap.layouts" require

    [
        "resource:basis/bootstrap/stage2.factor"
        dup exists? [
            run-file
        ] [
            "Cannot find " write write "." print
            "Please move " write image write " to the same directory as the Factor sources," print
            "and try again." print
            1 exit
        ] if
    ] %
] [ ] make
bootstrap-boot-quot set
