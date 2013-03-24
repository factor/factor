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

GENERIC: handle ( obj -- )

M: live-interval-state handle
    [ start>> deactivate-intervals ]
    [ start>> activate-intervals ]
    [ assign-register ]
    tri ;

: handle-sync-point ( sync-point -- )
    active-intervals get values
    [ [ spill-at-sync-point ] with filter! drop ] with each ;

M: sync-point handle ( sync-point -- )
    [ n>> deactivate-intervals ]
    [ n>> activate-intervals ]
    [ handle-sync-point ]
    tri ;

: smallest-heap ( heap1 heap2 -- heap )
    [ [ heap-peek nip ] bi@ <= ] most ;

:: (allocate-registers-step) ( unhandled-intervals unhandled-sync-points -- )
    {
        { [ unhandled-intervals heap-empty? ] [ unhandled-sync-points ] }
        { [ unhandled-sync-points heap-empty? ] [ unhandled-intervals ] }
        [ unhandled-intervals unhandled-sync-points smallest-heap ]
    } cond heap-pop drop handle ;

: (allocate-registers) ( unhandled-intervals unhandled-sync-points -- )
    2dup [ heap-empty? ] both? [ 2drop ] [
        [ (allocate-registers-step) ]
        [ (allocate-registers) ]
        2bi
    ] if ;

: finish-allocation ( -- )
    active-intervals inactive-intervals
    [ get values [ handled-intervals get push-all ] each ] bi@ ;

: allocate-registers ( live-intervals sync-point machine-registers -- live-intervals )
    init-allocator
    init-unhandled
    unhandled-intervals get unhandled-sync-points get (allocate-registers)
    finish-allocation
    handled-intervals get ;
