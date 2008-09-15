! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences math math.order kernel assocs
accessors vectors fry heaps
compiler.cfg.linear-scan.live-intervals
compiler.backend ;
IN: compiler.cfg.linear-scan.allocation

! Mapping from register classes to sequences of machine registers
SYMBOL: free-registers

: free-registers-for ( vreg -- seq )
    reg-class>> free-registers get at ;

: deallocate-register ( live-interval -- )
    [ reg>> ] [ vreg>> ] bi free-registers-for push ;

! Vector of active live intervals
SYMBOL: active-intervals

: add-active ( live-interval -- )
    active-intervals get push ;

: delete-active ( live-interval -- )
    active-intervals get delete ;

: expire-old-intervals ( n -- )
    active-intervals get
    swap '[ end>> _ < ] partition
    active-intervals set
    [ deallocate-register ] each ;

: expire-old-uses ( n -- )
    active-intervals get
    swap '[ uses>> dup peek _ < [ pop* ] [ drop ] if ] each ;

: update-state ( live-interval -- )
    start>> [ expire-old-intervals ] [ expire-old-uses ] bi ;

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

: assign-free-register ( live-interval registers -- )
    #! If the live interval does not have any uses, it means it
    #! will be spilled immediately, so it still needs a register
    #! to compute the new value, but we don't add the interval
    #! to the active set and we don't remove the register from
    #! the free list.
    over uses>> empty?
    [ peek >>reg drop ] [ pop >>reg add-active ] if ;

! Spilling
SYMBOL: spill-counter

: next-spill-location ( -- n )
    spill-counter [ dup 1+ ] change ;

: interval-to-spill ( -- live-interval )
    #! We spill the interval with the most distant use location.
    active-intervals get unclip-slice [
        [ [ uses>> peek ] bi@ > ] most
    ] reduce ;

: check-split ( live-interval -- )
    [ start>> ] [ end>> ] bi = [ "Cannot split any further" throw ] when ;

: split-interval ( live-interval -- before after )
    #! Split the live interval at the location of its first use.
    #! 'Before' now starts and ends on the same instruction.
    [ check-split ]
    [ clone [ uses>> delete-all ] [ dup start>> >>end ] bi ]
    [ clone f >>reg dup uses>> peek >>start ]
    tri ;

: record-split ( live-interval before after -- )
    [ >>split-before ] [ >>split-after ] bi* drop ;

: assign-spill ( before after -- before after )
    #! If it has been spilled already, reuse spill location.
    over reload-from>> [ next-spill-location ] unless*
    tuck [ >>spill-to ] [ >>reload-from ] 2bi* ;

: split-and-spill ( live-interval -- before after )
    dup split-interval [ record-split ] [ assign-spill ] 2bi ;

: reuse-register ( new existing -- )
    reg>> >>reg
    dup uses>> empty? [ deallocate-register ] [ add-active ] if ;

: spill-existing ( new existing -- )
    #! Our new interval will be used before the active interval
    #! with the most distant use location. Spill the existing
    #! interval, then process the new interval and the tail end
    #! of the existing interval again.
    [ reuse-register ]
    [ delete-active ]
    [ split-and-spill [ drop ] [ add-unhandled ] bi* ] tri ;

: spill-new ( new existing -- )
    #! Our new interval will be used after the active interval
    #! with the most distant use location. Split the new
    #! interval, then process both parts of the new interval
    #! again.
    [ split-and-spill add-unhandled ] dip spill-existing ;

: spill-existing? ( new existing -- ? )
    over uses>> empty? [ 2drop t ] [ [ uses>> peek ] bi@ < ] if ;

: assign-blocked-register ( live-interval -- )
    interval-to-spill
    2dup spill-existing?
    [ spill-existing ] [ spill-new ] if ;

: assign-register ( live-interval -- )
    dup vreg>> free-registers-for [
        assign-blocked-register
    ] [
        assign-free-register
    ] if-empty ;

! Main loop
: init-allocator ( registers -- )
    V{ } clone active-intervals set
    <min-heap> unhandled-intervals set
    [ >vector ] assoc-map free-registers set
    0 spill-counter set
    -1 progress set ;

: handle-interval ( live-interval -- )
    [ start>> progress set ] [ update-state ] [ assign-register ] tri ;

: (allocate-registers) ( -- )
    unhandled-intervals get [ handle-interval ] slurp-heap ;

: allocate-registers ( live-intervals machine-registers -- )
    #! This modifies the input live-intervals.
    [
        init-allocator
        init-unhandled
        (allocate-registers)
    ] with-scope ;
