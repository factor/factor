! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel lists math namespaces
strings vectors words hashtables prettyprint ;

: longest-vector ( list -- length )
    [ vector-length ] map [ > ] top ;

: computed-value-vector ( n -- vector )
    [ drop object <computed> ] vector-project ;

: add-inputs ( count stack -- stack )
    #! Add this many inputs to the given stack.
    [ vector-length - computed-value-vector ] keep
    vector-append ;

: unify-lengths ( list -- list )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup longest-vector swap [ add-inputs ] map-with ;

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
    dup car vector-length [
        over [ vector-nth ] map-with
    ] vector-project nip ;

: unify-stacks ( list -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    unify-lengths vector-transpose [ unify-results ] vector-map ; 

: balanced? ( list -- ? )
    #! Check if a list of [[ instack outstack ]] pairs is
    #! balanced.
    [ uncons vector-length swap vector-length - ] map all=? ;

: unify-effect ( list -- in out )
    #! Unify a list of [[ instack outstack ]] pairs.
    dup balanced? [
        unzip unify-stacks >r unify-stacks r>
    ] [
        "Unbalanced branches" throw
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
    [ [ d-in get meta-d get and ] bind ] subset [
        "No branch has a stack effect" throw
    ] unless* ;

: unify-effects ( list -- )
    filter-terminators dup datastack-effect callstack-effect ;

SYMBOL: cloned

: deep-clone ( obj -- obj )
    #! Clone an object if it hasn't already been cloned in this
    #! with-deep-clone scope.
    dup cloned get assoc [
        clone [ dup cloned [ acons ] change ] keep
    ] ?unless ;

: deep-clone-vector ( vector -- vector )
    #! Clone a vector of vectors.
    [ deep-clone ] vector-map ;

: copy-inference ( -- )
    #! We avoid cloning the same object more than once in order
    #! to preserve identity structure.
    cloned off
    meta-r [ deep-clone-vector ] change
    meta-d [ deep-clone-vector ] change
    d-in [ deep-clone-vector ] change
    dataflow-graph off ;

: terminator? ( obj -- ? )
    dup word? [ "terminator" word-property ] [ drop f ] ifte ;

: handle-terminator ( quot -- )
    [ terminator? ] some? [
        meta-d off meta-r off d-in off
    ] when ;

: propagate-type ( [[ value class ]] -- )
    #! Type propagation is chained.
    [
        unswons 2dup set-value-class
        value-type-prop assoc propagate-type
    ] when* ;

: infer-branch ( value -- namespace )
    <namespace> [
        uncons propagate-type
        dup value-recursion recursive-state set
        copy-inference
        literal-value dup infer-quot
        #values values-node
        handle-terminator
    ] extend ;

: (infer-branches) ( branchlist -- list )
    #! The branchlist is a list of pairs: [[ value typeprop ]]
    #! value is either a literal or computed instance; typeprop
    #! is a pair [[ value class ]] indicating a type propagation
    #! for the given branch.
    [
        [
            branches-can-fail? [
                [ infer-branch , ] [ [ drop ] when ] catch
            ] [
                infer-branch ,
            ] ifte
        ] each
    ] make-list ;

: unify-dataflow ( inputs instruction effectlist -- )
    [ [ get-dataflow ] bind ] map
    swap dataflow, [ node-consume-d set ] bind ;

: infer-branches ( inputs instruction branchlist -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again. The inputs
    #! parameter is a vector.
    (infer-branches) dup unify-effects unify-dataflow ;

: (with-block) ( label quot -- node )
    #! Call a quotation in a new namespace, and transfer
    #! inference state from the outer scope.
    swap >r [
        dataflow-graph off
        call
        d-in get meta-d get meta-r get get-dataflow
    ] with-scope
    r> swap #label dataflow, [ node-label set ] extend >r
    meta-r set meta-d set d-in set r> ;

: boolean-value? ( value -- ? )
    #! Return if the value's boolean valuation is known.
    value-class
    dup \ f = swap
    builtin-supertypes
    \ f builtin-supertypes intersection not
    or ;

: boolean-value ( value -- ? )
    #! Only valid if boolean? returns true.
    value-class \ f = not ;

: static-branch? ( value -- ? )
    drop f ;
!    boolean-value? branches-can-fail? not and ;

: static-ifte ( true false -- )
    #! If the branch taken is statically known, just infer
    #! along that branch.
    dataflow-drop, pop-d boolean-value [ drop ] [ nip ] ifte
    gensym [
        dup value-recursion recursive-state set
        literal-value infer-quot
    ] (with-block) drop ;

: dynamic-ifte ( true false -- )
    #! If branch taken is computed, infer along both paths and
    #! unify.
    2list >r 1 meta-d get vector-tail* \ ifte r>
    pop-d [
        dup \ general-t cons ,
        \ f cons ,
    ] make-list zip ( condition )
    infer-branches ;

: infer-ifte ( -- )
    #! Infer effects for both branches, unify.
    [ object general-list general-list ] ensure-d
    dataflow-drop, pop-d
    dataflow-drop, pop-d swap
    peek-d static-branch? [
        static-ifte
    ] [
        dynamic-ifte
    ] ifte ;

\ ifte [ infer-ifte ] "infer" set-word-property

: vtable>list ( value -- list )
    dup value-recursion swap literal-value vector>list
    [ over <literal> ] map nip ;

USE: kernel-internals
: infer-dispatch ( -- )
    #! Infer effects for all branches, unify.
    [ object vector ] ensure-d
    dataflow-drop, pop-d vtable>list
    >r 1 meta-d get vector-tail* \ dispatch r>
    pop-d ( n ) num-types [ dupd cons ] project nip zip
    infer-branches ;

\ dispatch [ infer-dispatch ] "infer" set-word-property
\ dispatch [ [ fixnum vector ] [ ] ]
"infer-effect" set-word-property
