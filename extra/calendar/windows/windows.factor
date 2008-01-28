USING: calendar.backend namespaces alien.c-types
windows windows.kernel32 kernel math ;
IN: calendar.windows

TUPLE: windows-calendar ;

T{ windows-calendar } calendar-backend set-global

M: windows-calendar gmt-offset ( -- float )
    "TIME_ZONE_INFORMATION" <c-object>
    [ GetTimeZoneInformation win32-error=0/f ] keep
    [ TIME_ZONE_INFORMATION-Bias ] keep
    TIME_ZONE_INFORMATION-DaylightBias + 60 /f neg ;
