! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: arrays errors generic hashtables assocs kernel math
namespaces parser prettyprint sequences strings vectors words
quotations ;

: unify-lengths ( seq -- newseq )
    dup [ length ] map supremum
    swap [ add-inputs nip ] map-with ;

: unify-values ( seq -- value )
    dup all-eq? [ first ] [ drop <computed> ] if ;

: unify-stacks ( seq -- stack ) flip [ unify-values ] map ;

: balanced? ( in out -- ? )
    [ dup [ length - ] [ 2drop f ] if ] 2map
    [ ] subset all-equal? ;

TUPLE: unbalanced-branches-error quots in out ;

: unbalanced-branches-error ( quots in out -- * )
    <unbalanced-branches-error> inference-error ;

: unify-inputs ( max-d-in d-in meta-d -- meta-d )
    dup [
        [ >r - r> length + ] keep add-inputs nip
    ] [
        2nip
    ] if ;

: unify-effect ( quots in out -- newin newout )
    #! in is a sequence of integers, out is a sequence of
    #! stacks.
    2dup balanced? [
        over supremum -rot
        [ >r dupd r> unify-inputs ] 2map
        [ ] subset unify-stacks
        rot drop
    ] [
        unbalanced-branches-error
    ] if ;

: active-variable ( seq symbol -- seq )
    swap [
        terminated? over at [ 2drop f ] [ at ] if
    ] map-with ;

: branch-variable ( seq symbol -- seq )
    swap [ at ] map-with ;

: datastack-effect ( seq -- )
    dup quotation branch-variable
    over d-in branch-variable
    rot meta-d active-variable
    unify-effect meta-d set d-in set ;

: retainstack-effect ( seq -- )
    dup quotation branch-variable
    over length 0 <array>
    rot meta-r active-variable
    unify-effect meta-r set drop ;

TUPLE: unbalanced-namestacks ;

: unify-namestacks ( seq -- )
    flip
    [ H{ } clone [ dupd update ] reduce ] map
    meta-n set ;

: namestack-effect ( seq -- )
    #! If the namestack is unbalanced, we don't throw an error
    [ meta-n swap at ] map
    dup [ length ] map all-equal? [
        <unbalanced-namestacks> inference-error
    ] unless
    unify-namestacks ;

: unify-vars ( seq -- )
    #! Don't use active-variable here, because we want to
    #! consider variables set right before a throw too
    [ inferred-vars swap at ] map apply-var-seq ;

: unify-effects ( seq -- )
    dup datastack-effect
    dup retainstack-effect
    dup namestack-effect
    dup unify-vars
    [ terminated? swap at ] all? terminated? set ;

: unify-dataflow ( effects -- nodes )
    [ dataflow-graph swap at ] map ;

: copy-inference ( -- )
    meta-d [ clone ] change
    meta-r [ clone ] change
    meta-n [ [ clone ] map ] change
    inferred-vars [ clone ] change
    d-in [ ] change
    dataflow-graph off
    current-node off ;

: infer-branch ( last value -- namespace )
    [
        copy-inference
        dup value-recursion recursive-state set
        dup value-literal quotation set
        value-literal infer-quot
        terminated? get [ drop ] [ call node, ] if
    ] H{ } make-assoc ; inline

: (infer-branches) ( last branches -- list )
    [ infer-branch ] map-with
    dup unify-effects unify-dataflow ; inline

: infer-branches ( last branches node -- )
    #! last is a quotation which provides a #return or a #values
    dup node,
    >r (infer-branches) r> set-node-children
    #merge node, ; inline
