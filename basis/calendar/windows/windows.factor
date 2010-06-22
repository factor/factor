USING: calendar namespaces alien.c-types system
windows.kernel32 kernel math combinators windows.errors
accessors classes.struct calendar.format math.functions ;
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
    } cleave \ SYSTEMTIME <struct-boa> ;

: SYSTEMTIME>timestamp ( SYSTEMTIME -- timestamp )
    {
        [ wYear>> ]
        [ wMonth>> ]
        [ wDay>> ]
        [ wHour>> ]
        [ wMinute>> ]
        [ [ wSecond>> ] [ wMilliseconds>> 1000 / ] bi + ]
    } cleave instant <timestamp> ;

M: windows gmt-offset ( -- hours minutes seconds )
    TIME_ZONE_INFORMATION <struct>
    dup GetTimeZoneInformation {
        { TIME_ZONE_ID_INVALID [ win32-error-string throw ] }
        { TIME_ZONE_ID_UNKNOWN [ Bias>> ] }
        { TIME_ZONE_ID_STANDARD [ Bias>> ] }
        { TIME_ZONE_ID_DAYLIGHT [ [ Bias>> ] [ DaylightBias>> ] bi + ] }
    } case neg 60 /mod 0 ;

M: windows gmt
    SYSTEMTIME <struct> [ GetSystemTime ] keep SYSTEMTIME>timestamp ;
