! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: errors generic kernel math sequences ;

! Sequence protocol
M: f length drop 0 ;
M: cons length cdr length 1+ ;

M: f empty? drop t ;
M: cons empty? drop f ;

M: f peek ( f -- f ) ;

M: cons peek ( list -- last )
    #! Last element of a list.
    last car ;

M: f each ( list quot -- ) 2drop ;

M: cons each ( list quot -- | quot: elt -- )
    [ >r car r> call ] 2keep >r cdr r> each ;

M: f map ( f quot -- f ) drop ;

M: cons map ( cons quot -- cons )
    over cdr over >r >r >r car r> call r> r> rot >r map r> swons ;

: (list-find) ( list quot i -- i elt )
    pick [
        >r 2dup >r >r >r car r> call [
            r> car r> drop r> swap
        ] [
            r> cdr r> r> 1+ (list-find)
        ] ifte
    ] [
        3drop -1 f
    ] ifte ; inline

M: general-list find ( list quot -- i elt )
    0 (list-find) ;

M: general-list reverse-slice ( list -- list )
    [ ] [ swons ] reduce ;

M: general-list reverse reverse-slice ;

M: general-list head ( n list -- list )
    #! Return the first n elements of the list.
    over 0 > [
        unswons >r >r 1- r> head r> swons
    ] [
        2drop f
    ] ifte ;

M: general-list tail ( n list -- tail )
    #! Return the rest of the list, from the nth index onward.
    swap [ cdr ] times ;

M: general-list nth ( n list -- element )
    over 0 number= [ nip car ] [ >r 1- r> cdr nth ] ifte ;

M: cons = ( obj cons -- ? )
    @{
        @{ [ 2dup eq? ] [ 2drop t ] }@
        @{ [ over cons? not ] [ 2drop f ] }@
        @{ [ t ] [ 2dup 2car = >r 2cdr = r> and ] }@
    }@ cond ;

M: f = ( obj f -- ? ) eq? ;
