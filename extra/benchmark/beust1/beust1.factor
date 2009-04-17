! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math.ranges math.parser math.vectors sets sequences
kernel io ;
IN: benchmark.beust1

: count-numbers ( max -- n )
    1 [a,b] [ number>string all-unique? ] count ; inline

: beust ( -- )
    2000000 count-numbers
    number>string " unique numbers." append print ;

MAIN: beust
