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
USE: ansi
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

: cli-args ( -- args ) 10 getenv ;

: warm-boot ( -- )
    #! A fully bootstrapped image has this as the boot
    #! quotation.
    boot

    init-error-handler
    init-random
    init-assembler

    ! Some flags are *on* by default, unless user specifies
    ! -no-<flag> CLI switch
    t "user-init" set
    t "interactive" set
    t "compile" set
    t "smart-terminal" set

    ! The first CLI arg is the image name.
    cli-args uncons parse-command-line "image" set

    os "win32" = "compile" get and [
        "kernel32" "kernel32.dll" "stdcall" add-library
        "user32"   "user32.dll"   "stdcall" add-library
        "gdi32"    "gdi32.dll"    "stdcall" add-library
        "libc"     "msvcrt.dll"   "cdecl"   add-library
    ] when

    "compile" get [ compile-all ] when

    "smart-terminal" get [
        stdio smart-term-hook get change 
    ] when

    run-user-init ;

: auto-inline-count 5 ;
[
    warm-boot
    garbage-collection
    "interactive" get [ print-banner listener ] when
    0 exit* 
] set-boot

init-error-handler

0 [ drop succ ] each-word unparse write " words" print 

! "Counting word usages..." print
! tally-usages
! 
! "Automatically inlining words called " write
! auto-inline-count unparse write
! " or less times..." print
! auto-inline-count auto-inline

"Inferring stack effects..." print
0 [ unit try-infer [ succ ] when ] each-word
unparse write " words have a stack effect" print

"Bootstrapping is complete." print
"Now, you can run ./f factor.image" print

! Save a bit of space
global [ stdio off ] bind

garbage-collection
"factor.image" save-image
0 exit*
