USING: alien alien.c-types kernel math
windows windows.kernel32 calendar namespaces ;
IN: calendar.windows

TUPLE: windows-calendar ;

T{ windows-calendar } calendar-impl set-global

M: windows-calendar gmt-offset ( -- float )
    "TIME_ZONE_INFORMATION" <c-object>
    [ GetTimeZoneInformation win32-error=0/f ] keep
    [ TIME_ZONE_INFORMATION-Bias ] keep
    TIME_ZONE_INFORMATION-DaylightBias + 60 /f neg ;

: >64bit ( lo hi -- n )
    32 shift bitor ;

: windows-1601 ( -- timestamp )
    1601 1 1 0 0 0 0 <timestamp> ;

: FILETIME>windows-time ( FILETIME -- n )
    [ FILETIME-dwLowDateTime ] keep
    FILETIME-dwHighDateTime >64bit ;

: windows-time>timestamp ( n -- timestamp )
    10000000 /i seconds windows-1601 swap +dt ;

: windows-time ( -- n )
    "FILETIME" <c-object> [ GetSystemTimeAsFileTime ] keep
    FILETIME>windows-time ;

: timestamp>windows-time ( timestamp -- n )
    #! 64bit number representing # of nanoseconds since Jan 1, 1601 (UTC)
    >gmt windows-1601 timestamp- >bignum 10000000 * ;

: windows-time>FILETIME ( n -- FILETIME )
    "FILETIME" <c-object>
    [
        [ >r HEX: ffffffff bitand r> set-FILETIME-dwLowDateTime ] 2keep
        >r -32 shift r> set-FILETIME-dwHighDateTime
    ] keep ;

: timestamp>FILETIME ( timestamp -- FILETIME/f )
    [ >gmt timestamp>windows-time windows-time>FILETIME ] [ f ] if* ;

: FILETIME>timestamp ( FILETIME -- timestamp/f )
    FILETIME>windows-time windows-time>timestamp ;

