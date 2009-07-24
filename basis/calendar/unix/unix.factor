! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax arrays calendar
kernel math unix unix.time unix.types namespaces system ;
IN: calendar.unix

: timeval>seconds ( timeval -- seconds )
    [ timeval-sec seconds ] [ timeval-usec microseconds ] bi
    time+ ;

: timeval>unix-time ( timeval -- timestamp )
    timeval>seconds since-1970 ;

: timespec>seconds ( timespec -- seconds )
    [ timespec-sec seconds ] [ timespec-nsec nanoseconds ] bi
    time+ ;

: timespec>unix-time ( timespec -- timestamp )
    timespec>seconds since-1970 ;

: get-time ( -- alien )
    f time <time_t> localtime ;

: timezone-name ( -- string )
    get-time tm-zone ;

M: unix gmt-offset ( -- hours minutes seconds )
    get-time tm-gmtoff 3600 /mod 60 /mod ;
