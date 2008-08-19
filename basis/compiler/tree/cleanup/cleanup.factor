! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sequences.deep combinators fry
classes.algebra namespaces assocs math math.private
math.partial-dispatch classes.tuple classes.tuple.private
compiler.tree
compiler.tree.intrinsics
compiler.tree.combinators
compiler.tree.propagation.info
compiler.tree.propagation.branches ;
IN: compiler.tree.cleanup

! A phase run after propagation to finish the job, so to speak.
! Codifies speculative inlining decisions, deletes branches
! marked as never taken, and flattens local recursive blocks
! that do not call themselves. Finally, if inlining inserts a
! #terminate, we delete all nodes after that.

GENERIC: delete-node ( node -- )

M: #call-recursive delete-node
    dup label>> [ [ eq? not ] with filter ] change-calls drop ;

M: #return-recursive delete-node
    label>> f >>return drop ;

M: node delete-node drop ;

: delete-nodes ( nodes -- ) [ delete-node ] each-node ;

GENERIC: cleanup* ( node -- node/nodes )

: termination-cleanup ( nodes -- nodes' )
    dup [ #terminate? ] find drop [ 1+ cut delete-nodes ] when* ;

: cleanup ( nodes -- nodes' )
    #! We don't recurse into children here, instead the methods
    #! do it since the logic is a bit more involved
    [ cleanup* ] map flatten ; ! termination-cleanup ;

: cleanup-folding? ( #call -- ? )
    node-output-infos dup empty?
    [ drop f ] [ [ literal?>> ] all? ] if ;

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

: immutable-tuple-boa? ( #call -- ? )
    dup word>> \ <tuple-boa> eq? [
        dup in-d>> peek node-value-info
        literal>> class>> immutable-tuple-class?
    ] [ drop f ] if ;

: immutable-tuple-boa ( #call -- #call )
    \ <immutable-tuple-boa> >>word ;

M: #call cleanup*
    {
        { [ dup body>> ] [ cleanup-inlining ] }
        { [ dup cleanup-folding? ] [ cleanup-folding ] }
        { [ dup remove-overflow-check? ] [ remove-overflow-check ] }
        { [ dup immutable-tuple-boa? ] [ immutable-tuple-boa ] }
        [ ]
    } cond ;

M: #declare cleanup* drop f ;

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
        [ delete-unreachable-branches ]
        [ cleanup-children ]
        [ fold-only-branch ]
        [ live-branches>> live-branches set ]
    } cleave ;

M: #phi cleanup*
    #! Remove #phi function inputs which no longer exist.
    live-branches get
    [ '[ , select-children sift ] change-phi-in-d ]
    [ '[ , select-children sift ] change-phi-info-d ] bi
    live-branches off ;

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
