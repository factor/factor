! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel lists math namespaces
sequences strings vectors words hashtables parser prettyprint ;

: with-dataflow ( param op [[ in# out# ]] quot -- )
    #! Take input parameters, execute quotation, take output
    #! parameters, add node. The quotation is called with the
    #! stack effect.
    >r dup car ensure-d
    >r dataflow, r> r> rot
    [ pick car swap [ length 0 node-inputs ] bind ] keep
    pick >r >r nip call r> r> cdr car swap
    [ length 0 node-outputs ] bind ; inline

: consume-d ( typelist -- )
    [ pop-d 2drop ] each ;

: produce-d ( typelist -- )
    [ <computed> push-d ] each ;

: (consume/produce) ( param op effect )
    dup >r -rot r>
    [ unswons consume-d car produce-d ] with-dataflow ;

: consume/produce ( word [ in-types out-types ] -- )
    #! Add a node to the dataflow graph that consumes and
    #! produces a number of values.
    #call swap (consume/produce) ;

: no-effect ( word -- )
    "Unknown stack effect: " swap word-name cat2 inference-error ;

: inline-compound ( word -- effect node )
    #! Infer the stack effect of a compound word in the current
    #! inferencer instance. If the word in question is recursive
    #! we infer its stack effect inside a new block.
    gensym over word-def cons [
        word-def infer-quot effect
    ] with-block ;

: infer-compound ( word -- )
    #! Infer a word's stack effect in a separate inferencer
    #! instance.
    [
        [
            recursive-state get init-inference
            dup dup inline-compound drop present-effect
            [ "infer-effect" set-word-prop ] keep
        ] with-scope consume/produce
    ] [
        [
            >r branches-can-fail? [
                drop
            ] [
                t "no-effect" set-word-prop
            ] ifte r> rethrow
        ] when*
    ] catch ;

GENERIC: (apply-word)

M: object (apply-word) ( word -- )
    #! A primitive with an unknown stack effect.
    no-effect ;

M: compound (apply-word) ( word -- )
    #! Infer a compound word's stack effect.
    dup "no-effect" word-prop [
        no-effect
    ] [
        infer-compound
    ] ifte ;

M: symbol (apply-word) ( word -- )
    apply-literal ;

GENERIC: apply-word

: apply-default ( word -- )
    dup "infer-effect" word-prop [
        over "infer" word-prop [
            swap car ensure-d call drop
        ] [
            consume/produce
        ] ifte*
    ] [
        (apply-word)
    ] ifte* ;

M: word apply-word ( word -- )
    apply-default ;

M: compound apply-word ( word -- )
    dup "inline" word-prop [
        inline-compound 2drop
    ] [
        apply-default
    ] ifte ;

: literal-type? ( -- ? )
    peek-d value-class builtin-supertypes
    dup length 1 = >r [ tuple ] = not r> and ;

: dynamic-dispatch-warning ( word -- )
    "Dynamic dispatch for " swap word-name cat2
    inference-warning ;

! M: generic apply-word ( word -- )
!     #! If the type of the value at the top of the stack is
!     #! known, inline the method body.
!     [ object ] ensure-d
!    literal-type? branches-can-fail? not and [
!        inline-compound 2drop
!    ] [
!        dup dynamic-dispatch-warning apply-default ;
!    ] ifte ;

: with-recursion ( quot -- )
    [
        inferring-base-case inc
        call
    ] [
        inferring-base-case dec
        rethrow
    ] catch ;

: base-case ( word [ label quot ] -- )
    [
        car over inline-compound [
            drop
            [ #call-label ] [ #call ] ?ifte
            node-op set
            node-param set
        ] bind
    ] with-recursion ;

: no-base-case ( word -- )
    word-name " does not have a base case." cat2 inference-error ;

: recursive-word ( word [ label quot ] -- )
    #! Handle a recursive call, by either applying a previously
    #! inferred base case, or raising an error. If the recursive
    #! call is to a local block, emit a label call node.
    inferring-base-case get max-recursion > [
        drop no-base-case
    ] [
        inferring-base-case get max-recursion = [
            base-case
        ] [
            [ drop inline-compound 2drop ] with-recursion
        ] ifte
    ] ifte ;

M: word apply-object ( word -- )
    #! Apply the word's stack effect to the inferencer state.
    dup recursive-state get assoc [
        recursive-word
    ] [
        apply-word
    ] ifte* ;

: infer-call ( -- )
    [ general-list ] ensure-d
    dataflow-drop, pop-d infer-quot-value ;

\ call [ infer-call ] "infer" set-word-prop

! These hacks will go away soon
\ * [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ - [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ + [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ = [ [ object object ] [ boolean ] ] "infer-effect" set-word-prop
\ <no-method> [ [ object object ] [ tuple ] ] "infer-effect" set-word-prop

\ no-method t "terminator" set-word-prop
\ no-method [ [ object word ] [ ] ] "infer-effect" set-word-prop
\ not-a-number t "terminator" set-word-prop
\ throw t "terminator" set-word-prop
