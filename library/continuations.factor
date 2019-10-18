! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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
USE: errors
USE: kernel
USE: lists
USE: namespaces
USE: vectors

: reify ( quot -- )
    >r datastack >pop> callstack >pop> namestack catchstack
    r> call ;

: (callcc) cons cons cons cons swap call ;

: continue0 ( ds rs ns cs -- )
    set-catchstack set-namestack
    >r set-datastack r> set-callstack ;

: callcc0 ( code -- )
    #! Calls the code with a special quotation at the top of the
    #! stack. The quotation has stack effect:
    #!
    #! ( -- ... )
    #!
    #! When called, the quotation restores execution state to
    #! the point after the callcc0 call.
    [ [ continue0 ] (callcc) ] reify ;

: continue1 ( obj ds rs ns cs -- obj )
    set-catchstack set-namestack
    rot >r >r set-datastack r> r> swap set-callstack ;

: callcc1 ( code -- )
    #! Calls the code with a special quotation at the top of the
    #! stack. The quotation has stack effect:
    #!
    #! ( X -- ... )
    #!
    #! When called, the quotation restores execution state to
    #! the point after the callcc1 call, and places X at the top
    #! of the original datastack.
    [ [ continue1 ] (callcc) ] reify ;
