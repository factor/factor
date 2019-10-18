! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax arrays calendar
kernel math unix unix.time unix.types namespaces system
accessors classes.struct ;
IN: calendar.unix

: timeval>seconds ( timeval -- seconds )
    [ sec>> seconds ] [ usec>> microseconds ] bi time+ ;

: timeval>unix-time ( timeval -- timestamp )
    timeval>seconds since-1970 ;

: timespec>seconds ( timespec -- seconds )
    [ sec>> seconds ] [ nsec>> nanoseconds ] bi time+ ;

: timespec>nanoseconds ( timespec -- seconds )
    [ sec>> 1000000000 * ] [ nsec>> ] bi + ;

: timespec>unix-time ( timespec -- timestamp )
    timespec>seconds since-1970 ;

: get-time ( -- alien )
    f time <time_t> localtime tm memory>struct ;

: timezone-name ( -- string )
    get-time zone>> ;

M: unix gmt-offset ( -- hours minutes seconds )
    get-time gmtoff>> 3600 /mod 60 /mod ;
