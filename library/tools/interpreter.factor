! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: interpreter
USING: errors generic io kernel kernel-internals lists math
namespaces prettyprint sequences strings vectors words ;

! A Factor interpreter written in Factor. Used by compiler for
! partial evaluation, also by the walker.

! Meta-stacks
SYMBOL: meta-r
: push-r meta-r get push ;
: pop-r meta-r get pop ;
SYMBOL: meta-d
: push-d meta-d get push ;
: pop-d meta-d get pop ;
SYMBOL: meta-n
SYMBOL: meta-c

! Call frame
SYMBOL: meta-cf

! Currently executing word.
SYMBOL: meta-executing

! Callframe.
: up ( -- ) pop-r meta-cf set  pop-r drop ;

: next ( -- obj )
    meta-cf get [ meta-cf [ uncons ] change ] [ up next ] if ;

: meta-interp ( -- interp )
    meta-d get meta-r get meta-n get meta-c get <continuation> ;

: set-meta-interp ( interp -- )
    >continuation< meta-c set meta-n set meta-r set meta-d set ;

: host-word ( word -- )
    [
        \ call push-r
        [ continuation swap continue-with ] cons cons push-r
        meta-interp continue
    ] callcc1 set-meta-interp pop-d 2drop ;

: meta-call ( quot -- )
    #! Note we do tail call optimization here.
    meta-cf [
        [ meta-executing get push-r  push-r ] when*
    ] change ;

GENERIC: do-1 ( object -- )

M: word do-1 ( word -- )
    dup "meta-word" word-prop [ call ] [ host-word ] ?if ;

M: wrapper do-1 ( wrapper -- ) wrapped push-d ;

M: object do-1 ( object -- ) push-d ;

GENERIC: do ( obj -- )

M: word do ( word -- )
    dup "meta-word" word-prop [
        call
    ] [
        dup compound? [
            dup word-def meta-call  meta-executing set
        ] [
            host-word
        ] if
    ] ?if ;

M: object do ( object -- ) do-1 ;

! The interpreter loses object identity of the name and catch
! stacks -- they are copied after each step -- so we execute
! them atomically and don't allow stepping into these words
\ >n [ \ >n host-word ] "meta-word" set-word-prop
\ n> [ \ n> host-word ] "meta-word" set-word-prop
\ >c [ \ >c host-word ] "meta-word" set-word-prop
\ c> [ \ c> host-word ] "meta-word" set-word-prop

\ call [ pop-d meta-call ] "meta-word" set-word-prop
\ execute [ pop-d do ] "meta-word" set-word-prop
\ if [ pop-d pop-d pop-d [ nip ] [ drop ] if meta-call ] "meta-word" set-word-prop
\ dispatch [ pop-d pop-d swap nth meta-call ] "meta-word" set-word-prop
