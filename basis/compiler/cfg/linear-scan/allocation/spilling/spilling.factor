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
    dup vreg>> assign-spill-slot >>spill-to drop ;

: assign-reload ( live-interval -- )
    dup vreg>> assign-spill-slot >>reload-from drop ;

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

: split-intersecting? ( live-interval new reg -- ? )
    { [ [ drop reg>> ] dip = ] [ drop intervals-intersect? ] } 3&& ;

: split-live-out ( live-interval -- )
    {
        [ trim-before-ranges ]
        [ compute-start/end ]
        [ assign-spill ]
        [ add-handled ]
    } cleave ;

: split-live-in ( live-interval -- )
    {
        [ trim-after-ranges ]
        [ compute-start/end ]
        [ assign-reload ]
        [ add-unhandled ]
    } cleave ;

: (split-intersecting) ( live-interval new -- )
    start>> {
        { [ 2dup [ uses>> last ] dip < ] [ drop split-live-out ] }
        { [ 2dup [ uses>> first ] dip > ] [ drop split-live-in ] }
        [ split-and-spill [ add-handled ] [ add-unhandled ] bi* ]
    } cond ;

: (split-intersecting-active) ( active new -- )
    [ drop delete-active ]
    [ (split-intersecting) ] 2bi ;

: split-intersecting-active ( new reg -- )
    [ [ vreg>> active-intervals-for ] keep ] dip
    [ '[ _ _ split-intersecting? ] filter ] 2keep drop
    '[ _ (split-intersecting-active) ] each ;

: (split-intersecting-inactive) ( inactive new -- )
    [ drop delete-inactive ]
    [ (split-intersecting) ] 2bi ;

: split-intersecting-inactive ( new reg -- )
    [ [ vreg>> inactive-intervals-for ] keep ] dip
    [ '[ _ _ split-intersecting? ] filter ] 2keep drop
    '[ _ (split-intersecting-inactive) ] each ;

: split-intersecting ( new reg -- )
    [ split-intersecting-active ]
    [ split-intersecting-inactive ]
    2bi ;

: spill-available ( new pair -- )
    [ first split-intersecting ] [ register-available ] 2bi ;

: spill-partially-available ( new pair -- )
    [ second 1 - split-and-spill add-unhandled ] keep
    spill-available ;

: assign-blocked-register ( new -- )
    dup spill-status {
        { [ 2dup spill-new? ] [ spill-new ] }
        { [ 2dup register-available? ] [ spill-available ] }
        [ spill-partially-available ]
    } cond ;