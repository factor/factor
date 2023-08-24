! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.ranges compiler.cfg.registers
cpu.architecture heaps kernel math math.order namespaces
sequences ;
IN: compiler.cfg.linear-scan.allocation.state

SYMBOL: progress

: check-unhandled ( live-interval -- )
    live-interval-start progress get <= [ "check-unhandled" throw ] when ; inline

: check-handled ( live-interval -- )
    live-interval-end progress get > [ "check-handled" throw ] when ; inline

SYMBOL: unhandled-min-heap

GENERIC: interval/sync-point-key ( interval/sync-point -- key )

M: live-interval-state interval/sync-point-key
    [ ranges>> ranges-endpoints ] [ vreg>> ] bi 3array ;

M: sync-point interval/sync-point-key
    n>> 1/0. 1/0. 3array ;

: >unhandled-min-heap ( intervals/sync-points -- min-heap )
    [ [ interval/sync-point-key ] keep 2array ] map >min-heap ;

SYMBOL: registers

SYMBOL: active-intervals

: active-intervals-for ( live-interval -- seq )
    interval-reg-class active-intervals get at ;

: add-active ( live-interval -- )
    dup active-intervals-for push ;

: delete-active ( live-interval -- )
    dup active-intervals-for remove-eq! drop ;

: assign-free-register ( new registers -- )
    pop >>reg add-active ;

SYMBOL: inactive-intervals

: inactive-intervals-for ( live-interval -- seq )
    interval-reg-class inactive-intervals get at ;

: add-inactive ( live-interval -- )
    dup inactive-intervals-for push ;

: delete-inactive ( live-interval -- )
    dup inactive-intervals-for remove-eq! drop ;

SYMBOL: handled-intervals

: add-handled ( live-interval -- )
    [ check-handled ] [ handled-intervals get push ] bi ;

: finished? ( n live-interval -- ? ) live-interval-end swap < ;

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

: covers? ( n live-interval -- ? )
    ranges>> ranges-cover? ;

: deactivate-intervals ( n -- )
    dup progress set
    active-intervals {
        { [ 2dup finished? ] [ finish ] }
        { [ 2dup covers? not ] [ deactivate ] }
        [ don't-change ]
    } process-intervals ;

: activate-intervals ( n -- )
    inactive-intervals {
        { [ 2dup finished? ] [ finish ] }
        { [ 2dup covers? ] [ activate ] }
        [ don't-change ]
    } process-intervals ;

: add-unhandled ( live-interval -- )
    dup check-unhandled
    dup interval/sync-point-key unhandled-min-heap get heap-push ;

: reg-class-assoc ( quot -- assoc )
    [ reg-classes ] dip { } map>assoc ; inline

: align-spill-area ( align stack-frame -- )
    [ max ] change-spill-area-align drop ;

: next-spill-slot ( size stack-frame -- spill-slot )
    [ swap [ align dup ] [ + ] bi ] change-spill-area-size drop <spill-slot> ;

SYMBOL: spill-slots

: assign-spill-slot ( coalesced-vreg rep -- spill-slot )
    rep-size spill-slots get [
        nip cfg get stack-frame>>
        [ align-spill-area ] [ next-spill-slot ] 2bi
    ] 2cache ;

: lookup-spill-slot ( coalesced-vreg rep -- spill-slot )
    rep-size 2array spill-slots get ?at [ ] [ bad-vreg ] if ;

: init-allocator ( intervals/sync-points registers -- )
    registers set
    >unhandled-min-heap unhandled-min-heap set
    [ V{ } clone ] reg-class-assoc active-intervals set
    [ V{ } clone ] reg-class-assoc inactive-intervals set
    V{ } clone handled-intervals set
    H{ } clone spill-slots set
    -1 progress set ;

: add-use-position ( n reg assoc -- )
    [ [ min ] when* ] change-at ;

: register-available? ( new result -- ? )
    [ live-interval-end ] [ second ] bi* < ; inline

: register-available ( new result -- )
    first >>reg add-active ;
