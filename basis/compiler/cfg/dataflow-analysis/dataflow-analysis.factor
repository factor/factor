! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs deques dlists kernel locals sequences lexer
namespaces functors compiler.cfg.rpo compiler.cfg.utilities
compiler.cfg.predecessors compiler.cfg ;
IN: compiler.cfg.dataflow-analysis

GENERIC: join-sets ( sets bb dfa -- set )
GENERIC: transfer-set ( in-set bb dfa -- out-set )
GENERIC: block-order ( cfg dfa -- bbs )
GENERIC: successors ( bb dfa -- seq )
GENERIC: predecessors ( bb dfa -- seq )

<PRIVATE

MIXIN: dataflow-analysis

: <dfa-worklist> ( cfg dfa -- queue )
    block-order <hashed-dlist> [ push-all-front ] keep ;

:: compute-in-set ( bb out-sets dfa -- set )
    ! Only consider initialized sets.
    bb kill-block?>> [ f ] [
        bb dfa predecessors
        [ out-sets key? ] filter
        [ out-sets at ] map
        bb dfa join-sets
    ] if ;

:: update-in-set ( bb in-sets out-sets dfa -- ? )
    bb out-sets dfa compute-in-set
    bb in-sets maybe-set-at ; inline

:: compute-out-set ( bb in-sets dfa -- set )
    bb kill-block?>> [ f ] [ bb in-sets at bb dfa transfer-set ] if ;

:: update-out-set ( bb in-sets out-sets dfa -- ? )
    bb in-sets dfa compute-out-set
    bb out-sets maybe-set-at ; inline

:: dfa-step ( bb in-sets out-sets dfa work-list -- )
    bb in-sets out-sets dfa update-in-set [
        bb in-sets out-sets dfa update-out-set [
            bb dfa successors work-list push-all-front
        ] when
    ] when ; inline

:: run-dataflow-analysis ( cfg dfa -- in-sets out-sets )
    cfg needs-predecessors drop
    H{ } clone :> in-sets
    H{ } clone :> out-sets
    cfg dfa <dfa-worklist> :> work-list
    work-list [ in-sets out-sets dfa work-list dfa-step ] slurp-deque
    in-sets
    out-sets ; inline

M: dataflow-analysis join-sets 2drop assoc-refine ;

FUNCTOR: define-analysis ( name -- )

name-analysis DEFINES-CLASS ${name}-analysis
name-ins DEFINES ${name}-ins
name-outs DEFINES ${name}-outs
name-in DEFINES ${name}-in
name-out DEFINES ${name}-out

WHERE

SINGLETON: name-analysis

SYMBOL: name-ins

: name-in ( bb -- set ) name-ins get at ;

SYMBOL: name-outs

: name-out ( bb -- set ) name-outs get at ;

;FUNCTOR

! ! ! Forward dataflow analysis

MIXIN: forward-analysis
INSTANCE: forward-analysis dataflow-analysis

M: forward-analysis block-order  drop reverse-post-order ;
M: forward-analysis successors   drop successors>> ;
M: forward-analysis predecessors drop predecessors>> ;

FUNCTOR: define-forward-analysis ( name -- )

name-analysis IS ${name}-analysis
name-ins IS ${name}-ins
name-outs IS ${name}-outs
compute-name-sets DEFINES compute-${name}-sets

WHERE

INSTANCE: name-analysis forward-analysis

: compute-name-sets ( cfg -- )
    name-analysis run-dataflow-analysis
    [ name-ins set ] [ name-outs set ] bi* ;

;FUNCTOR

! ! ! Backward dataflow analysis

MIXIN: backward-analysis
INSTANCE: backward-analysis dataflow-analysis

M: backward-analysis block-order  drop post-order ;
M: backward-analysis successors   drop predecessors>> ;
M: backward-analysis predecessors drop successors>> ;

FUNCTOR: define-backward-analysis ( name -- )

name-analysis IS ${name}-analysis
name-ins IS ${name}-ins
name-outs IS ${name}-outs
compute-name-sets DEFINES compute-${name}-sets

WHERE

INSTANCE: name-analysis backward-analysis

: compute-name-sets ( cfg -- )
    \ name-analysis run-dataflow-analysis
    [ name-outs set ] [ name-ins set ] bi* ;

;FUNCTOR

PRIVATE>

SYNTAX: FORWARD-ANALYSIS:
    scan [ define-analysis ] [ define-forward-analysis ] bi ;

SYNTAX: BACKWARD-ANALYSIS:
    scan [ define-analysis ] [ define-backward-analysis ] bi ;
