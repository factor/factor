! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals compiler.cfg.registers
cpu.architecture fry heaps kernel linked-assocs math
math.order namespaces sequences ;
FROM: assocs => change-at ;
IN: compiler.cfg.linear-scan.allocation.state

SYMBOL: progress

: check-unhandled ( live-interval -- )
    start>> progress get <= [ "check-unhandled" throw ] when ; inline

: check-handled ( live-interval -- )
    end>> progress get > [ "check-handled" throw ] when ; inline

SYMBOL: unhandled-min-heap

: live-interval-key ( live-interval -- key )
    [ start>> ] [ end>> ] bi 2array ;

: sync-point-key ( sync-point -- key )
    n>> 1/0. 2array ;

: zip-keyed ( seq quot: ( elt -- key ) -- alist )
    [ keep ] curry { } map>assoc ; inline

: >unhandled-min-heap ( live-intervals sync-points -- min-heap )
    [ [ live-interval-key ] zip-keyed ]
    [ [ sync-point-key ] zip-keyed ] bi* append >min-heap ;

SYMBOL: registers

SYMBOL: active-intervals

: active-intervals-for ( live-interval -- seq )
    reg-class>> active-intervals get at ;

: add-active ( live-interval -- )
    dup active-intervals-for push ;

: delete-active ( live-interval -- )
    dup active-intervals-for remove-eq! drop ;

: assign-free-register ( new registers -- )
    pop >>reg add-active ;

SYMBOL: inactive-intervals

: inactive-intervals-for ( live-interval -- seq )
    reg-class>> inactive-intervals get at ;

: add-inactive ( live-interval -- )
    dup inactive-intervals-for push ;

: delete-inactive ( live-interval -- )
    dup inactive-intervals-for remove-eq! drop ;

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
    [ check-unhandled ]
    [
        dup live-interval-key unhandled-min-heap get heap-push
    ] bi ;

: reg-class-assoc ( quot -- assoc )
    [ reg-classes ] dip { } map>assoc ; inline

: next-spill-slot ( size -- spill-slot )
    cfg get
    [ swap [ align dup ] [ + ] bi ] change-spill-area-size drop
    <spill-slot> ;

: align-spill-area ( align cfg -- )
    [ max ] change-spill-area-align drop ;

SYMBOL: spill-slots

: assign-spill-slot ( coalesced-vreg rep -- spill-slot )
    rep-size
    [ cfg get align-spill-area ]
    [ spill-slots get [ nip next-spill-slot ] 2cache ]
    bi ;

: lookup-spill-slot ( coalesced-vreg rep -- spill-slot )
    rep-size 2array spill-slots get ?at [ ] [ bad-vreg ] if ;

: init-allocator ( live-intervals sync-points registers -- )
    registers set
    >unhandled-min-heap unhandled-min-heap set
    [ V{ } clone ] reg-class-assoc active-intervals set
    [ V{ } clone ] reg-class-assoc inactive-intervals set
    V{ } clone handled-intervals set
    H{ } clone spill-slots set
    -1 progress set ;

: free-positions ( new -- assoc )
    reg-class>> registers get at
    [ 1/0. ] H{ } <linked-assoc> map>assoc ;

: add-use-position ( n reg assoc -- ) [ [ min ] when* ] change-at ;

: register-available? ( new result -- ? )
    [ end>> ] [ second ] bi* < ; inline

: register-available ( new result -- )
    first >>reg add-active ;
