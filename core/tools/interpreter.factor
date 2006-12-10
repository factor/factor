! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays errors generic io kernel kernel-internals math
namespaces prettyprint sequences strings threads vectors words
hashtables ;
IN: interpreter

! Metacircular interpreter for single-stepping
SYMBOL: meta-interp

! Meta-stacks;
: meta-d meta-interp get continuation-data ;
: push-d meta-d push ;
: pop-d meta-d pop ;
: peek-d meta-d peek ;

: meta-r meta-interp get continuation-retain ;
: push-r meta-r push ;
: pop-r meta-r pop ;
: peek-r meta-r peek ;

: meta-c meta-interp get continuation-call ;
: push-c meta-c push ;
: pop-c meta-c pop ;
: peek-c meta-c peek ;

! Call frame
SYMBOL: callframe
SYMBOL: callframe-scan
SYMBOL: callframe-end

! Hook
SYMBOL: break-hook

: meta-callframe ( -- seq )
    { callframe callframe-scan callframe-end } [ get ] map ;

: (meta-call) ( quot -- )
    dup callframe set
    length callframe-end set
    0 callframe-scan set ;

! Callframe.

: break ( -- )
    continuation get-walker-hook
    [ continue-with ] [ break-hook get call ] if* ;

: remove-breaks \ break swap remove ;

: up ( -- )
    pop-c drop
    pop-c pop-c cut [ remove-breaks ] 2apply
    >r dup length callframe-scan set r> append
    dup length callframe-end set callframe set ;

: done-cf? ( -- ? ) callframe-scan get callframe-end get >= ;

: done? ( -- ? ) done-cf? meta-c empty? and ;

: reset-interpreter ( -- )
    meta-interp off f (meta-call) ;

: (save-callframe) ( -- )
    callframe get push-c
    callframe-scan get push-c
    callframe-end get push-c ;

: save-callframe ( -- )
    done-cf? [ (save-callframe) ] unless ;

: meta-call ( quot -- )
    #! Note we do tail call optimization here.
    save-callframe (meta-call) ;

: restore-normally
    clone meta-interp set
    meta-c empty? [ f (meta-call) ] [ up ] if ;

: restore-with
    first2 restore-normally push-d
    meta-d [ length 1- dup 1- ] keep exchange ;

: restore-harness ( obj -- )
    {
        { [ dup continuation? ] [ restore-normally ] }
        { [ dup not ] [ drop reset-interpreter ] }
        { [ dup length 2 = ] [ restore-with ] }
    } cond ;

: <callframe> ( quot scan -- seq )
    >r >quotation r> over length 3array >vector ;

: <breakpoint> ( break quot scan -- callframe )
    >r cut [ break ] swap 3append r> <callframe> ;

: step-to ( n -- )
    >r meta-c r>
    callframe get callframe-scan get <breakpoint>
    nappend
    [ set-walker-hook meta-interp get (continue) ] callcc1
    restore-harness ;

! The interpreter loses object identity of the name and catch
! stacks -- they are copied after each step -- so we execute
! these atomically and don't allow stepping into these words
{ >n n> >c c> rethrow continue continue-with continuation
(continue) (continue-with) }
[ t "no-meta-word" set-word-prop ] each

\ call [ pop-d meta-call ] "meta-word" set-word-prop
\ execute [ pop-d unit meta-call ] "meta-word" set-word-prop
\ if [ pop-d pop-d pop-d [ nip ] [ drop ] if meta-call ] "meta-word" set-word-prop
\ dispatch [ pop-d pop-d swap nth meta-call ] "meta-word" set-word-prop

! Time travel
SYMBOL: meta-history

: save-interp ( -- )
    meta-history get [
        [
            callframe [ ] change
            callframe-scan [ ] change
            callframe-end [ ] change
            meta-interp [ clone ] change
        ] make-hash swap push
    ] when* ;

: restore-interp ( ns -- )
    { callframe callframe-scan callframe-end }
    [ dup pick hash swap set ] each
    meta-interp swap hash clone meta-interp set ;

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
    save-interp callframe-end get step-to ;

: step-all ( -- )
    save-callframe meta-interp get schedule-thread ;

: step-back ( -- )
    meta-history get dup empty?
    [ drop ] [ pop restore-interp ] if ;
