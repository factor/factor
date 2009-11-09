! Copyright (C) 2008 James Cash, Daniel Ehrenberg, Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors math arrays vectors classes words
combinators.short-circuit combinators locals ;
IN: lists

! List Protocol
MIXIN: list
GENERIC: car ( cons -- car )
GENERIC: cdr ( cons -- cdr )
GENERIC: nil? ( object -- ?   )
    
TUPLE: cons { car read-only } { cdr read-only } ;

C: cons cons

M: cons car ( cons -- car ) car>> ;

M: cons cdr ( cons -- cdr ) cdr>> ;

SINGLETON: +nil+
M: +nil+ nil? drop t ;
M: object nil? drop f ;

: atom? ( obj -- ? ) list? not ; inline

: nil ( -- symbol ) +nil+ ; inline

: uncons ( cons -- car cdr ) [ car ] [ cdr ] bi ; inline

: swons ( cdr car -- cons ) swap cons ; inline

: unswons ( cons -- cdr car ) uncons swap ; inline

: 1list ( obj -- cons ) nil cons ; inline

: 1list? ( list -- ? ) { [ nil? not ] [ cdr nil? ] } 1&& ; inline

: 2list ( a b -- cons ) nil cons cons ; inline

: 3list ( a b c -- cons ) nil cons cons cons ; inline

: cadr ( list -- elt ) cdr car ; inline
 
: 2car ( list -- car caar ) [ car ] [ cdr car ] bi ; inline
 
: 3car ( list -- car cadr caddr ) [ car ] [ cdr car ] [ cdr cdr car ] tri ; inline

: lnth ( n list -- elt ) swap [ cdr ] times car ; inline

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

:: foldr ( list identity quot: ( obj1 obj2 -- obj ) -- result )
    list nil? [ identity ] [
        list cdr identity quot foldr
        list car quot call
    ] if ; inline recursive

: llength ( list -- n )
    0 [ drop 1 + ] foldl ;

: lreverse ( list -- newlist )    
    nil [ swap cons ] foldl ;

: lappend ( list1 list2 -- newlist )    
    [ lreverse ] dip [ swap cons ] foldl ;

: lcut ( list index -- before after )
    [ nil ] dip
    [ [ unswons ] dip cons ] times
    lreverse swap ;

: sequence>list ( sequence -- list )    
    <reversed> nil [ swons ] reduce ;

: lmap>array ( list quot -- array )
    accumulator [ leach ] dip { } like ; inline

: list>array ( list -- array )  
    [ ] lmap>array ;

INSTANCE: cons list
INSTANCE: +nil+ list
