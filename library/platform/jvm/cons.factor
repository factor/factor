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

IN: lists USE: kernel USE: stack

: array>list ( array -- list )
    #! Convert an array into a proper list.
    [ [ "java.lang.Object" ] ] "factor.Cons" "fromArray"
    jinvoke-static ;

: car ( [ car | cdr ] -- car )
    #! Push the head of a list.
    "factor.Cons" "car" jvar-get ; inline

: cdr ( [ car | cdr ] -- cdr )
    #! Push the tail of a list. In a proper list, the tail is
    #! always a cons cell or f; in an improper list, the tail
    #! can be anything.
    "factor.Cons" "cdr" jvar-get ; inline

: cons ( car cdr -- [ car , cdr ] )
    #! Push a new cons cell. If the cdr is f or a proper list,
    #! has the effect of prepending the car to the cdr.
    [ "java.lang.Object" "java.lang.Object" ] "factor.Cons" jnew
    ; inline

: cons? ( list -- boolean )
    #! Test for cons cell type.
    "factor.Cons" is ; inline

: deep-clone ( cons -- cons )
    [ "factor.Cons" ] "factor.Cons" "deepClone" jinvoke-static ;

: rplaca ( A [ B | C ] -- )
    #! DESTRUCTIVE. Replace the head of a list.
    "factor.Cons" "car" jvar-set ; inline

: rplacd ( A [ B | C ] -- )
    #! DESTRUCTIVE. Replace the tail of a list.
    "factor.Cons" "cdr" jvar-set ; inline
