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
USE: combinators
USE: kernel
USE: logic
USE: math
USE: stack
USE: vectors

: 2list ( a b -- [ a b ] )
    unit cons ;

: 3list ( a b c -- [ a b c ] )
    2list cons ;

: append ( [ list1 ] [ list2 ] -- [ list1 list2 ] )
    over [ >r uncons r> append cons ] [ nip ] ifte ;

: contains? ( element list -- remainder )
    dup [
        2dup car = [ nip ] [ cdr contains? ] ifte
    ] [
        2drop f
    ] ifte ;

: nth ( n list -- list[n] )
    #! Push the nth element of a proper list.
    #! Supplying n <= 0 pushes the first element of the list.
    #! Supplying an argument beyond the end of the list raises
    #! an error.
    swap [ cdr ] times car ;

: last* ( list -- last )
    #! Pushes last cons of a list.
    dup cdr cons? [ cdr last* ] when ;

: last ( list -- last )
    last* car ;

: list? ( list -- boolean )
    #! Proper list test. A proper list is either f, or a cons
    #! cell whose cdr is a proper list.
    [ dup cons? [ cdr list? ] [ drop f ] ifte ] [ t ] ifte* ;

: partition-add ( obj ? ret1 ret2 -- ret1 ret2 )
    >r >r [ r> cons r> ] [ r> swap r> cons ] ifte ; inline

: partition-step ( ret1 ret2 ref combinator car -- ret1 ret2 )
    >r rot >r rot r> r> -rot >r >r dup >r swap call r> swap r> r>
    partition-add ; inline

: partition-iter ( ret1 ret2 ref combinator list -- ret1 ret2 )
    dup [
        3dup cdr >r >r >r
        car partition-step
        r> r> r> partition-iter
    ] [
        3drop
    ] ifte ; inline interpret-only

: partition ( ref list combinator -- list1 list2 )
    #! Compare each element in a proper list against a
    #! reference element using a combinator. The combinator's
    #! return value determines if the element is prepended to
    #! the first or second list.
    #! The combinator must have stack effect:
    #! ( ref element -- ? )
    swap >r >r >r [ ] [ ] r> r> r> partition-iter ;
    inline interpret-only

: sort ( list comparator -- sorted )
    #! Sort the elements in a proper list using a comparator.
    #! The comparator must have stack effect:
    #! ( x y -- ? )
    #! To sort elements in descending order, return t if x < y.
    #! To sort elements in ascending order, return t if x > y.
    over [
        ! Partition
        dup >r >r uncons dupd r> partition r>
        ! Recurse
        tuck sort >r sort swap r>
        ! Combine
        cons append
    ] [
        drop
    ] ifte ; inline interpret-only

: num-sort ( list -- sorted )
    #! Sorts the list into ascending numerical order.
    [ > ] sort ;

! Redefined below
DEFER: tree-contains?

: =-or-contains? ( element obj -- ? )
    dup cons? [ tree-contains? ] [ = ] ifte ;

: tree-contains? ( element tree -- ? )
    dup [
        2dup car =-or-contains? [
            nip
        ] [
            cdr dup cons? [
                tree-contains?
            ] [
                ! don't bomb on dotted pairs
                =-or-contains?
            ] ifte
        ] ifte
    ] [
        2drop f
    ] ifte ;

: unique ( elem list -- list )
    #! Prepend an element to a proper list if it is not
    #! already contained in the list.
    2dup contains? [ nip ] [ cons ] ifte ;

: (each) ( list quot -- list quot )
    >r uncons r> tuck 2slip ; inline interpret-only

: each ( list quot -- )
    #! Push each element of a proper list in turn, and apply a
    #! quotation with effect ( X -- ) to each element.
    over [ (each) each ] [ 2drop ] ifte ;
    inline interpret-only

: reverse ( list -- list )
    [ ] swap [ swons ] each ;

: map ( list quot -- list )
    #! Push each element of a proper list in turn, and collect
    #! return values of applying a quotation with effect
    #! ( X -- Y ) to each element into a new list.
    over [ (each) rot >r map r> swons ] [ drop ] ifte ;
    inline interpret-only

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
    ] ifte ; inline interpret-only

: remove ( obj list -- list )
    #! Remove all occurrences of the object from the list.
    [ dupd = not ] subset nip ;

: length ( list -- length )
    0 swap [ drop succ ] each ;

: prune ( list -- list )
    #! Remove duplicate elements.
    dup [
        uncons prune 2dup contains? [ nip ] [ cons ] ifte
    ] when ;

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
    ] ifte ;

: (count) ( n list -- list )
    >r pred dup 0 < [ drop r> ] [ dup r> cons (count) ] ifte ;

: count ( n -- [ 0 ... n-1 ] )
    [ ] (count) ;

: cons= ( obj cons -- ? )
    2dup eq? [
        2drop t
    ] [
        over cons? [
            2dup 2car = >r 2cdr = r> and
        ] [
            2drop f
        ] ifte
    ] ifte ;

: (cons-hashcode) ( cons count -- hash )
    dup 0 = [
        2drop 0
    ] [
        over cons? [
            pred >r uncons r> tuck
            (cons-hashcode) >r
            (cons-hashcode) r>
            bitxor
        ] [
            drop hashcode
        ] ifte
    ] ifte ;

: cons-hashcode ( cons -- hash )
    4 (cons-hashcode) ;

: list>vector ( list -- vector )
    dup length <vector> swap [ over vector-push ] each ;

: stack>list ( vector -- list )
    [ ] swap [ swons ] vector-each ;

: vector>list ( vector -- list )
    stack>list reverse ;
