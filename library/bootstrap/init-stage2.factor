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

IN: kernel
USE: alien
USE: compiler
USE: errors
USE: inference
USE: command-line
USE: listener
USE: lists
USE: math
USE: namespaces
USE: parser
USE: random
USE: streams
USE: stdio
USE: presentation
USE: words
USE: unparser
USE: kernel-internals
USE: console
USE: assembler

: default-cli-args
    #! Some flags are *on* by default, unless user specifies
    #! -no-<flag> CLI switch
    "user-init" on
    "interactive" on
    "smart-terminal" on
    "verbose-compile" on
    "compile" on
    os "win32" = "sdl" "ansi" ? "shell" set ;

: warm-boot ( -- )
    #! A fully bootstrapped image has this as the boot
    #! quotation.
    init-assembler
    init-error-handler
    init-random
    default-cli-args
    parse-command-line ;

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
