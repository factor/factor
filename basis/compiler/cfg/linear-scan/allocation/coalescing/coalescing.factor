! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.allocation.coalescing

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
