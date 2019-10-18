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
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: strings

: make-string ( quot -- string )
    #! Call a quotation. The quotation can call , to prepend
    #! objects to the list that is returned when the quotation
    #! is done.
    make-list cat ; inline

: make-rstring ( quot -- string )
    #! Return a string whose entries are in the same order that ,
    #! was called.
    make-rlist cat ; inline

: fill ( count char -- string )
    #! Push a string that consists of the same character
    #! repeated.
    [ swap [ dup , ] times drop ] make-string ;

: str-map ( str code -- str )
    #! Apply a quotation to each character in the string, and
    #! push a new string constructed from return values.
    #! The quotation must have stack effect ( X -- X ).
    over str-length <sbuf> rot [
        swap >r apply r> tuck sbuf-append
    ] str-each nip sbuf>str ; inline

: split-next ( index string split -- next )
    3dup index-of* dup -1 = [
        >r drop str-tail , r> ( end of string )
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
    [ 0 -rot (split) ] make-list ;

: split-n-advance substring , >r tuck + swap r> ;
: split-n-finish nip dup str-length swap substring , ;

: (split-n) ( start n str -- )
    3dup >r dupd + r> 2dup str-length < [
        split-n-advance (split-n)
    ] [
        split-n-finish 3drop
    ] ifte ;

: split-n ( n str -- list )
    #! Split a string into n-character chunks.
    [ 0 -rot (split-n) ] make-list ;
