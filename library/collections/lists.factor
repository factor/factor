! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: errors generic kernel math sequences ;

! Sequence protocol
M: f length drop 0 ;
M: cons length cdr length 1 + ;

M: f empty? drop t ;
M: cons empty? drop f ;

M: cons peek ( list -- last )
    #! Last element of a list.
    last car ;

: (each) ( list quot -- list quot )
    [ >r car r> call ] 2keep >r cdr r> ; inline

M: f each ( list quot -- ) 2drop ;

M: cons each ( list quot -- | quot: elt -- ) (each) each ;

: (list-find) ( list quot i -- i elt )
    pick [
        >r 2dup >r >r >r car r> call [
            r> car r> drop r> swap
        ] [
            r> cdr r> r> 1 + (list-find)
        ] ifte
    ] [
        3drop -1 f
    ] ifte ; inline

M: general-list find ( list quot -- i elt )
    0 (list-find) ;

M: general-list find* ( start list quot -- i elt )
    >r tail r> find ;

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
    2dup member? [ nip ] [ cons ] ifte ;

M: general-list reverse-slice ( list -- list )
    [ ] [ swons ] reduce ;

M: general-list reverse reverse-slice ;

IN: sequences
DEFER: <range>

IN: lists

: count ( n -- [ 0 ... n-1 ] )
    0 swap <range> >list ;

: project ( n quot -- list )
    >r count r> map ; inline

: project-with ( elt n quot -- list )
    swap [ with rot ] project 2nip ; inline

: seq-transpose ( seq -- list )
    #! An example illustrates this word best:
    #! [ [ 1 2 3 ] [ 4 5 6 ] ] ==> [ [ 1 2 ] [ 3 4 ] [ 5 6 ] ]
    dup first length [ swap [ nth ] map-with ] project-with ;

M: general-list head ( n list -- list )
    #! Return the first n elements of the list.
    over 0 > [
        unswons >r >r 1 - r> head r> swons
    ] [
        2drop f
    ] ifte ;

M: general-list tail ( n list -- tail )
    #! Return the rest of the list, from the nth index onward.
    swap [ cdr ] times ;

M: general-list nth ( n list -- element )
    over 0 number= [ nip car ] [ >r 1 - r> cdr nth ] ifte ;
