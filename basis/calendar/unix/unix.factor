! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.data calendar calendar.private
classes.struct kernel math system unix unix.time unix.types ;
IN: calendar.unix

: timeval>seconds ( timeval -- seconds )
    [ sec>> ] [ usec>> 1,000,000 / ] bi + ; inline

: timeval>duration ( timeval -- duration )
    timeval>seconds seconds ;

: timeval>unix-time ( timeval -- timestamp )
    [ unix-1970 ] dip timeval>seconds +second ;

: timespec>seconds ( timespec -- seconds )
    [ sec>> ] [ nsec>> 1,000,000,000 / ] bi + ; inline

: timespec>duration ( timespec -- duration )
    timespec>seconds seconds ;

: timespec>unix-time ( timespec -- timestamp )
    [ unix-1970 ] dip timespec>seconds +second ;

: get-time ( -- alien )
    f time time_t <ref> localtime ;

: timezone-name ( -- string )
    get-time zone>> ;

M: unix gmt-offset ( -- hours minutes seconds )
    get-time gmtoff>> 3600 /mod 60 /mod ;

: current-timeval ( -- timeval )
    timeval <struct> f [ gettimeofday io-error ] 2keep drop ;

: system-micros ( -- n )
    current-timeval
    [ sec>> 1,000,000 * ] [ usec>> ] bi + ;

M: unix gmt
    current-timeval timeval>unix-time ;
