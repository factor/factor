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
USE: ansi
USE: combinators
USE: errors
USE: httpd-responder
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: random
USE: streams
USE: styles
USE: words

: cli-args ( -- args ) 10 getenv ;

: warm-boot ( -- )
    #! A fully bootstrapped image has this as the boot
    #! quotation.
    boot

    init-random
    "stdio" get <ansi-stream> "stdio" set

    ! Some flags are *on* by default, unless user specifies
    ! -no-<flag> CLI switch
    t "user-init" set
    t "interactive" set

    ! The first CLI arg is the image name.
    cli-args uncons parse-command-line "image" set
    
    run-user-init

    "interactive" get [ init-interpreter ] when

    0 exit* ;

: finish-cold-boot ( -- )
    #! After the stage2 bootstrap is done, this word
    #! completes initialization.
    init-scratchpad
    init-styles
    init-vocab-styles
    default-responders ;
