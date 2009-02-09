! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors math arrays vectors classes words
combinators.short-circuit combinators ;
IN: lists

! List Protocol
MIXIN: list
GENERIC: car ( cons -- car )
GENERIC: cdr ( cons -- cdr )
GENERIC: nil? ( object -- ?   )
    
TUPLE: cons { car read-only } { cdr read-only } ;

C: cons cons

M: cons car ( cons -- car )
    car>> ;

M: cons cdr ( cons -- cdr )
    cdr>> ;

SINGLETON: +nil+
M: +nil+ nil? drop t ;
M: object nil? drop f ;

: atom? ( obj -- ? )
    { [ list? ] [ nil? ] } 1|| not ;

: nil ( -- symbol ) +nil+ ; 

: uncons ( cons -- car cdr )
    [ car ] [ cdr ] bi ;

: swons ( cdr car -- cons )
    swap cons ;

: unswons ( cons -- cdr car )
    uncons swap ;

: 1list ( obj -- cons )
    nil cons ;

: 1list? ( list -- ? )
    { [ nil? not ] [ cdr nil? ] } 1&& ;

: 2list ( a b -- cons )
    nil cons cons ;

: 3list ( a b c -- cons )
    nil cons cons cons ;

: cadr ( list -- elt )    
    cdr car ;
 
: 2car ( list -- car caar )    
    [ car ] [ cdr car ] bi ;
 
: 3car ( list -- car cadr caddr )    
    [ car ] [ cdr car ] [ cdr cdr car ] tri ;

: lnth ( n list -- elt )
    swap [ cdr ] times car ;

<PRIVATE
: (leach) ( list quot -- cdr quot )
    [ [ car ] dip call ] [ [ cdr ] dip ] 2bi ; inline
PRIVATE>

: leach ( list quot: ( elt -- ) -- )
    over nil? [ 2drop ] [ (leach) leach ] if ; inline recursive

: lmap ( list quot: ( elt -- ) -- result )
    over nil? [ drop ] [ (leach) lmap cons ] if ; inline recursive

: foldl ( list identity quot: ( obj1 obj2 -- obj ) -- result )
    swapd leach ; inline

: foldr ( list identity quot: ( obj1 obj2 -- obj ) -- result )
    pick nil? [ [ drop ] [ ] [ drop ] tri* ] [
        [ [ cdr ] 2dip foldr ] [ nip [ car ] dip ] 3bi
        call
    ] if ; inline recursive

: llength ( list -- n )
    0 [ drop 1+ ] foldl ;

: lreverse ( list -- newlist )    
    nil [ swap cons ] foldl ;

: lappend ( list1 list2 -- newlist )    
    [ lreverse ] dip [ swap cons ] foldl ;

: lcut ( list index -- before after )
    [ +nil+ ] dip
    [ [ [ cdr ] [ car ] bi ] dip cons ] times
    lreverse swap ;

: sequence>cons ( sequence -- list )    
    <reversed> nil [ swap cons ] reduce ;

<PRIVATE
: same? ( obj1 obj2 -- ? ) 
    [ class ] bi@ = ;
PRIVATE>

: deep-sequence>cons ( sequence -- cons )
    [ <reversed> ] keep nil
    [ tuck same? [ deep-sequence>cons ] when swons ] with reduce ;

<PRIVATE
: (lmap>array) ( acc cons quot: ( elt -- elt' ) -- newcons )
    over nil? [ 2drop ]
    [ [ unswons ] dip [ call ] keep swapd [ suffix ] 2dip (lmap>array) ] if ;
    inline recursive
PRIVATE>

: lmap>array ( list quot -- array )
    [ { } ] 2dip (lmap>array) ; inline

: lmap-as ( list quot exemplar -- sequence )
    [ lmap>array ] dip like ;

: deep-list>array ( list -- array )    
    [
        {
            { [ dup list? ] [ deep-list>array ] }
            { [ dup nil? ] [ drop { } ] }
            [ ]
        } cond
    ] lmap>array ;

: list>array ( list -- array )    
    [ ] lmap>array ;

: traverse ( list pred quot: ( list/elt -- result ) -- result )
    [
        2over call [ tuck [ call ] 2dip ] when
        pick list? [ traverse ] [ 2drop ] if
    ] 2curry lmap ; inline recursive

INSTANCE: cons list
