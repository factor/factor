!:folding=indent:collapseFolds=1:

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
USE: combinators
USE: kernel
USE: lists
USE: logic
USE: stack
USE: strings
USE: vectors

!!! Other languages have classes, objects, variables, etc.
!!! Factor has similar concepts.
!!!
!!!   5 "x" set
!!!   "x" get 2 + .
!!! 7
!!!   7 "x" set
!!!   "x" get 2 + .
!!! 9
!!!
!!! get ( name -- value ) and set ( value name -- ) search in
!!! the namespaces on the namespace stack, in top-down order.
!!!
!!! At the bottom of the namespace stack, is the global
!!! namespace; it is always present.
!!!
!!! bind ( namespace quot -- ) executes a quotation with a
!!! namespace pushed on the namespace stack.

: namestack ( -- stack )
    #! Push a copy of the namespace stack; same naming
    #! convention as the primitives datastack and callstack.
    namestack* clone ; inline

: set-namestack ( stack -- )
    #! Set the namespace stack to a copy of another stack; same
    #! naming convention as the primitives datastack and
    #! callstack.
    clone set-namestack* ; inline

: >n ( namespace -- n:namespace )
    #! Push a namespace on the namespace stack.
    namestack* vector-push ; inline

: n> ( n:namespace -- namespace )
    #! Pop the top of the namespace stack.
    namestack* vector-pop ; inline

: namespace ( -- namespace )
    #! Push the current namespace.
    namestack* vector-peek ; inline

: extend ( object code -- object )
    #! Used in code like this:
    #! : <subclass>
    #!      <superclass> [
    #!          ....
    #!      ] extend ;
    swap namespace-of >n call n> ; inline

: bind ( namespace quot -- )
    #! Execute a quotation with a new namespace on the namespace
    #! stack. Compiles if the quotation compiles.
    extend drop ; inline

: lazy ( var [ a ] -- value )
    #! If the value of the variable is f, set the value to the
    #! result of evaluating [ a ].
    over get [ drop get ] [ dip dupd set ] ifte ;

: alist> ( alist namespace -- )
    #! Set each key in the alist to its value in the
    #! namespace.
    [ [ unswons set ] each ] bind ;

: alist>namespace ( alist -- namespace )
    <namespace> tuck alist> ;

: object-path-traverse ( name object -- object )
    dup has-namespace? [ get* ] [ 2drop f ] ifte ;

: object-path-iter ( object list -- object )
    [
        uncons [ swap object-path-traverse ] dip
        object-path-iter
    ] when* ;

: object-path ( list -- object )
    #! An object path is a list of strings. Each string is a
    #! variable name in the object namespace at that level.
    #! Returns f if any of the objects are not set.
    this swap object-path-iter ;

: global-object-path ( string -- object )
    #! An object path based from the global namespace.
    "'" split global [ object-path ] bind ;

: on ( var -- ) t put ;
: off ( var -- ) f put ;
: toggle ( var -- ) dup get not put ;
