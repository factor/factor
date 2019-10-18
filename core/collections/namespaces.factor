! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: namespaces
TUPLE: namespace-error object ;

IN: kernel-internals
USING: kernel vectors sequences hashtables errors ;

: namestack* ( -- namestack )
    3 getenv { vector } declare ; inline

: >n ( namespace -- )
    namestack* push ;

: n> ( -- namespace ) namestack* pop ;

IN: namespaces
USING: arrays kernel-internals math strings words assocs ;

: namespace ( -- namespace )
    namestack* peek ;

: namestack ( -- namestack ) namestack* clone ; inline
: set-namestack ( namestack -- ) >vector 3 setenv ; inline
: ndrop ( -- ) namestack* pop* ;
: global ( -- g ) 4 getenv { hashtable } declare ; inline
: get ( variable -- value ) namestack* assoc-stack ;
: set ( value variable -- ) namespace set-at ;
: on ( variable -- ) t swap set ; inline
: off ( variable -- ) f swap set ; inline
: get-global ( variable -- value ) global at ; inline
: set-global ( value variable -- ) global set-at ; inline

: change ( variable quot -- )
    >r dup get r> rot slip set ; inline

: +@ ( n variable -- ) [ [ 0 ] unless* + ] change ;

: inc ( variable -- ) 1 swap +@ ; inline

: dec ( variable -- ) -1 swap +@ ; inline

: bind ( ns quot -- ) swap >n call ndrop ; inline

: counter ( variable -- n ) global [ dup inc get ] bind ;

: make-assoc ( quot exemplar -- hash ) 20 swap new-assoc >n call n> ; inline

: with-scope ( quot -- ) H{ } clone >n call ndrop ; inline

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

: init-namespaces ( -- ) global 1array set-namestack ;

IN: sequences

: join ( seq glue -- newseq )
    [ swap [ dup % ] [ % ] interleave drop ] over make ;

: (prune) ( hash vec elt -- )
    rot 2dup key?
    [ 3drop ] [ dupd dupd set-at swap push ] if ; inline

: prune ( seq -- newseq )
    dup length <hashtable> over length <vector>
    rot [ >r 2dup r> (prune) ] each nip ;
