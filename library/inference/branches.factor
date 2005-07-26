! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic hashtables interpreter kernel lists math
matrices namespaces prettyprint sequences strings vectors words ;

: computed-value-vector ( n -- vector )
    empty-vector [ drop object <computed> ] map ;

: add-inputs ( count stack -- stack )
    #! Add this many inputs to the given stack.
    [ length - computed-value-vector ] keep append ;

: unify-lengths ( seq -- list )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup max-length swap [ add-inputs ] map-with ;

: unify-results ( seq -- value )
    #! If all values in list are equal, return the value.
    #! Otherwise, unify types.
    dup [ eq? ] fiber?
    [ first ]
    [ [ value-class ] map class-or-list <computed> ] ifte ;

: unify-stacks ( seq -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    unify-lengths seq-transpose [ unify-results ] map ;

: balanced? ( in out -- ? )
    swap [ length ] map swap [ length ] map v- [ = ] fiber? ;

: unify-effect ( in out -- in out )
    2dup balanced?
    [ unify-stacks >r unify-stacks r> ]
    [ "Unbalanced branches" inference-error ] ifte ;

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
    filter-terminators [
        dup datastack-effect callstack-effect
    ] [
        terminate
    ] ifte* ;

: unify-dataflow ( effects -- nodes )
    [ [ dataflow-graph get ] bind ] map ;

: clone-values ( seq -- seq ) [ clone-value ] map ;

: copy-inference ( -- )
    #! We avoid cloning the same object more than once in order
    #! to preserve identity structure.
    cloned off
    meta-r [ clone-values ] change
    meta-d [ clone-values ] change
    d-in [ clone-values ] change
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
        active? [
            #values node,
            handle-terminator
        ] [
            drop
        ] ifte
    ] extend ;

: (infer-branches) ( branchlist -- list )
    [ infer-branch ] map dup unify-effects unify-dataflow ;

: infer-branches ( branches node -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again.
    [ >r (infer-branches) r> set-node-children ] keep node, ;

\ ifte [
    2 #drop node, pop-d pop-d swap 2list
    #ifte pop-d drop infer-branches
] "infer" set-word-prop

: vtable>list ( rstate vtable -- list  )
    [ swap <literal> ] map-with >list ;

USE: kernel-internals

\ dispatch [
    pop-literal vtable>list
    #dispatch pop-d drop infer-branches
] "infer" set-word-prop
