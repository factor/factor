! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types kernel math windows.errors
windows.kernel32 windows.types namespaces calendar math.bitwise
accessors classes.struct windows.handles ;
IN: windows.time

: >64bit ( lo hi -- n )
    32 shift bitor ; inline

: windows-1601 ( -- timestamp ) 1601 <year-gmt> ;

: FILETIME>windows-time ( FILETIME -- n )
    [ dwLowDateTime>> ] [ dwHighDateTime>> ] bi >64bit ;

: windows-time>timestamp ( n -- timestamp )
    [ windows-1601 ] dip 10,000,000 /i +second ;

: windows-time ( -- n )
    FILETIME <struct> [ GetSystemTimeAsFileTime ] keep
    FILETIME>windows-time ;

: timestamp>windows-time ( timestamp -- n )
    #! 64bit number representing # of nanoseconds since Jan 1, 1601 (UTC)
    >gmt windows-1601 (time-) 10,000,000 * >integer ;

: windows-time>FILETIME ( n -- FILETIME )
    [ FILETIME <struct> ] dip
    [ 32 bits >>dwLowDateTime ] [ -32 shift >>dwHighDateTime ] bi ;

: timestamp>FILETIME ( timestamp -- FILETIME/f )
    dup [ >gmt timestamp>windows-time windows-time>FILETIME ] when ;

: FILETIME>timestamp ( FILETIME -- timestamp/f )
    FILETIME>windows-time windows-time>timestamp ;
