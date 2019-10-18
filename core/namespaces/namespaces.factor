! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel vectors sequences hashtables
arrays kernel.private math strings assocs ;
IN: namespaces

<PRIVATE

: namestack* ( -- namestack )
    0 getenv { vector } declare ; inline

: >n ( namespace -- ) namestack* push ;
: ndrop ( -- ) namestack* pop* ;

PRIVATE>

: namespace ( -- namespace ) namestack* peek ;
: namestack ( -- namestack ) namestack* clone ; inline
: set-namestack ( namestack -- ) >vector 0 setenv ; inline
: global ( -- g ) 21 getenv { hashtable } declare ; inline
: init-namespaces ( -- ) global 1array set-namestack ;
: get ( variable -- value ) namestack* assoc-stack ; flushable
: set ( value variable -- ) namespace set-at ;
: on ( variable -- ) t swap set ; inline
: off ( variable -- ) f swap set ; inline
: get-global ( variable -- value ) global at ; inline
: set-global ( value variable -- ) global set-at ; inline

: change ( variable quot -- )
    >r dup get r> rot slip set ; inline

: +@ ( n variable -- ) [ 0 or + ] change ;

: inc ( variable -- ) 1 swap +@ ; inline

: dec ( variable -- ) -1 swap +@ ; inline

: bind ( ns quot -- ) swap >n call ndrop ; inline

: counter ( variable -- n ) global [ dup inc get ] bind ;

: make-assoc ( quot exemplar -- hash )
    20 swap new-assoc [ >n call ndrop ] keep ; inline

: with-scope ( quot -- )
    H{ } clone >n call ndrop ; inline

: with-variable ( value key quot -- )
    >r associate >n r> call ndrop ; inline

! Building sequences
SYMBOL: building

: make ( quot exemplar -- seq )
    [
        [
            1024 swap new-resizable [
                building set call
            ] keep
        ] keep like
    ] with-scope ; inline

: , ( elt -- ) building get push ;

: % ( seq -- ) building get push-all ;
