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

primitives,
[
    "/library/kernel.factor"
    "/library/stack.factor"
    "/library/types.factor"
    "/library/math/math.factor"
    "/library/cons.factor"
    "/library/combinators.factor"
    "/library/logic.factor"
    "/library/vector-combinators.factor"
    "/library/lists.factor"
    "/library/assoc.factor"
    "/library/math/arithmetic.factor"
    "/library/math/math-combinators.factor"
    "/library/vectors.factor"
    "/library/strings.factor"
    "/library/hashtables.factor"
    "/library/namespaces.factor"
    "/library/math/namespace-math.factor"
    "/library/list-namespaces.factor"
    "/library/sbuf.factor"
    "/library/continuations.factor"
    "/library/errors.factor"
    "/library/threads.factor"
    "/library/io/stream.factor"
    "/library/io/io-internals.factor"
    "/library/io/stream-impl.factor"
    "/library/io/stdio.factor"
    "/library/io/extend-stream.factor"
    "/library/words.factor"
    "/library/vocabularies.factor"
    "/library/syntax/parse-numbers.factor"
    "/library/syntax/parser.factor"
    "/library/syntax/parse-syntax.factor"
    "/library/syntax/parse-stream.factor"
    "/library/math/generic.factor"
    "/library/bootstrap/init.factor"
] [
    cross-compile-resource
] each

version,

IN: init
DEFER: boot

[
    boot
    "/library/bootstrap/boot-stage2.factor" run-resource
] (set-boot)
