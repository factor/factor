! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: arrays errors generic hashtables interpreter kernel math
namespaces parser prettyprint sequences strings vectors words ;

: unify-lengths ( seq -- seq )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup 0 [ length max ] reduce swap [ add-inputs ] map-with ;

: unify-length ( seq seq -- seq )
    2array unify-lengths first2 ;

: unify-values ( seq -- value )
    #! If all values in list are equal, return the value.
    #! Otherwise, unify.
    dup all-eq? [ first ] [ drop <value> ] ifte ;

: unify-stacks ( seq -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    [ ] subset dup empty?
    [ drop f ] [ unify-lengths flip [ unify-values ] map ] ifte ;

: balanced? ( in out -- ? )
    [ dup [ length - ] [ 2drop f ] ifte ] 2map
    [ ] subset all-equal? ;

: unify-in-d ( seq -- n )
    #! Input is a sequence of positive integers or f.
    #! Output is the maximum or 0.
    0 [ [ max ] when* ] reduce ;

: unbalanced-branches ( in out -- )
    { "Unbalanced branches:" } -rot [
        swap number>string " " rot length number>string
        append3
    ] 2map append "\n" join inference-error ;

: unify-effect ( in out -- in out )
    #! In is a sequence of integers; out is a sequence of stacks.
    2dup balanced? [
        unify-stacks >r unify-in-d r>
    ] [
        unbalanced-branches
    ] ifte ;

: datastack-effect ( seq -- )
    dup [ d-in swap hash ] map
    swap [ meta-d swap hash ] map
    unify-effect
    meta-d set d-in set ;

: callstack-effect ( seq -- )
    dup length 0 <repeated>
    swap [ meta-r swap hash ] map
    unify-effect
    meta-r set drop ;

: filter-terminators ( seq -- seq )
    #! Remove branches that unconditionally throw errors.
    [ [ active? ] bind ] subset ;

: unify-effects ( seq -- )
    dup datastack-effect callstack-effect ;

: unify-dataflow ( effects -- nodes )
    [ [ dataflow-graph get ] bind ] map ;

: copy-inference ( -- )
    meta-r [ clone ] change
    meta-d [ clone ] change
    d-in [ ] change
    dataflow-graph off
    current-node off ;

: infer-branch ( value -- namespace )
    #! Return a namespace with inferencer variables:
    #! meta-d, meta-r, d-in. They are set to f if
    #! terminate was called.
    [
        [
            base-case-continuation set
            copy-inference
            dup value-recursion recursive-state set
            dup literal-value infer-quot
            active? [ #values node, ] when
            f
        ] callcc1 [ terminate ] when drop
    ] make-hash ;

: (infer-branches) ( branchlist -- list )
    [ infer-branch ] map dup unify-effects unify-dataflow ;

: infer-branches ( branches node -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again.
    [ >r (infer-branches) r> set-node-children ] keep
    node, #merge node, ;
