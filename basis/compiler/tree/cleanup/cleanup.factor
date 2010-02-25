! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences combinators fry
classes.algebra namespaces assocs words math math.private
math.partial-dispatch math.intervals classes classes.tuple
classes.tuple.private layouts definitions stack-checker.dependencies
stack-checker.branches
compiler.utilities
compiler.tree
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
    dup label>> calls>> [ node>> eq? not ] with filter! drop ;

M: #return-recursive delete-node
    label>> f >>return drop ;

M: node delete-node drop ;

: delete-nodes ( nodes -- ) [ delete-node ] each-node ;

GENERIC: cleanup* ( node -- node/nodes )

: cleanup ( nodes -- nodes' )
    #! We don't recurse into children here, instead the methods
    #! do it since the logic is a bit more involved
    [ cleanup* ] map-flat ;

! Constant folding
: cleanup-folding? ( #call -- ? )
    node-output-infos
    [ f ] [ [ literal?>> ] all? ] if-empty ;

: (cleanup-folding) ( #call -- nodes )
    #! Replace a #call having a known result with a #drop of its
    #! inputs followed by #push nodes for the outputs.
    [
        [ node-output-infos ] [ out-d>> ] bi
        [ [ literal>> ] dip #push ] 2map
    ]
    [ in-d>> #drop ]
    bi prefix ;

: >predicate-folding< ( #call -- value-info class result )
    [ node-input-infos first ]
    [ word>> "predicating" word-prop ]
    [ node-output-infos first literal>> ] tri ;

: record-predicate-folding ( #call -- )
    >predicate-folding< pick literal?>>
    [ [ literal>> ] 2dip depends-on-instance-predicate ]
    [ [ class>> ] 2dip depends-on-class-predicate ]
    if ;

: record-folding ( #call -- )
    dup word>> predicate?
    [ record-predicate-folding ]
    [ word>> depends-on-definition ]
    if ;

: cleanup-folding ( #call -- nodes )
    [ (cleanup-folding) ] [ record-folding ] bi ;

! Method inlining
: add-method-dependency ( #call -- )
    dup method>> word? [
        [ [ class>> ] [ word>> ] bi depends-on-generic ]
        [ [ class>> ] [ word>> ] [ method>> ] tri depends-on-method ]
        bi
    ] [ drop ] if ;

: record-inlining ( #call -- )
    dup method>>
    [ add-method-dependency ]
    [ word>> depends-on-definition ] if ;

: cleanup-inlining ( #call -- nodes )
    [ record-inlining ] [ body>> cleanup ] bi ;

! Removing overflow checks
: (remove-overflow-check?) ( #call -- ? )
    node-output-infos first class>> fixnum class<= ;

: small-shift? ( #call -- ? )
    node-input-infos second interval>>
    cell-bits tag-bits get - [ neg ] keep [a,b] interval-subset? ;

: remove-overflow-check? ( #call -- ? )
    {
        { [ dup word>> \ fixnum-shift eq? ] [ [ (remove-overflow-check?) ] [ small-shift? ] bi and ] }
        { [ dup word>> no-overflow-variant ] [ (remove-overflow-check?) ] }
        [ drop f ]
    } cond ;

: remove-overflow-check ( #call -- #call )
    [ no-overflow-variant ] change-word cleanup* ;

M: #call cleanup*
    {
        { [ dup body>> ] [ cleanup-inlining ] }
        { [ dup cleanup-folding? ] [ cleanup-folding ] }
        { [ dup remove-overflow-check? ] [ remove-overflow-check ] }
        [ ]
    } cond ;

: delete-unreachable-branches ( #branch -- )
    dup live-branches>> '[
        _
        [ [ [ drop ] [ delete-nodes ] if ] 2each ]
        [ select-children ]
        2bi
    ] change-children drop ;

: fold-only-branch ( #branch -- node/nodes )
    #! If only one branch is live we don't need to branch at
    #! all; just drop the condition value.
    dup live-children sift dup length {
        { 0 [ drop in-d>> #drop ] }
        { 1 [ first swap in-d>> #drop prefix ] }
        [ 2drop ]
    } case ;

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

: output-fs ( values -- nodes )
    [ f swap #push ] map ;

: eliminate-single-phi ( #phi -- node )
    [ phi-in-d>> first ] [ out-d>> ] bi over [ +bottom+ eq? ] all?
    [ [ drop ] [ output-fs ] bi* ]
    [ #copy ]
    if ;

: eliminate-phi ( #phi -- node )
    live-branches get sift length {
        { 0 [ out-d>> output-fs ] }
        { 1 [ eliminate-single-phi ] }
        [ drop ]
    } case ;

M: #phi cleanup*
    #! Remove #phi function inputs which no longer exist.
    live-branches get
    [ '[ _ sift-children ] change-phi-in-d ]
    [ '[ _ sift-children ] change-phi-info-d ]
    [ '[ _ sift-children ] change-terminated ] tri
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
