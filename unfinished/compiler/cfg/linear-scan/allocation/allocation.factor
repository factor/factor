! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences math math.order kernel assocs
accessors vectors fry
compiler.cfg.linear-scan.live-intervals
compiler.backend ;
IN: compiler.cfg.linear-scan.allocation

! Mapping from vregs to machine registers
SYMBOL: register-allocation

! Mapping from vregs to spill locations
SYMBOL: spill-locations

! Vector of active live intervals, in order of increasing end point
SYMBOL: active-intervals

: add-active ( live-interval -- )
    active-intervals get push ;

: delete-active ( live-interval -- )
    active-intervals get delete ;

! Mapping from register classes to sequences of machine registers
SYMBOL: free-registers

! Counter of spill locations
SYMBOL: spill-counter

: next-spill-location ( -- n )
    spill-counter [ dup 1+ ] change ;

: assign-spill ( live-interval -- )
    next-spill-location swap vreg>> spill-locations get set-at ;

: free-registers-for ( vreg -- seq )
    reg-class>> free-registers get at ;

: free-register ( vreg -- )
    #! Free machine register currently assigned to vreg.
    [ register-allocation get at ] [ free-registers-for ] bi push ;

: expire-old-intervals ( live-interval -- )
    active-intervals get
    swap '[ end>> _ start>> < ] partition
    active-intervals set
    [ vreg>> free-register ] each ;

: interval-to-spill ( -- live-interval )
    #! We spill the interval with the longest remaining range.
    active-intervals get unclip-slice [
        [ [ end>> ] bi@ > ] most
    ] reduce ;

: reuse-register ( live-interval to-spill -- )
    vreg>> swap vreg>>
    register-allocation get
    tuck [ at ] [ set-at ] 2bi* ;

: spill-at-interval ( live-interval -- )
    interval-to-spill
    2dup [ end>> ] bi@ > [
        [ reuse-register ]
        [ nip assign-spill ]
        [ [ add-active ] [ delete-active ] bi* ]
        2tri
    ] [ drop assign-spill ] if ;

: init-allocator ( -- )
    H{ } clone register-allocation set
    H{ } clone spill-locations set
    V{ } clone active-intervals set
    machine-registers [ >vector ] assoc-map free-registers set
    0 spill-counter set ;

: assign-register ( live-interval register -- )
    swap vreg>> register-allocation get set-at ;

: allocate-register ( live-interval -- )
    dup vreg>> free-registers-for [
        spill-at-interval
    ] [
        [ pop assign-register ]
        [ drop add-active ]
        2bi
    ] if-empty ;

: allocate-registers ( live-intervals -- )
    init-allocator
    [ [ expire-old-intervals ] [ allocate-register ] bi ] each ;
