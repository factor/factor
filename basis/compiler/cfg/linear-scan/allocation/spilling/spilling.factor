! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators fry hints kernel locals
math sequences sets sorting splitting compiler.utilities namespaces
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.allocation.spilling

: find-use ( live-interval n quot -- elt )
    [ uses>> ] 2dip curry find nip ; inline

: interval-to-spill ( active-intervals current -- live-interval )
    #! We spill the interval with the most distant use location.
    #! If an active interval has no more use positions, find-use
    #! returns f. This occurs if the interval is a split. In
    #! this case, we prefer to spill this interval always.
    start>> '[ dup _ [ >= ] find-use 1/0. or ] { } map>assoc
    alist-max first ;

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

: assign-spill ( live-interval -- live-interval )
    dup reload-from>>
    [ dup vreg>> reg-class>> next-spill-location ] unless*
    >>spill-to ;

: assign-reload ( before after -- before after )
    over spill-to>> >>reload-from ;

: split-and-spill ( new existing -- before after )
    swap start>> split-for-spill [ assign-spill ] dip assign-reload ;

: reuse-register ( new existing -- )
    [ nip delete-active ]
    [ reg>> >>reg add-active ] 2bi ;

: spill-existing? ( new existing -- ? )
    #! Test if 'new' will be used before 'existing'.
    over start>> '[ _ [ > ] find-use -1 or ] bi@ < ;

: spill-existing ( new existing -- )
    #! Our new interval will be used before the active interval
    #! with the most distant use location. Spill the existing
    #! interval, then process the new interval and the tail end
    #! of the existing interval again.
    [ reuse-register ]
    [ split-and-spill [ add-handled ] [ add-unhandled ] bi* ] 2bi ;

: spill-live-out? ( new existing -- ? )
    [ start>> ] [ uses>> last ] bi* > ;

: spill-live-out ( new existing -- )
    #! The existing interval is never used again. Spill it and
    #! re-use the register.
    assign-spill
    [ reuse-register ]
    [ nip add-handled ] 2bi ;

: spill-new ( new existing -- )
    #! Our new interval will be used after the active interval
    #! with the most distant use location. Split the new
    #! interval, then process both parts of the new interval
    #! again.
    [ dup split-and-spill add-unhandled ] dip spill-existing ;

: assign-blocked-register ( new -- )
    [ dup vreg>> active-intervals-for ] keep interval-to-spill {
        { [ 2dup spill-live-out? ] [ spill-live-out ] }
        { [ 2dup spill-existing? ] [ spill-existing ] }
        [ spill-new ]
    } cond ;

