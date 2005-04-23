! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: image
USING: lists parser namespaces stdio kernel vectors words
hashtables ;

"Bootstrap stage 1..." print

"/library/bootstrap/primitives.factor" run-resource

: pull-in ( list -- ) [ dup print parse-resource % ] each ;

! The make-list form creates a boot quotation
[
    [
        "/version.factor"
        "/library/stack.factor"
        "/library/combinators.factor"
        "/library/collections/sequences.factor"
        "/library/collections/arrays.factor"
        "/library/kernel.factor"
        "/library/math/math.factor"
        "/library/math/integer.factor"
        "/library/math/ratio.factor"
        "/library/math/float.factor"
        "/library/math/complex.factor"
        "/library/collections/cons.factor"
        "/library/collections/assoc.factor"
        "/library/collections/lists.factor"
        "/library/collections/vectors.factor"
        "/library/collections/strings.factor"
        "/library/collections/sequences-epilogue.factor"
        "/library/collections/vectors-epilogue.factor"
        "/library/collections/hashtables.factor"
        "/library/collections/namespaces.factor"
        "/library/collections/sbuf.factor"
        "/library/words.factor"
        "/library/vocabularies.factor"
        "/library/errors.factor"
        "/library/continuations.factor"
        "/library/io/stream.factor"
        "/library/io/stdio.factor"
        "/library/io/c-streams.factor"
        "/library/io/files.factor"
        "/library/threads.factor"
        "/library/syntax/parse-numbers.factor"
        "/library/syntax/parse-words.factor"
        "/library/syntax/parse-errors.factor"
        "/library/syntax/parser.factor"
        "/library/syntax/parse-stream.factor"
        "/library/syntax/generic.factor"
        "/library/syntax/parse-syntax.factor"
        "/library/alien/aliens.factor"
        "/library/cli.factor"
    ] pull-in

    "delegate" [ "generic" ] search
    "object" [ "generic" ] search
    "typemap" [ "generic" ] search
    "builtins" [ "generic" ] search

    vocabularies get [ "generic" off ] bind

    reveal
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
