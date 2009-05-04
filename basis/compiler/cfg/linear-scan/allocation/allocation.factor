! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences math math.order kernel assocs
accessors vectors fry heaps cpu.architecture combinators
compiler.cfg.registers
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.allocation

! Mapping from register classes to sequences of machine registers
SYMBOL: free-registers

: free-registers-for ( vreg -- seq )
    reg-class>> free-registers get at ;

: deallocate-register ( live-interval -- )
    [ reg>> ] [ vreg>> ] bi free-registers-for push ;

! Vector of active live intervals
SYMBOL: active-intervals

: active-intervals-for ( vreg -- seq )
    reg-class>> active-intervals get at ;

: add-active ( live-interval -- )
    dup vreg>> active-intervals-for push ;

: delete-active ( live-interval -- )
    dup vreg>> active-intervals-for delq ;

: expire-old-intervals ( n -- )
    active-intervals swap '[
        [
            [ end>> _ < ] partition
            [ [ deallocate-register ] each ] dip
        ] assoc-map
    ] change ;

! Minheap of live intervals which still need a register allocation
SYMBOL: unhandled-intervals

! Start index of current live interval. We ensure that all
! live intervals added to the unhandled set have a start index
! strictly greater than ths one. This ensures that we can catch
! infinite loop situations.
SYMBOL: progress

: check-progress ( live-interval -- )
    start>> progress get <= [ "No progress" throw ] when ; inline

: add-unhandled ( live-interval -- )
    [ check-progress ]
    [ dup start>> unhandled-intervals get heap-push ]
    bi ;

: init-unhandled ( live-intervals -- )
    [ [ start>> ] keep ] { } map>assoc
    unhandled-intervals get heap-push-all ;

! Coalescing
: active-interval ( vreg -- live-interval )
    dup [ dup active-intervals-for [ vreg>> = ] with find nip ] when ;

: coalesce? ( live-interval -- ? )
    [ start>> ] [ copy-from>> active-interval ] bi
    dup [ end>> = ] [ 2drop f ] if ;

: coalesce ( live-interval -- )
    dup copy-from>> active-interval
    [ [ add-active ] [ delete-active ] bi* ]
    [ reg>> >>reg drop ]
    2bi ;

! Splitting
: find-use ( live-interval n quot -- i elt )
    [ uses>> ] 2dip curry find ; inline

: split-before ( live-interval i -- before )
    [ clone dup uses>> ] dip
    [ head >>uses ] [ 1- swap nth >>end ] 2bi ;

: split-after ( live-interval i -- after )
    [ clone dup uses>> ] dip
    [ tail >>uses ] [ swap nth >>start ] 2bi
    f >>reg f >>copy-from ;

: split-interval ( live-interval n -- before after )
    [ drop ] [ [ > ] find-use drop ] 2bi
    [ split-before ] [ split-after ] 2bi ;

: record-split ( live-interval before after -- )
    [ >>split-before ] [ >>split-after ] bi* drop ;

! Spilling
SYMBOL: spill-counts

: next-spill-location ( reg-class -- n )
    spill-counts get [ dup 1+ ] change-at ;

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
    dup rot start>> split-interval
    [ record-split ] [ assign-spill ] 2bi ;

: reuse-register ( new existing -- )
    reg>> >>reg add-active ;

: spill-existing ( new existing -- )
    #! Our new interval will be used before the active interval
    #! with the most distant use location. Spill the existing
    #! interval, then process the new interval and the tail end
    #! of the existing interval again.
    [ reuse-register ]
    [ nip delete-active ]
    [ split-and-spill [ drop ] [ add-unhandled ] bi* ] 2tri ;

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

: assign-free-register ( new registers -- )
    pop >>reg add-active ;

: assign-register ( new -- )
    dup coalesce? [
        coalesce
    ] [
        dup vreg>> free-registers-for
        [ assign-blocked-register ]
        [ assign-free-register ]
        if-empty
    ] if ;

! Main loop
: reg-classes ( -- seq ) { int-regs double-float-regs } ; inline

: init-allocator ( registers -- )
    <min-heap> unhandled-intervals set
    [ reverse >vector ] assoc-map free-registers set
    reg-classes [ 0 ] { } map>assoc spill-counts set
    reg-classes [ V{ } clone ] { } map>assoc active-intervals set
    -1 progress set ;

: handle-interval ( live-interval -- )
    [ start>> progress set ]
    [ start>> expire-old-intervals ]
    [ assign-register ]
    tri ;

: (allocate-registers) ( -- )
    unhandled-intervals get [ handle-interval ] slurp-heap ;

: allocate-registers ( live-intervals machine-registers -- live-intervals )
    #! This modifies the input live-intervals.
    init-allocator
    dup init-unhandled
    (allocate-registers) ;
