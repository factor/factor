! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien.syntax alien.c-types math unix.types
classes.struct accessors ;
IN: unix.time

STRUCT: timeval
    { sec long }
    { usec long } ;

STRUCT: timespec
    { sec time_t }
    { nsec long } ;

: make-timeval ( us -- timeval )
    1000000 /mod
    timeval <struct>
        swap >>usec
        swap >>sec ;

: make-timespec ( nanos -- timespec )
    1000000000 /mod
    timespec <struct>
        swap >>nsec
        swap >>sec ;

STRUCT: tm
    { sec int }
    { min int }
    { hour int }
    { mday int }
    { mon int }
    { year int }
    { wday int }
    { yday int }
    { isdst int }
    { gmtoff long }
    { zone char* } ;

FUNCTION: time_t time ( time_t* t ) ;
FUNCTION: tm* localtime ( time_t* clock ) ;
FUNCTION: int gettimeofday ( timespec* TP, void* TZP ) ;
