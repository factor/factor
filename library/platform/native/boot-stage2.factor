! :folding=indent:collapseFolds=1:

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

IN: init
USE: combinators
USE: compiler
USE: errors
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: stack
USE: strings
USE: stdio

"Cold boot in progress..." print
[
    "/library/platform/native/kernel.factor"
    "/library/platform/native/stack.factor"
    "/library/platform/native/types.factor"
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
    "/library/platform/native/parse-numbers.factor"
    "/library/platform/native/parser.factor"
    "/library/platform/native/parse-syntax.factor"
    "/library/platform/native/parse-stream.factor"

    "/library/format.factor"
    "/library/platform/native/unparser.factor"
    "/library/presentation.factor"
    "/library/vocabulary-style.factor"
    "/library/prettyprint.factor"
    "/library/platform/native/debugger.factor"
    "/library/tools/debugger.factor"
    "/library/platform/native/init.factor"

    "/library/math/constants.factor"
    "/library/math/math.factor"
    "/library/platform/native/math.factor"
    "/library/math/pow.factor"
    "/library/math/trig-hyp.factor"
    "/library/math/arc-trig-hyp.factor"

    "/library/platform/native/in-thread.factor"
    "/library/platform/native/network.factor"
    "/library/logging.factor"
    "/library/platform/native/random.factor"
    "/library/random.factor"
    "/library/stdio-binary.factor"
    "/library/platform/native/prettyprint.factor"
    "/library/platform/native/files.factor"
    "/library/files.factor"
    "/library/eval-catch.factor"
    "/library/tools/listener.factor"
    "/library/tools/inspector.factor"
    "/library/tools/word-tools.factor"
    "/library/test/test.factor"
    "/library/ansi.factor"
    "/library/tools/telnetd.factor"
    "/library/tools/jedit-wire.factor"
    "/library/platform/native/profiler.factor"
    "/library/platform/native/heap-stats.factor"
    "/library/platform/native/gensym.factor"
    "/library/tools/interpreter.factor"
    "/library/tools/inference.factor"

    "/library/tools/image.factor"
    "/library/tools/cross-compiler.factor"
    "/library/platform/native/cross-compiler.factor"

    "/library/httpd/url-encoding.factor"
    "/library/httpd/html-tags.factor"
    "/library/httpd/html.factor"
    "/library/httpd/http-common.factor"
    "/library/httpd/responder.factor"
    "/library/httpd/httpd.factor"
    "/library/httpd/file-responder.factor"
    "/library/httpd/inspect-responder.factor"
    "/library/httpd/test-responder.factor"
    "/library/httpd/quit-responder.factor"
    "/library/httpd/resource-responder.factor"
    "/library/httpd/default-responders.factor"

    "/library/tools/jedit.factor"

    "/library/platform/native/primitives.factor"

    "/library/init.factor"
] [
    dup print
    run-resource
] each

cpu "x86" = [
    [
        "/library/compiler/assembler.factor"
        "/library/compiler/assembly-x86.factor"
        "/library/compiler/compiler-macros.factor"
        "/library/compiler/compiler.factor"
        "/library/compiler/ifte.factor"
        "/library/compiler/generic.factor"
        "/library/compiler/stack.factor"
        "/library/compiler/interpret-only.factor"
        "/library/compiler/compile-all.factor"
        "/library/compiler/alien-types.factor"
        "/library/compiler/alien-macros.factor"
        "/library/compiler/alien.factor"
        
        "/library/sdl/sdl.factor"
        "/library/sdl/sdl-video.factor"
        "/library/sdl/sdl-event.factor"
        "/library/sdl/sdl-gfx.factor"
        "/library/sdl/sdl-keysym.factor"
        "/library/sdl/sdl-utils.factor"
        "/library/sdl/hsv.factor"
    ] [
        dup print
        run-resource
    ] each
] [
    "/library/compiler/dummy-compiler.factor" dup print run-resource
] ifte

"/library/platform/native/init-stage2.factor" dup print run-resource

IN: init
DEFER: warm-boot

IN: compiler
DEFER: compilable-words
DEFER: compilable-word-list

IN: listener
DEFER: init-listener

[
    warm-boot
    "interactive" get [ init-listener ] when
    0 exit*
] set-boot

compilable-words compilable-word-list set

"Bootstrapping is complete." print
"Now, you can run ./f factor.image" print

! Save a bit of space
global [ "stdio" off ] bind

garbage-collection
"factor.image" save-image
0 exit*
