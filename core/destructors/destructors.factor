! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations kernel namespaces make
sequences vectors ;
IN: destructors

TUPLE: disposable disposed ;

GENERIC: dispose* ( disposable -- )

ERROR: already-disposed disposable ;

: check-disposed ( disposable -- )
    dup disposed>> [ already-disposed ] [ drop ] if ; inline

GENERIC: dispose ( disposable -- )

M: object dispose
    dup disposed>> [ drop ] [ t >>disposed dispose* ] if ;

: dispose-each ( seq -- )
    [
        [ [ dispose ] curry [ , ] recover ] each
    ] { } make [ last rethrow ] unless-empty ;

: with-disposal ( object quot -- )
    over [ dispose ] curry [ ] cleanup ; inline

<PRIVATE

SYMBOL: always-destructors

SYMBOL: error-destructors

: do-always-destructors ( -- )
    always-destructors get <reversed> dispose-each ;

: do-error-destructors ( -- )
    error-destructors get <reversed> dispose-each ;

PRIVATE>

: &dispose ( disposable -- disposable )
    dup always-destructors get push ; inline

: |dispose ( disposable -- disposable )
    dup error-destructors get push ; inline

: with-destructors ( quot -- )
    [
        V{ } clone always-destructors set
        V{ } clone error-destructors set
        [ do-always-destructors ]
        [ do-error-destructors ]
        cleanup
    ] with-scope ; inline
