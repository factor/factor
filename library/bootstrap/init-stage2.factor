! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: alien assembler command-line compiler console errors
generic inference kernel-internals listener lists math memory
namespaces parser presentation random stdio streams unparser
words ;

: warm-boot ( -- )
    #! A fully bootstrapped image has this as the boot
    #! quotation.
    init-assembler
    init-error-handler
    init-random
    default-cli-args
    parse-command-line
    "null-stdio" get [ << null-stream f >> stdio set ] when ;

: shell ( str -- )
    #! This handles the -shell:<foo> cli argument.
    [ "shells" ] search execute ;

[
    boot
    warm-boot
    garbage-collection
    run-user-init
    "shell" get shell
    0 exit* 
] set-boot

warm-boot

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
    ! FIXME: KLUDGE to get FFI-based IO going in Windows.
    "/library/bootstrap/win32-io.factor" run-resource
] when

"Compiling system..." print
"compile" get [ compile-all ] when

terpri
"Unless you're working on the compiler, ignore the errors above." print
"Not every word compiles, by design." print
terpri

0 [ compiled? [ 1 + ] when ] each-word
unparse write " words compiled" print

0 [ drop 1 + ] each-word
unparse write " words total" print 

"Bootstrapping is complete." print
"Now, you can run ./f factor.image" print

! Save a bit of space
global [ stdio off ] bind

"factor.image" save-image
0 exit*
