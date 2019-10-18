! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: image
USING: arrays errors generic hashtables io assocs
kernel-internals kernel math memory modules namespaces parser
prettyprint sequences vectors words ;

"Bootstrap stage 1..." print flush

"resource:/core/bootstrap/layouts.factor" run-file
"resource:/core/bootstrap/primitives.factor" run-file

! Create a boot quotation
[
    ! Rehash hashtables, since core/tools/image creates them
    ! using the host image's hashing algorithms
    [ [ hashtable? ] instances [ rehash ] each ] %
    \ boot ,

    "core" require
    "core/help" require
    "core/compiler" require
    "core/tools" require
    "core/documentation" require
    "core/ui" require
    "core/ui/tools" require
    "core/ui/handbook" require
    "core/compiler/" architecture get append require
    "core/handbook" require

    [
        "resource:core/bootstrap/boot-stage2.factor"
        dup ?resource-path exists? [
            run-file
        ] [
            "Cannot find " write write "." print
            "Please move " write image write " to the same directory as the Factor sources," print
            "and try again." print
            1 exit
        ] if
    ] %
] [ ] make boot-quot set

vocabularies get [
    "!syntax" get [
        "syntax" over set-word-vocabulary
        >r "!" ?head drop r> 2dup set-word-name
    ] assoc-map "syntax" set
] bind

"!syntax" vocabularies get delete-at
