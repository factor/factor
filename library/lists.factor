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
USE: math

: 2list ( a b -- [ a b ] )
    unit cons ;

: 3list ( a b c -- [ a b c ] )
    2list cons ;

: append ( [ list1 ] [ list2 ] -- [ list1 list2 ] )
    over [ >r uncons r> append cons ] [ nip ] ifte ;

: some? ( list pred -- ? )
    #! Apply predicate to each element ,return remainder of list
    #! from first occurrence where it is true, or return f.
    over [
        dup >r over >r >r car r> call [
            r> r> drop
        ] [
            r> cdr r> some?
        ] ifte
    ] [
        2drop f
    ] ifte ; inline

: contains? ( element list -- ? )
    #! Test if a list contains an element.
    [ over = ] some? >boolean nip ;

: partition-add ( obj ? ret1 ret2 -- ret1 ret2 )
    rot [ swapd cons ] [ >r cons r> ] ifte ;

: partition-step ( ref list combinator -- ref cdr combinator car ? )
    pick pick car pick call >r >r unswons r> swap r> ; inline

: (partition) ( ref list combinator ret1 ret2 -- ret1 ret2 )
    >r >r  over [
        partition-step  r> r> partition-add  (partition)
    ] [
        3drop  r> r>
    ] ifte ; inline

: partition ( ref list combinator -- list1 list2 )
    #! The combinator must have stack effect:
    #! ( ref element -- ? )
    [ ] [ ] (partition) ; inline

: sort ( list comparator -- sorted )
    #! To sort in ascending order, comparator must have stack
    #! effect ( x y -- x>y ).
    over [
        ( Partition ) [ >r uncons dupd r> partition ] keep
        ( Recurse ) [ sort swap ] keep sort
        ( Combine ) swapd cons append
    ] [
        drop
    ] ifte ; inline

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
    #! Prepend an element to a list if it does not occur in the
    #! list.
    2dup contains? [ nip ] [ cons ] ifte ;

: reverse ( list -- list )
    [ ] swap [ swons ] each ;

: map ( list quot -- list )
    #! Push each element of a proper list in turn, and collect
    #! return values of applying a quotation with effect
    #! ( X -- Y ) to each element into a new list.
    over [ (each) rot >r map r> swons ] [ drop ] ifte ; inline

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

: all=? ( list -- ? )
    #! Check if all elements of a list are equal.
    dup [ uncons [ over = ] all? nip ] [ drop t ] ifte ;

: maximize ( pred o1 o2 -- o1/o2 )
    #! Return o1 if pred returns true, o2 otherwise.
    [ rot call ] 2keep ? ; inline

: (top) ( list maximizer -- elt )
    #! Return the highest element in the list, where maximizer
    #! has stack effect ( o1 o2 -- max(o1,o2) ).
    >r uncons r> each ; inline

: top ( list pred -- elt )
    #! Return the highest element in the list, where pred is a
    #! partial order with stack effect ( o1 o2 -- ? ).
    swap [ pick >r maximize r> swap ] (top) nip ; inline

M: cons = ( obj cons -- ? )
    2dup eq? [
        2drop t
    ] [
        over cons? [
            2dup 2car = >r 2cdr = r> and
        ] [
            2drop f
        ] ifte
    ] ifte ;

: cons-hashcode ( cons count -- hash )
    dup 0 = [
        2drop 0
    ] [
        over cons? [
            pred >r uncons r> tuck
            cons-hashcode >r
            cons-hashcode r>
            bitxor
        ] [
            drop hashcode
        ] ifte
    ] ifte ;

M: cons hashcode ( cons -- hash ) 4 cons-hashcode ;

: project ( n quot -- list )
    #! Execute the quotation n times, passing the loop counter
    #! the quotation as it ranges from 0..n-1. Collect results
    #! in a new list.
    [ ] rot [ -rot over >r >r call r> cons r> swap ] times*
    nip reverse ; inline

: count ( n -- [ 0 ... n-1 ] )
    [ ] project ;
