! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel-internals
USING: vectors ;

: catchstack* ( -- cs ) 6 getenv { vector } declare ; inline

: (continue-with) 9 getenv ;

IN: errors
USING: kernel kernel-internals ;

: catchstack ( -- cs ) catchstack* clone ; inline
: set-catchstack ( cs -- ) >vector 6 setenv ; inline

IN: kernel
USING: namespaces sequences ;

TUPLE: continuation data retain call name catch ;

: continuation ( -- interp )
    datastack retainstack callstack dup pop* dup pop* dup pop*
    namestack catchstack <continuation> ; inline

: >continuation< ( continuation -- data retain call name catch )
    [ continuation-data ] keep
    [ continuation-retain ] keep
    [ continuation-call ] keep
    [ continuation-name ] keep
    continuation-catch ; inline

: ifcc ( terminator balance -- | quot: continuation -- )
    [ f f continuation 2nip dup ] call 2swap if ; inline

: callcc0 [ drop ] ifcc ; inline

: continue ( continuation -- )
    >continuation<
    set-catchstack
    set-namestack
    set-callstack
    set-retainstack
    set-datastack ;
    inline

: callcc1 [ drop (continue-with) ] ifcc ; inline

: continue-with swap 9 setenv continue ; inline
