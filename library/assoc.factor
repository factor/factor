! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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

! An association list is a list of conses where the car of each
! cons is a key, and the cdr is a value. See the Factor
! Developer's Guide for details.

: assoc? ( list -- ? )
    #! Push if the list appears to be an alist.
    dup list? [ [ cons? ] all? ] [ drop f ] ifte ;

: assoc* ( key alist -- [[ key value ]] )
    #! Looks up the key in an alist. Push the key/value pair.
    #! Most of the time you want to use assoc not assoc*.
    dup [
        2dup car car = [ nip car ] [ cdr assoc* ] ifte
    ] [
        2drop f
    ] ifte ;

: assoc ( key alist -- value )
    #! Looks up the key in an alist.
    assoc* dup [ cdr ] when ;

: remove-assoc ( key alist -- alist )
    #! Remove all key/value pairs with this key.
    [ car = not ] subset-with ;

: acons ( value key alist -- alist )
    #! Adds the key/value pair to the alist. Existing pairs with
    #! this key are not removed; the new pair simply shadows
    #! existing pairs.
    >r swons r> cons ;

: set-assoc ( value key alist -- alist )
    #! Adds the key/value pair to the alist.
    dupd remove-assoc acons ;

: assoc-apply ( value-alist quot-alist -- )
    #! Looks up the key of each pair in the first list in the
    #! second list to produce a quotation. The quotation is
    #! applied to the value of the pair. If there is no
    #! corresponding quotation, the value is popped off the
    #! stack.
    swap [
        unswons rot assoc* dup [
            cdr call
        ] [
            2drop
        ] ifte
    ] each-with ;

: 2cons ( car1 car2 cdr1 cdr2 -- cons1 cons2 )
    rot swons >r cons r> ;

: zip ( list list -- list )
    #! Make a new list containing pairs of corresponding
    #! elements from the two given lists.
    dup [ 2uncons zip >r cons r> cons ] [ 2drop [ ] ] ifte ;

: unzip ( assoc -- keys values )
    #! Split an association list into two lists of keys and
    #! values.
    [ uncons >r uncons r> unzip 2cons ] [ [ ] [ ] ] ifte* ;
