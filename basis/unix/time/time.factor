! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax
classes.struct kernel math unix.types ;
IN: unix.time

STRUCT: timeval
    { sec long }
    { usec long } ;

STRUCT: timespec
    { sec time_t }
    { nsec long } ;

: make-timeval ( us -- timeval )
    [ timeval <struct> ] dip [
        1000000 /mod [ >>sec ] [ >>usec ] bi*
    ] unless-zero ;

: make-timespec ( nanos -- timespec )
    [ timespec <struct> ] dip [
        1000000000 /mod [ >>sec ] [ >>nsec ] bi*
    ] unless-zero ;

STRUCT: timezone
    { tz_minuteswest int }
    { tz_dsttime int } ;

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
    { zone c-string } ;

FUNCTION: time_t time ( time_t* t )
FUNCTION: tm* localtime ( time_t* clock )
FUNCTION: int gettimeofday ( timespec* TP, void* TZP )
FUNCTION: int settimeofday ( timeval* TP, timezone* TZP )
FUNCTION: int adjtime ( timeval* delta, timeval* olddelta )
