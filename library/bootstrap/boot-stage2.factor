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
USE: kernel
USE: lists
USE: parser
USE: stdio

"Cold boot in progress..." print
[
    "/version.factor"
    "/library/stack.factor"
    "/library/kernel.factor"
    "/library/generic/generic.factor"
    "/library/generic/object.factor"
    "/library/generic/builtin.factor"
    "/library/generic/predicate.factor"
    "/library/generic/traits.factor"
    "/library/types.factor"
    "/library/math/math.factor"
    "/library/cons.factor"
    "/library/combinators.factor"
    "/library/logic.factor"
    "/library/vectors.factor"
    "/library/lists.factor"
    "/library/assoc.factor"
    "/library/math/arithmetic.factor"
    "/library/math/math-combinators.factor"
    "/library/strings.factor"
    "/library/hashtables.factor"
    "/library/namespaces.factor"
    "/library/list-namespaces.factor"
    "/library/sbuf.factor"
    "/library/continuations.factor"
    "/library/errors.factor"
    "/library/threads.factor"
    "/library/io/stream.factor"
    "/library/io/io-internals.factor"
    "/library/io/stream-impl.factor"
    "/library/io/stdio.factor"
    "/library/words.factor"
    "/library/vocabularies.factor"
    "/library/syntax/parse-numbers.factor"
    "/library/syntax/parser.factor"
    "/library/syntax/parse-syntax.factor"
    "/library/syntax/parse-stream.factor"
    "/library/math/generic.factor"
    "/library/bootstrap/init.factor"

    "/library/format.factor"
    "/library/syntax/unparser.factor"
    "/library/io/presentation.factor"
    "/library/io/vocabulary-style.factor"
    "/library/syntax/prettyprint.factor"
    "/library/syntax/see.factor"
    "/library/tools/debugger.factor"

    "/library/math/constants.factor"
    "/library/math/pow.factor"
    "/library/math/trig-hyp.factor"
    "/library/math/arc-trig-hyp.factor"

    "/library/in-thread.factor"
    "/library/io/network.factor"
    "/library/io/logging.factor"
    "/library/random.factor"
    "/library/io/stdio-binary.factor"
    "/library/io/files.factor"
    "/library/eval-catch.factor"
    "/library/tools/listener.factor"
    "/library/tools/inspector.factor"
    "/library/tools/word-tools.factor"
    "/library/test/test.factor"
    "/library/io/ansi.factor"
    "/library/tools/telnetd.factor"
    "/library/tools/jedit-wire.factor"
    "/library/tools/profiler.factor"
    "/library/tools/heap-stats.factor"
    "/library/gensym.factor"
    "/library/tools/interpreter.factor"

    ! Inference needs to know primitive stack effects at load time
    "/library/primitives.factor"

    "/library/inference/dataflow.factor"
    "/library/inference/inference.factor"
    "/library/inference/words.factor"
    "/library/inference/branches.factor"
    "/library/inference/stack.factor"

    "/library/compiler/optimizer.factor"
    "/library/compiler/linearizer.factor"
    "/library/compiler/assembler.factor"
    "/library/compiler/xt.factor"
    "/library/compiler/generator.factor"
    "/library/compiler/compiler.factor"

    "/library/bootstrap/image.factor"
    "/library/bootstrap/cross-compiler.factor"

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

    "/library/cli.factor"
    "/library/sdl/hsv.factor"
] [
    dup print
    run-resource
] each

cpu "x86" = [
    [
         "/library/compiler/assembly-x86.factor"
         "/library/compiler/generator-x86.factor"
!        "/library/compiler/compiler-macros.factor"
!        "/library/compiler/ifte.factor"
!        "/library/compiler/generic.factor"
!        "/library/compiler/stack.factor"
!        "/library/compiler/interpret-only.factor"
!        "/library/compiler/alien-types.factor"
!        "/library/compiler/alien-macros.factor"
!        "/library/compiler/alien.factor"
!        
!        "/library/sdl/sdl.factor"
!        "/library/sdl/sdl-video.factor"
!        "/library/sdl/sdl-event.factor"
!        "/library/sdl/sdl-gfx.factor"
!        "/library/sdl/sdl-keysym.factor"
!        "/library/sdl/sdl-utils.factor"
    ] [
        dup print
        run-resource
    ] each
] when

"/library/bootstrap/init-stage2.factor" dup print run-resource
