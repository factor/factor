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
USE: kernel
USE: namespaces

: cons@ ( x var -- )
    #! Prepend x to the list stored in var.
    [ cons ] change ;

: unique@ ( elem var -- )
    #! Prepend an element to the proper list stored in a
    #! variable if it is not already contained in the list.
    [ unique ] change ;

SYMBOL: list-buffer

: make-rlist ( quot -- list )
    #! Call a quotation. The quotation can call , to prepend
    #! objects to the list that is returned when the quotation
    #! is done.
    [ list-buffer off call list-buffer get ] with-scope ;
    inline

: make-list ( quot -- list )
    #! Return a list whose entries are in the same order that ,
    #! was called.
    make-rlist reverse ; inline

: , ( obj -- )
    #! Append an object to the currently constructing list.
    list-buffer cons@ ;

: unique, ( obj -- )
    #! Append an object to the currently constructing list, only
    #! if the object does not already occur in the list.
    list-buffer unique@ ;

: append, ( list -- )
    [ , ] each ;
