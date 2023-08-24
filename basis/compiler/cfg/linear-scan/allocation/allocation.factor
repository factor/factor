! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.utilities heaps
kernel namespaces sequences ;
IN: compiler.cfg.linear-scan.allocation

: active-positions ( new assoc -- )
    swap active-intervals-for [ reg>> 0 2array ] map assoc-union! drop ;

: inactive-positions ( new assoc -- )
    [ [ inactive-intervals-for ] keep ] dip
    '[
        [ _ intersect-intervals 1/0. or ] [ reg>> ] bi
        _ add-use-position
    ] each ;

: free-positions ( registers reg-class -- avail-registers )
    of [ 1/0. 2array ] map ;

: register-status ( new registers -- free-pos )
    over interval-reg-class free-positions [
        [ inactive-positions ] [ active-positions ] 2bi
    ] keep alist-max ;

: assign-register ( new registers -- )
    dupd register-status {
        { [ dup second 0 = ] [ drop assign-blocked-register ] }
        { [ 2dup register-available? ] [ register-available ] }
        [ drop assign-blocked-register ]
    } cond ;

: spill-at-sync-point? ( sync-point live-interval -- ? )
    {
        [ drop keep-dst?>> not ]
        [ [ n>> ] dip find-use [ def-rep>> ] ?call not ]
    } 2|| ;

: spill-at-sync-point ( sync-point live-interval -- ? )
    2dup spill-at-sync-point?
    [ swap n>> spill f ] [ 2drop t ] if ;

GENERIC: handle ( obj -- )

M: live-interval-state handle
    [
        live-interval-start
        [ deactivate-intervals ] [ activate-intervals ] bi
    ]
    [ registers get assign-register ] bi ;

: handle-sync-point ( sync-point active-intervals -- )
    values [ [ spill-at-sync-point ] with filter! drop ] with each ;

M: sync-point handle ( sync-point -- )
    [ n>> [ deactivate-intervals ] [ activate-intervals ] bi ]
    [ active-intervals get handle-sync-point ] bi ;

: (allocate-registers) ( unhandled-min-heap -- )
    [ drop handle ] slurp-heap ;

: gather-intervals ( -- live-intervals )
    handled-intervals get
    active-intervals inactive-intervals [ get values concat ] bi@ 3append ;

: allocate-registers ( intervals/sync-points registers -- live-intervals' )
    init-allocator unhandled-min-heap get (allocate-registers)
    gather-intervals ;
