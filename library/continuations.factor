! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: errors
USING: kernel-internals ;

: catchstack ( -- cs ) 6 getenv ;
: set-catchstack ( cs -- ) 6 setenv ;

IN: kernel
USING: namespaces sequences ;

TUPLE: continuation data c call name catch ;

: c-stack ( -- c-stack )
    #! In the interpreter, this is a no-op. The compiler has an
    #! an intrinsic for this word.
    f ;

: set-c-stack ( c-stack -- )
    [ "not supported" throw ] when ;

: continuation ( -- interp )
    #! The continuation is reified from after the *caller* of
    #! this word returns.
    datastack c-stack callstack dup pop* dup pop*
    namestack catchstack <continuation> ; inline

: >continuation< ( continuation -- data c call name catch )
    [ continuation-data ] keep
    [ continuation-c ] keep
    [ continuation-call ] keep
    [ continuation-name ] keep
    continuation-catch ; inline

: ifcc ( terminator balance -- | quot: continuation -- )
    [
        t continuation
        dup continuation-data dup pop* f swap push
        swap >r -rot r>
    ] call -rot ifte ; inline

: infer-only ( quot -- )
    #! For stack effect inference, pretend the quotation is
    #! there, but ignore it during execution.
    drop ;

: callcc1 ( quot -- | quot: continuation -- )
    #! Call a quotation with the current continuation, which may
    #! be restored using continue-with.
    [ [ drop ] infer-only 9 getenv ] ifcc ; inline

: callcc0 ( quot -- | quot: continuation -- )
    #! Call a quotation with the current continuation, which may
    #! be restored using continue-with.
    [ [ drop ] infer-only ] ifcc ; inline

: continue ( continuation -- )
    #! Restore a continuation.
    >continuation< set-catchstack set-namestack set-callstack
    >r set-datastack r> set-c-stack ; inline

: continue-with ( object continuation -- object )
    #! Restore a continuation, and place the object in the
    #! restored data stack.
    swap 9 setenv continue ; inline
