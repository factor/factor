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
    #! The continuation is reified from after the *caller* of
    #! this word returns. It must be declared inline for this
    #! invariant to be preserved in compiled code too.
    datastack callstack dup pop* dup pop*
    namestack catchstack <continuation> ; inline

: >continuation< ( continuation -- data call name catch )
    [ continuation-data ] keep
    [ continuation-call ] keep
    [ continuation-name ] keep
    continuation-catch ; inline

: ifcc ( terminator balance -- | quot: continuation -- )
    #! Note that the branch at the end must not be optimized out
    #! by the compiler.
    [
        continuation
        dup continuation-data f over push f swap push dup
    ] call 2swap if ; inline

: callcc0 ( quot -- | quot: continuation -- )
    #! Call a quotation with the current continuation, which may
    #! be restored using continue.
    [ drop ] ifcc ; inline

: continue ( continuation -- )
    #! Restore a continuation.
    >continuation<
    set-catchstack set-namestack set-callstack set-datastack ;
    inline

: (continue-with) 9 getenv ;

: callcc1 ( quot -- | quot: continuation -- )
    #! Call a quotation with the current continuation, which may
    #! be restored using continue-with.
    [ drop (continue-with) ] ifcc ; inline

: continue-with ( object continuation -- object )
    #! Restore a continuation, and place the object in the
    #! restored data stack.
    swap 9 setenv continue ; inline
