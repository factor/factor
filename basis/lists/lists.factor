! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors math arrays vectors classes words locals ;
IN: lists

! List Protocol
MIXIN: list
GENERIC: car   ( cons -- car )
GENERIC: cdr   ( cons -- cdr )
GENERIC: nil?  ( object -- ?   )
    
TUPLE: cons car cdr ;

C: cons cons

M: cons car ( cons -- car )
    car>> ;

M: cons cdr ( cons -- cdr )
    cdr>> ;
    
SYMBOL: +nil+
M: word nil? +nil+ eq? ;
M: object nil? drop f ;
    
: atom? ( obj -- ? ) [ list? ] [ nil? ] bi or not ;

: nil ( -- symbol ) +nil+ ; 
    
: uncons ( cons -- cdr car )
    [ cdr ] [ car ] bi ;
    
: 1list ( obj -- cons )
    nil cons ;
    
: 2list ( a b -- cons )
    nil cons cons ;

: 3list ( a b c -- cons )
    nil cons cons cons ;
    
: cadr ( cons -- elt )    
    cdr car ;
    
: 2car ( cons -- car caar )    
    [ car ] [ cdr car ] bi ;
    
: 3car ( cons -- car cadr caddr )    
    [ car ] [ cdr car ] [ cdr cdr car ] tri ;

: lnth ( n list -- elt )
    swap [ cdr ] times car ;
    
: (leach) ( list quot -- cdr quot )
    [ [ car ] dip call ] [ [ cdr ] dip ] 2bi ; inline

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
    
: seq>list ( seq -- list )    
    <reversed> nil [ swap cons ] reduce ;
    
: same? ( obj1 obj2 -- ? ) 
    [ class ] bi@ = ;
    
: seq>cons ( seq -- cons )
    [ <reversed> ] keep nil [ tuck same? [ seq>cons ] when f cons swap >>cdr ] with reduce ;
    
: (lmap>array) ( acc cons quot: ( elt -- elt' ) -- newcons )
    over nil? [ 2drop ]
    [ [ uncons ] dip [ call ] keep swapd [ suffix ] 2dip (lmap>array) ] if ;
    inline recursive
    
: lmap>array ( cons quot -- newcons )
    { } -rot (lmap>array) ; inline
    
: lmap-as ( cons quot exemplar -- seq )
    [ lmap>array ] dip like ;
    
: cons>seq ( cons -- array )    
    [ dup cons? [ cons>seq ] when dup nil? [ drop { } ] when ] lmap>array ;
    
: list>seq ( list -- array )    
    [ ] lmap>array ;
    
: traverse ( list pred quot: ( list/elt -- result ) -- result )
    [ 2over call [ tuck [ call ] 2dip ] when
      pick list? [ traverse ] [ 2drop ] if ] 2curry lmap ; inline recursive
    
INSTANCE: cons list
