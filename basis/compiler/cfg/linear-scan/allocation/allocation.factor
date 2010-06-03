! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs binary-search combinators
combinators.short-circuit heaps kernel namespaces
sequences fry locals math math.order arrays sorting
compiler.utilities
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.allocation

: active-positions ( new assoc -- )
    [ active-intervals-for ] dip
    '[ [ 0 ] dip reg>> _ add-use-position ] each ;

: inactive-positions ( new assoc -- )
    [ [ inactive-intervals-for ] keep ] dip
    '[
        [ _ relevant-ranges intersect-live-ranges 1/0. or ] [ reg>> ] bi
        _ add-use-position
    ] each ;

: register-status ( new -- free-pos )
    dup free-positions
    [ inactive-positions ] [ active-positions ] [ nip ] 2tri
    >alist alist-max ;

: no-free-registers? ( result -- ? )
    second 0 = ; inline

: assign-register ( new -- )
    dup register-status {
        { [ dup no-free-registers? ] [ drop assign-blocked-register ] }
        { [ 2dup register-available? ] [ register-available ] }
        [ drop assign-blocked-register ]
    } cond ;

: spill-at-sync-point? ( sync-point live-interval -- ? )
    ! If the live interval has a definition at a keep-dst?
    ! sync-point, don't spill.
    {
        [ drop keep-dst?>> not ]
        [ [ n>> ] dip find-use dup [ def-rep>> ] when not ]
    } 2|| ;

: spill-at-sync-point ( sync-point live-interval -- ? )
    2dup spill-at-sync-point?
    [ swap n>> spill f ] [ 2drop t ] if ;

GENERIC: handle-progress* ( obj -- )

M: live-interval handle-progress* drop ;

M: sync-point handle-progress*
    active-intervals get values
    [ [ spill-at-sync-point ] with filter! drop ] with each ;

:: handle-progress ( n obj -- )
    n progress set
    n deactivate-intervals
    obj handle-progress*
    n activate-intervals ;

GENERIC: handle ( obj -- )

M: live-interval handle ( live-interval -- )
    [ [ start>> ] keep handle-progress ] [ assign-register ] bi ;

M: sync-point handle ( sync-point -- )
    [ n>> ] keep handle-progress ;

: smallest-heap ( heap1 heap2 -- heap )
    ! If heap1 and heap2 have the same key, favors heap1.
    {
        { [ dup heap-empty? ] [ drop ] }
        { [ over heap-empty? ] [ nip ] }
        [ [ [ heap-peek nip ] bi@ <= ] most ]
    } cond ;

: (allocate-registers) ( -- )
    unhandled-intervals get unhandled-sync-points get smallest-heap
    dup heap-empty? [ drop ] [ heap-pop drop handle (allocate-registers) ] if ;

: finish-allocation ( -- )
    active-intervals inactive-intervals
    [ get values [ handled-intervals get push-all ] each ] bi@ ;

: allocate-registers ( live-intervals sync-point machine-registers -- live-intervals )
    init-allocator
    init-unhandled
    (allocate-registers)
    finish-allocation
    handled-intervals get ;
