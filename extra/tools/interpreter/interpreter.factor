! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes combinators combinators.private
continuations continuations.private generic hashtables io kernel
kernel.private math namespaces namespaces.private prettyprint
quotations sequences splitting strings threads vectors words ;
IN: tools.interpreter

TUPLE: interpreter continuation ;

: <interpreter> interpreter construct-empty ;

SYMBOL: break-hook

: break ( -- )
    continuation callstack
    over set-continuation-call
    walker-hook [ continue-with ] [ break-hook get call ] if* ;

GENERIC# restore 1 ( obj interpreter -- )

M: f restore
    set-interpreter-continuation ;

M: continuation restore
    >r clone r> set-interpreter-continuation ;

: with-interpreter-datastack ( quot interpreter -- )
    interpreter-continuation [
        continuation-data
        swap with-datastack
    ] keep set-continuation-data ; inline

M: pair restore
    >r first2 r> [ restore ] keep
    >r [ nip f ] curry r> with-interpreter-datastack ;

<PRIVATE

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

: (step-into-continuation)
    continuation callstack over set-continuation-call break ;

{
    { call [ (step-into-call) ] }
    { (throw) [ (step-into-call) ] }
    { execute [ (step-into-execute) ] }
    { if [ (step-into-if) ] }
    { dispatch [ (step-into-dispatch) ] }
    { continuation [ (step-into-continuation) ] }
} [ "step-into" set-word-prop ] assoc-each

{
    >n ndrop >c c>
    continue continue-with
    (continue-with) stop break
} [
    dup [ execute break ] curry
    "step-into" set-word-prop
] each

: (continue) ( continuation -- )
    >continuation<
    set-catchstack
    set-namestack
    set-retainstack
    >r set-datastack r>
    set-callstack ;

! Stepping
: change-innermost-frame ( quot interpreter -- )
    interpreter-continuation [
        continuation-call clone
        [
            dup innermost-frame-scan 1+
            swap innermost-frame-quot
            rot call
        ] keep
        [ set-innermost-frame-quot ] keep
    ] keep set-continuation-call ; inline

: (step) ( interpreter quot -- )
    swap
    [ change-innermost-frame ] keep
    [
        set-walker-hook
        interpreter-continuation (continue)
    ] callcc1 swap restore ;

GENERIC: (step-into) ( obj -- )

M: word (step-into) (step-into-execute) ;
M: wrapper (step-into) wrapped break ;
M: object (step-into) break ;

PRIVATE>

: step ( interpreter -- )
    [
        2dup nth \ break = [
            nip
        ] [
            >r 1+ r> cut [ break ] swap 3append
        ] if
    ] (step) ;

: step-out ( interpreter -- )
    [ nip \ break add ] (step) ;

: step-into ( interpreter -- )
    [
        cut [
            swap % unclip literalize , \ (step-into) , %
        ] [ ] make
    ] (step) ;

: step-all ( interpreter -- )
    interpreter-continuation [ (continue) ] curry in-thread ;
