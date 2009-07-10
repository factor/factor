! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators fry hints kernel locals
math sequences sets sorting splitting namespaces
combinators.short-circuit compiler.utilities
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.allocation.spilling

ERROR: bad-live-ranges interval ;

: check-ranges ( live-interval -- )
    check-allocation? get [
        dup ranges>> [ [ from>> ] [ to>> ] bi <= ] all?
        [ drop ] [ bad-live-ranges ] if
    ] [ drop ] if ;

: trim-before-ranges ( live-interval -- )
    [ ranges>> ] [ uses>> last ] bi
    [ '[ from>> _ <= ] filter-here ]
    [ swap last (>>to) ]
    2bi ;

: trim-after-ranges ( live-interval -- )
    [ ranges>> ] [ uses>> first ] bi
    [ '[ to>> _ >= ] filter-here ]
    [ swap first (>>from) ]
    2bi ;

: split-for-spill ( live-interval n -- before after )
    split-interval
    {
        [ [ trim-before-ranges ] [ trim-after-ranges ] bi* ]
        [ [ compute-start/end ] bi@ ]
        [ [ check-ranges ] bi@ ]
        [ ]
    } 2cleave ;

: assign-spill ( live-interval -- )
    dup assign-spill-slot >>spill-to f >>split-next drop ;

: assign-reload ( live-interval -- )
    dup assign-spill-slot >>reload-from drop ;

: split-and-spill ( live-interval n -- before after )
    split-for-spill 2dup [ assign-spill ] [ assign-reload ] bi* ;

: find-use-position ( live-interval new -- n )
    [ uses>> ] [ start>> '[ _ >= ] ] bi* find nip 1/0. or ;

: find-use-positions ( live-intervals new assoc -- )
    '[ [ _ find-use-position ] [ reg>> ] bi _ add-use-position ] each ;

: active-positions ( new assoc -- )
    [ [ vreg>> active-intervals-for ] keep ] dip
    find-use-positions ;

: inactive-positions ( new assoc -- )
    [
        [ vreg>> inactive-intervals-for ] keep
        [ '[ _ intervals-intersect? ] filter ] keep
    ] dip
    find-use-positions ;

: spill-status ( new -- use-pos )
    H{ } clone
    [ inactive-positions ] [ active-positions ] [ nip ] 2tri
    >alist alist-max ;

: spill-new? ( new pair -- ? )
    [ uses>> first ] [ second ] bi* > ;

: spill-new ( new pair -- )
    drop
    {
        [ trim-after-ranges ]
        [ compute-start/end ]
        [ assign-reload ]
        [ add-unhandled ]
    } cleave ;

: spill-live-out? ( live-interval n -- ? ) [ uses>> last ] dip < ;

: spill-live-out ( live-interval -- )
    ! The interval has no more usages after the spill location.  This
    !  means it is the first child of an interval that was split.  We
    ! spill the value and let the resolve pass insert a reload later.
    {
        [ trim-before-ranges ]
        [ compute-start/end ]
        [ assign-spill ]
        [ add-handled ]
    } cleave ;

: spill-live-in? ( live-interval n -- ? ) [ uses>> first ] dip > ;

: spill-live-in ( live-interval -- )
    ! The interval does not have any usages before the spill location.
    !  This means it is the second child of an interval that was
    ! split.  We reload the value and let the resolve pass insert a
    ! split later.
    {
        [ trim-after-ranges ]
        [ compute-start/end ]
        [ assign-reload ]
        [ add-unhandled ]
    } cleave ;

: spill ( live-interval n -- )
    {
        { [ 2dup spill-live-out? ] [ drop spill-live-out ] }
        { [ 2dup spill-live-in? ] [ drop spill-live-in ] }
        [ split-and-spill [ add-handled ] [ add-unhandled ] bi* ]
    } cond ;

:: spill-intersecting-active ( new reg -- )
    ! If there is an active interval using 'reg' (there should be at
    ! most one) are split and spilled and removed from the inactive
    ! set.
    new vreg>> active-intervals-for [ [ reg>> reg = ] find swap dup ] keep
    '[ _ delete-nth new start>> spill ] [ 2drop ] if ;

:: spill-intersecting-inactive ( new reg -- )
    ! Any inactive intervals using 'reg' are split and spilled
    ! and removed from the inactive set.
    new vreg>> inactive-intervals-for [
        dup reg>> reg = [
            dup new intervals-intersect? [
                new start>> spill f
            ] [ drop t ] if
        ] [ drop t ] if
    ] filter-here ;

: spill-intersecting ( new reg -- )
    ! Split and spill all active and inactive intervals
    ! which intersect 'new' and use 'reg'.
    [ spill-intersecting-active ]
    [ spill-intersecting-inactive ]
    2bi ;

: spill-available ( new pair -- )
    ! A register would become fully available if all
    ! active and inactive intervals using it were split
    ! and spilled.
    [ first spill-intersecting ] [ register-available ] 2bi ;

: spill-partially-available ( new pair -- )
    ! A register would be available for part of the new
    ! interval's lifetime if all active and inactive intervals
    ! using that register were split and spilled.
    [ second 1 - split-and-spill add-unhandled ] keep
    spill-available ;

: assign-blocked-register ( new -- )
    dup spill-status {
        { [ 2dup spill-new? ] [ spill-new ] }
        { [ 2dup register-available? ] [ spill-available ] }
        [ spill-partially-available ]
    } cond ;