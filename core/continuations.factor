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
    >r >r f [ continuation nip t ] call r> r> if ; inline

: callcc0 ( quot -- ) [ ] ifcc ; inline

: callcc1 ( quot -- obj ) callcc0 ; inline

DEFER: continue-with

: set-walker-hook 2 setenv ; inline

: get-walker-hook 2 getenv f set-walker-hook ; inline

: (continue) ( continuation -- )
    >continuation<
    set-catchstack
    set-namestack
    set-callstack
    set-retainstack
    set-datastack ; inline

: (continue-with) ( obj continuation -- )
    #! There's no good way to avoid this code duplication!
    swap 9 setenv
    >continuation<
    set-catchstack
    set-namestack
    set-callstack
    set-retainstack
    set-datastack
    9 getenv swap ; inline

: continue ( continuation -- )
    get-walker-hook [ (continue-with) ] [ (continue) ] if* ;
    inline

: continue-with ( obj continuation -- )
    get-walker-hook [ >r 2array r> ] when* (continue-with) ;
    inline

M: continuation clone
    [ continuation-data clone ] keep
    [ continuation-retain clone ] keep
    [ continuation-call clone ] keep
    [ continuation-name clone ] keep
    continuation-catch clone <continuation> ;
