USING: accessors calendar combinators kernel math math.functions
system windows.errors windows.kernel32 ;
IN: calendar.windows

: timestamp>SYSTEMTIME ( timestamp -- SYSTEMTIME )
    {
        [ year>> ]
        [ month>> ]
        [ day-of-week ]
        [ day>> ]
        [ hour>> ]
        [ minute>> ]
        [
            second>> dup floor
            [ nip >integer ]
            [ - 1000 * >integer ] 2bi
        ]
    } cleave \ SYSTEMTIME boa ;

: SYSTEMTIME>timestamp ( SYSTEMTIME -- timestamp )
    {
        [ wYear>> ]
        [ wMonth>> ]
        [ wDay>> ]
        [ wHour>> ]
        [ wMinute>> ]
        [ [ wSecond>> ] [ wMilliseconds>> 1000 / ] bi + ]
    } cleave instant <timestamp> ;

M: windows gmt-offset
    TIME_ZONE_INFORMATION new
    dup GetTimeZoneInformation {
        { TIME_ZONE_ID_INVALID [ win32-error ] }
        { TIME_ZONE_ID_UNKNOWN [ Bias>> ] }
        { TIME_ZONE_ID_STANDARD [ Bias>> ] }
        { TIME_ZONE_ID_DAYLIGHT [ [ Bias>> ] [ DaylightBias>> ] bi + ] }
    } case neg 60 /mod 0 ;

M: windows now-gmt
    SYSTEMTIME new [ GetSystemTime ] keep SYSTEMTIME>timestamp ;
