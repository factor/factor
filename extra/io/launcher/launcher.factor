! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend system kernel namespaces strings hashtables
sequences assocs combinators vocabs.loader init threads
continuations ;
IN: io.launcher

! Non-blocking process exit notification facility
SYMBOL: processes

[ H{ } clone processes set-global ] "io.launcher" add-init-hook

TUPLE: process handle status ;

HOOK: register-process io-backend ( process -- )

M: object register-process drop ;

: <process> ( handle -- process )
    f process construct-boa
    V{ } clone over processes get set-at
    dup register-process ;

M: process equal? 2drop f ;

M: process hashcode* process-handle hashcode* ;

SYMBOL: +command+
SYMBOL: +arguments+
SYMBOL: +detached+
SYMBOL: +environment+
SYMBOL: +environment-mode+
SYMBOL: +stdin+
SYMBOL: +stdout+
SYMBOL: +stderr+
SYMBOL: +closed+

SYMBOL: prepend-environment
SYMBOL: replace-environment
SYMBOL: append-environment

: default-descriptor
    H{
        { +command+ f }
        { +arguments+ f }
        { +detached+ f }
        { +environment+ H{ } }
        { +environment-mode+ append-environment }
    } ;

: with-descriptor ( desc quot -- )
    default-descriptor [ >r clone r> bind ] bind ; inline

: pass-environment? ( -- ? )
    +environment+ get assoc-empty? not
    +environment-mode+ get replace-environment eq? or ;

: get-environment ( -- env )
    +environment+ get
    +environment-mode+ get {
        { prepend-environment [ os-envs union ] }
        { append-environment [ os-envs swap union ] }
        { replace-environment [ ] }
    } case ;

GENERIC: >descriptor ( desc -- desc )

M: string >descriptor +command+ associate ;
M: sequence >descriptor +arguments+ associate ;
M: assoc >descriptor >hashtable ;

HOOK: run-process* io-backend ( desc -- handle )

: wait-for-process ( process -- status )
    dup process-handle [
        dup [ processes get at push stop ] curry callcc0
    ] when process-status ;

: run-process ( desc -- process )
    >descriptor
    dup run-process*
    +detached+ rot at [ dup wait-for-process drop ] unless ;

: run-detached ( desc -- process )
    >descriptor H{ { +detached+ t } } union run-process ;

HOOK: process-stream* io-backend ( desc -- stream process )

TUPLE: process-stream process ;

: <process-stream> ( desc -- stream )
    >descriptor process-stream*
    { set-delegate set-process-stream-process }
    process-stream construct ;

: with-process-stream ( desc quot -- process )
    swap <process-stream>
    [ swap with-stream ] keep
    process-stream-process ; inline

: notify-exit ( status process -- )
    [ set-process-status ] keep
    [ processes get delete-at* drop [ schedule-thread ] each ] keep
    f swap set-process-handle ;
