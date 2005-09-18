! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: arrays errors lists namespaces sequences words vectors ;

TUPLE: interp data call name catch ;

: continuation ( -- interp )
    #! The continuation is reified from after the *caller* of
    #! this word returns.
    datastack callstack dup pop* dup pop*
    namestack catchstack <interp> ;

: >interp< ( interp -- data call name catch )
    [ interp-data ] keep
    [ interp-call ] keep
    [ interp-name ] keep
    interp-catch ;

: continue ( continuation -- )
    #! Restore a continuation.
    >interp<
    set-catchstack set-namestack set-callstack set-datastack ;

: continue-with ( object continuation -- object )
    #! Restore a continuation, and place the object in the
    #! restored data stack.
    >interp< set-catchstack set-namestack
    >r swap >r set-datastack r> r> set-callstack ;

: (callcc) ( terminator balance  -- | quot: continuation -- )
    #! Direct calls to this word will not compile correctly;
    #! use callcc0 or callcc1 to declare continuation arity
    #! instead. The terminator branch always executes. It might
    #! contain a call to 'continue', which ends control flow.
    #! The balance branch is never called, but it is there to
    #! give the callcc form a stack effect.
    >r >r
    continuation dup interp-call dup pop* pop*
    t r> r> ifte ;
    inline

: callcc0 ( quot -- | quot: continuation -- )
    #! Call a quotation with the current continuation, which may
    #! be restored using continue.
    [ drop ] (callcc) ; inline

: callcc1 ( quot -- | quot: continuation -- )
    #! Call a quotation with the current continuation, which may
    #! be restored using continue-with.
    [ ] (callcc) ; inline
