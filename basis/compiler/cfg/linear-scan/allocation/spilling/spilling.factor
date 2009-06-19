! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators fry hints kernel locals
math sequences sets sorting splitting
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.allocation.spilling

: split-for-spill ( live-interval n -- before after )
    split-interval
    [
        [ [ ranges>> last ] [ uses>> last ] bi >>to drop ]
        [ [ ranges>> first ] [ uses>> first ] bi >>from drop ] bi*
    ]
    [ [ compute-start/end ] bi@ ]
    [ ]
    2tri ;

: find-use ( live-interval n quot -- i elt )
    [ uses>> ] 2dip curry find ; inline

: interval-to-spill ( active-intervals current -- live-interval )
    #! We spill the interval with the most distant use location.
    start>> '[ dup _ [ >= ] find-use nip ] { } map>assoc
    [ ] [ [ [ second ] bi@ > ] most ] map-reduce first ;

: assign-spill ( before after -- before after )
    #! If it has been spilled already, reuse spill location.
    over reload-from>>
    [ over vreg>> reg-class>> next-spill-location ] unless*
    [ >>spill-to ] [ >>reload-from ] bi-curry bi* ;

: split-and-spill ( new existing -- before after )
    swap start>> split-for-spill assign-spill ;

: spill-existing ( new existing -- )
    #! Our new interval will be used before the active interval
    #! with the most distant use location. Spill the existing
    #! interval, then process the new interval and the tail end
    #! of the existing interval again.
    [ reg>> >>reg add-active ]
    [ [ add-handled ] [ delete-active ] bi* ]
    [ split-and-spill [ add-handled ] [ add-unhandled ] bi* ] 2tri ;

: spill-new ( new existing -- )
    #! Our new interval will be used after the active interval
    #! with the most distant use location. Split the new
    #! interval, then process both parts of the new interval
    #! again.
    [ dup split-and-spill add-unhandled ] dip spill-existing ;

: spill-existing? ( new existing -- ? )
    #! Test if 'new' will be used before 'existing'.
    over start>> '[ _ [ > ] find-use nip -1 or ] bi@ < ;

: assign-blocked-register ( new -- )
    [ dup vreg>> active-intervals-for ] keep interval-to-spill
    2dup spill-existing? [ spill-existing ] [ spill-new ] if ;

