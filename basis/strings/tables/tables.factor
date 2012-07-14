! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences fry math.order math.ranges splitting ;
IN: strings.tables

<PRIVATE

: max-length ( seq -- n )
    [ length ] [ max ] map-reduce ; inline

: format-row ( seq -- seq )
    dup max-length '[ _ "" pad-tail ] map! ;

: format-column ( seq -- seq )
    dup max-length '[ _ CHAR: \s pad-tail ] map! ;

PRIVATE>

: format-table ( table -- seq )
    [ [ string-lines ] map format-row flip ] map concat
    flip [ but-last-slice [ format-column ] map! drop ] keep
    flip [ " " join ] map! ;
