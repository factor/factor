! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar alien.c-types alien.syntax ;
IN: core-foundation.time

TYPEDEF: double CFTimeInterval
TYPEDEF: double CFAbsoluteTime

: >CFTimeInterval ( duration -- interval )
    duration>seconds ; inline

: >CFAbsoluteTime ( timestamp -- time )
    T{ timestamp { year 2001 } { month 1 } { day 1 } } time-
    duration>seconds ; inline
