USING: calendar namespaces alien.c-types system
windows.kernel32 kernel math combinators windows.errors ;
IN: calendar.windows

M: windows gmt-offset ( -- hours minutes seconds )
    "TIME_ZONE_INFORMATION" <c-object>
    dup GetTimeZoneInformation {
        { TIME_ZONE_ID_INVALID [ win32-error-string throw ] }
        { TIME_ZONE_ID_UNKNOWN [ TIME_ZONE_INFORMATION-Bias ] }
        { TIME_ZONE_ID_STANDARD [ TIME_ZONE_INFORMATION-Bias ] }
        { TIME_ZONE_ID_DAYLIGHT [
            [ TIME_ZONE_INFORMATION-Bias ]
            [ TIME_ZONE_INFORMATION-DaylightBias ] bi +
        ] }
    } case neg 60 /mod 0 ;
