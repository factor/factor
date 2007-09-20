USING: alien alien.c-types arrays kernel structs
math unix calendar namespaces ;
IN: calendar.unix

TUPLE: unix-calendar ;

T{ unix-calendar } calendar-impl set-global

: get-time
    f time <uint> localtime ;

: timezone-name
    get-time tm-zone ;

M: unix-calendar gmt-offset
    get-time tm-gmtoff 3600 / ;

: timestamp>timeval ( timestamp -- timeval )
    timestamp>unix-time 1000 * make-timeval ;

: timeval>timestamp ( timeval -- timestamp )
    [ timeval-sec ] keep
    timeval-usec 1000000 / + unix-time>timestamp ;

: timestamp>timespec ( timestamp -- timespec )
    timestamp>unix-time "timespec" <c-object>
    [ set-timespec-sec ] keep ;

: timespec>timestamp ( timespec -- timestamp )
    [ timespec-sec ] keep
    timespec-nsec 1000000000 / +
    unix-time>timestamp ;
