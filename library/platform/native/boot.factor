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

primitives,
[
    "/library/platform/native/kernel.factor"
    "/library/platform/native/stack.factor"
    "/library/platform/native/types.factor"
    "/library/math/math.factor"
    "/library/platform/native/math.factor"
    "/library/cons.factor"
    "/library/combinators.factor"
    "/library/logic.factor"
    "/library/platform/native/vectors.factor"
    "/library/vector-combinators.factor"
    "/library/lists.factor"
    "/library/assoc.factor"
    "/library/math/arithmetic.factor"
    "/library/math/math-combinators.factor"
    "/library/vectors.factor"
    "/library/platform/native/strings.factor"
    "/library/strings.factor"
    "/library/hashtables.factor"
    "/library/platform/native/namespaces.factor"
    "/library/namespaces.factor"
    "/library/math/namespace-math.factor"
    "/library/list-namespaces.factor"
    "/library/sbuf.factor"
    "/library/continuations.factor"
    "/library/platform/native/errors.factor"
    "/library/errors.factor"
    "/library/platform/native/threads.factor"
    "/library/stream.factor"
    "/library/platform/native/io-internals.factor"
    "/library/platform/native/stream.factor"
    "/library/stdio.factor"
    "/library/extend-stream.factor"
    "/library/platform/native/words.factor"
    "/library/words.factor"
    "/library/platform/native/vocabularies.factor"
    "/library/vocabularies.factor"
    "/library/platform/native/parse-numbers.factor"
    "/library/platform/native/parser.factor"
    "/library/platform/native/parse-syntax.factor"
    "/library/platform/native/parse-stream.factor"
    "/library/platform/native/init.factor"
] [
    cross-compile-resource
] each

version,

IN: init
DEFER: cold-boot

[ cold-boot ] (set-boot)
