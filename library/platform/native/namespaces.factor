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

IN: namespaces
USE: arithmetic
USE: combinators
USE: hashtables
USE: kernel
USE: lists
USE: stack
USE: vectors

DEFER: namespace
DEFER: >n

: namestack* ( -- ns ) 3 getenv ;
: set-namestack* ( ns -- ) 3 setenv ;

: global ( -- g ) 4 getenv ;
: set-global ( g -- ) 4 setenv ;

: init-namespaces ( -- )
    64 <vector> set-namestack* global >n
    global "global" set ;

: namespace-buckets 23 ;

: <namespace> ( -- n )
    #! Create a new namespace.
    namespace-buckets <hashtable> ;

: get* ( var namespace -- value ) hash ;
: set*  ( value variable namespace -- ) set-hash ;
: put* swapd set* ;

: namestack-search ( var n -- )
    #! Internal word for searching the namestack.
    dup 0 eq? [
        2drop f ( not found )
    ] [
        pred 2dup >r >r namestack* vector-nth hash* dup [
            r> drop r> drop ( [ key | value ] -- ) cdr ( found )
        ] [
            drop r> r> namestack-search ( check next entry )
        ] ifte
    ] ifte ;

: get ( variable -- value )
    #! Push the value of a variable by searching the namestack
    #! from the top down.
    namestack* vector-length namestack-search ;

: set ( value variable -- ) namespace set* ;
: put ( variable value -- ) namespace put* ;

: vars ( -- list ) namespace hash-keys ;
: values ( -- list ) namespace hash-values ;
: vars-values ( -- list ) namespace hash>alist ;

! We don't have bound objects in native Factor.
: namespace? hashtable? ;
: namespace-of ;
: this namespace ;
: has-namespace? hashtable? ;
