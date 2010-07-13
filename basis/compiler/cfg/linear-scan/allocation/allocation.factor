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

: handle-interval ( live-interval -- )
    [ start>> deactivate-intervals ]
    [ start>> activate-intervals ]
    [ assign-register ]
    tri ;

: (handle-sync-point) ( sync-point -- )
    active-intervals get values
    [ [ spill-at-sync-point ] with filter! drop ] with each ;

: handle-sync-point ( sync-point -- )
    [ n>> deactivate-intervals ]
    [ (handle-sync-point) ]
    [ n>> activate-intervals ]
    tri ;

:: (allocate-registers-step) ( unhandled-intervals unhandled-sync-points -- )
    {
        {
            [ unhandled-intervals heap-empty? ]
            [ unhandled-sync-points heap-pop drop handle-sync-point ]
        }
        {
            [ unhandled-sync-points heap-empty? ]
            [ unhandled-intervals heap-pop drop handle-interval ]
        }
        [
            unhandled-intervals heap-peek :> ( i ik )
            unhandled-sync-points heap-peek :> ( s sk )
            {
                {
                    [ ik sk < ]
                    [ unhandled-intervals heap-pop* i handle-interval ]
                }
                {
                    [ ik sk > ]
                    [ unhandled-sync-points heap-pop* s handle-sync-point ]
                }
                [
                    unhandled-intervals heap-pop*
                    i handle-interval
                    s (handle-sync-point)
                ]
            } cond
        ]
    } cond ;

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
