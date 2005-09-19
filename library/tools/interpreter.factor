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

: init-interpreter ( -- )
    { } clone meta-r set
    { } clone meta-d set
    namestack meta-n set
    catchstack meta-c set
    f meta-cf set
    f meta-executing set ;

: copy-interpreter ( -- )
    #! Copy interpreter state from containing namespaces.
    meta-r [ clone ] change
    meta-d [ clone ] change
    meta-n [ ] change
    meta-c [ ] change ;

! Callframe.
: up ( -- ) pop-r meta-cf set  pop-r drop ;

: next ( -- obj )
    meta-cf get [ meta-cf [ uncons ] change ] [ up next ] ifte ;

: meta-interp ( -- interp )
    meta-d get f meta-r get meta-n get meta-c get
    <continuation> ;

: set-meta-interp ( interp -- )
    >continuation<
    meta-c set meta-n set meta-r set drop meta-d set ;

: host-word ( word -- )
    [
        \ call push-r  continuation [
            continuation over continuation-data push continue
        ] cons cons push-r  meta-interp continue
    ] call  set-meta-interp  pop-d 2drop ;

: meta-call ( quot -- )
    #! Note we do tail call optimization here.
    meta-cf [
        [ meta-executing get push-r  push-r ] when*
    ] change ;

GENERIC: do ( obj -- )

M: word do ( word -- )
    dup "meta-word" word-prop [
        call
    ] [
        dup compound? [
            dup word-def meta-call  meta-executing set
        ] [
            host-word
        ] ifte
    ] ?ifte ;

M: wrapper do ( wrapper -- ) wrapped push-d ;

M: object do ( object -- ) push-d ;

GENERIC: do-1 ( object -- )

M: word do-1 ( word -- )
    dup "meta-word" word-prop [ call ] [ host-word ] ?ifte ;

M: wrapper do-1 ( wrapper -- ) wrapped push-d ;

M: object do-1 ( object -- ) push-d ;

: set-meta-word ( word quot -- ) "meta-word" set-word-prop ;

\ datastack [ meta-d get clone push-d ] set-meta-word
\ set-datastack [ pop-d clone meta-d set ] set-meta-word
\ >r [ pop-d push-r ] set-meta-word
\ r> [ pop-r push-d ] set-meta-word
\ callstack [ meta-r get clone push-d ] set-meta-word
\ set-callstack [ pop-d clone meta-r set ] set-meta-word
\ call [ pop-d meta-call ] set-meta-word
\ execute [ pop-d do ] set-meta-word
\ ifte [ pop-d pop-d pop-d [ nip ] [ drop ] ifte meta-call ] set-meta-word
\ dispatch [ pop-d pop-d swap nth meta-call ] set-meta-word

\ set-meta-word forget
