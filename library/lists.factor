! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: errors generic kernel math sequences ;

! Sequence protocol
M: general-list length 0 swap [ drop 1 + ] each ;

M: f nth "List index out of bounds" throw ;

M: cons nth ( n list -- element )
    >r dup 0 = [
        drop r> car
    ] [
        1 - r> cdr nth
    ] ifte ;

: 2list ( a b -- [ a b ] )
    unit cons ;

: 2unlist ( [ a b ] -- a b )
    uncons car ;

: 3list ( a b c -- [ a b c ] )
    2list cons ;

: 3unlist ( [ a b c ] -- a b c )
    uncons uncons car ;

: append ( [ list1 ] [ list2 ] -- [ list1 list2 ] )
    over [ >r uncons r> append cons ] [ nip ] ifte ;

: contains? ( obj list -- ? )
    #! Test if a list contains an element equal to an object.
    [ = ] some-with? >boolean ;

: memq? ( obj list -- ? )
    #! Test if a list contains an object.
    [ eq? ] some-with? >boolean ;

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

: map-with ( obj list quot -- list )
    #! Push each element of a proper list in turn, and collect
    #! return values of applying a quotation with effect
    #! ( obj elt -- obj ) to each element into a new list.
    swap [ with rot ] map 2nip ; inline

: remove ( obj list -- list )
    #! Remove all occurrences of objects equal to this one from
    #! the list.
    [ = not ] subset-with ;

: remq ( obj list -- list )
    #! Remove all occurrences of the object from the list.
    [ eq? not ] subset-with ;

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

M: f = ( obj f -- ? ) eq? ;

M: cons hashcode ( cons -- hash ) car hashcode ;

: (count) ( i n -- list )
    2dup >= [ 2drop [ ] ] [ >r dup 1 + r> (count) cons ] ifte ;

: count ( n -- [ 0 ... n-1 ] )
    0 swap (count) ;

: project ( n quot -- list )
    >r count r> map ; inline

: project-with ( elt n quot -- list )
    swap [ with rot ] project 2nip ; inline

: head ( list n -- list )
    #! Return the first n elements of the list.
    dup 0 > [ >r uncons r> 1 - head cons ] [ 2drop f ] ifte ;

: tail ( list n -- tail )
    #! Return the rest of the list, from the nth index onward.
    [ cdr ] times ;

: intersection ( list list -- list )
    #! Make a list of elements that occur in both lists.
    [ over contains? ] subset nip ;

: difference ( list1 list2 -- list )
    #! Make a list of elements that occur in list2 but not
    #! list1.
    [ over contains? not ] subset nip ;

: <queue> ( -- queue )
    #! Make a new functional queue.
    [[ [ ] [ ] ]] ;

: queue-empty? ( queue -- ? )
    uncons or not ;

: enque ( obj queue -- queue )
    uncons >r cons r> cons ;

: deque ( queue -- obj queue )
    uncons [
        uncons swapd cons
    ] [
        reverse uncons f swons
    ] ifte* ;
