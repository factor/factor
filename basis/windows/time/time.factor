! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types kernel math windows.errors
windows.kernel32 namespaces calendar math.bitwise ;
IN: windows.time

: >64bit ( lo hi -- n )
    32 shift bitor ; inline

: windows-1601 ( -- timestamp )
    1601 1 1 0 0 0 instant <timestamp> ;

: FILETIME>windows-time ( FILETIME -- n )
    [ FILETIME-dwLowDateTime ]
    [ FILETIME-dwHighDateTime ]
    bi >64bit ;

: windows-time>timestamp ( n -- timestamp )
    10000000 /i seconds windows-1601 swap time+ ;

: windows-time ( -- n )
    "FILETIME" <c-object> [ GetSystemTimeAsFileTime ] keep
    FILETIME>windows-time ;

: timestamp>windows-time ( timestamp -- n )
    #! 64bit number representing # of nanoseconds since Jan 1, 1601 (UTC)
    >gmt windows-1601 (time-) 10000000 * >integer ;

: windows-time>FILETIME ( n -- FILETIME )
    "FILETIME" <c-object>
    [
        [ [ 32 bits ] dip set-FILETIME-dwLowDateTime ]
        [ [ -32 shift ] dip set-FILETIME-dwHighDateTime ] 2bi
    ] keep ;

: timestamp>FILETIME ( timestamp -- FILETIME/f )
    dup [ >gmt timestamp>windows-time windows-time>FILETIME ] when ;

: FILETIME>timestamp ( FILETIME -- timestamp/f )
    FILETIME>windows-time windows-time>timestamp ;
