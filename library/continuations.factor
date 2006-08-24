! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: vectors ;

: catchstack* ( -- catchstack )
    6 getenv { vector } declare ; inline

: (continue-with) 9 getenv ;

IN: errors
USING: kernel kernel-internals ;

: catchstack ( -- catchstack ) catchstack* clone ; inline
: set-catchstack ( catchstack -- ) >vector 6 setenv ; inline

IN: kernel
USING: namespaces sequences ;

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

: continue ( continuation -- )
    >continuation<
    set-catchstack
    set-namestack
    set-callstack
    set-retainstack
    set-datastack ;
    inline

: callcc1 ( quot -- obj )
    [ drop (continue-with) ] ifcc ; inline

: continue-with ( obj continuation -- )
    swap 9 setenv continue ; inline

M: continuation clone
    [ continuation-data clone ] keep
    [ continuation-retain clone ] keep
    [ continuation-call clone ] keep
    [ continuation-name clone ] keep
    continuation-catch clone <continuation> ;
