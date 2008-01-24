! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend system kernel namespaces strings hashtables
sequences assocs combinators vocabs.loader ;
IN: io.launcher

TUPLE: process handle status ;

: <process> ( handle -- process ) f process construct-boa ;

M: process equal? 2drop f ;

M: process hashcode* process-handle hashcode* ;

SYMBOL: +command+
SYMBOL: +arguments+
SYMBOL: +detached+
SYMBOL: +environment+
SYMBOL: +environment-mode+

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

GENERIC: >descriptor ( obj -- desc )

M: string >descriptor +command+ associate ;
M: sequence >descriptor +arguments+ associate ;
M: assoc >descriptor ;

HOOK: run-process* io-backend ( desc -- handle )

HOOK: wait-for-process* io-backend ( process -- )

: wait-for-process ( process -- status )
    dup process-handle [ dup wait-for-process* ] when
    process-status ;

: run-process ( obj -- process )
    >descriptor
    dup run-process*
    +detached+ rot at [ dup wait-for-process drop ] unless ;

: run-detached ( obj -- process )
    >descriptor H{ { +detached+ t } } union run-process ;

HOOK: process-stream* io-backend ( desc -- stream process )

TUPLE: process-stream process ;

: <process-stream> ( obj -- stream )
    >descriptor process-stream*
    { set-delegate set-process-stream-process }
    process-stream construct ;

: with-process-stream ( obj quot -- process )
    swap <process-stream>
    [ swap with-stream ] keep
    process-stream-process ; inline
