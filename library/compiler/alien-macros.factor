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

IN: alien
USE: compiler
USE: kernel
USE: lists
USE: math
USE: namespaces

: UNBOX ( name -- )
    #! Move top of datastack to C stack.
    SELF-CALL  EAX PUSH-R ;

: BOX ( name -- )
    #! Move EAX to datastack.
    EAX PUSH-R  SELF-CALL  4 ESP R+I ;

: PARAMETERS ( params -- count )
    #! Generate code for boxing a list of C types.
    #! Return amount stack must be unwound by.
    0 swap [
        c-type [
            "unboxer" get UNBOX "width" get cell align +
        ] bind
    ] each ;

: CLEANUP ( amount -- )
    dup 0 = [ drop ] [ ESP R+I ] ifte ;

: RETURNS ( type -- )
    dup "void" = [
        drop
    ] [
        c-type [ "boxer" get ] bind BOX
    ] ifte ;
