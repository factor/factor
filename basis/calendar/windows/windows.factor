USING: calendar namespaces alien.c-types system
windows.kernel32 kernel math combinators windows.errors
accessors classes.struct ;
IN: calendar.windows

M: windows gmt-offset ( -- hours minutes seconds )
    TIME_ZONE_INFORMATION <struct>
    dup GetTimeZoneInformation {
        { TIME_ZONE_ID_INVALID [ win32-error-string throw ] }
        { TIME_ZONE_ID_UNKNOWN [ Bias>> ] }
        { TIME_ZONE_ID_STANDARD [ Bias>> ] }
        { TIME_ZONE_ID_DAYLIGHT [ [ Bias>> ] [ DaylightBias>> ] bi + ] }
    } case neg 60 /mod 0 ;
