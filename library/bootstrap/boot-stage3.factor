! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien assembler command-line compiler io-internals kernel
lists namespaces parser sequences stdio unparser words ;

"Bootstrap stage 3..." print

os "unix" = [
    "libc"     "libc.so"       "cdecl"   add-library
    "sdl"      "libSDL.so"     "cdecl"   add-library
    "sdl-gfx"  "libSDL_gfx.so" "cdecl"   add-library
    "sdl-ttf"  "libSDL_ttf.so" "cdecl"   add-library
] when

os "win32" = [
    "kernel32" "kernel32.dll" "stdcall"  add-library
    "user32"   "user32.dll"   "stdcall"  add-library
    "gdi32"    "gdi32.dll"    "stdcall"  add-library
    "winsock"  "ws2_32.dll"   "stdcall"  add-library
    "mswsock"  "mswsock.dll"  "stdcall"  add-library
    "libc"     "msvcrt.dll"   "cdecl"    add-library
    "sdl"      "SDL.dll"      "cdecl"    add-library
    "sdl-gfx"  "SDL_gfx.dll"  "cdecl"    add-library
    "sdl-ttf"  "SDL_ttf.dll"  "cdecl"    add-library
] when

default-cli-args
parse-command-line
init-assembler

"/library/io/buffer.factor" run-resource

: compile? "compile" get supported-cpu? and ;

compile? [
    \ car compile
    \ = compile
    \ length compile
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

    "/library/io/directories.factor"
    "/library/io/stdio-binary.factor"
    
    "/library/eval-catch.factor"
    "/library/tools/memory.factor"
    "/library/tools/listener.factor"
    "/library/io/ansi.factor"
    "/library/tools/word-tools.factor"
    "/library/syntax/see.factor"
    "/library/test/test.factor"
    "/library/inference/test.factor"
    "/library/tools/profiler.factor"
    "/library/tools/walker.factor"
    "/library/tools/annotations.factor"
    "/library/tools/dump.factor"
    "/library/bootstrap/image.factor"
    
    "/library/io/logging.factor"

    "/library/tools/telnetd.factor"
    "/library/tools/jedit-wire.factor"
    "/library/tools/jedit.factor"

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
    "/library/ui/menus.factor"
    "/library/ui/presentations.factor"
    "/library/ui/panes.factor"
    "/library/ui/tiles.factor"
    "/library/ui/dialogs.factor"
    "/library/ui/inspector.factor"
    "/library/ui/init-world.factor"
    "/library/ui/tool-menus.factor"
] pull-in

compile? [
    os "win32" = [
        "/library/win32/win32-io.factor"
        "/library/win32/win32-errors.factor"
        "/library/win32/winsock.factor"
        "/library/win32/win32-io-internals.factor"
        "/library/win32/win32-stream.factor"
        "/library/win32/win32-server.factor"
        "/library/bootstrap/win32-io.factor"
    ] pull-in
    
    os "unix" = [
        "/library/unix/syscalls.factor"
        "/library/unix/io.factor"
        "/library/unix/sockets.factor"
        "/library/unix/files.factor"
    ] pull-in
] when

compile? [
    "Compiling system..." print
    compile-all
    "Initializing native I/O..." print
    init-io
] when

FORGET: pull-in
FORGET: compile?

"/library/bootstrap/boot-stage4.factor" dup print run-resource
