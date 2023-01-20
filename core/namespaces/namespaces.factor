! Copyright (C) 2003, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel kernel.private math
sequences vectors ;
IN: namespaces

<PRIVATE

TUPLE: global-hashtable
    { boxes hashtable read-only } ;
TUPLE: global-box value ;

: (box-at) ( key globals -- box )
    boxes>> [ drop f global-box boa ] cache ; foldable

: box-at ( key globals -- box )
    (box-at) { global-box } declare ; inline

M: global-hashtable at*
    boxes>> at* [
        { global-box } declare value>> t
    ] [ drop f f ] if ; inline

M: global-hashtable set-at
    box-at value<< ; inline

M: global-hashtable delete-at
    box-at f swap value<< ; inline

: (get-namestack) ( -- namestack )
    CONTEXT-OBJ-NAMESTACK context-object { vector } declare ; inline

: (set-namestack) ( namestack -- )
    CONTEXT-OBJ-NAMESTACK set-context-object ; inline

: >n ( namespace -- ) (get-namestack) push ;

: ndrop ( -- ) (get-namestack) pop* ;

PRIVATE>

: global ( -- g )
    OBJ-GLOBAL special-object { global-hashtable } declare ; foldable

: namespace ( -- namespace ) (get-namestack) last ; inline
: get-namestack ( -- namestack ) (get-namestack) clone ;
: set-namestack ( namestack -- ) >vector (set-namestack) ;
: init-namestack ( -- ) global 1vector (set-namestack) ;

: get-global ( variable -- value ) global box-at value>> ; inline
: set-global ( value variable -- ) global set-at ; inline
: change-global ( variable quot -- )
    [ [ get-global ] keep ] dip dip set-global ; inline
: counter ( variable -- n ) [ 0 or 1 + dup ] change-global ; inline
: initialize ( variable quot -- ) [ unless* ] curry change-global ; inline

: get ( variable -- value ) (get-namestack) assoc-stack ; inline
: set ( value variable -- ) namespace set-at ;
: change ( variable quot -- ) [ [ get ] keep ] dip dip set ; inline
: on ( variable -- ) t swap set ; inline
: off ( variable -- ) f swap set ; inline
: toggle ( variable -- ) [ not ] change ; inline
: +@ ( n variable -- ) [ 0 or + ] change ; inline
: inc ( variable -- ) 1 swap +@ ; inline
: dec ( variable -- ) -1 swap +@ ; inline

: with-variables ( ns quot -- ) swap >n call ndrop ; inline
: with-scope ( quot -- ) 5 <hashtable> swap with-variables ; inline
: with-variable ( value key quot -- ) [ associate ] dip with-variables ; inline
: with-global ( quot -- ) [ global ] dip with-variables ; inline
