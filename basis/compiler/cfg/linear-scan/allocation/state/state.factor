! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators cpu.architecture fry heaps
kernel math math.order namespaces sequences vectors
compiler.cfg.linear-scan.live-intervals ;
IN: compiler.cfg.linear-scan.allocation.state

! Start index of current live interval. We ensure that all
! live intervals added to the unhandled set have a start index
! strictly greater than this one. This ensures that we can catch
! infinite loop situations. We also ensure that all live
! intervals added to the handled set have an end index strictly
! smaller than this one. This helps catch bugs.
SYMBOL: progress

: check-unhandled ( live-interval -- )
    start>> progress get <= [ "check-unhandled" throw ] when ; inline

: check-handled ( live-interval -- )
    end>> progress get > [ "check-handled" throw ] when ; inline

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

: delete-inactive ( live-interval -- )
    dup vreg>> inactive-intervals-for delq ;

! Vector of handled live intervals
SYMBOL: handled-intervals

: add-handled ( live-interval -- )
    [ check-handled ] [ handled-intervals get push ] bi ;

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

: add-unhandled ( live-interval -- )
    [ check-unhandled ]
    [ dup start>> unhandled-intervals get heap-push ]
    bi ;

CONSTANT: reg-classes { int-regs double-float-regs }

: reg-class-assoc ( quot -- assoc )
    [ reg-classes ] dip { } map>assoc ; inline

! Mapping from register classes to spill counts
SYMBOL: spill-counts

: next-spill-slot ( reg-class -- n )
    spill-counts get [ dup 1 + ] change-at ;

! Mapping from vregs to spill slots
SYMBOL: spill-slots

DEFER: assign-spill-slot

: compute-spill-slot ( live-interval -- n )
    dup copy-from>>
    [ assign-spill-slot ]
    [ vreg>> reg-class>> next-spill-slot ] ?if ;

: assign-spill-slot ( live-interval -- n )
    dup vreg>> spill-slots get at [ ] [
        [ compute-spill-slot dup ] keep
        vreg>> spill-slots get set-at
    ] ?if ;

: init-allocator ( registers -- )
    registers set
    <min-heap> unhandled-intervals set
    [ V{ } clone ] reg-class-assoc active-intervals set
    [ V{ } clone ] reg-class-assoc inactive-intervals set
    V{ } clone handled-intervals set
    [ 0 ] reg-class-assoc spill-counts set
    H{ } clone spill-slots set
    -1 progress set ;

: init-unhandled ( live-intervals -- )
    [ [ start>> ] keep ] { } map>assoc
    unhandled-intervals get heap-push-all ;

! A utility used by register-status and spill-status words
: free-positions ( new -- assoc )
    vreg>> reg-class>> registers get at [ 1/0. ] H{ } map>assoc ;

: add-use-position ( n reg assoc -- ) [ [ min ] when* ] change-at ;

: register-available? ( new result -- ? )
    [ end>> ] [ second ] bi* < ; inline

: register-available ( new result -- )
    first >>reg add-active ;
