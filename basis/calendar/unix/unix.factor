! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data calendar calendar.private
classes.struct kernel math system libc unix unix.time unix.types ;
IN: calendar.unix

: timeval>seconds ( timeval -- seconds )
    [ sec>> ] [ usec>> 1,000,000 / ] bi + ; inline

: timeval>micros ( timeval -- micros )
    [ sec>> 1,000,000 * ] [ usec>> ] bi + ; inline

: timeval>duration ( timeval -- duration )
    timeval>seconds seconds ; inline

: timeval>unix-time ( timeval -- timestamp )
    [ unix-1970 ] dip timeval>seconds +second ; inline

: timespec>seconds ( timespec -- seconds )
    [ sec>> ] [ nsec>> 1,000,000,000 / ] bi + ; inline

: timespec>duration ( timespec -- duration )
    timespec>seconds seconds ; inline

: timespec>unix-time ( timespec -- timestamp )
    [ unix-1970 ] dip timespec>seconds +second ; inline

: get-time ( -- alien )
    f time time_t <ref> localtime ; inline

: timezone-name ( -- string )
    get-time zone>> ;

M: unix gmt-offset
    get-time gmtoff>> 3600 /mod 60 /mod ;

: current-timeval ( -- timeval )
    timeval new [ f gettimeofday io-error ] keep ; inline

: system-micros ( -- n )
    current-timeval timeval>micros ;

M: unix now-gmt
    current-timeval timeval>unix-time ;
