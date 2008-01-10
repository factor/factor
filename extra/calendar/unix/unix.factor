USING: alien alien.c-types arrays calendar.backend
kernel structs math unix namespaces ;
IN: calendar.unix

TUPLE: unix-calendar ;

T{ unix-calendar } calendar-backend set-global

: get-time
    f time <uint> localtime ;

: timezone-name
    get-time tm-zone ;

M: unix-calendar gmt-offset
    get-time tm-gmtoff 3600 / ;
