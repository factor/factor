! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar math alien.c-types alien.syntax memoize system ;
IN: core-foundation.time

TYPEDEF: double CFTimeInterval
TYPEDEF: double CFAbsoluteTime

ALIAS: >CFTimeInterval duration>seconds

MEMO: epoch ( -- micros )
    T{ timestamp { year 2001 } { month 1 } { day 1 } } timestamp>micros ;

: >CFAbsoluteTime ( micros -- time )
    epoch - 1,000,000 /f ; inline
