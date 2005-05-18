! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel lists math namespaces
sequences strings vectors words hashtables prettyprint ;

: longest ( list -- length )
    0 swap [ length max ] each ;

: computed-value-vector ( n -- vector )
    [ drop object <computed> ] project >vector ;

: add-inputs ( count stack -- stack )
    #! Add this many inputs to the given stack.
    [ length - computed-value-vector ] keep append ;

: unify-lengths ( list -- list )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup longest swap [ add-inputs ] map-with ;

: unify-results ( list -- value )
    #! If all values in list are equal, return the value.
    #! Otherwise, unify types.
    dup all=? [
        car
    ] [
        [ value-class ] map class-or-list <computed>
    ] ifte ;

: vector-transpose ( list -- vector )
    #! Turn a list of same-length vectors into a vector of lists.
    dup car length [
        over [ nth ] map-with
    ] project >vector nip ;

: unify-stacks ( list -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    unify-lengths vector-transpose [ unify-results ] map ; 

: balanced? ( list -- ? )
    #! Check if a list of [[ instack outstack ]] pairs is
    #! balanced.
    [ uncons length swap length - ] map all=? ;

: unify-effect ( list -- in out )
    #! Unify a list of [[ instack outstack ]] pairs.
    dup balanced? [
        unzip unify-stacks >r unify-stacks r>
    ] [
        "Unbalanced branches" inference-error
    ] ifte ;

: datastack-effect ( list -- )
    [ [ effect ] bind ] map
    unify-effect
    meta-d set d-in set ;

: callstack-effect ( list -- )
    [ [ { } meta-r get ] bind cons ] map
    unify-effect
    meta-r set drop ;

: filter-terminators ( list -- list )
    #! Remove branches that unconditionally throw errors.
    [ [ active? ] bind ] subset ;

: unify-effects ( list -- )
    filter-terminators [
        dup datastack-effect callstack-effect
    ] [
        terminate
    ] ifte* ;

: unify-dataflow ( effects -- nodes )
    [ [ dataflow-graph get ] bind ] map ;

: deep-clone ( seq -- seq ) [ clone ] map ;

: copy-inference ( -- )
    #! We avoid cloning the same object more than once in order
    #! to preserve identity structure.
    meta-r [ deep-clone ] change
    meta-d [ deep-clone ] change
    d-in [ deep-clone ] change
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
    [
        [
            inferring-base-case get [
                [ infer-branch , ] [ [ drop ] when ] catch
            ] [
                infer-branch ,
            ] ifte
        ] each
    ] make-list ;

: infer-branches ( branches node -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again.
    [
        >r (infer-branches) dup unify-effects unify-dataflow
        r> set-node-children
    ] keep node, ;

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

\ dispatch [ [ fixnum vector ] [ ] ] "infer-effect" set-word-prop
