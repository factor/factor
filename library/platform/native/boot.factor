!:folding=none:collapseFolds=1:

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

USE: arithmetic
USE: combinators
USE: format
USE: inspector
USE: init
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
USE: stdio
USE: streams
USE: strings
USE: vectors
USE: words
USE: cross-compiler

primitives,
[
    "/library/ansi.factor"
    "/library/assoc.factor"
    "/library/combinators.factor"
    "/library/cons.factor"
    "/library/continuations.factor"
    "/library/debugger.factor"
    "/library/errors.factor"
    "/library/format.factor"
    "/library/hashtables.factor"
    "/library/init.factor"
    "/library/inspector.factor"
    "/library/inspect-vocabularies.factor"
    "/library/interpreter.factor"
    "/library/list-namespaces.factor"
    "/library/logging.factor"
    "/library/logic.factor"
    "/library/namespaces.factor"
    "/library/prettyprint.factor"
    "/library/sbuf.factor"
    "/library/stdio.factor"
    "/library/stream.factor"
    "/library/strings.factor"
    "/library/styles.factor"
    "/library/vectors.factor"
    "/library/vector-combinators.factor"
    "/library/vocabularies.factor"
    "/library/vocabulary-style.factor"
    "/library/words.factor"
    "/library/math/math-combinators.factor"
    "/library/math/namespace-math.factor"
    "/library/platform/native/errors.factor"
    "/library/platform/native/io-internals.factor"
    "/library/platform/native/stream.factor"
    "/library/platform/native/kernel.factor"
    "/library/platform/native/namespaces.factor"
    "/library/platform/native/parser.factor"
    "/library/platform/native/parse-stream.factor"
    "/library/platform/native/prettyprint.factor"
    "/library/platform/native/stack.factor"
    "/library/platform/native/words.factor"
    "/library/platform/native/vectors.factor"
    "/library/platform/native/vocabularies.factor"
    "/library/platform/native/unparser.factor"
    "/library/platform/native/init.factor"
] [
    cross-compile-resource
] each
[
    ! We don't include all of 'lists' or 'math' yet...
    between? min max
    append add remove contains unique
    pred succ neg fib each nreverse nreverse-iter
    max 2list length reverse nth list? 2rlist
    all? clone-list clone-list-iter subset subset-iter
    subset-add car= cdr= cons= cons-hashcode
    tree-contains? =-or-contains? last* last
] [ worddef worddef, ] each

version,

[ boot ] (set-boot)
