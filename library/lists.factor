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
USE: arithmetic
USE: combinators
USE: kernel
USE: logic
USE: stack
USE: vectors

: 2list ( a b -- [ a b ] )
    #! Construct a proper list of 2 elements.
    unit cons ;

: 3list ( a b c -- [ a b c ] )
    #! Construct a proper list of 3 elements.
    2list cons ;

: 2rlist ( a b -- [ b a ] )
    #! Construct a proper list of 2 elements in reverse stack order.
    swap unit cons ;

: copy-cons ( accum cons -- accum cdr )
    uncons >r unit dup rot set-cdr r> ;

: (clone-list) ( accum list -- last )
    dup cons? [ copy-cons (clone-list) ] [ over set-cdr ] ifte ;

: clone-list* ( list -- list last )
    #! Push the cloned list, and the last cons cell of the
    #! cloned list.
    uncons >r unit dup r> (clone-list) ;

: clone-list ( list -- list )
    #! Push a shallow copy of a list.
    dup [ clone-list* drop ] when ;

: append ( [ list1 ] [ list2 ] -- [ list1 list2 ] )
    #! Append two lists. A new list is constructed by copying
    #! the first list and setting its tail to the second.
    over [ >r clone-list* r> swap set-cdr ] [ nip ] ifte ;

: add ( [ list1 ] elem -- [ list1 elem ] )
    #! Push a new proper list with an element added to the end.
    unit append ;

: caar ( list -- caar )
    car car ; inline

: cdar ( list -- cadr )
    cdr car ; inline

: cadr ( list -- cdar )
    car cdr ; inline

: cddr ( list -- cddr )
    cdr cdr ; inline

: contains ( element list -- remainder )
    #! If the proper list contains the element, push the
    #! remainder of the list, starting from the cell whose car
    #! is elem. Otherwise push f.
    dup [
        2dup car = [
            nip
        ] [
            cdr contains
        ] ifte
    ] [
        2drop f
    ] ifte ;

: nth ( n list -- list[n] )
    #! Gets the nth element of a proper list by successively
    #! iterating down the cdr pointer.
    #! Supplying n <= 0 pushes the first element of the list.
    #! Supplying an argument beyond the end of the list raises
    #! an error.
    swap [ cdr ] times car ;

: last* ( list -- last )
    #! Pushes last cons of a list.
    #! For example, given a proper list, pushes a cons cell
    #! whose car is the last element of the list, and whose cdr
    #! is f.
    [ dup cdr cons? ] [ cdr ] while ;

: last ( list -- last )
    #! Pushes last element of a list. Since this pushes the
    #! car of the last cons cell, the list may be an improper
    #! list.
    last* car ;

: list? ( list -- boolean )
    #! Proper list test. A proper list is either f, or a cons
    #! cell whose cdr is a proper list.
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
    #! DESTRUCTIVE. Append two lists. The last node of the first
    #! list is destructively modified to point to the second
    #! list, unless the first list is f, in which case the
    #! second list is returned.
    over [ over last* set-cdr ] [ nip ] ifte ;

: first ( list -- obj )
    #! Push the head of the list, or f if the list is empty.
    dup [ car ] when ;

: next ( obj list -- obj )
    #! Push the next object in the list after an object. Wraps
    #! around to beginning of list if object is at the end.
    tuck contains dup [
        ! Is there another entry in the list?
        cdr dup [
            nip car
        ] [
            ! No. Pick first
            drop first
        ] ifte
    ] [
        drop first
    ] ifte ;

: nreverse-iter ( list cons -- list cons )
    [ dup dup cdr 2swap set-cdr nreverse-iter ] when* ;

: nreverse ( list -- list )
    #! DESTRUCTIVE. Reverse the given list, without consing.
    f swap nreverse-iter ;

: partition-add ( obj ? ret1 ret2 -- ret1 ret2 )
    >r >r [ r> cons r> ] [ r> r> swapd cons ] ifte ; inline

: partition-step ( ret1 ret2 ref combinator car -- ret1 ret2 )
    >r 2swap r> -rot >r >r dup >r swap call r> swap r> r>
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
        tuck sort >r sort r>
        ! Combine
        swapd cons nappend
    ] [
        drop
    ] ifte ; inline interpret-only

: num-sort ( list -- sorted )
    #! Sorts the list into ascending numerical order.
    [ > ] sort ;

! Redefined below
DEFER: tree-contains?

: =-or-contains? ( element obj -- ? )
    dup cons? [
        tree-contains?
    ] [
        =
    ] ifte ;

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
    2dup contains [
        nip
    ] [
        cons
    ] ifte ;

: each ( list quotation -- )
    #! Push each element of a proper list in turn, and apply a
    #! quotation to each element.
    #!
    #! In order to compile, the quotation must consume one more
    #! value than it produces.
    over [
        >r uncons r> tuck >r >r call r> r> each
    ] [
        2drop
    ] ifte ; inline interpret-only

: map ( list code -- list )
    #! Applies the code to each item, returns a list that
    #! contains the result of each application.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    f transp [
        ( accum code elem -- accum code )
        transp over >r >r call r> cons r>
    ] each drop nreverse ; inline interpret-only

: 2uncons ( list1 list2 -- car1 car2 cdr1 cdr2 )
    uncons >r >r uncons r> swap r> ;

: 2each-step ( list list quot -- cdr cdr )
    >r 2uncons r> -rot >r >r call r> r> ; inline interpret-only

: 2each ( list list quot -- )
    #! Apply the quotation to each pair of elements from the
    #! two lists in turn. The quotation must have stack effect
    #! ( x y -- ).
    >r 2dup and [
        r> dup >r 2each-step r> 2each
    ] [
        r> 3drop
    ] ifte ; inline interpret-only

: 2map-step ( accum quot elt elt -- accum )
    2swap swap >r call r> cons ;

: <2map ( list list quot -- accum quot list list )
    >r f -rot r> -rot ;

: 2map ( list list quot -- list )
    #! Apply the quotation to each pair of elements from the
    #! two lists in turn, collecting the return value into a
    #! new list. The quotation must have stack effect
    #! ( x y -- z ).
    <2map [ pick >r 2map-step r> ] 2each drop nreverse ;
    inline interpret-only

: substitute ( new old list -- list )
    [ 2dup = [ drop over ] when ] map nip nip ;

: (head) ( accum list n -- last list )
    dup 1 = [ drop ] [ pred >r copy-cons r> (head) ] ifte ;

: head* ( n list -- head last rest )
    #! Push the head of the list, the last cons cell of the
    #! head, and the rest of the list.
    uncons >r unit tuck r> rot (head) ;

: head ( n list -- head )
    #! Push a new list containing the first n elements.
    over 0 = [ 2drop f ] [ head* 2drop ] ifte ;

: set-nth ( value index list -- list )
    over 0 = [
        nip cdr cons
    ] [
        rot >r head* cdr r> swons swap set-cdr
    ] ifte ;

: subset-add ( car pred accum -- accum )
    >r over >r call r> r> rot [ cons ] [ nip ] ifte ;

: subset-iter ( accum list pred -- accum )
    over [
        >r unswons r> 2swap pick
        >r >r subset-add r> r> subset-iter
	] [
        2drop
    ] ifte ;

: subset ( list pred -- list )
    #! Applies a quotation to each element of a list; all
    #! elements for which the quotation returned a value other
    #! than f are collected in a new list.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    f -rot subset-iter nreverse ; inline interpret-only

: remove ( obj list -- list )
    #! Remove all occurrences of the object from the list.
    [ dupd = not ] subset nip ;

: remove-nth ( n list -- list )
    #! Push a new list with the nth element removed.
    over 0 = [ nip cdr ] [ head* cdr swap set-cdr ] ifte ;

: length ( list -- length )
    #! Pushes the length of the given proper list.
    0 swap [ drop succ ] each ;

: leaves ( list -- length )
    #! Like length, but counts each sub-list recursively.
    0 swap [ dup list? [ leaves + ] [ drop succ ] ifte ] each ;

: reverse ( list -- list )
    #! Push a new list that is the reverse of a proper list.
    [ ] swap [ swons ] each ;

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

: car= swap car swap car = ;
: cdr= swap cdr swap cdr = ;

: cons= ( obj cons -- ? )
    over cons? [ 2dup car= >r cdr= r> and ] [ 2drop f ] ifte ;

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

: list>vector ( list -- vector )
    dup length <vector> swap [ over vector-push ] each ;

: stack>list ( vector -- list )
    [ ] swap [ swons ] vector-each ;

: vector>list ( vector -- list )
    stack>list nreverse ;
