! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend io.timeouts system kernel namespaces
strings hashtables sequences assocs combinators vocabs.loader
init threads continuations math ;
IN: io.launcher

! Non-blocking process exit notification facility
SYMBOL: processes

[ H{ } clone processes set-global ] "io.launcher" add-init-hook

TUPLE: process handle status killed? lapse ;

HOOK: register-process io-backend ( process -- )

M: object register-process drop ;

: <process> ( handle -- process )
    f f <lapse> process construct-boa
    V{ } clone over processes get set-at
    dup register-process ;

M: process equal? 2drop f ;

M: process hashcode* process-handle hashcode* ;

: process-running? ( process -- ? ) process-status not ;

SYMBOL: +command+
SYMBOL: +arguments+
SYMBOL: +detached+
SYMBOL: +environment+
SYMBOL: +environment-mode+
SYMBOL: +stdin+
SYMBOL: +stdout+
SYMBOL: +stderr+
SYMBOL: +closed+
SYMBOL: +timeout+

SYMBOL: +prepend-environment+
SYMBOL: +replace-environment+
SYMBOL: +append-environment+

: default-descriptor
    H{
        { +command+ f }
        { +arguments+ f }
        { +detached+ f }
        { +environment+ H{ } }
        { +environment-mode+ +append-environment+ }
    } ;

: with-descriptor ( desc quot -- )
    default-descriptor [ >r clone r> bind ] bind ; inline

: pass-environment? ( -- ? )
    +environment+ get assoc-empty? not
    +environment-mode+ get +replace-environment+ eq? or ;

: get-environment ( -- env )
    +environment+ get
    +environment-mode+ get {
        { +prepend-environment+ [ os-envs union ] }
        { +append-environment+ [ os-envs swap union ] }
        { +replace-environment+ [ ] }
    } case ;

: string-array? ( obj -- ? )
    dup sequence? [ [ string? ] all? ] [ drop f ] if ;

: >descriptor ( desc -- desc )
    {
        { [ dup string? ] [ +command+ associate ] }
        { [ dup string-array? ] [ +arguments+ associate ] }
        { [ dup assoc? ] [ >hashtable ] }
    } cond ;

HOOK: current-process-handle io-backend ( -- handle )

HOOK: run-process* io-backend ( desc -- handle )

: wait-for-process ( process -- status )
    [
        dup process-handle
        [
            dup [ processes get at push ] curry
            "process" suspend drop
        ] when
        dup process-killed?
        [ "Process was killed" throw ] [ process-status ] if
    ] with-timeout ;

: run-process ( desc -- process )
    >descriptor
    dup run-process*
    +timeout+ pick at [ over set-timeout ] when*
    +detached+ rot at [ dup wait-for-process drop ] unless ;

: run-detached ( desc -- process )
    >descriptor H{ { +detached+ t } } union run-process ;

TUPLE: process-failed code ;

: process-failed ( code -- * )
    \ process-failed construct-boa throw ;

: try-process ( desc -- )
    run-process wait-for-process dup zero?
    [ drop ] [ process-failed ] if ;

HOOK: kill-process* io-backend ( handle -- )

: kill-process ( process -- )
    t over set-process-killed?
    process-handle [ kill-process* ] when* ;

M: process get-lapse process-lapse ;

M: process timed-out kill-process ;

HOOK: process-stream* io-backend ( desc -- stream process )

TUPLE: process-stream process ;

: <process-stream> ( desc -- stream )
    >descriptor
    [ process-stream* ] keep
    +timeout+ swap at [ over set-timeout ] when*
    { set-delegate set-process-stream-process }
    process-stream construct ;

: with-process-stream ( desc quot -- status )
    swap <process-stream>
    [ swap with-stream ] keep
    process-stream-process wait-for-process ; inline

: notify-exit ( status process -- )
    [ set-process-status ] keep
    [ processes get delete-at* drop [ resume ] each ] keep
    f swap set-process-handle ;
