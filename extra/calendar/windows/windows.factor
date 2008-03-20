USING: calendar.backend namespaces alien.c-types
windows windows.kernel32 kernel math combinators.cleave
combinators ;
IN: calendar.windows

TUPLE: windows-calendar ;

T{ windows-calendar } calendar-backend set-global

M: windows-calendar gmt-offset ( -- hours minutes seconds )
    "TIME_ZONE_INFORMATION" <c-object>
    dup GetTimeZoneInformation {
        { [ dup TIME_ZONE_ID_INVALID = ] [ win32-error-string throw ] }
        { [ dup [ TIME_ZONE_ID_UNKNOWN = ] [ TIME_ZONE_ID_STANDARD = ] bi or ] [
            drop TIME_ZONE_INFORMATION-Bias ] }
        { [ dup TIME_ZONE_ID_DAYLIGHT = ] [
            drop
            [ TIME_ZONE_INFORMATION-Bias ]
            [ TIME_ZONE_INFORMATION-DaylightBias ] bi +
        ] }
    } cond neg 60 /mod 0 ;
