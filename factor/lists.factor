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

: 2list (a b -- [ a b ])
    unit cons ;

: 2rlist (a b -- [ b a ])
    swap unit cons ;

: append ( [ list1 ] [ list2 ] -- [ list1 list2 ] )
    over [ [ uncons ] dip append cons ] [ nip ] ifte ;

: add ([ list1 ] elem -- [ list1 elem ])
    unit append ;

: append@ ([ list ] variable --)
    ! Adds the list to the end of the list stored in the given variable.
    dup [ $ swap append ] dip @ ;

: array>list ( array -- list )
    [ [ "java.lang.Object" ] ] "factor.Cons" "fromArray"
    jinvoke-static ;

: add@ (elem variable --)
    ! Adds the element to the end of the list stored in the given variable.
    dup [ $ swap add ] dip @ ;

: assoc (key alist -- value)
    ! Looks up the key in the given alist. An alist is a list of comma pairs,
    ! the car of each pair is a key, the cdr is the value. For example:
    ! [ [ 1 , "one" ] [ 2 , "two" ] [ 3 , "three" ] ]
    dup [
        2dup car car = [
            nip car cdr
        ] [
            cdr assoc
        ] ifte
    ] [
        2drop f
    ] ifte ;

: car ([ car , cdr ] -- car)
    |factor.Cons |car jvar$ ;

: cdr ([ car , cdr ] -- cdr)
    |factor.Cons |cdr jvar$ ;

: caar (list -- caar)
    car car ;

: cdar (list -- cadr)
    cdr car ;

: cadr (list -- cdar)
    car cdr ;

: cddr (list -- cddr)
    cdr cdr ;

: cloneList (list -- list)
    ! Returns a new list where each element is a clone of the elements of
    ! the given list.
    dup [ [ ] "factor.Cons" "deepClone" jinvoke ] when ;

: cons (car cdr -- [ car , cdr ])
    [ |java.lang.Object |java.lang.Object ] |factor.Cons jnew ;

: contains (elem list -- boolean)
    dup [
        2dup car = [
            2drop t
        ] [
            cdr contains
        ] ifte
    ] [
        2drop f
    ] ifte ;

: cons@ (x var --)
    ! Prepends x to the list stored in var.
    dup [ $ cons ] dip @ ;

: count (n -- [ 1 2 3 ... n ])
    [ [ ] times* ] cons expand ;

: swons@ (var x --)
    ! Prepends x to the list stored in var.
    over $ cons s@ ;

: get (list n -- list[n])
    [ cdr ] times car ;

: last* ( list -- last )
    ! Pushes last cons of the list.
    [ dup cdr ] [ cdr ] while ;

: last ( list -- last )
    ! Pushes last element of the list.
    last* car ;

: length (list -- length)
    0 swap [ drop succ ] each ;

: list (list[0] ... list[n] n -- list)
    [ ] swap [ cons ] times ;

: list? (list -- boolean)
    dup pair? [ cdr list? ] [ f ] ifte ;

: nappend ( [ list1 ] [ list2 ] -- [ list1 list2 ] )
    ! Destructive on list1!
    over [ last* rplacd ] when* ;

: pair? (list -- boolean)
    |factor.Cons is ;

: reverse (list -- list)
    [ ] swap [ swons ] each ;

: rplaca ( A [ B , C ] -- [ A , C ] )
    ! Destructive!
    "factor.Cons" "car" jvar@ ;

: rplacd ( A [ B , C ] -- [ B , A ] )
    ! Destructive!
    "factor.Cons" "cdr" jvar@ ;

: swons (cdr car -- [ car , cdr ])
    swap [ |java.lang.Object |java.lang.Object ]
    |factor.Cons jnew ;

: uncons ([ car , cdr ] -- car cdr)
    dup car swap cdr ;

: unit (a -- [ a ])
    f cons ;

: unswons ([ car , cdr ] -- cdr car)
    dup cdr swap car ;
