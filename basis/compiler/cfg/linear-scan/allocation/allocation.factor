! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs heaps kernel namespaces sequences fry math
math.order combinators arrays sorting compiler.utilities
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation.coalescing
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.allocation

: free-positions ( new -- assoc )
    vreg>> reg-class>> registers get at [ 1/0. ] H{ } map>assoc ;

: add-use-position ( n reg assoc -- ) [ [ min ] when* ] change-at ;

: active-positions ( new assoc -- )
    [ vreg>> active-intervals-for ] dip
    '[ [ 0 ] dip reg>> _ add-use-position ] each ;

: inactive-positions ( new assoc -- )
    [ [ vreg>> inactive-intervals-for ] keep ] dip
    '[
        [ _ relevant-ranges intersect-live-ranges ] [ reg>> ] bi
        _ add-use-position
    ] each ;

: compute-free-pos ( new -- free-pos )
    dup free-positions
    [ inactive-positions ] [ active-positions ] [ nip ] 2tri
    >alist alist-max ;

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
        dup compute-free-pos {
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
