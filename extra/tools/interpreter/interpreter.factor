! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes combinators combinators.private
continuations continuations.private generic hashtables io kernel
kernel.private math namespaces namespaces.private prettyprint
quotations sequences splitting strings threads vectors words ;
IN: tools.interpreter

SYMBOL: meta-interp

SYMBOL: callframe
SYMBOL: callframe-scan

! Meta-stacks;
: meta-d ( -- seq )
    meta-interp get continuation-data ;

: set-meta-d ( seq -- )
    meta-interp get set-continuation-data ;

: unclip-last ( seq -- last seq' ) dup peek swap 1 head* ;

: push-d ( obj -- ) meta-d swap add set-meta-d ;
: pop-d  ( -- obj ) meta-d unclip-last set-meta-d ;
: peek-d ( -- obj ) meta-d peek ;

: meta-r ( -- seq )
    meta-interp get continuation-retain ;

: set-meta-r ( seq -- )
    meta-interp get set-continuation-retain ;

: push-r ( obj -- ) meta-r swap add set-meta-r ;
: pop-r  ( -- obj ) meta-r unclip-last set-meta-r ;
: peek-r ( -- obj ) meta-r peek ;

: meta-c ( -- seq )
    meta-interp get continuation-call callstack>array ;

: set-meta-c ( seq -- )
    array>callstack meta-interp get set-continuation-call ;

: push-c ( obj -- ) meta-c swap append set-meta-c ;
: pop-c  ( -- obj ) meta-c 2 swap cut* swap set-meta-c ;
: peek-c ( -- obj ) meta-c 2 tail* ;

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
    pop-c first2 cut [ remove-breaks ] 2apply
    >r dup length callframe-scan set r> append
    callframe set ;

: done-cf? ( -- ? ) callframe-scan get callframe get length >= ;

: done? ( -- ? ) done-cf? meta-c empty? and ;

: reset-interpreter ( -- )
    meta-interp off [ ] (meta-call) ;

: <callframe> ( quot scan -- seq )
    >r { } like r> 2array ;

: (save-callframe) ( -- )
    callframe get callframe-scan get <callframe> push-c ;

: save-callframe ( -- )
    done-cf? [ (save-callframe) ] unless ;

GENERIC: meta-call ( quot -- )

M: quotation meta-call save-callframe (meta-call) ;

M: curry meta-call
    dup curry-obj push-d curry-quot meta-call ;

: meta-swap ( -- )
    meta-d 2 cut* reverse append set-meta-d ;

GENERIC: restore ( obj -- )

M: continuation restore
    clone meta-interp set
    f push-d
    meta-c empty? [ [ ] (meta-call) ] [ up ] if ;

M: pair restore
    first2 restore push-d meta-swap ;

M: f restore
    drop reset-interpreter ;

: <breakpoint> ( break quot scan -- callframe )
    >r cut [ break ] swap 3append r> <callframe> ;

: step-to ( n -- )
    callframe get callframe-scan get <breakpoint> push-c
    [ set-walker-hook meta-interp get (continue) ] callcc1
    restore ;

! The interpreter loses object identity of the name and catch
! stacks -- they are copied after each step -- so we execute
! these atomically and don't allow stepping into these words
{ >n >c c> rethrow continue continue-with continuation
(continue) (continue-with) }
[ t "no-meta-word" set-word-prop ] each

\ call [ pop-d meta-call ] "meta-word" set-word-prop
\ execute [ pop-d 1quotation meta-call ] "meta-word" set-word-prop
\ if [ pop-d pop-d pop-d [ nip ] [ drop ] if meta-call ] "meta-word" set-word-prop
\ dispatch [ pop-d pop-d swap nth meta-call ] "meta-word" set-word-prop
\ (callcc1) [ ] "meta-word" set-word-prop

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
    callframe over at callframe set
    callframe-scan over at callframe-scan set
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
