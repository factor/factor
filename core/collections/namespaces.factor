! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: vectors sequences ;

: namestack* ( -- namestack )
    3 getenv { vector } declare ; inline
: >n ( namespace -- ) namestack* push ;
: n> ( -- namespace ) namestack* pop ;

IN: namespaces
USING: arrays hashtables kernel kernel-internals math strings
words ;

: namestack ( -- namestack ) namestack* clone ; inline
: set-namestack ( namestack -- ) >vector 3 setenv ; inline
: namespace ( -- namespace ) namestack* peek ;
: ndrop ( -- ) namestack* pop* ;
: global ( -- g ) 4 getenv { hashtable } declare ; inline
: get ( variable -- value ) namestack* hash-stack ;
: set ( value variable -- ) namespace set-hash ; inline
: on ( variable -- ) t swap set ; inline
: off ( variable -- ) f swap set ; inline
: get-global ( variable -- value ) global hash ; inline
: set-global ( value variable -- ) global set-hash ; inline

: nest ( variable -- namespace )
    dup namespace hash [ ] [ >r H{ } clone dup r> set ] ?if ;

: change ( variable quot -- )
    >r dup get r> rot slip set ; inline

: +@ ( n variable -- ) [ [ 0 ] unless* + ] change ;

: inc ( variable -- ) 1 swap +@ ; inline

: dec ( variable -- ) -1 swap +@ ; inline

: bind ( ns quot -- ) swap >n call ndrop ; inline

: counter ( variable -- n ) global [ dup inc get ] bind ;

: make-hash ( quot -- hash ) H{ } clone >n call n> ; inline

: with-scope ( quot -- ) H{ } clone >n call ndrop ; inline

! Building sequences
SYMBOL: building

: make ( quot exemplar -- seq )
    >r
    [ V{ } clone building set call building get ] with-scope
    r> like ; inline

: , ( elt -- ) building get push ;

: % ( seq -- ) building get swap nappend ;

: # ( n -- ) number>string % ;

: init-namespaces ( -- ) global 1array set-namestack ;

IN: sequences

: concat ( seq -- newseq )
    dup empty? [ [ [ % ] each ] over first make ] unless ;

: join ( seq glue -- newseq )
    [ swap [ % ] [ dup % ] interleave drop ] over make ;
