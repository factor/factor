! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: generic kernel sequences ;

! This file contains vital list-related words that everything
! else depends on, and is loaded early in bootstrap.
! lists.factor has everything else.

! We borrow an idiom from Common Lisp. The car/cdr of an empty
! list is the empty list.
M: f car ;
M: f cdr ;

UNION: general-list POSTPONE: f cons ;

GENERIC: >list ( seq -- list )
M: general-list >list ( list -- list ) ;

: last ( list -- last )
    #! Last cons of a list.
    dup cdr cons? [ cdr last ] when ; foldable

PREDICATE: general-list list ( list -- ? )
    #! Proper list test. A proper list is either f, or a cons
    #! cell whose cdr is a proper list.
    dup [ last cdr ] when not ;

: uncons ( [[ car cdr ]] -- car cdr ) dup car swap cdr ; inline
: unswons ( [[ car cdr ]] -- cdr car ) dup cdr swap car ; inline

: swons ( cdr car -- [[ car cdr ]] ) swap cons ; inline
: unit ( a -- [ a ] ) f cons ; inline
: 2list ( a b -- [ a b ] ) unit cons ; inline

: 2car ( cons cons -- car car ) [ car ] 2apply ; inline
: 2cdr ( cons cons -- car car ) [ cdr ] 2apply ; inline

M: cons = ( obj cons -- ? )
    @{
        @{ [ 2dup eq? ] [ 2drop t ] }@
        @{ [ over cons? not ] [ 2drop f ] }@
        @{ [ t ] [ 2dup 2car = >r 2cdr = r> and ] }@
    }@ cond ;

M: f = ( obj f -- ? ) eq? ;
