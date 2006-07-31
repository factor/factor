! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: interpreter
USING: errors generic io kernel kernel-internals math
namespaces prettyprint sequences strings vectors words ;

! A Factor interpreter written in Factor. It can transfer the
! continuation to and from the primary interpreter. Used by
! compiler for partial evaluation, also by the walker.

! Meta-stacks;
SYMBOL: meta-d
: push-d meta-d get push ;
: pop-d meta-d get pop ;
: peek-d meta-d get peek ;
SYMBOL: meta-r
: push-r meta-r get push ;
: pop-r meta-r get pop ;
: peek-r meta-r get peek ;
SYMBOL: meta-c
: push-c meta-c get push ;
: pop-c meta-c get pop ;
: peek-c meta-c get peek ;
SYMBOL: meta-name
SYMBOL: meta-catch

! Call frame
SYMBOL: callframe
SYMBOL: callframe-scan
SYMBOL: callframe-end

: meta-callframe ( -- seq )
    { callframe callframe-scan callframe-end } [ get ] map ;

! Callframe.
: up ( -- )
    pop-c callframe-end set
    pop-c callframe-scan set
    pop-c callframe set ;

: done? ( -- ? ) callframe-scan get callframe-end get >= ;

: next ( -- obj )
    done? [
        up next
    ] [
        callframe-scan get callframe get nth callframe-scan inc
    ] if ;

: meta-interp ( -- interp )
    meta-d get meta-r get meta-c get
    meta-name get meta-catch get <continuation> ;

: set-meta-interp ( interp -- )
    >continuation<
    meta-catch set
    meta-name set
    meta-c set
    meta-r set
    meta-d set ;

: save-callframe ( -- )
    callframe get push-c
    callframe-scan get push-c
    callframe-end get push-c ;

: (meta-call) ( quot -- )
    dup callframe set
    length callframe-end set
    0 callframe-scan set ;

: meta-call ( quot -- )
    #! Note we do tail call optimization here.
    done? [ save-callframe ] unless (meta-call) ;

: host-word ( word -- )
    [
        [
            swap , \ continuation , , \ continue-with ,
        ] [ ] make dup push-c 0 push-c length push-c
        meta-interp continue
    ] callcc1 set-meta-interp drop ;

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
        dup compound? [ word-def meta-call ] [ host-word ] if
    ] ?if ;

M: object do ( object -- ) do-1 ;

! The interpreter loses object identity of the name and catch
! stacks -- they are copied after each step -- so we execute
! these atomically and don't allow stepping into these words
\ >n [ \ >n host-word ] "meta-word" set-word-prop
\ n> [ \ n> host-word ] "meta-word" set-word-prop
\ >c [ \ >c host-word ] "meta-word" set-word-prop
\ c> [ \ c> host-word ] "meta-word" set-word-prop

\ call [ pop-d meta-call ] "meta-word" set-word-prop
\ execute [ pop-d do ] "meta-word" set-word-prop
\ if [ pop-d pop-d pop-d [ nip ] [ drop ] if meta-call ] "meta-word" set-word-prop
\ dispatch [ pop-d pop-d swap nth meta-call ] "meta-word" set-word-prop
