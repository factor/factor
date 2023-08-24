! Copyright (C) 2005 Chris Double, 2007 Clemens Hofreither, 2008 James Cash.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel hashtables namespaces make continuations accessors ;
IN: coroutines

SYMBOL: current-coro

TUPLE: coroutine resumecc exitcc originalcc ;

: cocreate ( quot -- co )
    coroutine new
    dup current-coro associate
    [
        swapd , , \ with-variables ,
        "Coroutine has terminated illegally." , \ throw ,
    ] [ ] make
    [ >>resumecc ] [ >>originalcc ] bi ;

: coresume ( v co -- result )
    [
        >>exitcc
        resumecc>> call( -- )
        ! At this point, the coroutine quotation must have terminated
        ! normally (without calling coyield, coreset, or coterminate).
        ! This shouldn't happen.
        f over
    ] callcc1 2nip ;

: coresume* ( v co -- ) coresume drop ; inline
: *coresume ( co -- result ) f swap coresume ; inline

: coyield ( v -- result )
    current-coro get
    [
        [ continue-with ] curry
        >>resumecc
        exitcc>> continue-with
    ] callcc1 2nip ;

: coyield* ( v -- ) coyield drop ; inline
: *coyield ( -- v ) f coyield ; inline

: coterminate ( v -- )
    current-coro get
    [ ] >>resumecc
    exitcc>> continue-with ;

: coreset ( v -- )
    current-coro get dup
    originalcc>> >>resumecc
    exitcc>> continue-with ;
