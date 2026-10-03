! Copyright (C) 2003, 2010 Slava Pestov.
! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel kernel.private math
namespaces.contexts sequences vectors ;
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

: (set-namestack) ( namestack -- )
    CONTEXT-OBJ-NAMESTACK set-context-object ; inline

: >namespace-context ( namestack -- context )
    dup namespace-context? [
        OBJ-GLOBAL special-object namestack>context
    ] unless ;

! Migrate contexts from an older saved image once, on first access.
: migrate-namestack ( namestack -- context )
    >namespace-context dup (set-namestack) ;

: (get-namestack) ( -- context )
    CONTEXT-OBJ-NAMESTACK context-object
    dup namespace-context? [ migrate-namestack ] unless
    { namespace-context } declare ; inline

: >n ( namespace -- ) (get-namestack) context-push-variables ;

: >scope ( -- ) (get-namestack) context-push-scope ;

: ndrop ( -- ) (get-namestack) context-pop ;

PRIVATE>

: global ( -- g )
    OBJ-GLOBAL special-object { global-hashtable } declare ; foldable

: namestack>vector ( namestack -- vector )
    dup namespace-context? [ context>namestack ] [ >vector ] if ;

: snapshot-namestack ( namestack -- snapshot )
    >namespace-context context-snapshot ;

: capture-namestack ( -- snapshot )
    (get-namestack) context-snapshot ;

: namespace ( -- namespace ) (get-namestack) context-namespace ; inline
: get-namestack ( -- namestack ) (get-namestack) context>namestack ;
: set-namestack ( namestack -- ) snapshot-namestack (set-namestack) ;
: init-namestack ( -- ) global <namespace-context> (set-namestack) ;

: get-global ( variable -- value ) global box-at value>> ; inline
: set-global ( value variable -- ) global set-at ; inline
: change-global ( variable quot -- )
    [ [ get-global ] keep ] dip dip set-global ; inline
: counter ( variable -- n ) [ 0 or 1 + dup ] change-global ; inline
: initialize ( variable quot -- ) [ unless* ] curry change-global ; inline

: get ( variable -- value ) (get-namestack) context-get ; inline
: set ( value variable -- ) (get-namestack) context-set ;
: change ( variable quot -- ) [ [ get ] keep ] dip dip set ; inline
: on ( variable -- ) t swap set ; inline
: off ( variable -- ) f swap set ; inline
: toggle ( variable -- ) [ not ] change ; inline
: +@ ( n variable -- ) [ 0 or + ] change ; inline
: inc ( variable -- ) 1 swap +@ ; inline
: dec ( variable -- ) -1 swap +@ ; inline

: with-variables ( ns quot -- ) swap >n call ndrop ; inline
: with-scope ( quot -- )
    >scope call ndrop ; inline
: with-variable ( value key quot -- )
    [ >scope set ] dip call ndrop ; inline
: with-global ( quot -- ) [ global ] dip with-variables ; inline
