! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: vectors sequences ;

: namestack* ( -- ns ) 3 getenv { vector } declare ; inline
: >n ( namespace -- n:namespace ) namestack* push ;
: n> ( n:namespace -- namespace ) namestack* pop ;

IN: namespaces
USING: arrays hashtables kernel kernel-internals math strings
words ;

: namestack ( -- ns ) namestack* clone ; inline
: set-namestack ( ns -- ) >vector 3 setenv ; inline
: namespace ( -- namespace ) namestack* peek ;
: ndrop ( n:namespace -- ) namestack* pop* ;
: global ( -- g ) 4 getenv { hashtable } declare ; inline
: get ( variable -- value ) namestack* hash-stack ; flushable
: set ( value variable -- ) namespace set-hash ; inline
: on ( var -- ) t swap set ; inline
: off ( var -- ) f swap set ; inline
: get-global ( var -- value ) global hash ; inline
: set-global ( value var -- ) global set-hash ; inline

: nest ( variable -- hash )
    dup namespace hash [ ] [ >r H{ } clone dup r> set ] ?if ;

: change ( var quot -- quot: old -- new )
    >r dup get r> rot slip set ; inline

: +@ ( n var -- ) [ [ 0 ] unless* + ] change ;

: inc ( var -- ) 1 swap +@ ; inline

: dec ( var -- ) -1 swap +@ ; inline

: bind ( namespace quot -- ) swap >n call ndrop ; inline

: counter ( var -- n ) global [ dup inc get ] bind ;

: make-hash ( quot -- hash ) H{ } clone >n call n> ; inline

: with-scope ( quot -- ) H{ } clone >n call ndrop ; inline

! Building sequences
SYMBOL: building

: make ( quot proto -- )
    [
        dup thaw building set >r call building get r> like
    ] with-scope ; inline

: , ( obj -- ) building get push ;

: % ( seq -- ) building get swap nappend ;

: # ( n -- ) number>string % ;

: init-namespaces ( -- ) global 1array >vector set-namestack ;

IN: sequences

: prune ( seq -- seq )
    [ [ dup set ] each ] make-hash hash-keys ;

: concat ( seq -- seq )
    dup empty? [ [ [ % ] each ] over first make ] unless ;
    flushable

: join ( seq glue -- seq )
    [ swap [ % ] [ dup % ] interleave drop ] over make ;
    flushable
