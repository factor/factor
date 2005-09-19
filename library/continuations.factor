! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: arrays errors lists namespaces sequences words vectors ;

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

: continue ( continuation -- )
    #! Restore a continuation.
    >continuation< set-catchstack set-namestack set-callstack
    >r set-datastack r> set-c-stack ;

: continue-with ( object continuation -- object )
    #! Restore a continuation, and place the object in the
    #! restored data stack.
    >continuation< set-catchstack set-namestack set-callstack
    >r swap >r set-datastack r> r> set-c-stack ;

: (callcc) ( terminator balance  -- | quot: continuation -- )
    #! Direct calls to this word will not compile correctly;
    #! use callcc0 or callcc1 to declare continuation arity
    #! instead. The terminator branch always executes. It might
    #! contain a call to 'continue', which ends control flow.
    #! The balance branch is never called, but it is there to
    #! give the callcc form a stack effect.
    >r >r
    continuation dup continuation-call dup pop* pop*
    t r> r> ifte ; inline

: callcc0 ( quot -- | quot: continuation -- )
    #! Call a quotation with the current continuation, which may
    #! be restored using continue.
    [ drop ] (callcc) ; inline

: callcc1 ( quot -- | quot: continuation -- )
    #! Call a quotation with the current continuation, which may
    #! be restored using continue-with.
    [ ] (callcc) ; inline
