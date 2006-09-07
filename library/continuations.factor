! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: vectors ;

: catchstack* ( -- catchstack )
    6 getenv { vector } declare ; inline

IN: errors
USING: kernel kernel-internals ;

: catchstack ( -- catchstack ) catchstack* clone ; inline
: set-catchstack ( catchstack -- ) >vector 6 setenv ; inline

IN: kernel
USING: arrays namespaces sequences ;

TUPLE: continuation data retain call name catch ;

: <empty-continuation> ( -- continuation )
    V{ } clone V{ } clone V{ } clone V{ } clone V{ } clone
    <continuation> ;

: continuation ( -- continuation )
    datastack retainstack callstack namestack catchstack
    <continuation> ; inline

: >continuation< ( continuation -- data retain call name catch )
    [ continuation-data ] keep
    [ continuation-retain ] keep
    [ continuation-call ] keep
    [ continuation-name ] keep
    continuation-catch ; inline

: ifcc ( terminator balance -- )
    [ f f continuation 2nip dup ] call 2swap if ; inline

: callcc0 ( quot -- ) [ drop ] ifcc ; inline

DEFER: continue-with

: set-walker-hook 2 setenv ; inline

: get-walker-hook 2 getenv f set-walker-hook ; inline

: end-walk continuation get-walker-hook continue-with ;

: (continue) ( continuation -- )
    >continuation<
    set-catchstack
    set-namestack
    set-callstack
    set-retainstack
    set-datastack ; inline

: (continue-with) ( obj continuation -- )
    swap 9 setenv (continue) ; inline

: continue ( continuation -- )
    get-walker-hook [ (continue-with) ] [ (continue) ] if* ;
    inline

: from-callcc1 9 getenv ;

: callcc1 ( quot -- obj )
    [ drop from-callcc1 ] ifcc ; inline

: continue-with ( obj continuation -- )
    get-walker-hook [ >r 2array r> ] when* (continue-with) ;
    inline

M: continuation clone
    [ continuation-data clone ] keep
    [ continuation-retain clone ] keep
    [ continuation-call clone ] keep
    [ continuation-name clone ] keep
    continuation-catch clone <continuation> ;
