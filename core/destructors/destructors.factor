! Copyright (C) 2007, 2009 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations kernel namespaces make
sequences vectors sets assocs init ;
IN: destructors

SYMBOL: disposables

[ H{ } clone disposables set-global ] "destructors" add-init-hook

<PRIVATE

: register-disposable ( obj -- )
    disposables get conjoin ;

: unregister-disposable ( obj -- )
    disposables get delete-at ;

PRIVATE>

TUPLE: disposable < identity-tuple disposed id ;

M: disposable hashcode* nip id>> ;

: new-disposable ( class -- disposable )
    new \ disposable counter >>id
    dup register-disposable ; inline

GENERIC: dispose* ( disposable -- )

ERROR: already-disposed disposable ;

: check-disposed ( disposable -- )
    dup disposed>> [ already-disposed ] [ drop ] if ; inline

GENERIC: dispose ( disposable -- )

M: object dispose
    dup disposed>> [ drop ] [ t >>disposed dispose* ] if ;

M: disposable dispose
    [ unregister-disposable ] [ call-next-method ] bi ;

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
