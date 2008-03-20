USING: alien alien.c-types arrays calendar.backend
kernel structs math unix.time namespaces ;

IN: calendar.unix

TUPLE: unix-calendar ;

T{ unix-calendar } calendar-backend set-global

: get-time ( -- alien )
    f time <uint> localtime ;

: timezone-name ( -- string )
    get-time tm-zone ;

M: unix-calendar gmt-offset ( -- hours minutes seconds )
    get-time tm-gmtoff 3600 /mod 60 /mod ;
