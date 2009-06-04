! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences math math.order kernel assocs
accessors vectors fry heaps cpu.architecture sorting locals
combinators compiler.cfg.registers
compiler.cfg.linear-scan.live-intervals hints ;
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

! Vector of inactive live intervals
SYMBOL: inactive-intervals

: inactive-intervals-for ( vreg -- seq )
    reg-class>> inactive-intervals get at ;

: add-inactive ( live-interval -- )
    dup vreg>> inactive-intervals-for push ;

! Vector of handled live intervals
SYMBOL: handled-intervals

: add-handled ( live-interval -- )
    handled-intervals get push ;

: finished? ( n live-interval -- ? ) end>> swap < ;

: finish ( n live-interval -- keep? )
    nip [ deallocate-register ] [ add-handled ] bi f ;

: activate ( n live-interval -- keep? )
    nip add-active f ;

: deactivate ( n live-interval -- keep? )
    nip add-inactive f ;

: don't-change ( n live-interval -- keep? ) 2drop t ;

! Moving intervals between active and inactive sets
: process-intervals ( n symbol quots -- )
    ! symbol stores an alist mapping register classes to vectors
    [ get values ] dip '[ [ _ cond ] with filter-here ] with each ; inline

: covers? ( insn# live-interval -- ? )
    ranges>> [ [ from>> ] [ to>> ] bi between? ] with any? ;

: deactivate-intervals ( n -- )
    ! Any active intervals which have ended are moved to handled
    ! Any active intervals which cover the current position
    ! are moved to inactive
    active-intervals {
        { [ 2dup finished? ] [ finish ] }
        { [ 2dup covers? not ] [ deactivate ] }
        [ don't-change ]
    } process-intervals ;

: activate-intervals ( n -- )
    ! Any inactive intervals which have ended are moved to handled
    ! Any inactive intervals which do not cover the current position
    ! are moved to active
    inactive-intervals {
        { [ 2dup finished? ] [ finish ] }
        { [ 2dup covers? ] [ activate ] }
        [ don't-change ]
    } process-intervals ;

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
    [ [ add-active ] [ [ delete-active ] [ add-handled ] bi ] bi* ]
    [ reg>> >>reg drop ]
    2bi ;

! Splitting
: split-range ( live-range n -- before after )
    [ [ from>> ] dip <live-range> ]
    [ 1 + swap to>> <live-range> ]
    2bi ;

: split-last-range? ( last n -- ? )
    swap to>> <= ;

: split-last-range ( before after last n -- before' after' )
    split-range [ [ but-last ] dip suffix ] [ prefix ] bi-curry* bi* ;

: split-ranges ( live-ranges n -- before after )
    [ '[ from>> _ <= ] partition ]
    [
        pick empty? [ drop ] [
            [ over last ] dip 2dup split-last-range?
            [ split-last-range ] [ 2drop ] if
        ] if
    ] bi ;

: split-uses ( uses n -- before after )
    '[ _ <= ] partition ;

: record-split ( live-interval before after -- )
    [ >>split-before ] [ >>split-after ] bi* drop ; inline

: check-split ( live-interval -- )
    [ end>> ] [ start>> ] bi - 0 =
    [ "BUG: splitting atomic interval" throw ] when ; inline

: split-before ( before -- before' )
    [ [ ranges>> last ] [ uses>> last ] bi >>to drop ]
    [ compute-start/end ]
    [ ]
    tri ; inline

: split-after ( after -- after' )
    [ [ ranges>> first ] [ uses>> first ] bi >>from drop ]
    [ compute-start/end ]
    [ ]
    tri ; inline

:: split-interval ( live-interval n -- before after )
    live-interval check-split
    live-interval clone :> before
    live-interval clone f >>copy-from f >>reg :> after
    live-interval uses>> n split-uses before after [ (>>uses) ] bi-curry@ bi*
    live-interval ranges>> n split-ranges before after [ (>>ranges) ] bi-curry@ bi*
    live-interval before after record-split
    before split-before
    after split-after ;

HINTS: split-interval live-interval object ;

! Spilling
SYMBOL: spill-counts

: next-spill-location ( reg-class -- n )
    spill-counts get [ dup 1+ ] change-at ;

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
    swap start>> split-interval assign-spill ;

: reuse-register ( new existing -- )
    reg>> >>reg add-active ;

: spill-existing ( new existing -- )
    #! Our new interval will be used before the active interval
    #! with the most distant use location. Spill the existing
    #! interval, then process the new interval and the tail end
    #! of the existing interval again.
    [ reuse-register ]
    [ nip delete-active ]
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

: assign-free-register ( new registers -- )
    pop >>reg add-active ;

: next-intersection ( new inactive -- n )
    2drop 0 ;

: intersecting-inactive ( new -- live-intervals )
    dup vreg>> inactive-intervals-for
    [ tuck next-intersection ] with { } map>assoc ;

: fits-in-hole ( new pair -- )
    first reuse-register ;

: split-before-use ( new pair -- before after )
    ! Find optimal split position
    second split-interval ;

: assign-inactive-register ( new live-intervals -- )
    ! If there is an interval which is inactive for the entire lifetime
    ! if the new interval, reuse its vreg. Otherwise, split new so that
    ! the first half fits.
    sort-values last
    2dup [ end>> ] [ second ] bi* < [
        fits-in-hole
    ] [
        [ split-before-use ] keep
       '[ _ fits-in-hole ] [ add-unhandled ] bi*
    ] if ;

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

! Main loop
: reg-classes ( -- seq ) { int-regs double-float-regs } ; inline

: reg-class-assoc ( quot -- assoc )
    [ reg-classes ] dip { } map>assoc ; inline

: init-allocator ( registers -- )
    [ reverse >vector ] assoc-map free-registers set
    [ 0 ] reg-class-assoc spill-counts set
    <min-heap> unhandled-intervals set
    [ V{ } clone ] reg-class-assoc active-intervals set
    [ V{ } clone ] reg-class-assoc inactive-intervals set
    V{ } clone handled-intervals set
    -1 progress set ;

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
    ! Sanity check: all live intervals should've been processed
    active-intervals inactive-intervals
    [ get values [ handled-intervals get push-all ] each ] bi@ ;

: allocate-registers ( live-intervals machine-registers -- live-intervals )
    #! This modifies the input live-intervals.
    init-allocator
    init-unhandled
    (allocate-registers)
    finish-allocation
    handled-intervals get ;
