! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs heaps kernel namespaces sequences fry math
combinators arrays sorting
compiler.cfg.linear-scan.allocation.coalescing
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.allocation

: relevant-ranges ( new inactive -- new' inactive' )
    ! Slice off all ranges of 'inactive' that precede the start of 'new'
    [ [ ranges>> ] bi@ ] [ nip start>> ] 2bi '[ to>> _ >= ] filter ;

: intersect-live-range ( range1 range2 -- n/f )
    2dup [ from>> ] bi@ > [ swap ] when
    2dup [ to>> ] [ from>> ] bi* >= [ nip from>> ] [ 2drop f ] if ;

: intersect-live-ranges ( ranges1 ranges2 -- n )
    {
        { [ over empty? ] [ 2drop 1/0. ] }
        { [ dup empty? ] [ 2drop 1/0. ] }
        [
            2dup [ first ] bi@ intersect-live-range dup [ 2nip ] [
                drop
                2dup [ first from>> ] bi@ <
                [ [ rest-slice ] dip ] [ rest-slice ] if
                intersect-live-ranges
            ] if
        ]
    } cond ;

: intersect-inactive ( new inactive -- n )
    relevant-ranges intersect-live-ranges ;

: compute-free-pos ( new -- free-pos )
    dup vreg>>
    [ nip reg-class>> registers get at [ 1/0. ] H{ } map>assoc ]
    [ inactive-intervals-for [ [ reg>> swap ] keep intersect-inactive ] with H{ } map>assoc ]
    [ nip active-intervals-for [ reg>> 0 ] H{ } map>assoc ]
    2tri 3array assoc-combine
    >alist sort-values ;

: no-free-registers? ( result -- ? )
    second 0 = ; inline

: register-available? ( new result -- ? )
    [ end>> ] [ second ] bi* < ; inline

: register-available ( new result -- )
    first >>reg add-active ;

: register-partially-available ( new result -- )
    [ second split-before-use ] keep
    '[ _ register-available ] [ add-unhandled ] bi* ;

: assign-register ( new -- )
    dup coalesce? [ coalesce ] [
        dup compute-free-pos last {
            { [ dup no-free-registers? ] [ drop assign-blocked-register ] }
            { [ 2dup register-available? ] [ register-available ] }
            [ register-partially-available ]
        } cond
    ] if ;

: handle-interval ( live-interval -- )
    [
        start>>
        [ progress set ]
        [ deactivate-intervals ]
        [ activate-intervals ] tri
    ] [ assign-register ] bi ;

: (allocate-registers) ( -- )
    unhandled-intervals get [ handle-interval ] slurp-heap ;

: finish-allocation ( -- )
    active-intervals inactive-intervals
    [ get values [ handled-intervals get push-all ] each ] bi@ ;

: allocate-registers ( live-intervals machine-registers -- live-intervals )
    init-allocator
    init-unhandled
    (allocate-registers)
    finish-allocation
    handled-intervals get ;
