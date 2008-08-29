! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences sequences.deep combinators fry
classes.algebra namespaces assocs words math math.private
math.partial-dispatch classes classes.tuple classes.tuple.private
definitions stack-checker.state stack-checker.branches
compiler.tree
compiler.tree.intrinsics
compiler.tree.combinators
compiler.tree.propagation.info
compiler.tree.propagation.branches ;
IN: compiler.tree.cleanup

! A phase run after propagation to finish the job, so to speak.
! Codifies speculative inlining decisions, deletes branches
! marked as never taken, and flattens local recursive blocks
! that do not call themselves.

GENERIC: delete-node ( node -- )

M: #call-recursive delete-node
    dup label>> [ [ eq? not ] with filter ] change-calls drop ;

M: #return-recursive delete-node
    label>> f >>return drop ;

M: node delete-node drop ;

: delete-nodes ( nodes -- ) [ delete-node ] each-node ;

GENERIC: cleanup* ( node -- node/nodes )

: cleanup ( nodes -- nodes' )
    #! We don't recurse into children here, instead the methods
    #! do it since the logic is a bit more involved
    [ cleanup* ] map flatten ;

: cleanup-folding? ( #call -- ? )
    node-output-infos dup empty?
    [ drop f ] [ [ literal?>> ] all? ] if ;

: cleanup-folding ( #call -- nodes )
    #! Replace a #call having a known result with a #drop of its
    #! inputs followed by #push nodes for the outputs.
    [ word>> +inlined+ depends-on ]
    [
        [ node-output-infos ] [ out-d>> ] bi
        [ [ literal>> ] dip #push ] 2map
    ]
    [ in-d>> #drop ]
    tri prefix ;

: cleanup-inlining ( #call -- nodes )
    [ dup method>> [ drop ] [ word>> +inlined+ depends-on ] if ]
    [ body>> cleanup ]
    bi ;

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

: eliminate-single-phi ( #phi -- node )
    [ phi-in-d>> first ] [ out-d>> ] bi over [ +bottom+ eq? ] all?
    [ [ drop ] [ [ f swap #push ] map ] bi* ]
    [ #copy ]
    if ;

: eliminate-phi ( #phi -- node )
    live-branches get sift length {
        { 0 [ drop f ] }
        { 1 [ eliminate-single-phi ] }
        [ drop ]
    } case ;

M: #phi cleanup*
    #! Remove #phi function inputs which no longer exist.
    live-branches get
    [ '[ , sift-children ] change-phi-in-d ]
    [ '[ , sift-children ] change-phi-info-d ]
    [ '[ , sift-children ] change-terminated ] tri
    eliminate-phi
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
