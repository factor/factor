! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: arrays errors generic hashtables interpreter kernel math
namespaces parser prettyprint sequences strings vectors words ;

: unify-lengths ( seq -- newseq )
    dup [ length ] map supremum
    swap [ add-inputs nip ] map-with ;

: unify-values ( seq -- value )
    dup all-eq? [ first ] [ drop <computed> ] if ;

: unify-stacks ( seq -- stack ) flip [ unify-values ] map ;

: balanced? ( in out -- ? )
    [ dup [ length - ] [ 2drop f ] if ] 2map
    [ ] subset all-equal? ;

TUPLE: unbalanced-branches-error in out ;

: unbalanced-branches-error ( in out -- * )
    <unbalanced-branches-error> inference-error ;

: unify-inputs ( max-d-in d-in meta-d -- meta-d )
    dup [
        [ >r - r> length + ] keep add-inputs nip
    ] [
        2nip
    ] if ;

: unify-effect ( in out -- newin newout )
    #! in is a sequence of integers, out is a sequence of
    #! stacks.
    2dup balanced? [
        over supremum -rot
        [ >r dupd r> unify-inputs ] 2map
        [ ] subset unify-stacks
    ] [
        unbalanced-branches-error
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

: infer-branch ( value -- namespace )
    [
        copy-inference
        dup value-recursion recursive-state set
        value-literal infer-quot
        terminated? get [ #values node, ] unless
    ] make-hash ;

: (infer-branches) ( branchlist -- list )
    [ infer-branch ] map dup unify-effects unify-dataflow ;

: infer-branches ( branches node -- )
    [ >r (infer-branches) r> set-node-children ] keep
    node, #merge node, ;
