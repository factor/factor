! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: namespaces
USING: arrays hashtables kernel kernel-internals lists math
sequences strings vectors words ;

: namestack* ( -- ns ) 3 getenv ; inline
: namestack ( -- ns ) namestack* clone ; inline
: set-namestack ( ns -- ) clone 3 setenv ; inline
: namespace ( -- namespace ) namestack* peek ; inline
: >n ( namespace -- n:namespace ) namestack* push ; inline
: n> ( n:namespace -- namespace ) namestack* pop ; inline
: global ( -- g ) 4 getenv ; inline
: get ( variable -- value ) namestack* hash-stack ; flushable
: set ( value variable -- ) namespace set-hash ;
: on ( var -- ) t swap set ; inline
: off ( var -- ) f swap set ; inline
: set-global ( value var -- ) global set-hash ; inline

: nest ( variable -- hash )
    dup namespace hash [ ] [ >r H{ } clone dup r> set ] ?if ;

: change ( var quot -- quot: old -- new )
    >r dup get r> rot slip set ; inline

: +@ ( n var -- ) [ [ 0 ] unless* + ] change ;

: inc ( var -- ) 1 swap +@ ; inline

: dec ( var -- ) -1 swap +@ ; inline

: bind ( namespace quot -- ) swap >n call n> drop ; inline

: counter ( var -- n ) global [ dup inc get ] bind ;

: make-hash ( quot -- hash ) H{ } clone >n call n> ; inline

: with-scope ( quot -- ) make-hash drop ; inline

! Building sequences
SYMBOL: building

: make ( quot proto -- )
    [
        dup thaw building set >r call building get r> like
    ] with-scope ; inline

: , ( obj -- ) building get push ;

: ?, ( obj ? -- ) [ , ] [ drop ] if ;

: % ( seq -- ) building get swap nappend ;

: # ( n -- ) number>string % ;

SYMBOL: hash-buffer

: closure, ( value key -- old )
    hash-buffer get [ hash swap ] 2keep set-hash ;

: (closure) ( key hash -- )
    tuck hash dup [
        [
            drop dup dup closure,
            [ 2drop ] [ swap (closure) ] if
        ] hash-each-with
    ] [
        2drop
    ] if ;

: closure ( key hash -- list )
    [
        H{ } clone hash-buffer set
        (closure)
        hash-buffer get hash-keys
    ] with-scope ;

IN: lists

: alist>quot ( default alist -- quot )
    [ [ first2 swap % , , \ if , ] [ ] make ] each ;

IN: kernel-internals

: init-namespaces ( -- ) global 1array >vector set-namestack ;
