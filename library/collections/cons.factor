! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: generic kernel sequences ;

! This file contains vital list-related words that everything
! else depends on, and is loaded early in bootstrap.
! lists.factor has everything else.

DEFER: cons?
BUILTIN: cons 2 cons? [ 0 "car" f ] [ 1 "cdr" f ] ;

! We borrow an idiom from Common Lisp. The car/cdr of an empty
! list is the empty list.
M: f car ;
M: f cdr ;

UNION: general-list f cons ;

GENERIC: >list ( seq -- list )
M: general-list >list ( list -- list ) ;

: last ( list -- last )
    #! Last cons of a list.
    dup cdr cons? [ cdr last ] when ;

PREDICATE: general-list list ( list -- ? )
    #! Proper list test. A proper list is either f, or a cons
    #! cell whose cdr is a proper list.
    dup [ last cdr ] when not ;

: uncons ( [[ car cdr ]] -- car cdr ) dup car swap cdr ;
: unswons ( [[ car cdr ]] -- cdr car ) dup cdr swap car ;

: swons ( cdr car -- [[ car cdr ]] ) swap cons ;
: unit ( a -- [ a ] ) f cons ;
: 2list ( a b -- [ a b ] ) unit cons ;
: 3list ( a b c -- [ a b c ] ) 2list cons ;
: 2unlist ( [ a b ] -- a b ) uncons car ;
: 3unlist ( [ a b c ] -- a b c ) uncons uncons car ;

: 2car ( cons cons -- car car ) swap car swap car ;
: 2cdr ( cons cons -- car car ) swap cdr swap cdr ;
: 2cons ( ca1 ca2 cd1 cd2 -- c1 c2 ) rot swons >r cons r> ;
: 2uncons ( c1 c2 -- ca1 ca2 cd1 cd2 ) [ 2car ] 2keep 2cdr ;

: unzip ( assoc -- keys values )
    #! Split an association list into two lists of keys and
    #! values.
    [ uncons >r uncons r> unzip 2cons ] [ [ ] [ ] ] ifte* ;

: unpair ( list -- list1 list2 )
    [ uncons uncons unpair rot swons >r cons r> ] [ f f ] ifte* ;

: <queue> ( -- queue )
    #! Make a new functional queue.
    [[ [ ] [ ] ]] ;

: queue-empty? ( queue -- ? )
    uncons or not ;

: enque ( obj queue -- queue )
    uncons >r cons r> cons ;

: deque ( queue -- obj queue )
    uncons
    [ uncons swapd cons ] [ reverse uncons f swons ] ifte* ;

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
