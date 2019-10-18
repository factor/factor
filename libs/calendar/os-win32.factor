IN: calendar
USING: alien kernel math win32-api ;

: gmt-offset
    "TIME_ZONE_INFORMATION" <c-object> dup GetTimeZoneInformation drop
    dup TIME_ZONE_INFORMATION-Bias swap TIME_ZONE_INFORMATION-DaylightBias +
    60 /f neg ;
    
