! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: lists image parser namespaces stdio kernel vectors
words hashtables ;

"/library/bootstrap/primitives.factor" run-resource

! The make-list form creates a boot quotation
[
    "/version.factor" parse-resource append,
    "/library/stack.factor" parse-resource append,
    "/library/combinators.factor" parse-resource append,
    "/library/arrays.factor" parse-resource append,
    "/library/kernel.factor" parse-resource append,
    "/library/cons.factor" parse-resource append,
    "/library/assoc.factor" parse-resource append,
    "/library/math/math.factor" parse-resource append,
    "/library/math/integer.factor" parse-resource append,
    "/library/math/ratio.factor" parse-resource append,
    "/library/math/float.factor" parse-resource append,
    "/library/math/complex.factor" parse-resource append,
    "/library/lists.factor" parse-resource append,
    "/library/vectors.factor" parse-resource append,
    "/library/strings.factor" parse-resource append,
    "/library/hashtables.factor" parse-resource append,
    "/library/words.factor" parse-resource append,
    "/library/namespaces.factor" parse-resource append,
    "/library/sbuf.factor" parse-resource append,
    "/library/errors.factor" parse-resource append,
    "/library/continuations.factor" parse-resource append,
    "/library/threads.factor" parse-resource append,
    "/library/io/stream.factor" parse-resource append,
    "/library/io/stdio.factor" parse-resource append,
    "/library/io/io-internals.factor" parse-resource append,
    "/library/io/stream-impl.factor" parse-resource append,
    "/library/vocabularies.factor" parse-resource append,
    "/library/syntax/parse-numbers.factor" parse-resource append,
    "/library/syntax/parser.factor" parse-resource append,
    "/library/syntax/parse-stream.factor" parse-resource append,

    "delegate" [ "generic" ] search
    "object" [ "generic" ] search

    vocabularies get [ "generic" off ] bind

    reveal
    reveal

    "/library/generic/generic.factor" parse-resource append,
    "/library/generic/object.factor" parse-resource append,
    "/library/generic/null.factor" parse-resource append,
    "/library/generic/builtin.factor" parse-resource append,
    "/library/generic/predicate.factor" parse-resource append,
    "/library/generic/union.factor" parse-resource append,
    "/library/generic/complement.factor" parse-resource append,
    "/library/generic/tuple.factor" parse-resource append,

    "/library/bootstrap/init.factor" parse-resource append,
    "/library/syntax/parse-syntax.factor" parse-resource append,
] make-list

"boot" [ "kernel" ] search swons

vocabularies get [
    "!syntax" get "syntax" set

    "syntax" get [
        cdr dup word? [
            "syntax" "vocabulary" set-word-property
        ] [
            drop
        ] ifte
    ] hash-each
] bind

"!syntax" vocabularies get remove-hash
