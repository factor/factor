! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: kernel lists parser stdio words namespaces ;

"Cold boot in progress..." print

[
    "/library/generic/generic.factor"
    "/library/generic/slots.factor"
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
    "/library/tools/debugger.factor"

    "/library/io/files.factor"
    "/library/eval-catch.factor"
    "/library/tools/memory.factor"
    "/library/tools/listener.factor"
    "/library/cli.factor"
] [
    dup print run-resource
] each

IN: command-line DEFER: parse-command-line
parse-command-line

! Dummy defs for mini bootstrap
IN: compiler : compile-all ;
IN: assembler : init-assembler ;
IN: alien : add-library 3drop ;

"mini" get [
    [
        "/library/math/constants.factor"
        "/library/math/pow.factor"
        "/library/math/trig-hyp.factor"
        "/library/math/arc-trig-hyp.factor"

        "/library/syntax/see.factor"

        "/library/gensym.factor"
        "/library/in-thread.factor"
        "/library/io/network.factor"
        "/library/io/logging.factor"
        "/library/random.factor"
        "/library/io/stdio-binary.factor"

        "/library/tools/word-tools.factor"
        "/library/test/test.factor"
        "/library/io/ansi.factor"
        "/library/tools/telnetd.factor"
        "/library/tools/jedit-wire.factor"
        "/library/tools/profiler.factor"
        "/library/tools/interpreter.factor"
    
        "/library/inference/conditions.factor"
        "/library/inference/dataflow.factor"
        "/library/inference/inference.factor"
        "/library/inference/ties.factor"
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
        "/library/httpd/cont-responder.factor"
        "/library/httpd/browser-responder.factor"
        "/library/httpd/default-responders.factor"
    
        "/library/tools/jedit.factor"
    ] [
        dup print run-resource
    ] each
] unless

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

cpu "x86" = "mini" get not and [
    [
        "/library/compiler/x86/assembler.factor"
        "/library/compiler/x86/stack.factor"
        "/library/compiler/x86/generator.factor"
        "/library/compiler/x86/fixnum.factor"

        "/library/ui/shapes.factor"
        "/library/ui/gadgets.factor"
        "/library/ui/paint.factor"
        "/library/ui/text.factor"
        "/library/ui/gestures.factor"
        "/library/ui/hand.factor"
        "/library/ui/layouts.factor"
        "/library/ui/world.factor"
        "/library/ui/labels.factor"
        "/library/ui/buttons.factor"
        "/library/ui/checkboxes.factor"
        "/library/ui/line-editor.factor"
        "/library/ui/editors.factor"
        "/library/ui/dialogs.factor"
        "/library/ui/events.factor"
        "/library/ui/scrolling.factor"
        "/library/ui/menus.factor"
        "/library/ui/presentations.factor"
        "/library/ui/panes.factor"
        "/library/ui/tiles.factor"
        "/library/ui/inspector.factor"
        "/library/ui/init-world.factor"
        "/library/ui/tool-menus.factor"
    ] [
        dup print
        run-resource
    ] each
] when

"/library/bootstrap/init-stage2.factor" dup print run-resource
