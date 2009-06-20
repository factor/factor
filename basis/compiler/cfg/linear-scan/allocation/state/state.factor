! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators cpu.architecture fry heaps
kernel math namespaces sequences vectors
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.allocation.state

! Mapping from register classes to sequences of machine registers
SYMBOL: registers

! Vector of active live intervals
SYMBOL: active-intervals

: active-intervals-for ( vreg -- seq )
    reg-class>> active-intervals get at ;

: add-active ( live-interval -- )
    dup vreg>> active-intervals-for push ;

: delete-active ( live-interval -- )
    dup vreg>> active-intervals-for delq ;

: assign-free-register ( new registers -- )
    pop >>reg add-active ;

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
    nip add-handled f ;

SYMBOL: check-allocation?

ERROR: register-already-used live-interval ;

: check-activate ( live-interval -- )
    check-allocation? get [
        dup [ reg>> ] [ vreg>> active-intervals-for [ reg>> ] map ] bi member?
        [ register-already-used ] [ drop ] if
    ] [ drop ] if ;

: activate ( n live-interval -- keep? )
    dup check-activate
    nip add-active f ;

: deactivate ( n live-interval -- keep? )
    nip add-inactive f ;

: don't-change ( n live-interval -- keep? ) 2drop t ;

! Moving intervals between active and inactive sets
: process-intervals ( n symbol quots -- )
    ! symbol stores an alist mapping register classes to vectors
    [ get values ] dip '[ [ _ cond ] with filter-here ] with each ; inline

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

CONSTANT: reg-classes { int-regs double-float-regs }

: reg-class-assoc ( quot -- assoc )
    [ reg-classes ] dip { } map>assoc ; inline

SYMBOL: spill-counts

: next-spill-location ( reg-class -- n )
    spill-counts get [ dup 1 + ] change-at ;

: init-allocator ( registers -- )
    registers set
    [ 0 ] reg-class-assoc spill-counts set
    <min-heap> unhandled-intervals set
    [ V{ } clone ] reg-class-assoc active-intervals set
    [ V{ } clone ] reg-class-assoc inactive-intervals set
    V{ } clone handled-intervals set
    -1 progress set ;

: init-unhandled ( live-intervals -- )
    [ [ start>> ] keep ] { } map>assoc
    unhandled-intervals get heap-push-all ;