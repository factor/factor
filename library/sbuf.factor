! :folding=indent:collapseFolds=0:

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

IN: strings
USE: arithmetic
USE: combinators
USE: kernel
USE: lists
USE: namespaces
USE: strings
USE: stack

: str>sbuf ( str -- sbuf )
    dup str-length <sbuf> tuck sbuf-append ;

: string-buffer-size 80 ;

: <% ( -- )
    #! Begins constructing a string.
    <namespace> >n string-buffer-size <sbuf>
    "string-buffer" set ;

: % ( str -- )
    #! Append a string to the construction buffer.
    "string-buffer" get sbuf-append ;

: %> ( -- str )
    #! Ends construction and pushes the constructed text on the
    #! stack.
    "string-buffer" get sbuf>str n> drop ;

: reverse%> ( -- str )
     #! Ends construction and pushes the *reversed*, constructed
     #! text on the stack.
     "string-buffer" get dup sbuf-reverse sbuf>str n> drop ;

: fill ( count char -- string )
    #! Push a string that consists of the same character
    #! repeated.
    <% swap [ dup % ] times drop %> ;

: str-map ( str code -- str )
    #! Apply a quotation to each character in the string, and
    #! push a new string constructed from return values.
    #! The quotation must have stack effect ( X -- X ).
    <% swap [ swap dup >r call % r> ] str-each drop %> ;

: split-next ( index string split -- next )
    3dup index-of* dup -1 = [
        >r drop swap str-tail , r> ( end of string )
    ] [
        swap str-length dupd + >r swap substring , r>
    ] ifte ;

: (split) ( index string split -- )
    2dup >r >r split-next dup -1 = [
        drop r> drop r> drop
    ] [
        r> r> (split)
    ] ifte ;

: split ( string split -- list )
    #! Split the string at each occurrence of split, and push a
    #! list of the pieces.
    [, 0 -rot (split) ,] ;
