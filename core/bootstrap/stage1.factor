! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: bootstrap.stage1
USING: arrays debugger generic hashtables io assocs
kernel.private kernel math memory namespaces parser
prettyprint sequences vectors words system splitting
init io.files bootstrap.image bootstrap.image.private vocabs
vocabs.loader system ;

{ "resource:core" } vocab-roots set

"Bootstrap stage 1..." print flush

"resource:core/bootstrap/primitives.factor" run-file

! Create a boot quotation
[
    ! Rehash hashtables, since core/tools/image creates them
    ! using the host image's hashing algorithms

    [ [ hashtable? ] instances [ rehash ] each ] %

    \ boot ,

    "math.integers" require
    "math.floats" require
    "memory" require
    "io.streams.c" require
    "vocabs.loader" require
    "syntax" require
    "bootstrap.layouts" require

    [
        "resource:core/bootstrap/stage2.factor"
        dup ?resource-path exists? [
            run-file
        ] [
            "Cannot find " write write "." print
            "Please move " write image write " to the same directory as the Factor sources," print
            "and try again." print
            1 exit
        ] if
    ] %
] [ ] make bootstrap-boot-quot set
