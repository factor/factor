! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs deques dlists fry kernel namespaces sequences
combinators combinators.short-circuit compiler.cfg.instructions
compiler.cfg.dcn.local compiler.cfg.rpo compiler.cfg.utilities
compiler.cfg ;
IN: compiler.cfg.dcn.global

<PRIVATE

: assoc-refine ( seq -- assoc )
    [ f ] [ [ ] [ assoc-intersect ] map-reduce ] if-empty ;

SYMBOL: work-list

: add-to-work-list ( basic-blocks -- )
    work-list get '[ _ push-front ] each ;

! Peek analysis. Peek-in is the set of all locations anticipated at
! the start of a basic block.
SYMBOLS: peek-ins peek-outs ;

PRIVATE>

: peek-in ( bb -- assoc ) peek-ins get at ;
: peek-out ( bb -- assoc ) peek-outs get at ;

<PRIVATE

GENERIC: compute-peek-in ( bb -- assoc )

M: basic-block compute-peek-in
    [ [ peek-out ] [ replace ] bi assoc-diff ] [ peek ] bi assoc-union ;

M: kill-block compute-peek-in drop f ;

: update-peek-in ( bb -- ? )
    [ compute-peek-in ] keep peek-ins get maybe-set-at ;

GENERIC: compute-peek-out ( bb -- assoc )

M: basic-block compute-peek-out
    successors>> peek-ins get '[ _ at ] map assoc-refine ;

M: kill-block compute-peek-out drop f ;

: update-peek-out ( bb -- ? )
    [ compute-peek-out ] keep peek-outs get maybe-set-at ;

: peek-step ( bb -- )
    dup update-peek-out [
        dup update-peek-in
        [ predecessors>> add-to-work-list ] [ drop ] if
    ] [ drop ] if ;

: compute-peek-sets ( cfg -- )
    H{ } clone peek-ins set
    H{ } clone peek-outs set
    post-order add-to-work-list work-list get [ peek-step ] slurp-deque ;

! Replace analysis. Replace-in is the set of all locations which
! will be overwritten at some point after the start of a basic block.
SYMBOLS: replace-ins replace-outs ;

PRIVATE>

: replace-in ( bb -- assoc ) replace-ins get at ;
: replace-out ( bb -- assoc ) replace-outs get at ;

<PRIVATE

GENERIC: compute-replace-in ( bb -- assoc )

M: basic-block compute-replace-in
    predecessors>> replace-outs get '[ _ at ] map assoc-refine ;

M: kill-block compute-replace-in drop f ;

: update-replace-in ( bb -- ? )
    [ compute-replace-in ] keep replace-ins get maybe-set-at ;

GENERIC: compute-replace-out ( bb -- assoc )

M: basic-block compute-replace-out
    [ replace-in ] [ replace ] bi assoc-union ;

M: kill-block compute-replace-out drop f ;

: update-replace-out ( bb -- ? )
    [ compute-replace-out ] keep replace-outs get maybe-set-at ;

: replace-step ( bb -- )
    dup update-replace-in [
        dup update-replace-out
        [ successors>> add-to-work-list ] [ drop ] if
    ] [ drop ] if ;

: compute-replace-sets ( cfg -- )
    H{ } clone replace-ins set
    H{ } clone replace-outs set
    reverse-post-order add-to-work-list work-list get [ replace-step ] slurp-deque ;

! Availability analysis. Avail-out is the set of all locations
! in registers at the end of a basic block.
SYMBOLS: avail-ins avail-outs ;

PRIVATE>

: avail-in ( bb -- assoc ) avail-ins get at ;
: avail-out ( bb -- assoc ) avail-outs get at ;

<PRIVATE

GENERIC: compute-avail-in ( bb -- assoc )

M: basic-block compute-avail-in
    predecessors>> avail-outs get '[ _ at ] map assoc-refine ;

M: kill-block compute-avail-in drop f ;

: update-avail-in ( bb -- ? )
    [ compute-avail-in ] keep avail-ins get maybe-set-at ;

GENERIC: compute-avail-out ( bb -- assoc )

M: basic-block compute-avail-out
    [ avail-in ] [ peek ] [ replace ] tri assoc-union assoc-union ;

M: kill-block compute-avail-out drop f ;

: update-avail-out ( bb -- ? )
    [ compute-avail-out ] keep avail-outs get maybe-set-at ;

: avail-step ( bb -- )
    dup update-avail-in [
        dup update-avail-out
        [ successors>> add-to-work-list ] [ drop ] if
    ] [ drop ] if ;

: compute-avail-sets ( cfg -- )
    H{ } clone avail-ins set
    H{ } clone avail-outs set
    reverse-post-order add-to-work-list work-list get [ avail-step ] slurp-deque ;

! Kill analysis. Kill-in is the set of all locations
! which are going to be overwritten.
SYMBOLS: kill-ins kill-outs ;

PRIVATE>

: kill-in ( bb -- assoc ) kill-ins get at ;
: kill-out ( bb -- assoc ) kill-outs get at ;

<PRIVATE

GENERIC: compute-kill-in ( bb -- assoc )

M: basic-block compute-kill-in
    [ kill-out ] [ replace ] bi assoc-union ;

M: kill-block compute-kill-in drop f ;

: update-kill-in ( bb -- ? )
    [ compute-kill-in ] keep kill-ins get maybe-set-at ;

GENERIC: compute-kill-out ( bb -- assoc )

M: basic-block compute-kill-out
    successors>> kill-ins get '[ _ at ] map assoc-refine ;

M: kill-block compute-kill-out drop f ;

: update-kill-out ( bb -- ? )
    [ compute-kill-out ] keep kill-outs get maybe-set-at ;

: kill-step ( bb -- )
    dup update-kill-out [
        dup update-kill-in
        [ predecessors>> add-to-work-list ] [ drop ] if
    ] [ drop ] if ;

: compute-kill-sets ( cfg -- )
    H{ } clone kill-ins set
    H{ } clone kill-outs set
    post-order add-to-work-list work-list get [ kill-step ] slurp-deque ;

PRIVATE>

! Main word
: compute-global-sets ( cfg -- )
    <hashed-dlist> work-list set
    {
        [ compute-peek-sets ]
        [ compute-replace-sets ]
        [ compute-avail-sets ]
        [ compute-kill-sets ]
    } cleave ;