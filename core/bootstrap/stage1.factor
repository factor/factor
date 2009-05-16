! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays debugger generic hashtables io assocs kernel.private
kernel math memory namespaces make parser prettyprint sequences
vectors words system splitting init io.files vocabs vocabs.loader
debugger continuations ;
QUALIFIED: bootstrap.image.private
IN: bootstrap.stage1

"Bootstrap stage 1..." print flush

"vocab:bootstrap/primitives.factor" run-file

load-help? off
{ "resource:core" } vocab-roots set

! Create a boot quotation for the target
[
    [
        ! Rehash hashtables, since bootstrap.image creates them
        ! using the host image's hashing algorithms. We don't
        ! use each-object here since the catch stack isn't yet
        ! set up.
        gc
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
        "vocab:bootstrap/stage2.factor"
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
bootstrap.image.private:bootstrap-boot-quot set
