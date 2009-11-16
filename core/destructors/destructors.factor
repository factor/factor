! Copyright (C) 2007, 2009 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations kernel namespaces make
sequences vectors sets assocs init math ;
IN: destructors

SYMBOL: disposables

[ H{ } clone disposables set-global ] "destructors" add-startup-hook

ERROR: already-unregistered disposable ;

SYMBOL: debug-leaks?

<PRIVATE

SLOT: continuation

: register-disposable ( obj -- )
    debug-leaks? get-global [ continuation >>continuation ] when
    disposables get conjoin ;

: unregister-disposable ( obj -- )
    disposables get 2dup key? [ delete-at ] [ drop already-unregistered ] if ;

PRIVATE>

TUPLE: disposable < identity-tuple
{ disposed boolean }
continuation ;

: new-disposable ( class -- disposable )
    new dup register-disposable ; inline

GENERIC: dispose* ( disposable -- )

ERROR: already-disposed disposable ;

: check-disposed ( disposable -- )
    dup disposed>> [ already-disposed ] [ drop ] if ; inline

GENERIC: dispose ( disposable -- )

M: object dispose
    dup disposed>> [ drop ] [ t >>disposed dispose* ] if ;

M: disposable dispose
    dup disposed>> [ drop ] [
        [ unregister-disposable ]
        [ call-next-method ]
        bi
    ] if ;

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

[
    always-destructors get-global
    error-destructors get-global append dispose-each
] "destructors.global" add-shutdown-hook
