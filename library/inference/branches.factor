! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic hashtables interpreter kernel lists math
namespaces prettyprint sequences strings unparser vectors words ;

: unify-lengths ( seq -- seq )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup max-length swap
    [ [ required-inputs ] keep append ] map-with ;

: flatten-values ( seq -- seq )
    [
        [
            dup meet? [
                meet-values [ unique, ] each
            ] [
                unique,
            ] ifte
        ] each
    ] make-vector ;

: unify-values ( seq -- value )
    #! If all values in list are equal, return the value.
    #! Otherwise, unify.
    dup [ eq? ] every? [ first ] [ <meet> ] ifte ;

: unify-stacks ( seq -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    unify-lengths flip [ flatten-values unify-values ] map ;

: balanced? ( in out -- ? )
    [ swap length swap length - ] 2map [ = ] every? ;

: unify-effect ( in out -- in out )
    2dup balanced?
    [ unify-stacks >r unify-stacks r> ]
    [
        { "Unbalanced branches:" } -rot [
            swap length unparse " " rot length unparse append3
        ] 2map append "\n" join inference-error
    ] ifte ;

: datastack-effect ( seq -- )
    dup [ d-in swap hash ] map
    swap [ meta-d swap hash ] map
    unify-effect
    meta-d set d-in set ;

: callstack-effect ( seq -- )
    dup length { } <repeated>
    swap [ meta-r swap hash ] map
    unify-effect
    meta-r set drop ;

: filter-terminators ( seq -- seq )
    #! Remove branches that unconditionally throw errors.
    [ [ active? ] bind ] subset ;

: unify-effects ( seq -- )
    filter-terminators dup empty?
    [ drop terminate ]
    [ dup datastack-effect callstack-effect ] ifte ;

: unify-dataflow ( effects -- nodes )
    [ [ dataflow-graph get ] bind ] map ;

: copy-inference ( -- )
    #! We avoid cloning the same object more than once in order
    #! to preserve identity structure.
    meta-r [ clone ] change
    meta-d [ clone ] change
    d-in [ clone ] change
    dataflow-graph off
    current-node off ;

: infer-branch ( value -- namespace )
    #! Return a namespace with inferencer variables:
    #! meta-d, meta-r, d-in. They are set to f if
    #! terminate was called.
    <namespace> [
        copy-inference
        dup value-recursion recursive-state set
        literal-value dup infer-quot
        active? [ #values node, handle-terminator ] [ drop ] ifte
    ] extend ;

: (infer-branches) ( branchlist -- list )
    [ infer-branch ] map dup unify-effects
    unify-dataflow ;

: infer-branches ( branches node -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again.
    [ >r (infer-branches) r> set-node-children ] keep
    node, meta-d get >list #merge node, ;

\ ifte [
    2 #drop node, pop-d pop-d swap 2vector
    #ifte pop-d drop infer-branches
] "infer" set-word-prop

USE: kernel-internals

\ dispatch [
    pop-literal nip [ <literal> ] map
    #dispatch pop-d drop infer-branches
] "infer" set-word-prop
