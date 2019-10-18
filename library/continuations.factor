! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: errors
USING: kernel kernel-internals ;

: catchstack* ( -- cs ) 6 getenv ; inline
: catchstack ( -- cs ) catchstack* clone ; inline
: set-catchstack ( cs -- ) clone 6 setenv ; inline

IN: kernel
USING: namespaces sequences ;

TUPLE: continuation data call name catch ;

: continuation ( -- interp )
    datastack callstack dup pop* dup pop*
    namestack catchstack <continuation> ; inline

: >continuation< ( continuation -- data call name catch )
    [ continuation-data ] keep
    [ continuation-call ] keep
    [ continuation-name ] keep
    continuation-catch ; inline

: ifcc ( terminator balance -- | quot: continuation -- )
    [
        continuation
        dup continuation-data f over push f swap push dup
    ] call 2swap if ; inline

: callcc0 [ drop ] ifcc ; inline

: continue ( continuation -- )
    >continuation<
    set-catchstack set-namestack set-callstack set-datastack ;
    inline

: (continue-with) 9 getenv ;

: callcc1 [ drop (continue-with) ] ifcc ; inline

: continue-with swap 9 setenv continue ; inline
