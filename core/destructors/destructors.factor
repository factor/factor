! Copyright (C) 2007, 2010 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations init kernel namespaces
sequences sets ;
IN: destructors

SYMBOL: disposables

ERROR: already-unregistered disposable ;

SYMBOL: debug-leaks?

<PRIVATE

SLOT: continuation

: register-disposable ( obj -- )
    debug-leaks? get-global [ current-continuation >>continuation ] when
    disposables get adjoin ;

: unregister-disposable ( obj -- )
    dup disposables get ?delete [ drop ] [ already-unregistered ] if ;

PRIVATE>

TUPLE: disposable < identity-tuple
{ disposed boolean }
continuation ;

: new-disposable ( class -- disposable )
    new dup register-disposable ; inline

GENERIC: dispose* ( disposable -- )

ERROR: already-disposed disposable ;

: check-disposed ( disposable -- disposable )
    dup disposed>> [ already-disposed ] when ; inline

GENERIC: dispose ( disposable -- )

: unless-disposed ( disposable quot -- )
    [ dup disposed>> [ drop ] ] dip if ; inline

M: object dispose [ t >>disposed dispose* ] unless-disposed ;

M: disposable dispose
    [
        [ unregister-disposable ]
        [ call-next-method ]
        bi
    ] unless-disposed ;

: dispose-to ( obj accum -- )
    [ dispose ] [ push ] bi-curry* recover ; inline

: dispose-each ( seq -- )
    V{ } clone [ [ dispose-to ] curry each ] keep
    [ last rethrow ] unless-empty ;

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
    H{ } clone
    V{ } clone always-destructors pick set-at
    V{ } clone error-destructors pick set-at [
        [ do-always-destructors ]
        [ do-error-destructors ]
        cleanup
    ] with-variables ; inline

[
    HS{ } clone disposables set-global
    V{ } clone always-destructors set-global
    V{ } clone error-destructors set-global
] "destructors" add-startup-hook

[
    do-always-destructors
    do-error-destructors
] "destructors" add-shutdown-hook
