! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes combinators combinators.private
continuations continuations.private generic hashtables io kernel
kernel.private math namespaces namespaces.private prettyprint
quotations sequences splitting strings threads vectors words ;
IN: tools.interpreter

SYMBOL: interpreter

SYMBOL: break-hook

: break ( -- )
    continuation callstack
    over set-continuation-call
    walker-hook [ continue-with ] [ break-hook get call ] if* ;

: with-interpreter-datastack ( quot -- )
    interpreter get continuation-data
    swap with-datastack
    interpreter get set-continuation-data ; inline

GENERIC: restore ( obj -- )

M: continuation restore
    clone interpreter set ;

M: pair restore
    first2 restore [ nip f ] curry with-interpreter-datastack ;

M: f restore
    drop interpreter off ;

: (step-into-call) \ break add* call ;

: (step-into-if) ? (step-into-call) ;

: (step-into-dispatch)
    nth (step-into-call) ;

: (step-into-execute) ( word -- )
    dup "step-into" word-prop [
        call
    ] [
        dup compound? [
            word-def (step-into-call)
        ] [
            execute break
        ] if
    ] ?if ;

{
    { call [ (step-into-call) ] }
    { (throw) [ (step-into-call) ] }
    { execute [ (step-into-execute) ] }
    { if [ (step-into-if) ] }
    { dispatch [ (step-into-dispatch) ] }
} [ "step-into" set-word-prop ] assoc-each

{
    >n ndrop >c c>
    continuation continue continue-with
    (continue-with) stop break
} [
    dup [ execute break ] curry
    "step-into" set-word-prop
] each

! Time travel
SYMBOL: history

: save-interpreter ( -- )
    history get [ interpreter get clone swap push ] when* ;

: step-back ( -- )
    history get dup empty?
    [ drop ] [ pop restore ] if ;

: (continue) ( continuation -- )
    >continuation<
    set-catchstack
    set-namestack
    set-retainstack
    >r set-datastack r>
    set-callstack ;

! Stepping
: step-all ( -- )
    [ interpreter get (continue) ] in-thread ;

: change-innermost-frame ( quot -- )
    interpreter get continuation-call clone
    [
        dup innermost-frame-scan 1+
        swap innermost-frame-quot
        rot call
    ] keep
    [ set-innermost-frame-quot ] keep
    interpreter get set-continuation-call ; inline

: (step) ( quot -- )
    save-interpreter
    change-innermost-frame
    [ set-walker-hook interpreter get (continue) ] callcc1
    restore ;

: step ( n -- )
    [
        2dup nth \ break = [
            nip
        ] [
            >r 1+ r> cut [ break ] swap 3append
        ] if
    ] (step) ;

: step-out ( -- )
    [ nip \ break add ] (step) ;

GENERIC: (step-into) ( obj -- )

M: word (step-into) (step-into-execute) ;
M: wrapper (step-into) wrapped break ;
M: object (step-into) break ;

: step-into ( -- )
    [
        cut [
            swap % unclip literalize , \ (step-into) , %
        ] [ ] make
    ] (step) ;
