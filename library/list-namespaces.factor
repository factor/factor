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

IN: lists
USE: combinators
USE: kernel
USE: namespaces
USE: stack

: append@ ( [ list ] var -- )
    #! Append a proper list stored in a variable with another
    #! list, storing the result back in the variable.
    #! given variable using 'append'.
    tuck get swap append put ;

: add@ ( elem var -- )
    #! Add an element at the end of a proper list stored in a
    #! variable, storing the result back in the variable.
    tuck get swap add put ;

: cons@ ( x var -- )
    #! Prepend x to the list stored in var.
    tuck get cons put ;

: remove@ ( obj var -- )
    #! Remove all occurrences of the object from the list
    #! stored in the variable.
    tuck get remove put ;

: unique@ ( elem var -- )
    #! Prepend an element to the proper list stored in a
    #! variable if it is not already contained in the list.
    tuck get unique put ;

: [, ( -- )
    #! Begin constructing a list.
    <namespace> >n f "list-buffer" set ;

: , ( obj -- )
    #! Append an object to the currently constructing list.
    "list-buffer" cons@ ;

: unique, ( obj -- )
    #! Append an object to the currently constructing list, only
    #! if the object does not already occur in the list.
    "list-buffer" unique@ ;

: list, ( list -- )
    #! Append each element to the currently constructing list.
    [ , ] each ;

: ,] ( -- list )
    #! Finish constructing a list and push it on the stack.
    "list-buffer" get nreverse n> drop ;
