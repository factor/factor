! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend system kernel namespaces strings hashtables
sequences assocs combinators ;
IN: io.launcher

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

HOOK: run-process* io-backend ( desc -- )

: run-process ( obj -- )
    >descriptor run-process* ;

: run-detached ( obj -- )
    >descriptor H{ { +detached+ t } } union run-process* ;

HOOK: process-stream* io-backend ( desc -- stream )

: <process-stream> ( obj -- stream )
    >descriptor process-stream* ;

USE-IF: unix? io.unix.launcher
USE-IF: windows? io.windows.launcher
