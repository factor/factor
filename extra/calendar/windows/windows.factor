USING: calendar.backend namespaces alien.c-types
windows windows.kernel32 kernel math ;
IN: calendar.windows

TUPLE: windows-calendar ;

T{ windows-calendar } calendar-backend set-global

: TIME_ZONE_ID_INVALID HEX: ffffffff ; inline

M: windows-calendar gmt-offset ( -- hours minutes seconds )
    0 0 0 ;
    ! "TIME_ZONE_INFORMATION" <c-object>
    ! dup GetTimeZoneInformation {
    !     { [ dup TIME_ZONE_ID_INVALID = ] [ win32-error ] }
    !     { [ dup { TIME_ZONE_ID_UNKNOWN TIME_ZONE_ID_STANDARD } member? ]
    !         [ TIME_ZONE_INFORMATION-Bias 60 / neg ] }
    !     { [ dup TIME_ZONE_ID_DAYLIGHT = ] [
    !         [ TIME_ZONE_INFORMATION-Bias 60 / neg ]
    !         [ TIME_ZONE_INFORMATION-DaylightBias ] bi
    !     ] }
    ! } cond ;
