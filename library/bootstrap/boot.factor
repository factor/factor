! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: lists parser namespaces stdio kernel vectors words
hashtables ;

"/library/bootstrap/primitives.factor" run-resource

: pull-in ( list -- ) [ parse-resource append, ] each ;

! The make-list form creates a boot quotation
[
    [
        "/version.factor"
        "/library/stack.factor"
        "/library/combinators.factor"
        "/library/arrays.factor"
        "/library/kernel.factor"
        "/library/cons.factor"
        "/library/assoc.factor"
        "/library/math/math.factor"
        "/library/math/integer.factor"
        "/library/math/ratio.factor"
        "/library/math/float.factor"
        "/library/math/complex.factor"
        "/library/lists.factor"
        "/library/vectors.factor"
        "/library/strings.factor"
        "/library/hashtables.factor"
        "/library/words.factor"
        "/library/namespaces.factor"
        "/library/sbuf.factor"
        "/library/errors.factor"
        "/library/continuations.factor"
        "/library/threads.factor"
        "/library/io/stream.factor"
        "/library/io/stdio.factor"
        "/library/io/io-internals.factor"
        "/library/io/stream-impl.factor"
        "/library/vocabularies.factor"
        "/library/syntax/parse-numbers.factor"
        "/library/syntax/parser.factor"
        "/library/syntax/parse-stream.factor"
        "/library/syntax/generic.factor"
        "/library/syntax/parse-syntax.factor"
        "/library/syntax/unparser.factor"
        "/library/syntax/prettyprint.factor"
        "/library/io/files.factor"
        "/library/cli.factor"
    ] pull-in

    "delegate" [ "generic" ] search
    "object" [ "generic" ] search
    "classes" [ "generic" ] search

    vocabularies get [ "generic" off ] bind

    reveal
    reveal
    reveal

    [
        "/library/generic/generic.factor"
        "/library/generic/slots.factor"
        "/library/generic/object.factor"
        "/library/generic/null.factor"
        "/library/generic/builtin.factor"
        "/library/generic/predicate.factor"
        "/library/generic/union.factor"
        "/library/generic/complement.factor"
        "/library/generic/tuple.factor"
    
        "/library/bootstrap/init.factor"
    ] pull-in
] make-list

"boot" [ "kernel" ] search swons

vocabularies get [
    "!syntax" get "syntax" set

    "syntax" get [
        cdr dup word? [
            "syntax" "vocabulary" set-word-prop
        ] [
            drop
        ] ifte
    ] hash-each
] bind

"!syntax" vocabularies get remove-hash

FORGET: pull-in
