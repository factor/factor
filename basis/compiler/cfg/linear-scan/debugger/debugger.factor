! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences sets arrays math strings fry
namespaces prettyprint compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation compiler.cfg assocs ;
FROM: namespaces => set ;
IN: compiler.cfg.linear-scan.debugger

: check-linear-scan ( live-intervals machine-registers -- )
    [
        [ clone ] map dup [ [ vreg>> ] keep ] H{ } map>assoc
        live-intervals set
        f
    ] dip
    allocate-registers drop ;

: picture ( uses -- str )
    dup last 1 + CHAR: space <string>
    [ '[ CHAR: * swap _ set-nth ] each ] keep ;

: interval-picture ( interval -- str )
    [ uses>> picture ]
    [ vreg>> unparse ]
    bi 2array ;

: live-intervals. ( seq -- )
    [ interval-picture ] map simple-table. ;
