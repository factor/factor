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
USE: words
USE: namespaces

"Cold boot in progress..." print

! vocabularies get [
!     "generic" off
! ] bind

[
    "/library/generic/generic.factor"
    "/library/generic/object.factor"
    "/library/generic/builtin.factor"
    "/library/generic/predicate.factor"
    "/library/generic/union.factor"
    "/library/generic/traits.factor"

    "/version.factor"
    "/library/stack.factor"
    "/library/combinators.factor"
    "/library/kernel.factor"
    "/library/cons.factor"
    "/library/assoc.factor"
    "/library/math/math.factor"
    "/library/math/integer.factor"
    "/library/math/ratio.factor"
    "/library/math/float.factor"
    "/library/math/complex.factor"
    "/library/words.factor"
    "/library/math/math-combinators.factor"
    "/library/lists.factor"
    "/library/vectors.factor"
    "/library/strings.factor"
    "/library/hashtables.factor"
    "/library/namespaces.factor"
    "/library/list-namespaces.factor"
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
    "/library/inference/branches.factor"
    "/library/inference/words.factor"
    "/library/inference/stack.factor"
    "/library/inference/types.factor"

    "/library/compiler/assembler.factor"
    "/library/compiler/xt.factor"
    "/library/compiler/optimizer.factor"
    "/library/compiler/linearizer.factor"
    "/library/compiler/simplifier.factor"
    "/library/compiler/generator.factor"
    "/library/compiler/compiler.factor"
    "/library/compiler/alien-types.factor"
    "/library/compiler/alien.factor"

    "/library/sdl/sdl.factor"
    "/library/sdl/sdl-video.factor"
    "/library/sdl/sdl-event.factor"
    "/library/sdl/sdl-gfx.factor"
    "/library/sdl/sdl-keysym.factor"
    "/library/sdl/sdl-keyboard.factor"
    "/library/sdl/sdl-utils.factor"
    "/library/sdl/hsv.factor"

    "/library/ui/line-editor.factor"
    "/library/ui/console.factor"

    "/library/bootstrap/image.factor"

    "/library/httpd/url-encoding.factor"
    "/library/httpd/html-tags.factor"
    "/library/httpd/html.factor"
    "/library/httpd/http-common.factor"
    "/library/httpd/responder.factor"
    "/library/httpd/httpd.factor"
    "/library/httpd/file-responder.factor"
    "/library/httpd/test-responder.factor"
    "/library/httpd/quit-responder.factor"
    "/library/httpd/resource-responder.factor"
    "/library/httpd/default-responders.factor"

    "/library/tools/jedit.factor"

    "/library/cli.factor"
] [
    dup print
    run-resource
] each

os "win32" = [
    [
        "/library/io/buffer.factor"
        "/library/win32/win32-io.factor"
        "/library/win32/win32-errors.factor"
        "/library/win32/winsock.factor"
        "/library/io/win32-io-internals.factor"
        "/library/io/win32-stream.factor"
        "/library/io/win32-server.factor"
        "/library/io/win32-console.factor"
    ] [
        dup print
        run-resource
    ] each
] when

cpu "x86" = [
    [
         "/library/compiler/x86/assembler.factor"
         "/library/compiler/x86/stack.factor"
         "/library/compiler/x86/generator.factor"
         "/library/compiler/x86/fixnum.factor"
    ] [
        dup print
        run-resource
    ] each
] when

"/library/bootstrap/init-stage2.factor" dup print run-resource
