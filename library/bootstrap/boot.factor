! :folding=none:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

USE: lists
USE: image
USE: parser
USE: namespaces
USE: stdio
USE: kernel
USE: vectors
USE: words
USE: hashtables

"/library/bootstrap/primitives.factor" run-resource

! The make-list form creates a boot quotation
[
    "/version.factor" parse-resource append,
    "/library/stack.factor" parse-resource append,
    "/library/combinators.factor" parse-resource append,
    "/library/kernel.factor" parse-resource append,
    "/library/cons.factor" parse-resource append,
    "/library/assoc.factor" parse-resource append,
    "/library/math/math.factor" parse-resource append,
    "/library/math/integer.factor" parse-resource append,
    "/library/math/ratio.factor" parse-resource append,
    "/library/math/float.factor" parse-resource append,
    "/library/math/complex.factor" parse-resource append,
    "/library/words.factor" parse-resource append,
    "/library/lists.factor" parse-resource append,
    "/library/vectors.factor" parse-resource append,
    "/library/strings.factor" parse-resource append,
    "/library/hashtables.factor" parse-resource append,
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

    "traits" [ "generic" ] search
    "delegate" [ "generic" ] search
    "object" [ "generic" ] search

    vocabularies get [ "generic" off ] bind

    reveal
    reveal
    reveal

    "/library/generic/generic.factor" parse-resource append,
    "/library/generic/object.factor" parse-resource append,
    "/library/generic/null.factor" parse-resource append,
    "/library/generic/builtin.factor" parse-resource append,
    "/library/generic/predicate.factor" parse-resource append,
    "/library/generic/union.factor" parse-resource append,
    "/library/generic/complement.factor" parse-resource append,
    "/library/generic/traits.factor" parse-resource append,

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
