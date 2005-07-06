! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien assembler command-line compiler compiler-backend
compiler-frontend io-internals kernel lists math namespaces
parser sequences io unparser words ;

"Compiling base..." print

unix? [
    "sdl"      "libSDL.so"     "cdecl"    add-library
    "sdl-gfx"  "libSDL_gfx.so" "cdecl"    add-library
    "sdl-ttf"  "libSDL_ttf.so" "cdecl"    add-library
] when

win32? [
    "kernel32" "kernel32.dll"  "stdcall"  add-library
    "user32"   "user32.dll"    "stdcall"  add-library
    "gdi32"    "gdi32.dll"     "stdcall"  add-library
    "winsock"  "ws2_32.dll"    "stdcall"  add-library
    "mswsock"  "mswsock.dll"   "stdcall"  add-library
    "libc"     "msvcrt.dll"    "cdecl"    add-library
    "sdl"      "SDL.dll"       "cdecl"    add-library
    "sdl-gfx"  "SDL_gfx.dll"   "cdecl"    add-library
    "sdl-ttf"  "SDL_ttf.dll"   "cdecl"    add-library
] when

default-cli-args
parse-command-line
init-assembler

: compile? "compile" get supported-cpu? and ;

compile? [
    \ car compile
    \ * compile
    \ length compile
    \ = compile
    \ unparse compile
    \ scan compile
    \ optimize compile
    \ (generate) compile
] when

"Loading more library code..." print


t [
    "/library/alien/malloc.factor"
    "/library/io/buffer.factor"

    "/library/math/constants.factor"
    "/library/math/pow.factor"
    "/library/math/more-matrices.factor"
    "/library/math/trig-hyp.factor"
    "/library/math/arc-trig-hyp.factor"
    "/library/math/random.factor"

    "/library/in-thread.factor"

    "/library/io/directories.factor"
    "/library/io/binary.factor"
    
    "/library/eval-catch.factor"
    "/library/tools/listener.factor"
    "/library/tools/word-tools.factor"
    "/library/syntax/see.factor"
    "/library/test/test.factor"
    "/library/inference/test.factor"
    "/library/tools/walker.factor"
    "/library/tools/annotations.factor"
    "/library/tools/inspector.factor"
    "/library/bootstrap/image.factor"
    
    "/library/io/logging.factor"

    "/library/tools/telnetd.factor"
    "/library/tools/jedit-wire.factor"
    "/library/tools/jedit.factor"

    "/library/httpd/load.factor"
    "/library/sdl/load.factor"
    "/library/ui/load.factor"
] pull-in

compile? [
    unix? [
        "/library/unix/types.factor"
    ] pull-in

    os "freebsd" = [
        "/library/unix/syscalls-freebsd.factor"
    ] pull-in

    os "linux" = [
        "/library/unix/syscalls-linux.factor"
    ] pull-in

    os "macosx" = [
        "/library/unix/syscalls-macosx.factor"
    ] pull-in
    
    unix? [
        "/library/unix/syscalls.factor"
        "/library/unix/io.factor"
        "/library/unix/sockets.factor"
        "/library/unix/files.factor"
    ] pull-in
    
    os "win32" = [
        "/library/win32/win32-io.factor"
        "/library/win32/win32-errors.factor"
        "/library/win32/winsock.factor"
        "/library/win32/win32-io-internals.factor"
        "/library/win32/win32-stream.factor"
        "/library/win32/win32-server.factor"
        "/library/bootstrap/win32-io.factor"
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
