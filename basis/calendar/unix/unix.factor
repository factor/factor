! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax arrays calendar
kernel math unix unix.time namespaces system ;
IN: calendar.unix

: timeval>unix-time ( timeval -- timestamp )
    [ timeval-sec seconds ] [ timeval-usec microseconds ] bi
    time+ since-1970 ;

: timespec>unix-time ( timeval -- timestamp )
    [ timespec-sec seconds ] [ timespec-nsec nanoseconds ] bi
    time+ since-1970 ;

: get-time ( -- alien )
    f time <uint> localtime ;

: timezone-name ( -- string )
    get-time tm-zone ;

M: unix gmt-offset ( -- hours minutes seconds )
    get-time tm-gmtoff 3600 /mod 60 /mod ;
