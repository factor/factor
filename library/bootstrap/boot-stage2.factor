! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: command-line kernel lists namespaces parser stdio
unparser words ;

"Cold boot in progress..." print

default-cli-args
parse-command-line

! Dummy defs for mini bootstrap
IN: compiler : compile-all ; : compile drop ; : supported-cpu? f ;
IN: assembler : init-assembler ;

: pull-in ( ? list -- )
    swap [
        [
            dup print run-resource
        ] each
    ] [
        drop
    ] ifte ;

t [
    "/library/tools/debugger.factor"
    "/library/tools/gensym.factor"
    "/library/tools/interpreter.factor"

    "/library/inference/conditions.factor"
    "/library/inference/dataflow.factor"
    "/library/inference/inference.factor"
    "/library/inference/ties.factor"
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
] pull-in

cpu "x86" = [
    "/library/compiler/x86/assembler.factor"
    "/library/compiler/x86/stack.factor"
    "/library/compiler/x86/generator.factor"
    "/library/compiler/x86/fixnum.factor"
] pull-in

cpu "ppc" = [
    "/library/compiler/ppc/assembler.factor"
    "/library/compiler/ppc/stack.factor"
    "/library/compiler/ppc/generator.factor"
] pull-in

"compile" get supported-cpu? and [
    init-assembler
    \ car compile
    \ = compile
    \ unparse compile
    \ scan compile
] when

t [
    "/library/math/constants.factor"
    "/library/math/pow.factor"
    "/library/math/trig-hyp.factor"
    "/library/math/arc-trig-hyp.factor"

    "/library/in-thread.factor"
    "/library/random.factor"

    "/library/io/network.factor"
    "/library/io/logging.factor"
    "/library/io/stdio-binary.factor"
    
    "/library/syntax/see.factor"
    
    "/library/eval-catch.factor"
    "/library/tools/memory.factor"
    "/library/tools/listener.factor"
    "/library/io/ansi.factor"
    "/library/tools/word-tools.factor"
    "/library/test/test.factor"
    "/library/inference/test.factor"
    "/library/tools/telnetd.factor"
    "/library/tools/jedit-wire.factor"
    "/library/tools/profiler.factor"
    "/library/tools/walker.factor"
    "/library/tools/annotations.factor"
    "/library/tools/jedit.factor"
    "/library/bootstrap/image.factor"

    "/library/httpd/url-encoding.factor"
    "/library/httpd/mime.factor"
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

    "/library/sdl/sdl.factor"
    "/library/sdl/sdl-video.factor"
    "/library/sdl/sdl-event.factor"
    "/library/sdl/sdl-gfx.factor"
    "/library/sdl/sdl-keysym.factor"
    "/library/sdl/sdl-keyboard.factor"
    "/library/sdl/sdl-ttf.factor"
    "/library/sdl/sdl-utils.factor"
    "/library/ui/shapes.factor"
    "/library/ui/points.factor"
    "/library/ui/rectangles.factor"
    "/library/ui/lines.factor"
    "/library/ui/ellipses.factor"
    "/library/ui/gadgets.factor"
    "/library/ui/hierarchy.factor"
    "/library/ui/paint.factor"
    "/library/ui/text.factor"
    "/library/ui/gestures.factor"
    "/library/ui/hand.factor"
    "/library/ui/layouts.factor"
    "/library/ui/piles.factor"
    "/library/ui/shelves.factor"
    "/library/ui/borders.factor"
    "/library/ui/stacks.factor"
    "/library/ui/frames.factor"
    "/library/ui/world.factor"
    "/library/ui/labels.factor"
    "/library/ui/buttons.factor"
    "/library/ui/checkboxes.factor"
    "/library/ui/line-editor.factor"
    "/library/ui/events.factor"
    "/library/ui/scrolling.factor"
    "/library/ui/editors.factor"
    "/library/ui/dialogs.factor"
    "/library/ui/menus.factor"
    "/library/ui/presentations.factor"
    "/library/ui/panes.factor"
    "/library/ui/tiles.factor"
    "/library/ui/inspector.factor"
    "/library/ui/init-world.factor"
    "/library/ui/tool-menus.factor"
] pull-in

os "win32" = [
    "/library/io/buffer.factor"
    "/library/win32/win32-io.factor"
    "/library/win32/win32-errors.factor"
    "/library/win32/winsock.factor"
    "/library/io/win32-io-internals.factor"
    "/library/io/win32-stream.factor"
    "/library/io/win32-server.factor"
] pull-in

FORGET: pull-in

"/library/bootstrap/init-stage2.factor" dup print run-resource
