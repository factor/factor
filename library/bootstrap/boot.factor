! :folding=none:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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
"/version.factor" run-resource
"/library/stack.factor" run-resource
"/library/combinators.factor" run-resource
"/library/kernel.factor" run-resource
"/library/logic.factor" run-resource
"/library/cons.factor" run-resource
"/library/assoc.factor" run-resource
"/library/math/generic.factor" run-resource
"/library/words.factor" run-resource
"/library/math/arithmetic.factor" run-resource
"/library/math/math-combinators.factor" run-resource
"/library/math/math.factor" run-resource
"/library/lists.factor" run-resource
"/library/vectors.factor" run-resource
"/library/strings.factor" run-resource
"/library/hashtables.factor" run-resource
"/library/namespaces.factor" run-resource
"/library/list-namespaces.factor" run-resource
"/library/sbuf.factor" run-resource
"/library/errors.factor" run-resource
"/library/continuations.factor" run-resource
"/library/threads.factor" run-resource
"/library/io/stream.factor" run-resource
"/library/io/stdio.factor" run-resource
"/library/io/io-internals.factor" run-resource
"/library/io/stream-impl.factor" run-resource
"/library/vocabularies.factor" run-resource
"/library/syntax/parse-numbers.factor" run-resource
"/library/syntax/parser.factor" run-resource
"/library/syntax/parse-stream.factor" run-resource

! A bootstrapping trick. See doc/bootstrap.txt.
vocabularies get [
    "generic" off
] bind

"/library/generic/generic.factor" run-resource
"/library/generic/object.factor" run-resource
"/library/generic/builtin.factor" run-resource
"/library/generic/predicate.factor" run-resource
"/library/generic/traits.factor" run-resource

"/library/bootstrap/init.factor" run-resource

! A bootstrapping trick. See doc/bootstrap.txt.
"/library/syntax/parse-syntax.factor" run-resource

vocabularies get [
    "!syntax" get "syntax" set
    "!syntax" off

    "syntax" get [
        cdr dup word? [
            "syntax" "vocabulary" set-word-property
        ] [
            drop
        ] ifte
    ] hash-each
] bind
