! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs heaps kernel namespaces sequences
compiler.cfg.linear-scan.allocation.coalescing
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.allocation

: assign-register ( new -- )
    dup coalesce? [ coalesce ] [
        dup vreg>> free-registers-for [
            dup intersecting-inactive
            [ assign-blocked-register ]
            [ assign-inactive-register ]
            if-empty
        ] [ assign-free-register ]
        if-empty
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
