! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel lists math
math-internals namespaces sequences strings vectors words
hashtables parser prettyprint ;

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

: inhibit-parital ( -- )
    meta-d get [ f swap set-literal-safe? ] each ;

: recursive? ( word -- ? )
    f swap dup word-def [ = or ] tree-each-with ;

: (with-block) ( [[ label quot ]] quot -- node )
    #! Call a quotation in a new namespace, and transfer
    #! inference state from the outer scope.
    swap car >r [
        dataflow-graph off
        call
        d-in get meta-d get meta-r get get-dataflow
    ] with-scope
    r> swap #label dataflow, [ node-label set ] extend >r
    meta-r set meta-d set d-in set r> ;

: with-block ( word [[ label quot ]] quot -- node )
    #! Execute a quotation with the word on the stack, and add
    #! its dataflow contribution to a new block node in the IR.
    over [
        >r
        dupd cons
        recursive-state [ cons ] change
        r> call
    ] (with-block) ;

: inline-block ( word -- effect node )
    gensym over word-def cons [
        inhibit-parital
        word-def infer-quot effect
    ] with-block ;

: inline-compound ( word -- )
    #! Infer the stack effect of a compound word in the current
    #! inferencer instance. If the word in question is recursive
    #! we infer its stack effect inside a new block.
    dup recursive? [
        inline-block 2drop
    ] [
        word-def infer-quot
    ] ifte ;

: infer-compound ( word -- )
    #! Infer a word's stack effect in a separate inferencer
    #! instance.
    [
        [
            recursive-state get init-inference
            dup dup inline-block drop present-effect
            [ "infer-effect" set-word-prop ] keep
        ] with-scope consume/produce
    ] [
        [
            >r inferring-base-case get [
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

M: primitive (apply-word) ( word -- )
    dup "infer-effect" word-prop consume/produce ;

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
        inline-compound
    ] [
        apply-default
    ] ifte ;

: with-recursion ( quot -- )
    [
        inferring-base-case on
        call
    ] [
        inferring-base-case off
        rethrow
    ] catch ;

: base-case ( word [ label quot ] -- )
    [
        car over inline-block [
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
    over "infer-effect" word-prop [
        nip consume/produce
    ] [
        inferring-base-case get [
            drop no-base-case
        ] [
            base-case
        ] ifte
    ] ifte* ;

M: word apply-object ( word -- )
    #! Apply the word's stack effect to the inferencer state.
    dup recursive-state get assoc [
        recursive-word
    ] [
        apply-word
    ] ifte* ;

: infer-quot-value ( rstate quot -- )
    recursive-state get >r
    swap recursive-state set
    dup infer-quot handle-terminator
    r> recursive-state set ;

\ call [
    pop-literal infer-quot-value
] "infer" set-word-prop

\ execute [
    pop-literal unit infer-quot-value
] "infer" set-word-prop

! These hacks will go away soon
\ delegate [ [ object ] [ object ] ] "infer-effect" set-word-prop
\ no-method t "terminator" set-word-prop
\ no-method [ [ object word ] [ ] ] "infer-effect" set-word-prop
\ <no-method> [ [ object object ] [ tuple ] ] "infer-effect" set-word-prop
\ set-no-method-generic [ [ object tuple ] [ ] ] "infer-effect" set-word-prop
\ set-no-method-object [ [ object tuple ] [ ] ] "infer-effect" set-word-prop
\ not-a-number t "terminator" set-word-prop
\ throw t "terminator" set-word-prop
\ = [ [ object object ] [ boolean ] ] "infer-effect" set-word-prop
\ integer/ [ [ integer integer ] [ rational ] ] "infer-effect" set-word-prop
\ gcd [ [ integer integer ] [ integer integer ] ] "infer-effect" set-word-prop
