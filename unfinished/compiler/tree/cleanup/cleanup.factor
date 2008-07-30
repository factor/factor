! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sequences.deep combinators fry
classes.algebra namespaces assocs math math.private
math.partial-dispatch
compiler.tree
compiler.tree.combinators
compiler.tree.propagation.info
compiler.tree.propagation.branches ;
IN: compiler.tree.cleanup

! A phase run after propagation to finish the job, so to speak.
! Codifies speculative inlining decisions, deletes branches
! marked as never taken, and flattens local recursive blocks
! that do not call themselves.

GENERIC: cleanup* ( node -- node/nodes )

: cleanup ( nodes -- nodes' )
    #! We don't recurse into children here, instead the methods
    #! do it since the logic is a bit more involved
    [ cleanup* ] map flatten ;

: cleanup-folding? ( #call -- ? )
    node-output-infos [ literal?>> ] all? ;

: cleanup-folding ( #call -- nodes )
    #! Replace a #call having a known result with a #drop of its
    #! inputs followed by #push nodes for the outputs.
    [
        [ node-output-infos ] [ out-d>> ] bi
        [ [ literal>> ] dip #push ] 2map
    ]
    [ in-d>> #drop ] bi prefix ;

: cleanup-inlining ( #call -- nodes )
    body>> cleanup ;

! Removing overflow checks
: no-overflow-variant ( op -- fast-op )
    H{
        { fixnum+ fixnum+fast }
        { fixnum- fixnum-fast }
        { fixnum* fixnum*fast }
        { fixnum-shift fixnum-shift-fast }
    } at ;

: remove-overflow-check? ( #call -- ? )
    dup word>> no-overflow-variant
    [ node-output-infos first class>> fixnum class<= ] [ drop f ] if ;

: remove-overflow-check ( #call -- #call )
    [ in-d>> ] [ out-d>> ] [ word>> no-overflow-variant ] tri #call cleanup* ;

M: #call cleanup*
    {
        { [ dup body>> ] [ cleanup-inlining ] }
        { [ dup cleanup-folding? ] [ cleanup-folding ] }
        { [ dup remove-overflow-check? ] [ remove-overflow-check ] }
        [ ]
    } cond ;

GENERIC: delete-node ( node -- )

M: #call-recursive delete-node
    dup label>> [ [ eq? not ] with filter ] change-calls drop ;

M: #return-recursive delete-node
    label>> f >>return drop ;

M: node delete-node drop ;

: delete-nodes ( nodes -- ) [ delete-node ] each-node ;

: delete-unreachable-branches ( #branch -- )
    dup live-branches>> '[
        ,
        [ [ [ drop ] [ delete-nodes ] if ] 2each ]
        [ select-children ]
        2bi
    ] change-children drop ;

: fold-only-branch ( #branch -- node/nodes )
    #! If only one branch is live we don't need to branch at
    #! all; just drop the condition value.
    dup live-children sift dup length 1 =
    [ first swap in-d>> #drop prefix ] [ drop ] if ;

SYMBOL: live-branches

: cleanup-children ( #branch -- )
    [ [ cleanup ] map ] change-children drop ;

M: #branch cleanup*
    {
        [ live-branches>> live-branches set ]
        [ delete-unreachable-branches ]
        [ cleanup-children ]
        [ fold-only-branch ]
    } cleave ;

: cleanup-phi-in ( phi-in live-branches -- phi-in' )
    swap dup empty?
    [ nip ] [ flip swap select-children sift flip ] if ;

M: #phi cleanup*
    #! Remove #phi function inputs which no longer exist.
    live-branches get {
        [ '[ , cleanup-phi-in ] change-phi-in-d ]
        [ '[ , cleanup-phi-in ] change-phi-in-r ]
        [ '[ , cleanup-phi-in ] change-phi-info-d ]
        [ '[ , cleanup-phi-in ] change-phi-info-r ]
    } cleave ;

: >copy ( node -- #copy ) [ in-d>> ] [ out-d>> ] bi #copy ;

: flatten-recursive ( #recursive -- nodes )
    #! convert #enter-recursive and #return-recursive into
    #! #copy nodes.
    child>>
    unclip >copy prefix
    unclip-last >copy suffix ;

M: #recursive cleanup*
    #! Inline bodies of #recursive blocks with no calls left.
    [ cleanup ] change-child
    dup label>> calls>> empty? [ flatten-recursive ] when ;

M: node cleanup* ;
