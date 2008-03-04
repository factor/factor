USING: calendar.backend namespaces alien.c-types
windows windows.kernel32 kernel math ;
IN: calendar.windows

TUPLE: windows-calendar ;

T{ windows-calendar } calendar-backend set-global

: TIME_ZONE_ID_INVALID HEX: ffffffff ; inline

M: windows-calendar gmt-offset ( -- float )
    "TIME_ZONE_INFORMATION" <c-object>
    dup GetTimeZoneInformation
    TIME_ZONE_ID_INVALID = [ win32-error ] when
    TIME_ZONE_INFORMATION-Bias 60 / neg ;
