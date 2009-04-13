! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2.result-sets db2.sqlite.statements
db2.statements kernel db2.sqlite.lib destructors ;
IN: db2.sqlite.result-sets

TUPLE: sqlite-result-set < result-set has-more? ;

M: sqlite-result-set dispose
    f >>handle drop ;

M: sqlite-statement statement>result-set*
    sqlite-maybe-prepare >sqlite-result-set ;

M: sqlite-result-set advance-row ( result-set -- )
    dup handle>> sqlite-next >>has-more? drop ;

M: sqlite-result-set more-rows? ( result-set -- )
    has-more?>> ;

M: sqlite-result-set #columns ( result-set -- n )
    handle>> sqlite-#columns ;

M: sqlite-result-set column ( result-set n -- obj )
    [ handle>> ] [ sqlite-column ] bi* ;
