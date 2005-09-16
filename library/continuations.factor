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

: quot>interp ( quot -- continuation )
    #! Make a continuation that executes the quotation.
    #! The quotation should not return, or a call stack
    #! underflow will be signalled.
    { } f rot 2array >vector f f <interp> ;

: continue ( continuation -- )
    #! Restore a continuation.
    >interp<
    set-catchstack set-namestack set-callstack set-datastack ;

: continue-with ( object continuation -- object )
    #! Restore a continuation, and place the object in the
    #! restored data stack.
    >interp< set-catchstack set-namestack
    >r swap >r set-datastack r> r> set-callstack ;

: with-continuation ( quot -- | quot: continuation -- )
    #! Call a quotation with the current continuation, which may
    #! be restored using continue or continue-with.
    >r continuation dup interp-call dup pop* drop
    r> call ; inline

: callcc0 ( quot ++ | quot: cont -- | cont: ++ )
    "use with-continuation instead" throw ;

: callcc1 ( quot ++ obj | quot: cont -- | cont: obj ++ obj )
    "use with-continuation instead" throw ;
