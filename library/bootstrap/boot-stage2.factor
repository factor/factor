! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien assembler command-line compiler compiler-backend
errors generic hashtables io io-internals kernel
kernel-internals lists math memory namespaces parser sequences
sequences-internals words ;

: pull-in ( ? list -- )
    swap [
        [
            dup print run-resource
        ] each
    ] [
        drop
    ] ifte ;

"Loading compiler backend..." print

cpu "x86" = [
    "/library/compiler/x86/assembler.factor"
    "/library/compiler/x86/architecture.factor"
    "/library/compiler/x86/generator.factor"
    "/library/compiler/x86/slots.factor"
    "/library/compiler/x86/stack.factor"
    "/library/compiler/x86/fixnum.factor"
    "/library/compiler/x86/alien.factor"
    "/library/alien/primitive-types.factor"
] pull-in

cpu "ppc" = [
    "/library/compiler/ppc/assembler.factor"
    "/library/compiler/ppc/architecture.factor"
    "/library/compiler/ppc/generator.factor"
    "/library/compiler/ppc/slots.factor"
    "/library/compiler/ppc/stack.factor"
    "/library/compiler/ppc/fixnum.factor"
    "/library/compiler/ppc/alien.factor"
    "/library/alien/primitive-types.factor"
] pull-in

"statically-linked" get [
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
] unless

"Loading more library code..." print

t [
    "/library/alien/malloc.factor"
    "/library/io/buffer.factor"

    "/library/httpd/load.factor"
    "/library/sdl/load.factor"
    "/library/ui/load.factor"
    "/library/help/tutorial.factor"
] pull-in

: compile? "compile" get supported-cpu? and ;

compile? [
    "Compiling base..." print

    {
        uncons 1+ 1- + <= > >= mod length
        nth-unsafe set-nth-unsafe
        = string>number number>string scan (generate)
    } [ compile ] each
] when

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

"Building cross-reference database..." print
recrossref

compile? [
    "Compiling system..." print
    compile-all
    terpri
    "Unless you're working on the compiler, ignore the errors above." print
    "Not every word compiles, by design." print
    terpri
    "Initializing native I/O..." print
    init-io
] when

[
    boot
    run-user-init
    "shell" get [ "shells" ] search execute
    0 exit
] set-boot

0 [ compiled? [ 1+ ] when ] each-word
number>string write " words compiled" print

0 [ drop 1+ ] each-word
number>string write " words total" print 

"Total bootstrap GC time: " write gc-time
number>string write " ms" print

"Bootstrapping is complete." print
"Now, you can run ./f factor.image" print

"factor.image" save-image
0 exit

FORGET: pull-in
FORGET: compile?
