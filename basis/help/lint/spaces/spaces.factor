! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators.short-circuit formatting
io.directories io.encodings.utf8 io.files io.pathnames kernel
math namespaces prettyprint sequences vocabs.loader ;

IN: help.lint.spaces

: all-docs-files ( -- seq )
    vocab-roots get [
        recursive-directory-files [ "-docs.factor" tail? ] filter
    ] map concat ;

: lint-spaces ( -- )
    all-docs-files [
        dup utf8 file-lines [ 1 + 2array ] map-index
        [
            first [
                { [ CHAR: space = ] [ CHAR: " = ] } 1||
            ] trim-head
            "  " subseq-of?
        ] filter
        [ drop ] [
            swap <pathname> .
            [ first2 swap "%d: %s\n" printf ] each
        ] if-empty
    ] each ;
