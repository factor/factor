! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.ranges compiler.utilities kernel
linked-assocs math namespaces sequences ;
IN: compiler.cfg.linear-scan.allocation.spilling

: trim-before-ranges ( live-interval -- )
    dup last-use n>> 1 + swap [ fix-upper-bound ] change-ranges drop ;

: trim-after-ranges ( live-interval -- )
    dup first-use n>> swap [ fix-lower-bound ] change-ranges drop ;

: last-use-rep ( live-interval -- rep )
    last-use { [ def-rep>> ] [ use-rep>> ] } 1|| ; inline

: assign-spill ( live-interval -- )
    dup last-use-rep dup [
        >>spill-rep
        dup [ vreg>> ] [ spill-rep>> ] bi
        assign-spill-slot >>spill-to drop
    ] [ 2drop ] if ;

ERROR: bad-live-ranges interval ;

: check-ranges ( ranges -- )
    check-allocation? get [
        dup ranges>> valid-ranges? [ drop ] [ bad-live-ranges ] if
    ] [ drop ] if ;

: spill-before ( before -- before/f )
    dup uses>> empty? [ drop f ] [
        {
            [ ]
            [ assign-spill ]
            [ trim-before-ranges ]
            [ check-ranges ]
        } cleave
    ] if ;

: first-use-rep ( live-interval -- rep/f )
    first-use use-rep>> ; inline

: assign-reload ( live-interval -- )
    dup first-use-rep dup [
        >>reload-rep
        dup [ vreg>> ] [ reload-rep>> ] bi
        assign-spill-slot >>reload-from drop
    ] [ 2drop ] if ;

: spill-after ( after -- after/f )
    dup uses>> empty? [ drop f ] [
        {
            [ ]
            [ assign-reload ]
            [ trim-after-ranges ]
            [ check-ranges ]
        } cleave
    ] if ;

: split-for-spill ( live-interval n -- before/f after/f )
    split-interval [ spill-before ] [ spill-after ] bi* ;

: find-next-use ( live-interval new -- n )
    [ uses>> ] [ live-interval-start ] bi*
    '[ [ spill-slot?>> not ] [ n>> ] bi _ >= and ] find nip
    [ n>> ] [ 1/0. ] if* ;

: find-use-positions ( live-intervals new assoc -- )
    '[ [ _ find-next-use ] [ reg>> ] bi _ add-use-position ] each ;

: active-positions ( new assoc -- )
    [ [ active-intervals-for ] keep ] dip
    find-use-positions ;

: inactive-positions ( new assoc -- )
    [
        [ inactive-intervals-for ] keep
        [ '[ _ intervals-intersect? ] filter ] keep
    ] dip
    find-use-positions ;

: spill-status ( new -- use-pos )
    <linked-hash>
    [ inactive-positions ] [ active-positions ] [ nip ] 2tri
    >alist alist-max ;

: spill-new? ( new pair -- ? )
    [ first-use n>> ] [ second ] bi* > ;

: spill-new ( new pair -- )
    drop spill-after add-unhandled ;

: spill ( live-interval n -- )
    split-for-spill
    [ [ add-handled ] when* ] [ [ add-unhandled ] when* ] bi* ;

:: spill-intersecting-active ( new reg -- )
    new active-intervals-for [ [ reg>> reg = ] find swap dup ] keep
    '[ _ remove-nth! drop new live-interval-start spill ] [ 2drop ] if ;

:: spill-intersecting-inactive ( new reg -- )
    new inactive-intervals-for [
        dup reg>> reg = [
            dup new intervals-intersect? [
                new live-interval-start spill f
            ] [ drop t ] if
        ] [ drop t ] if
    ] filter! drop ;

: spill-intersecting ( new reg -- )
    [ spill-intersecting-active ]
    [ spill-intersecting-inactive ]
    2bi ;

: spill-available ( new pair -- )
    [ first spill-intersecting ] [ register-available ] 2bi ;

: spill-partially-available ( new pair -- )
    [ second 1 - split-for-spill [ add-unhandled ] when* ] keep
    '[ _ spill-available ] when* ;

: assign-blocked-register ( live-interval -- )
    dup spill-status {
        { [ 2dup spill-new? ] [ spill-new ] }
        { [ 2dup register-available? ] [ spill-available ] }
        [ spill-partially-available ]
    } cond ;
