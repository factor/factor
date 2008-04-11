USING: alien alien.c-types arrays calendar.backend
kernel structs math unix.time namespaces system ;
IN: calendar.unix

: get-time ( -- alien )
    f time <uint> localtime ;

: timezone-name ( -- string )
    get-time tm-zone ;

M: unix gmt-offset ( -- hours minutes seconds )
    get-time tm-gmtoff 3600 /mod 60 /mod ;
