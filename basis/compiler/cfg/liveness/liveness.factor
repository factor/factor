! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces deques accessors sets sequences assocs fry
dlists compiler.cfg.def-use ;
IN: compiler.cfg.liveness

! This is a backward dataflow analysis. See http://en.wikipedia.org/wiki/Liveness_analysis

! Assoc mapping basic blocks to sets of vregs
SYMBOL: live-ins

: live-in ( basic-block -- set ) live-ins get at ;

! Assoc mapping basic blocks to sets of vregs
SYMBOL: live-outs

: live-out ( basic-block -- set ) live-outs get at ;

SYMBOL: work-list

: add-to-work-list ( basic-blocks -- )
    work-list get '[ _ push-front ] each ;

: map-unique ( seq quot -- assoc )
    map concat unique ; inline

: gen-set ( basic-block -- seq )
    instructions>> [ uses-vregs ] map-unique ;

: kill-set ( basic-block -- seq )
    instructions>> [ defs-vregs ] map-unique ;

: update-live-in ( basic-block -- changed? )
    [
        [ [ gen-set ] [ live-out ] bi assoc-union ]
        [ kill-set ]
        bi assoc-diff
    ] keep live-ins get maybe-set-at ;

: update-live-out ( basic-block -- changed? )
    [ successors>> [ live-in ] map assoc-combine ] keep
    live-outs get maybe-set-at ;

: liveness-step ( basic-block -- )
    dup update-live-out [
        dup update-live-in
        [ predecessors>> add-to-work-list ] [ drop ] if
    ] [ drop ] if ;

: compute-liveness ( rpo -- )
    <hashed-dlist> work-list set
    H{ } clone live-ins set
    H{ } clone live-outs set
    <reversed> add-to-work-list
    work-list get [ liveness-step ] slurp-deque ;