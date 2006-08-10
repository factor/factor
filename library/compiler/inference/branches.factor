! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: arrays errors generic hashtables interpreter kernel math
namespaces parser prettyprint sequences strings vectors words ;

: unify-lengths ( seq -- seq )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup 0 [ length max ] reduce
    swap [ add-inputs nip ] map-with ;

: unify-values ( seq -- value )
    #! If all values in list are equal, return the value.
    #! Otherwise, unify.
    dup all-eq? [ first ] [ drop <computed> ] if ;

: unify-stacks ( seq -- stack ) flip [ unify-values ] map ;

: balanced? ( in out -- ? )
    [ dup [ length - ] [ 2drop f ] if ] 2map
    [ ] subset all-equal? ;

: supremum ( seq -- n ) -1./0. [ max ] reduce ;

: unbalanced-branches ( in out -- )
    [ swap unparse " " rot length unparse append3 ] 2map
    "Unbalanced branches:" add* "\n" join inference-error ;

: unify-inputs ( max-d-in meta-d -- meta-d )
    dup [
        [ >r - r> length + ] keep add-inputs nip
    ] [
        2nip
    ] if ;

: unify-effect ( in out -- in out )
    #! in is a sequence of integers, out is a sequence of
    #! stacks.
    2dup balanced? [
        over supremum -rot
        [ >r dupd r> unify-inputs ] 2map
        [ ] subset unify-stacks
    ] [
        unbalanced-branches
    ] if ;

: active-variable ( seq symbol -- seq )
    swap [
        terminated? over hash [ 2drop f ] [ hash ] if
    ] map-with ;

: datastack-effect ( seq -- )
    d-in over [ hash ] map-with
    swap meta-d active-variable
    unify-effect meta-d set d-in set ;

: callstack-effect ( seq -- )
    dup length 0 <array>
    swap meta-r active-variable
    unify-effect meta-r set drop ;

: unify-effects ( seq -- )
    dup datastack-effect dup callstack-effect
    [ terminated? swap hash ] all? terminated? set ;

: unify-dataflow ( effects -- nodes )
    [ dataflow-graph swap hash ] map ;

: copy-inference ( -- )
    meta-r [ clone ] change
    meta-d [ clone ] change
    d-in [ ] change
    dataflow-graph off
    current-node off ;

: no-base-case ( -- )
    "Cannot infer base case" inference-error ;

: recursive-branch ( hash ? -- obj )
    #! If the branch made an unresolved recursive call, and we
    #! are inferring the base case, ignore the branch (the base
    #! case being the stack effect of the branches not making
    #! recursive calls). Otherwise, raise an error.
    [
        base-case-continuation get
        [ drop f ] [ no-base-case ] if
    ] when ;

: infer-branch ( value -- namespace )
    #! Return a namespace with inferencer variables:
    #! meta-d, meta-r, d-in. They are set to f if
    #! terminate was called.
    [
        [
            base-case-continuation set
            copy-inference
            dup value-recursion recursive-state set
            dup value-literal infer-quot
            terminated? get [ #values node, ] unless
            f
        ] callcc1 nip
    ] make-hash swap recursive-branch ;

: notify-base-case ( -- )
    base-case-continuation get
    [ t swap continue-with ] [ no-base-case ] if* ;

: (infer-branches) ( branchlist -- list )
    [ infer-branch ] map [ ] subset
    dup empty? [ notify-base-case ] when
    dup unify-effects unify-dataflow ;

: infer-branches ( branches node -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again.
    [ >r (infer-branches) r> set-node-children ] keep
    node, #merge node, ;
