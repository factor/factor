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
USE: generic
USE: kernel
USE: kernel-internals

! This file contains vital list-related words that everything
! else depends on, and is loaded early in bootstrap.
! lists.factor has everything else.

BUILTIN: cons 2

: car ( [ car | cdr ] -- car ) >cons 0 slot ; inline
: cdr ( [ car | cdr ] -- cdr ) >cons 1 slot ; inline

: swons ( cdr car -- [ car | cdr ] )
    #! Push a new cons cell. If the cdr is f or a proper list,
    #! has the effect of prepending the car to the cdr.
    swap cons ; inline

: uncons ( [ car | cdr ] -- car cdr )
    #! Push both the head and tail of a list.
    dup car swap cdr ; inline

: unit ( a -- [ a ] )
    #! Construct a proper list of one element.
    f cons ; inline

: unswons ( [ car | cdr ] -- cdr car )
    #! Push both the head and tail of a list.
    dup cdr swap car ; inline

: 2car ( cons cons -- car car )
    swap car swap car ;

: 2cdr ( cons cons -- car car )
    swap cdr swap cdr ;

: 2uncons ( cons1 cons2 -- car1 car2 cdr1 cdr2 )
    [ 2car ] 2keep 2cdr ;

: last* ( list -- last )
    #! Last cons of a list.
    dup cdr cons? [ cdr last* ] when ;

: last ( list -- last )
    #! Last element of a list.
    last* car ;

UNION: general-list f cons ;

PREDICATE: general-list list ( list -- ? )
    #! Proper list test. A proper list is either f, or a cons
    #! cell whose cdr is a proper list.
    dup [ last* cdr ] when not ;

: all? ( list pred -- ? )
    #! Push if the predicate returns true for each element of
    #! the list.
    over [
        dup >r swap uncons >r swap call [
            r> r> all?
        ] [
            r> drop r> drop f
        ] ifte
    ] [
        2drop t
    ] ifte ; inline

: (each) ( list quot -- list quot )
    >r uncons r> tuck 2slip ; inline

: each ( list quot -- )
    #! Push each element of a proper list in turn, and apply a
    #! quotation with effect ( X -- ) to each element.
    over [ (each) each ] [ 2drop ] ifte ; inline

: subset ( list quot -- list )
    #! Applies a quotation with effect ( X -- ? ) to each
    #! element of a list; all elements for which the quotation
    #! returned a value other than f are collected in a new
    #! list.
    over [
        over car >r (each)
        rot >r subset r> [ r> swons ] [ r> drop ] ifte
    ] [
        drop
    ] ifte ; inline
