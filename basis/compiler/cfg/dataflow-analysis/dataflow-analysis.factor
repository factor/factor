! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit
compiler.cfg.predecessors compiler.cfg.rpo
compiler.cfg.utilities deques dlists functors2 kernel namespaces
sequences strings ;
IN: compiler.cfg.dataflow-analysis

GENERIC: join-sets ( sets bb dfa -- set )
GENERIC: transfer-set ( in-set bb dfa -- out-set )
GENERIC: block-order ( cfg dfa -- bbs )
GENERIC: successors ( bb dfa -- seq )
GENERIC: predecessors ( bb dfa -- seq )
GENERIC: ignore-block? ( bb dfa -- ? )

MIXIN: dataflow-analysis

: <dfa-worklist> ( cfg dfa -- queue )
    block-order <hashed-dlist> [ push-all-front ] keep ;

:: compute-in-set ( bb out-sets dfa -- set )
    ! Only consider initialized sets.
    bb dfa ignore-block? [ f ] [
        bb dfa predecessors
        [ out-sets key? ] filter
        [ out-sets at ] map
        bb dfa join-sets
    ] if ;

:: update-in-set ( bb in-sets out-sets dfa -- ? )
    bb out-sets dfa compute-in-set
    bb in-sets maybe-set-at ; inline

:: compute-out-set ( bb in-sets dfa -- set )
    bb dfa ignore-block? [ f ] [ bb in-sets at bb dfa transfer-set ] if ;

:: update-out-set ( bb in-sets out-sets dfa -- ? )
    bb in-sets dfa compute-out-set
    bb out-sets maybe-set-at ; inline

: update-in/out-set ( bb in-sets out-sets dfa -- ? )
    { [ update-in-set ] [ update-out-set ] } 4 n&& ;

:: dfa-step ( bb in-sets out-sets dfa -- bbs )
    bb in-sets out-sets dfa update-in/out-set bb dfa successors { } ? ;

:: run-dataflow-analysis ( cfg dfa -- in-sets out-sets )
    H{ } clone :> in-sets
    H{ } clone :> out-sets
    cfg needs-predecessors
    cfg dfa <dfa-worklist>
    [ in-sets out-sets dfa dfa-step ] slurp/replenish-deque
    in-sets
    out-sets ; inline

M: dataflow-analysis join-sets 2drop assoc-refine ;
M: dataflow-analysis ignore-block? drop kill-block?>> ;

INLINE-FUNCTOR: dataflow-analysis ( name: name -- ) [[
USING: assocs namespaces ;
SINGLETON: ${name}
SYMBOL: ${name}-ins
: ${name}-in ( bb -- set ) ${name}-ins get at ;
SYMBOL: ${name}-outs
: ${name}-out ( bb -- set ) ${name}-outs get at ;
]]

! ! ! Forward dataflow analysis

MIXIN: forward-analysis
INSTANCE: forward-analysis dataflow-analysis

M: forward-analysis block-order  drop reverse-post-order ;
M: forward-analysis successors   drop successors>> ;
M: forward-analysis predecessors drop predecessors>> ;

INLINE-FUNCTOR: forward-analysis ( name: name -- ) [[
USING: assocs kernel namespaces ;
QUALIFIED: namespaces

DATAFLOW-ANALYSIS: ${name}

INSTANCE: ${name} forward-analysis

: compute-${name}-sets ( cfg -- )
    \ ${name} run-dataflow-analysis
    [ ${name}-ins namespaces:set ] [ ${name}-outs namespaces:set ] bi* ;

]]

! ! ! Backward dataflow analysis

MIXIN: backward-analysis
INSTANCE: backward-analysis dataflow-analysis

M: backward-analysis block-order  drop post-order ;
M: backward-analysis successors   drop predecessors>> ;
M: backward-analysis predecessors drop successors>> ;

INLINE-FUNCTOR: backward-analysis ( name: name -- ) [[
USING: assocs kernel namespaces ;
QUALIFIED: namespaces

DATAFLOW-ANALYSIS: ${name}

INSTANCE: ${name} backward-analysis

: compute-${name}-sets ( cfg -- )
    \ ${name} run-dataflow-analysis
    [ ${name}-outs namespaces:set ] [ ${name}-ins namespaces:set ] bi* ;

]]
