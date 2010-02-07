! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax ;
IN: math.floats.parser

<PRIVATE

LIBRARY: libc
FUNCTION: double strtod ( char* nptr, char** endptr ) ;

PRIVATE>

: string>float ( str -- n/f ) f <void*> strtod ;

