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
USE: stack
USE: stdio

"Cold boot in progress..." print

[
    "/library/platform/native/kernel.factor"
    "/library/platform/native/stack.factor"
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
    "/library/platform/native/words.factor"
    "/library/words.factor"
    "/library/platform/native/vocabularies.factor"
    "/library/vocabularies.factor"
    "/library/platform/native/parse-numbers.factor"
    "/library/platform/native/parser.factor"
    "/library/platform/native/parse-syntax.factor"
    "/library/platform/native/parse-stream.factor"
    "/library/platform/native/unparser.factor"
    "/library/format.factor"
    "/library/styles.factor"
    "/library/vocabulary-style.factor"
    "/library/prettyprint.factor"
    "/library/debugger.factor"
    "/library/platform/native/debugger.factor"
    "/library/platform/native/init.factor"

    "/library/math/math.factor"
    "/library/math/pow.factor"
    "/library/math/trig-hyp.factor"
    "/library/math/arc-trig-hyp.factor"
    "/library/math/quadratic.factor"
    "/library/math/list-math.factor"
    "/library/math/simpson.factor"

    "/library/extend-stream.factor"
    "/library/platform/native/in-thread.factor"
    "/library/platform/native/network.factor"
    "/library/logging.factor"
    "/library/platform/native/random.factor"
    "/library/random.factor"
    "/library/stdio-binary.factor"
    "/library/platform/native/prettyprint.factor"
    "/library/interpreter.factor"
    "/library/inspector.factor"
    "/library/inspect-vocabularies.factor"
    "/library/test/test.factor"
    "/library/ansi.factor"
    "/library/telnetd.factor"
    "/library/inferior.factor"
    "/library/platform/native/profiler.factor"

    "/library/image.factor"
    "/library/cross-compiler.factor"
    "/library/platform/native/cross-compiler.factor"

    "/library/httpd/url-encoding.factor"
    "/library/httpd/html.factor"
    "/library/httpd/http-common.factor"
    "/library/httpd/responder.factor"
    "/library/httpd/httpd.factor"
    "/library/httpd/inspect-responder.factor"
    "/library/httpd/test-responder.factor"
    "/library/httpd/quit-responder.factor"
    "/library/httpd/default-responders.factor"

    "/library/jedit/jedit-no-local.factor"
    "/library/jedit/jedit-remote.factor"
    "/library/jedit/jedit.factor"

    "/library/init.factor"
    "/library/platform/native/init-stage2.factor"
] [
    dup print
    run-resource
] each

IN: init
DEFER: finish-cold-boot
DEFER: warm-boot
finish-cold-boot

: set-boot ( quot -- ) 8 setenv ;
[ warm-boot ] set-boot

garbage-collection
"factor.image" save-image
0 exit*
