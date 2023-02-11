! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax calendar literals math ;
IN: core-foundation.time

TYPEDEF: double CFTimeInterval
TYPEDEF: double CFAbsoluteTime

ALIAS: >CFTimeInterval duration>seconds

CONSTANT: epoch $[
    T{ timestamp { year 2001 } { month 1 } { day 1 } }
    timestamp>micros
]

: >CFAbsoluteTime ( micros -- time )
    epoch - 1,000,000 /f ; inline
