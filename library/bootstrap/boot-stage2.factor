! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: kernel lists parser stdio words namespaces ;

"Cold boot in progress..." print

[
    "/library/generic/generic.factor"
    "/library/generic/object.factor"
    "/library/generic/null.factor"
    "/library/generic/builtin.factor"
    "/library/generic/predicate.factor"
    "/library/generic/union.factor"
    "/library/generic/complement.factor"
    "/library/generic/tuple.factor"

    "/version.factor"
    "/library/stack.factor"
    "/library/combinators.factor"
    "/library/arrays.factor"
    "/library/kernel.factor"
    "/library/cons.factor"
    "/library/assoc.factor"
    "/library/math/math.factor"
    "/library/math/integer.factor"
    "/library/math/ratio.factor"
    "/library/math/float.factor"
    "/library/math/complex.factor"
    "/library/lists.factor"
    "/library/vectors.factor"
    "/library/strings.factor"
    "/library/hashtables.factor"
    "/library/words.factor"
    "/library/namespaces.factor"
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
    "/library/inference/test.factor"

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
    "/library/sdl/sdl-ttf.factor"
    "/library/sdl/sdl-utils.factor"
    "/library/sdl/hsv.factor"

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

        "/library/ui/line-editor.factor"
        "/library/ui/console.factor"
        "/library/ui/shapes.factor"
        "/library/ui/paint.factor"
        "/library/ui/gadgets.factor"
        "/library/ui/boxes.factor"
        "/library/ui/gestures.factor"
        "/library/ui/hand.factor"
        "/library/ui/world.factor"
        "/library/ui/label.factor"
        "/library/ui/events.factor"
    ] [
        dup print
        run-resource
    ] each
] when

"/library/bootstrap/init-stage2.factor" dup print run-resource
