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

IN: namespaces
USE: hashtables
USE: kernel
USE: kernel-internals
USE: lists

! Other languages have classes, objects, variables, etc.
! Factor has similar concepts.
!
!   5 "x" set
!   "x" get 2 + .
! 7
!   7 "x" set
!   "x" get 2 + .
! 9
!
! get ( name -- value ) and set ( value name -- ) search in
! the namespaces on the namespace stack, in top-down order.
!
! At the bottom of the namespace stack, is the global
! namespace; it is always present.
!
! bind ( namespace quot -- ) executes a quotation with a
! namespace pushed on the namespace stack.

: namestack ( -- ns ) 3 getenv ;
: set-namestack ( ns -- ) 3 setenv ;

: namespace ( -- namespace )
    #! Push the current namespace.
    namestack car ; inline

: >n ( namespace -- n:namespace )
    #! Push a namespace on the namespace stack.
    namestack cons set-namestack ; inline

: n> ( n:namespace -- namespace )
    #! Pop the top of the namespace stack.
    namestack uncons set-namestack ; inline

: global ( -- g ) 4 getenv ;
: set-global ( g -- ) 4 setenv ;

: init-namespaces ( -- )
    global >n ;

: <namespace> ( -- n )
    #! Create a new namespace.
    23 <hashtable> ;

: (get) ( var ns -- value )
    #! Internal word for searching the namestack.
    dup [
        2dup car hash* dup [
            nip nip cdr ( found )
        ] [
            drop cdr (get) ( keep looking )
        ] ifte
    ] [
        2drop f
    ] ifte ;

: get ( variable -- value )
    #! Push the value of a variable by searching the namestack
    #! from the top down.
    namestack (get) ;

: set ( value variable -- ) namespace set-hash ;
: put ( variable value -- ) swap set ;

: nest ( variable -- hash )
    #! If the variable is set in the current namespace, return
    #! its value, otherwise set its value to a new namespace.
    dup namespace hash dup [
        nip
    ] [
        drop >r <namespace> dup r> set
    ] ifte ;

: change ( var quot -- )
    #! Execute the quotation with the variable value on the
    #! stack. The set the variable to the return value of the
    #! quotation.
    >r dup get r> rot slip set ; inline

: bind ( namespace quot -- )
    #! Execute a quotation with a namespace on the namestack.
    swap >n call n> drop ; inline

: with-scope ( quot -- )
    #! Execute a quotation with a new namespace on the
    #! namestack.
    <namespace> >n call n> drop ; inline

: extend ( object code -- object )
    #! Used in code like this:
    #! : <subclass>
    #!      <superclass> [
    #!          ....
    #!      ] extend ;
    over >r bind r> ; inline

: on ( var -- ) t put ;
: off ( var -- ) f put ;
