! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: arrays errors generic kernel math sequences ;

M: f car ;
M: f cdr ;

UNION: general-list POSTPONE: f cons ;

GENERIC: >list ( seq -- list )
M: general-list >list ( list -- list ) ;

PREDICATE: general-list list ( list -- ? )
    #! Proper list test. A proper list is either f, or a cons
    #! cell whose cdr is a proper list.
    [ cdr list? ] [ t ] if* ;

: uncons ( [[ car cdr ]] -- car cdr ) dup car swap cdr ; inline
: unswons ( [[ car cdr ]] -- cdr car ) dup cdr swap car ; inline

: swons ( cdr car -- [[ car cdr ]] ) swap cons ; inline
: unit ( a -- [ a ] ) f cons ; inline

: 2car ( cons cons -- car car ) [ car ] 2apply ; inline
: 2cdr ( cons cons -- car car ) [ cdr ] 2apply ; inline

! Sequence protocol
M: f length drop 0 ;
M: cons length cdr length 1+ ;

: (list-each) ( list quot -- )
    over [
        [ >r car r> call ] 2keep >r cdr r> (list-each)
    ] [
        2drop
    ] if ; inline

M: general-list each ( list quot -- | quot: elt -- )
    (list-each) ;

: (list-map) ( list quot -- list )
    over [
        over cdr over >r >r >r car r> call
        r> r> rot >r (list-map) r> swons
    ] [
        drop
    ] if ; inline

M: general-list map ( list quot -- list ) (list-map) ;

: (list-find) ( list quot i -- i elt )
    pick [
        >r 2dup >r >r >r car r> call [
            r> car r> drop r> swap
        ] [
            r> cdr r> r> 1+ (list-find)
        ] if
    ] [
        3drop -1 f
    ] if ; inline

M: general-list find ( list quot -- i elt )
    0 (list-find) ;

M: general-list reverse-slice ( list -- list )
    [ ] [ swons ] reduce ;

M: general-list reverse reverse-slice ;

M: general-list nth ( n list -- element )
    over 0 <= [ nip car ] [ >r 1- r> cdr nth ] if ;

M: cons = ( obj cons -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over cons? not ] [ 2drop f ] }
        { [ t ] [ 2dup 2car = >r 2cdr = r> and ] }
    } cond ;

: curry ( obj quot -- quot ) >r literalize r> cons ;

: make-dip ( quot n -- quot )
    dup \ >r <array> -rot \ r> <array> append3 >list ;

: (>list) ( n i seq -- list )
    pick pick <= [
        3drop [ ]
    ] [
        2dup nth >r >r 1+ r> (>list) r> swons
    ] if ;

M: object >list ( seq -- list ) dup length 0 rot (>list) ;

M: general-list like drop >list ;
