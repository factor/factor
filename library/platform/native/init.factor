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

IN: init
USE: combinators
USE: errors
USE: kernel
USE: namespaces
USE: parser
USE: stdio
USE: streams
USE: threads
USE: words
USE: vectors

: init-errors ( -- )
    64 <vector> set-catchstack* ;

: init-gc ( -- )
    [ garbage-collection ] 7 setenv ;

: boot ( -- )
    #! Initialize an interpreter with the basic services.
    init-gc
    init-errors
    init-namespaces
    init-threads
    init-stdio
    "HOME" os-env [ "." ] unless* "~" set
    10 "base" set
    "/" "/" set
    init-search-path ;

: cold-boot ( -- )
    #! An initially-generated image has this as the boot
    #! quotation.
    boot
    "/library/platform/native/boot-stage2.factor" run-resource
    "finish-cold-boot" [ "init" ] search execute ;
