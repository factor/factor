! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences
combinators.short-circuit
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.allocation.coalescing

: active-interval ( vreg -- live-interval )
    dup [ dup active-intervals-for [ vreg>> = ] with find nip ] when ;

: intersects-inactive-intervals? ( live-interval -- ? )
    dup vreg>> inactive-intervals-for
    [ relevant-ranges intersect-live-ranges 1/0. = ] with all? ;

: coalesce? ( live-interval -- ? )
    {
        [ copy-from>> active-interval ]
        [ [ start>> ] [ copy-from>> active-interval end>> ] bi = ]
        [ intersects-inactive-intervals? ]
    } 1&& ;

: coalesce ( live-interval -- )
    dup copy-from>> active-interval
    [ [ add-active ] [ [ delete-active ] [ add-handled ] bi ] bi* ]
    [ reg>> >>reg drop ]
    2bi ;
 