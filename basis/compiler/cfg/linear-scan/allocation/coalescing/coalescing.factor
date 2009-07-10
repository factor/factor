! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences namespaces assocs fry
combinators.short-circuit
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.allocation.coalescing

: active-interval ( vreg -- live-interval )
    dup [ dup active-intervals-for [ vreg>> = ] with find nip ] when ;

: avoids-inactive-intervals? ( live-interval -- ? )
    dup vreg>> inactive-intervals-for
    [ intervals-intersect? not ] with all? ;

: coalesce? ( live-interval -- ? )
    {
        [ copy-from>> active-interval ]
        [ [ start>> ] [ copy-from>> active-interval end>> ] bi = ]
        [ avoids-inactive-intervals? ]
    } 1&& ;

: reuse-spill-slot ( old new -- )
    [ vreg>> spill-slots get at ] dip '[ _ vreg>> spill-slots get set-at ] when* ;

: reuse-register ( old new -- )
    reg>> >>reg drop ;

: (coalesce) ( old new -- )
    [ add-active ] [ [ delete-active ] [ add-handled ] bi ] bi* ;

: coalesce ( live-interval -- )
    dup copy-from>> active-interval
    [ reuse-spill-slot ] [ reuse-register ] [ (coalesce) ] 2tri ;
 