! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: image
USING: arrays errors generic hashtables io kernel
kernel-internals math memory modules namespaces parser
prettyprint sequences vectors words ;

"Bootstrap stage 1..." print flush

"resource:/core/bootstrap/primitives.factor" run-file

! The [ ] make form creates a boot quotation
[
    \ boot ,

    "core" require
    "core/help" require
    "core/tools" require
    "core/compiler" require
    "core/io/buffer" require
    "core/ui" require
    "core/ui/tools" require
    "core/compiler/" architecture get append require
    "core/handbook" require

    [
        "resource:/core/bootstrap/boot-stage2.factor"
        run-file
    ] %
] [ ] make

vocabularies get [
    "!syntax" get hash>alist [
        first2
        "syntax" over set-word-vocabulary
        >r "!" ?head drop r> 2dup set-word-name
        2array
    ] map alist>hash "syntax" set
] bind

"!syntax" vocabularies get remove-hash

"Building generic words..." print flush
all-words [ generic? ] subset [ make-generic ] each
