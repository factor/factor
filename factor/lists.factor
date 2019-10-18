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

!
! List manipulation primitives
!
: array>list ( array -- list )
    [ [ "java.lang.Object" ] ] "factor.Cons" "fromArray"
    jinvoke-static ;

: car ([ car , cdr ] -- car)
    |factor.Cons |car jvar$ ;

: cdr ([ car , cdr ] -- cdr)
    |factor.Cons |cdr jvar$ ;

: cons (car cdr -- [ car , cdr ])
    [ |java.lang.Object |java.lang.Object ] |factor.Cons jnew ;

: cons? (list -- boolean)
    |factor.Cons is ;

: rplaca ( A [ B , C ] -- [ A , C ] )
    ! Destructive!
    "factor.Cons" "car" jvar@ ;

: rplacd ( A [ B , C ] -- [ B , A ] )
    ! Destructive!
    "factor.Cons" "cdr" jvar@ ;

!
! List manipulation library
!
: 2list (a b -- [ a b ])
    unit cons ;

: 3list ( a b c -- [ a b c ] )
    2list cons ;

: 2rlist (a b -- [ b a ])
    swap unit cons ;

: append ( [ list1 ] [ list2 ] -- [ list1 list2 ] )
    over [ [ uncons ] dip append cons ] [ nip ] ifte ;

: add ([ list1 ] elem -- [ list1 elem ])
    unit append ;

: append@ ([ list ] variable --)
    ! Adds the list to the end of the list stored in the given variable.
    dup [ $ swap append ] dip @ ;

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

: assoc$ (key alist -- value)
    ! Looks up the key in the given variable alist. A variable
    ! alist is a list of comma pairs, the car of each pair is a
    ! variable name, the cdr is the value.
    dup [
        2dup car car $ = [
            nip car cdr
        ] [
            cdr assoc$
        ] ifte
    ] [
        2drop f
    ] ifte ;

: caar (list -- caar)
    car car ;

: cdar (list -- cadr)
    cdr car ;

: cadr (list -- cdar)
    car cdr ;

: cddr (list -- cddr)
    cdr cdr ;

: clone-list-iter ( result list -- last [ ] )
    [
        dup cons?
    ] [
        uncons [ unit tuck [ rplacd ] dip ] dip
    ] while ;

: clone-list (list -- list)
    dup [
        uncons [ unit dup ] dip clone-list-iter swap rplacd
    ] when ;

: contains ( elem list -- remainder )
    ! If the list contains elem, return the remainder of the
    ! list, starting from the cell whose car is elem.
    dup [
        2dup car = [
            nip
        ] [
            cdr contains
        ] ifte
    ] [
        2drop f
    ] ifte ;

: cons@ (x var --)
    ! Prepends x to the list stored in var.
    tuck $ cons s@ ;

: count (n -- [ 1 2 3 ... n ])
    [ [ ] times* ] cons expand ;

: get (list n -- list[n])
    [ cdr ] times car ;

: last* ( list -- last )
    ! Pushes last cons of the list.
    [ dup cdr cons? ] [ cdr ] while ;

: last ( list -- last )
    ! Pushes last element of the list.
    last* car ;

: length (list -- length)
    0 swap [ drop succ ] each ;

: list? ( list -- boolean )
    ! A list is either f, or a cons cell whose cdr is a list.
    dup [
        dup cons? [
            cdr list?
        ] [
            drop f
        ] ifte
    ] [
        drop t
    ] ifte ;

: nappend ( [ list1 ] [ list2 ] -- [ list1 list2 ] )
    ! Destructive on list1!
    over [ over last* rplacd ] [ nip ] ifte ;

~<< partition-iterI
    R1 R2 A D C -- A C r:R1 r:R2 r:A r:D r:C >>~

~<< partition-iterT{
    r:R1 r:R2 r:A r:D r:C -- A R1 r:R1 r:R2 r:D r:C >>~

~<< }partition-iterT
    R1 r:R1X r:R2 r:D r:C -- R1 R2 D C >>~

~<< partition-iterF{
    r:R1 r:R2 r:A r:D r:C -- A R2 r:R1 r:R2 r:D r:C >>~

~<< }partition-iterF
    R2 r:R1 r:R2X r:D r:C -- R1 R2 D C >>~

: partition-iter ( ref ret1 ret2 list combinator -- ret1 ret2 )
    over [
        ! Note this ifte must be in tail position!
        [ uncons ] dip partition-iterI [ dup ] 2dip call [
            partition-iterT{ cons }partition-iterT partition-iter
        ] [
            partition-iterF{ cons }partition-iterF partition-iter
        ] ifte
    ] [
        2drop
    ] ifte ;

: partition ( ref list combinator -- list1 list2 )
    [ ] [ ] 2swap partition-iter rot drop ;

: reverse (list -- list)
    [ ] swap [ swons ] each ;

: sort ( list comparator -- sorted )
    over [
        ! Partition
        dup [ [ uncons dupd ] dip partition ] dip
        ! Recurse
        tuck sort [ sort ] dip
        ! Combine
        swapd cons append
    ] [
        drop
    ] ifte ;

: swons (cdr car -- [ car , cdr ])
    swap cons ;

: swons@ (var x --)
    ! Prepends x to the list stored in var.
    over $ cons s@ ;

: uncons ([ car , cdr ] -- car cdr)
    dup car swap cdr ;

: unique ( elem list -- list )
    ! Cons elem onto list if its not already there.
    2dup contains [
        nip
    ] [
        cons
    ] ifte ;

: unique@ ( elem var -- )
    tuck $ unique s@ ;

: unit (a -- [ a ])
    f cons ;

: unswons ([ car , cdr ] -- cdr car)
    dup cdr swap car ;
