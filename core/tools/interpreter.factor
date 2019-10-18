! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays errors generic io kernel kernel-internals math
namespaces prettyprint sequences strings threads vectors words
hashtables quotations assocs ;
IN: interpreter

SYMBOL: meta-interp

SYMBOL: callframe
SYMBOL: callframe-scan

! Meta-stacks;
: meta-d ( -- seq ) meta-interp get continuation-data ;
: push-d ( obj -- ) meta-d push ;
: pop-d  ( -- obj ) meta-d pop ;
: peek-d ( -- obj ) meta-d peek ;

: meta-r ( -- seq ) meta-interp get continuation-retain ;
: push-r ( obj -- ) meta-r push ;
: pop-r  ( -- obj ) meta-r pop ;
: peek-r ( -- obj ) meta-r peek ;

: meta-c ( -- seq ) meta-interp get continuation-call ;
: push-c ( obj -- ) meta-c push ;
: pop-c  ( -- obj ) meta-c pop ;
: peek-c ( -- obj ) meta-c peek ;

! Hook
SYMBOL: break-hook

: (meta-call) ( quot -- )
    callframe set 0 callframe-scan set ;

! Callframe.

: break ( -- )
    continuation walker-hook
    [ continue-with ] [ break-hook get call ] if* ;

: remove-breaks \ break swap remove ;

: up ( -- )
    pop-c drop
    pop-c pop-c cut [ remove-breaks ] 2apply
    >r dup length callframe-scan set r> append
    callframe set ;

: done-cf? ( -- ? ) callframe-scan get callframe get length >= ;

: done? ( -- ? ) done-cf? meta-c empty? and ;

: reset-interpreter ( -- )
    meta-interp off f (meta-call) ;

: (save-callframe) ( -- )
    callframe get push-c
    callframe-scan get push-c
    callframe get length push-c ;

: save-callframe ( -- )
    done-cf? [ (save-callframe) ] unless ;

: meta-call ( quot -- )
    save-callframe (meta-call) ;

: meta-swap ( -- )
    meta-d [ length 1- dup 1- ] keep exchange ;

GENERIC: restore ( obj -- )

M: continuation restore
    clone meta-interp set
    meta-c empty? [ f (meta-call) ] [ up ] if ;

M: pair restore
    first2 restore push-d meta-swap ;

M: f restore
    drop reset-interpreter ;

: <callframe> ( quot scan -- seq )
    >r >quotation r> over length 3array >vector ;

: <breakpoint> ( break quot scan -- callframe )
    >r cut [ break ] swap 3append r> <callframe> ;

: step-to ( n -- )
    callframe get callframe-scan get <breakpoint>
    meta-c push-all
    [ set-walker-hook meta-interp get (continue) ] callcc1
    restore ;

! The interpreter loses object identity of the name and catch
! stacks -- they are copied after each step -- so we execute
! these atomically and don't allow stepping into these words
{ >n n> >c c> rethrow continue continue-with continuation
(continue) (continue-with) }
[ t "no-meta-word" set-word-prop ] each

\ call [ pop-d meta-call ] "meta-word" set-word-prop
\ execute [ pop-d 1quotation meta-call ] "meta-word" set-word-prop
\ if [ pop-d pop-d pop-d [ nip ] [ drop ] if meta-call ] "meta-word" set-word-prop
\ dispatch [ pop-d pop-d swap nth meta-call ] "meta-word" set-word-prop

! Time travel
SYMBOL: meta-history

: save-interp ( -- )
    meta-history get [
        [
            callframe [ ] change
            callframe-scan [ ] change
            meta-interp [ clone ] change
        ] H{ } make-assoc swap push
    ] when* ;

: restore-interp ( ns -- )
    { callframe callframe-scan }
    [ dup pick at swap set ] each
    meta-interp swap at clone meta-interp set ;

: advance ( -- ) callframe-scan inc ;

: (next) callframe-scan get callframe get nth ;

: next ( quot -- )
    save-interp {
        { [ done? ] [ drop [ ] (meta-call) ] }
        { [ done-cf? ] [ drop up ] }
        { [ >r (next) r> call ] [ ] }
        { [ t ] [ callframe-scan get 1+ step-to ] }
    } cond ; inline

GENERIC: (step) ( obj -- ? )

M: wrapper (step) advance wrapped push-d t ;

M: object (step) advance push-d t ;

M: word (step) drop f ;

: step ( -- ) [ (step) ] next ;

: (step-in) ( word -- ? )
    dup "meta-word" word-prop [
        advance call t
    ] [
        dup "no-meta-word" word-prop not over compound? and [
            advance word-def meta-call t
        ] [
            drop f
        ] if
    ] ?if ;

: step-in ( -- )
    [ dup word? [ (step-in) ] [ (step) ] if ] next ;

: step-out ( -- )
    save-interp callframe get length step-to ;

: step-back ( -- )
    meta-history get dup empty?
    [ drop ] [ pop restore-interp ] if ;

: step-all ( -- )
    save-callframe meta-interp get schedule-thread ;

: abandon ( -- )
    [ "Single-stepping abandoned" throw ] meta-call step-all ;
