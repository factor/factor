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

IN: hashtables
USE: combinators
USE: kernel
USE: lists
USE: math
USE: stack
USE: vectors

! Note that the length of a hashtable vector must not change
! for the lifetime of the hashtable, otherwise problems will
! occur. Do not use vector words with hashtables.

: hashtable? ( obj -- ? )
    dup vector? [ [ assoc? ] vector-all? ] [ drop f ] ifte ;

: <hashtable> ( buckets -- )
    #! A hashtable is implemented as an array of buckets. The
    #! array index is determined using a hash function, and the
    #! buckets are associative lists which are searched
    #! linearly. The number of buckets must be a power of two.
    empty-vector ;

: (hashcode) ( key table -- index )
    #! Compute the index of the bucket for a key.
    >r hashcode r> vector-length rem ;

: hash* ( key table -- [ key | value ] )
    #! Look up a value in the hashtable. First the bucket is
    #! determined using the hash function, then the association
    #! list therein is searched linearly.
    2dup (hashcode) swap vector-nth assoc* ;

: hash ( key table -- value )
    #! Unlike hash*, this word cannot distinglish between an
    #! undefined value, or a value set to f.
    hash* dup [ cdr ] when ;

: set-hash ( value key table -- )
    #! Store the value in the hashtable. Either replaces an
    #! existing value in the appropriate bucket, or adds a new
    #! key/value pair,
    dup >r 2dup (hashcode) dup >r swap
    vector-nth set-assoc
    r> r> set-vector-nth ;

: hash-each ( hash code -- )
    #! Apply the code to each key/value pair of the hashtable.
    swap [ swap dup >r each r> ] vector-each drop ;

: hash-subset ( hash code -- hash )
    #! Return a new hashtable containing all key/value pairs
    #! for which the predicate yielded a true value. The
    #! predicate must have stack effect ( obj -- ? ).
    swap [ swap dup >r subset r> swap ] vector-map nip ;

: hash-keys ( hash -- list )
    #! Push a list of keys in a hashtable.
    [ ] swap [ car swons ] hash-each ;

: hash-values ( hash -- alist )
    #! Push a list of values in a hashtable.
    [ ] swap [ cdr swons ] hash-each ;

: hash>alist ( hash -- list )
    #! Push a list of key/value pairs in a hashtable.
    [ ] swap [ swons ] hash-each ;

: alist>hash ( alist -- hash )
    37 <hashtable> swap [ unswons pick set-hash ] each ;
