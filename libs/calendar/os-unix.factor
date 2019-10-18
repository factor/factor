IN: calendar
USING: alien arrays compiler errors kernel math unix-internals ;

TYPEDEF: uint time_t

C-STRUCT: tm
    { "int" "sec" }    ! Seconds: 0-59 (K&R says 0-61?)
    { "int" "min" }    ! Minutes: 0-59
    { "int" "hour" }   ! Hours since midnight: 0-23
    { "int" "mday" }   ! Day of the month: 1-31
    { "int" "mon" }    ! Months *since* january: 0-11
    { "int" "year" }   ! Years since 1900
    { "int" "wday" }   ! Days since Sunday (0-6)
    { "int" "yday" }   ! Days since Jan. 1: 0-365
    { "int" "isdst" }  ! +1 Daylight Savings Time, 0 No DST,
    { "long" "gmtoff" } ! Seconds: 0-59 (K&R says 0-61?)
    { "char*" "zone" } ;

FUNCTION: time_t time ( time_t* t ) ;
FUNCTION: tm* localtime ( time_t* clock ) ;

: get-time
    f time <uint> localtime ;

: timezone-name
    get-time tm-zone ;

: gmt-offset
    get-time tm-gmtoff 3600 / ;

: timestamp>timeval ( timestamp -- timeval )
    timestamp>unix-time 1000 * make-timeval ;

: timeval>timestamp ( timeval -- timestamp )
    [ timeval-sec ] keep
    timeval-usec 1000000 / + unix-time>timestamp ;

C-STRUCT: timespec
    { "time_t" "sec" }
    { "long" "nsec" } ;

: timestamp>timespec ( timestamp -- timespec )
    timestamp>unix-time "timespec" <c-object>
    [ set-timespec-sec ] keep ;

: timespec>timestamp ( timespec -- timestamp )
    [ timespec-sec ] keep
    timespec-nsec 1000000000 / +
    unix-time>timestamp ;
