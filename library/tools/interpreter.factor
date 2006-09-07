! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: interpreter
USING: arrays errors generic io kernel kernel-internals math
namespaces prettyprint sequences strings threads vectors words
hashtables ;

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

: meta-callframe ( -- seq )
    { callframe callframe-scan callframe-end } [ get ] map ;

: (meta-call) ( quot -- )
    dup callframe set
    length callframe-end set
    0 callframe-scan set ;

! Callframe.
: up ( -- )
    pop-c callframe-end set
    pop-c callframe-scan set
    pop-c callframe set ;

: done-cf? ( -- ? ) callframe-scan get callframe-end get >= ;

: done? ( -- ? ) done-cf? meta-c empty? and ;

: (next)
    callframe-scan get callframe get nth callframe-scan inc ;

: next ( quot -- )
    {
        { [ done? ] [ drop [ ] (meta-call) ] }
        { [ done-cf? ] [ drop up ] }
        { [ t ] [ >r (next) r> call ] }
    } cond ; inline

: init-meta-interp ( -- )
    <empty-continuation> meta-interp set ;

: save-callframe ( -- )
    done-cf? [
        callframe get push-c
        callframe-scan get push-c
        callframe-end get push-c
    ] unless ;

: meta-call ( quot -- )
    #! Note we do tail call optimization here.
    save-callframe (meta-call) ;

: <callframe> ( quot -- seq )
    \ end-walk add >quotation 0 over length 3array >vector ;

: restore-harness ( obj -- )
    {
        { [ dup continuation? ] [ ] }
        { [ dup array? ] [ first2 >r push-d r> ] }
        { [ dup not ] [ drop <empty-continuation> ] }
    } cond meta-interp set ;

: host-quot ( quot -- )
    <callframe> meta-c swap nappend
    [ set-walker-hook meta-interp get (continue) ] callcc1
    restore-harness ;

: host-word ( word -- ) unit host-quot ;

GENERIC: do-1 ( object -- )

M: word do-1
    dup "meta-word" word-prop [ call ] [ host-word ] ?if ;

M: wrapper do-1 wrapped push-d ;

M: object do-1 push-d ;

GENERIC: do ( obj -- )

M: word do
    dup "meta-word" word-prop [
        call
    ] [
        dup compound? [ word-def meta-call ] [ host-word ] if
    ] ?if ;

M: object do do-1 ;

! The interpreter loses object identity of the name and catch
! stacks -- they are copied after each step -- so we execute
! these atomically and don't allow stepping into these words
{ >n n> >c c> rethrow continue continue-with }
[ dup [ host-word ] curry "meta-word" set-word-prop ] each

\ call [ pop-d meta-call ] "meta-word" set-word-prop
\ execute [ pop-d do ] "meta-word" set-word-prop
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

: step ( -- ) save-interp [ do-1 ] next ;

: step-in ( -- ) save-interp [ do ] next ;

: step-out ( -- )
    save-interp
    callframe get callframe-scan get tail
    host-quot [ ] (meta-call) ;

: step-all ( -- )
    save-callframe meta-interp get schedule-thread ;

: step-back ( -- )
    meta-history get dup empty? [
        drop
    ] [
        pop restore-interp
    ] if ;
