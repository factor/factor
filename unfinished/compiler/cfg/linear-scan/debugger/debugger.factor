! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences sets arrays
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation ;
IN: compiler.cfg.linear-scan.debugger

: check-assigned ( live-intervals -- )
    [
        reg>>
        [ "Not all intervals have registers" throw ] unless
    ] each ;

: split-children ( live-interval -- seq )
    dup split-before>> [
        [ split-before>> ] [ split-after>> ] bi
        [ split-children ] bi@
        append
    ] [ 1array ] if ;

: check-linear-scan ( live-intervals machine-registers -- )
    [ [ clone ] map dup ] dip allocate-registers
    [ split-children ] map concat check-assigned ;
