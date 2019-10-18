! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs continuations debugger destructors generic
hash-sets hashtables init io io.files kernel kernel.private
make math memory namespaces parser parser.notes prettyprint
sequences splitting system vectors vocabs vocabs.loader words ;
QUALIFIED: bootstrap.image.private
IN: bootstrap.stage1

"Bootstrap stage 1..." print flush

"vocab:bootstrap/primitives.factor" run-file

load-help? off
{ "resource:core" } vocab-roots set

! Create a boot quotation for the target by collecting all top-level
! forms into a quotation, surrounded by some boilerplate.
[
    [
        ! Rehash hashtables first, since bootstrap.image creates
        ! them using the host image's hashing algorithms.
        [ hashtable? ] instances [ hashtables:rehash ] each
        [ hash-set? ] instances [ hash-sets:rehash ] each
        boot
    ] %

    "math.integers" require
    "math.ratios" require
    "math.floats" require
    "memory" require

    "io.streams.c" require
    "io.streams.byte-array" require ! for utf16 on Windows
    "vocabs.loader" require

    "syntax" require
    "bootstrap.layouts" require

    [
        f parser-quiet? set-global

        init-resource-path

        "resource:basis/bootstrap/stage2.factor"
        dup exists? [
            run-file
        ] [
            "Cannot find " write write "." print
            "Please move " write image-path write " into the same directory as the Factor sources," print
            "and try again." print
            1 (exit)
        ] if
    ] %
] [ ] make
OBJ-STARTUP-QUOT
bootstrap.image.private:special-objects get set-at
