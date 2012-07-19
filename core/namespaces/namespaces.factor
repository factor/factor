! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs hashtables kernel kernel.private math
sequences vectors ;
SLOT: boxes
SLOT: value
FROM: accessors => boxes>> value>> value<< ;
IN: namespaces

<PRIVATE

TUPLE: global-hashtable
    { boxes hashtable read-only } ;
TUPLE: global-box value ;

: (box-at) ( key globals -- box )
    boxes>> 2dup at
    [ 2nip ] [ [ f global-box boa ] 2dip [ set-at ] 2curry keep ] if* ; foldable

: box-at ( key globals -- box )
    (box-at) { global-box } declare ; inline

M: global-hashtable at*
    box-at value>> dup ; inline

M: global-hashtable set-at
    box-at value<< ; inline

M: global-hashtable delete-at
    box-at f swap value<< ; inline

: namestack* ( -- namestack )
    CONTEXT-OBJ-NAMESTACK context-object { vector } declare ; inline
: >n ( namespace -- ) namestack* push ;
: ndrop ( -- ) namestack* pop* ;

PRIVATE>

: global ( -- g ) OBJ-GLOBAL special-object { global-hashtable } declare ; foldable

: namespace ( -- namespace ) namestack* last ; inline
: namestack ( -- namestack ) namestack* clone ;
: set-namestack ( namestack -- )
    >vector CONTEXT-OBJ-NAMESTACK set-context-object ;
: init-namespaces ( -- ) global 1array set-namestack ;
: get ( variable -- value ) namestack* assoc-stack ; inline
: set ( value variable -- ) namespace set-at ;
: on ( variable -- ) t swap set ; inline
: off ( variable -- ) f swap set ; inline
: get-global ( variable -- value ) global at ; inline
: set-global ( value variable -- ) global set-at ; inline
: change ( variable quot -- ) [ [ get ] keep ] dip dip set ; inline
: change-global ( variable quot -- ) [ global ] dip change-at ; inline
: toggle ( variable -- ) [ not ] change ; inline
: +@ ( n variable -- ) [ 0 or + ] change ; inline
: inc ( variable -- ) 1 swap +@ ; inline
: dec ( variable -- ) -1 swap +@ ; inline
: with-variables ( ns quot -- ) swap >n call ndrop ; inline
: counter ( variable -- n ) [ 0 or 1 + dup ] change-global ;
: make-assoc ( quot exemplar -- hash ) 20 swap new-assoc [ swap with-variables ] keep ; inline
: with-scope ( quot -- ) 5 <hashtable> swap with-variables ; inline
: with-variable ( value key quot -- ) [ associate ] dip with-variables ; inline
: with-new-scope ( quot -- ) 5 <hashtable> swap with-variables ; inline
: with-global ( quot -- ) [ global ] dip with-variables ; inline
: initialize ( variable quot -- ) [ unless* ] curry change-global ; inline
