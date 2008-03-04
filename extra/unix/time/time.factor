
USING: kernel alien.syntax alien.c-types math ;

IN: unix.time

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

C-STRUCT: timespec
    { "time_t" "sec" }
    { "long" "nsec" } ;

: make-timespec ( ms -- timespec )
    1000 /mod 1000000 *
    "timespec" <c-object>
    [ set-timespec-nsec ] keep
    [ set-timespec-sec ] keep ;

FUNCTION: time_t time ( time_t* t ) ;
FUNCTION: tm* localtime ( time_t* clock ) ;