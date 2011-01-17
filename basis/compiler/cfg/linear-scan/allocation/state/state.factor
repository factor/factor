! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors assocs combinators cpu.architecture fry
heaps kernel math math.order namespaces layouts sequences vectors
linked-assocs compiler.cfg compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals ;
FROM: assocs => change-at ;
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

: active-intervals-for ( live-interval -- seq )
    reg-class>> active-intervals get at ;

: add-active ( live-interval -- )
    dup active-intervals-for push ;

: delete-active ( live-interval -- )
    dup active-intervals-for remove-eq! drop ;

: assign-free-register ( new registers -- )
    pop >>reg add-active ;

! Vector of inactive live intervals
SYMBOL: inactive-intervals

: inactive-intervals-for ( live-interval -- seq )
    reg-class>> inactive-intervals get at ;

: add-inactive ( live-interval -- )
    dup inactive-intervals-for push ;

: delete-inactive ( live-interval -- )
    dup inactive-intervals-for remove-eq! drop ;

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
        dup [ reg>> ] [ active-intervals-for [ reg>> ] map ] bi member?
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
    [ get values ] dip '[ [ _ cond ] with filter! drop ] with each ; inline

: deactivate-intervals ( n -- )
    ! Any active intervals which have ended are moved to handled
    ! Any active intervals which cover the current position
    ! are moved to inactive
    dup progress set
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

: reg-class-assoc ( quot -- assoc )
    [ reg-classes ] dip { } map>assoc ; inline

: next-spill-slot ( size -- spill-slot )
    cfg get
    [ swap [ align dup ] [ + ] bi ] change-spill-area-size drop
    <spill-slot> ;

: align-spill-area ( align -- )
    cfg get [ max ] change-spill-area-align drop ;

! Minheap of sync points which still need to be processed
SYMBOL: unhandled-sync-points

! Mapping from vregs to spill slots
SYMBOL: spill-slots

: assign-spill-slot ( coalesced-vreg rep -- spill-slot )
    rep-size
    [ align-spill-area ]
    [ spill-slots get [ nip next-spill-slot ] 2cache ]
    bi ;

: lookup-spill-slot ( coalesced-vreg rep -- spill-slot )
    rep-size 2array spill-slots get ?at [ ] [ bad-vreg ] if ;

: init-allocator ( registers -- )
    registers set
    <min-heap> unhandled-intervals set
    <min-heap> unhandled-sync-points set
    [ V{ } clone ] reg-class-assoc active-intervals set
    [ V{ } clone ] reg-class-assoc inactive-intervals set
    V{ } clone handled-intervals set
    cfg get 0 >>spill-area-size cell >>spill-area-align drop
    H{ } clone spill-slots set
    -1 progress set ;

: init-unhandled ( live-intervals sync-points -- )
    [ [ [ start>> ] keep ] { } map>assoc unhandled-intervals get heap-push-all ]
    [ [ [ n>> ] keep ] { } map>assoc unhandled-sync-points get heap-push-all ]
    bi* ;

! A utility used by register-status and spill-status words
: free-positions ( new -- assoc )
    reg-class>> registers get at
    [ 1/0. ] H{ } <linked-assoc> map>assoc ;

: add-use-position ( n reg assoc -- ) [ [ min ] when* ] change-at ;

: register-available? ( new result -- ? )
    [ end>> ] [ second ] bi* < ; inline

: register-available ( new result -- )
    first >>reg add-active ;
