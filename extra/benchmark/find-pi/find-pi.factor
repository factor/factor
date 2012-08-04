! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: kernel locals math ;
IN: benchmark.find-pi

:: find-pi-to ( accuracy -- n approx )
    1 4 [
        over [ 2 * 1 + ] [ odd? [ neg ] when ] bi
        4 swap / [ + ] keep
        abs accuracy >= [ 1 + ] 2dip
    ] loop ;

: find-pi-benchmark ( -- )
    0.0005 find-pi-to drop 4001 assert= ;

MAIN: find-pi-benchmark
