! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs heaps kernel namespaces sequences fry math
math.order combinators arrays sorting compiler.utilities locals
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.allocation

: active-positions ( new assoc -- )
    [ vreg>> active-intervals-for ] dip
    '[ [ 0 ] dip reg>> _ add-use-position ] each ;

: inactive-positions ( new assoc -- )
    [ [ vreg>> inactive-intervals-for ] keep ] dip
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

: spill-at-sync-point ( live-interval n -- ? )
    ! If the live interval has a usage at 'n', don't spill it,
    ! since this means its being defined by the sync point
    ! instruction. Output t if this is the case.
    2dup [ uses>> ] dip swap member? [ 2drop t ] [ spill f ] if ;

: handle-sync-point ( n -- )
    [ active-intervals get values ] dip
    '[ [ _ spill-at-sync-point ] filter! drop ] each ;

:: handle-progress ( n sync? -- )
    n {
        [ progress set ]
        [ deactivate-intervals ]
        [ sync? [ handle-sync-point ] [ drop ] if ]
        [ activate-intervals ]
    } cleave ;

GENERIC: handle ( obj -- )

M: live-interval handle ( live-interval -- )
    [ start>> f handle-progress ] [ assign-register ] bi ;

M: sync-point handle ( sync-point -- )
    n>> t handle-progress ;

: smallest-heap ( heap1 heap2 -- heap )
    ! If heap1 and heap2 have the same key, favors heap1.
    [ [ heap-peek nip ] bi@ <= ] most ;

: (allocate-registers) ( -- )
    {
        { [ unhandled-intervals get heap-empty? ] [ unhandled-sync-points get ] }
        { [ unhandled-sync-points get heap-empty? ] [ unhandled-intervals get ] }
        ! If a live interval begins at the same location as a sync point,
        ! process the sync point before the live interval. This ensures that the
        ! return value of C function calls doesn't get spilled and reloaded
        ! unnecessarily.
        [ unhandled-sync-points get unhandled-intervals get smallest-heap ]
    } cond dup heap-empty? [ drop ] [ heap-pop drop handle (allocate-registers) ] if ;

: finish-allocation ( -- )
    active-intervals inactive-intervals
    [ get values [ handled-intervals get push-all ] each ] bi@ ;

: allocate-registers ( live-intervals sync-point machine-registers -- live-intervals )
    init-allocator
    init-unhandled
    (allocate-registers)
    finish-allocation
    handled-intervals get ;
