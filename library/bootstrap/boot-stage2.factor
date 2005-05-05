! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien assembler command-line compiler generic hashtables
kernel lists memory namespaces parser sequences stdio unparser
words ;

"Making the image happy..." print

! Rehash hashtables
[ hashtable? ] instances
[ dup hash-size swap set-bucket-count ] each

! Update generics
[ dup generic? [ make-generic ] [ drop ] ifte ] each-word

recrossref

: pull-in ( ? list -- )
    swap [
        [
            dup print run-resource
        ] each
    ] [
        drop
    ] ifte ;

! These are loaded here until bootstrap gets some fixes
t [
    "/library/alien/compiler.factor"
    "/library/io/buffer.factor"
] pull-in

"Loading compiler backend..." print

cpu "x86" = [
    "/library/compiler/x86/assembler.factor"
    "/library/compiler/x86/stack.factor"
    "/library/compiler/x86/generator.factor"
    "/library/compiler/x86/fixnum.factor"
    "/library/compiler/x86/alien.factor"
] pull-in

cpu "ppc" = [
    "/library/compiler/ppc/assembler.factor"
    "/library/compiler/ppc/stack.factor"
    "/library/compiler/ppc/generator.factor"
    "/library/compiler/ppc/alien.factor"
] pull-in

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
    \ = compile
    \ length compile
    \ unparse compile
    \ scan compile
] when

"/library/bootstrap/boot-stage3.factor" run-resource
