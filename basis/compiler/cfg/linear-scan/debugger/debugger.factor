! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences sets arrays math strings fry
namespaces prettyprint compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation compiler.cfg ;
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
    [ [ clone ] map ] dip allocate-registers
    [ split-children ] map concat check-assigned ;

: picture ( uses -- str )
    dup last 1 + CHAR: space <string>
    [ '[ CHAR: * swap _ set-nth ] each ] keep ;

: interval-picture ( interval -- str )
    [ uses>> picture ]
    [ copy-from>> unparse ]
    [ vreg>> unparse ]
    tri 3array ;

: live-intervals. ( seq -- )
    [ interval-picture ] map simple-table. ;

: test-bb ( insns n -- )
    [ <basic-block> swap >>number swap >>instructions ] keep set ;