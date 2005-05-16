! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel lists math namespaces
sequences strings vectors words hashtables prettyprint ;

: longest ( list -- length )
    0 swap [ length max ] each ;

: computed-value-vector ( n -- vector )
    [ drop object <computed> ] vector-project ;

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
    ] vector-project nip ;

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

SYMBOL: cloned

: deep-clone ( obj -- obj )
    #! Clone an object if it hasn't already been cloned in this
    #! with-deep-clone scope.
    dup cloned get assq [ ] [
        dup clone [ swap cloned [ acons ] change ] keep
    ] ?ifte ;

: deep-clone-seq ( seq -- seq )
    #! Clone a sequence and each object it contains.
    [ deep-clone ] map ;

: copy-inference ( -- )
    #! We avoid cloning the same object more than once in order
    #! to preserve identity structure.
    cloned off
    meta-r [ deep-clone-seq ] change
    meta-d [ deep-clone-seq ] change
    d-in [ deep-clone-seq ] change
    dataflow-graph off ;

: infer-branch ( value -- namespace )
    #! Return a namespace with inferencer variables:
    #! meta-d, meta-r, d-in. They are set to f if
    #! terminate was called.
    <namespace> [
        uncons pull-tie
        dup value-recursion recursive-state set
        copy-inference
        literal-value dup infer-quot
        active? [
            #values values-node
            handle-terminator
        ] [
            drop
        ] ifte
    ] extend ;

: (infer-branches) ( branchlist -- list )
    #! The branchlist is a list of pairs: [[ value typeprop ]]
    #! value is either a literal or computed instance; typeprop
    #! is a pair [[ value class ]] indicating a type propagation
    #! for the given branch.
    [
        [
            inferring-base-case get [
                [ infer-branch , ] [ [ drop ] when ] catch
            ] [
                infer-branch ,
            ] ifte
        ] each
    ] make-list ;

: unify-dataflow ( input instruction effectlist -- )
    [ [ get-dataflow ] bind ] map
    swap dataflow, [ unit node-consume-d set ] bind ;

: infer-branches ( input instruction branchlist -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again.
    (infer-branches) dup unify-effects unify-dataflow ;

: infer-ifte ( true false -- )
    #! If branch taken is computed, infer along both paths and
    #! unify.
    2list >r pop-d \ ifte r>
    pick [ general-t POSTPONE: f ] [ <class-tie> ] map-with
    zip ( condition )
    infer-branches ;

\ ifte [
    2 dataflow-drop, pop-d pop-d swap infer-ifte
] "infer" set-word-prop

: vtable>list ( rstate vtable -- list  )
    [ swap <literal> ] map-with >list ;

: <dispatch-index> ( value -- value )
    value-literal-ties
    0 recursive-state get <literal>
    [ set-value-literal-ties ] keep ;

USE: kernel-internals

: infer-dispatch ( rstate vtable -- )
    >r >r peek-d \ dispatch r> r>
    vtable>list
    pop-d <dispatch-index>
    over length [ <literal-tie> ] project-with
    zip infer-branches ;

\ dispatch [ pop-literal infer-dispatch ] "infer" set-word-prop
\ dispatch [ [ fixnum vector ] [ ] ] "infer-effect" set-word-prop
