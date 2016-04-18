! Copyright (C) 2008 James Cash, Daniel Ehrenberg, Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit kernel locals math
sequences ;
IN: lists

! List Protocol
MIXIN: list
GENERIC: car ( cons -- car )
GENERIC: cdr ( cons -- cdr )
GENERIC: nil? ( object -- ?   )

TUPLE: cons-state { car read-only } { cdr read-only } ;

C: cons cons-state

M: cons-state car ( cons -- car ) car>> ;

M: cons-state cdr ( cons -- cdr ) cdr>> ;

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

: 2list ( a b -- cons ) 1list cons ; inline

: 3list ( a b c -- cons ) 2list cons ; inline

: cadr ( list -- elt ) cdr car ; inline

: 2car ( list -- car cadr ) uncons car ; inline

: 3car ( list -- car cadr caddr ) uncons uncons car ; inline

: lnth ( n list -- elt ) swap [ cdr ] times car ; inline

<PRIVATE

: (leach) ( list quot -- cdr quot )
    [ [ car ] dip call ] [ [ cdr ] dip ] 2bi ; inline

PRIVATE>

: leach ( ... list quot: ( ... elt -- ... ) -- ... )
    over nil? [ 2drop ] [ (leach) leach ] if ; inline recursive

: foldl ( ... list identity quot: ( ... prev elt -- ... next ) -- ... result )
    swapd leach ; inline

:: foldr ( ... list identity quot: ( ... prev elt -- ... next ) -- ... result )
    list nil? [
        identity
    ] [
        list cdr identity quot foldr
        list car quot call
    ] if ; inline recursive

: llength ( list -- n )
    0 [ drop 1 + ] foldl ;

: lreverse ( list -- newlist )
    nil [ swons ] foldl ;

: lmap ( ... list quot: ( ... elt -- ... newelt ) -- ... result )
    [ nil ] dip [ swapd dip cons ] curry foldl lreverse ; inline

: lappend ( list1 list2 -- newlist )
    [ lreverse ] dip [ swons ] foldl ;

: lcut ( list index -- before after )
    [ nil ] dip [ [ unswons ] dip cons ] times lreverse swap ;

: sequence>list ( sequence -- list )
    <reversed> nil [ swons ] reduce ;

: lmap>array ( ... list quot: ( ... elt -- ... newelt ) -- ... array )
    collector [ leach ] dip { } like ; inline

: list>array ( list -- array )
    [ ] lmap>array ;

: deeplist>array ( list -- array )
    [ dup list? [ deeplist>array ] when ] lmap>array ;

INSTANCE: cons-state list
INSTANCE: +nil+ list

GENERIC: >list ( object -- list )

M: list >list ;
