IN: calendar
USING: alien arrays compiler errors kernel math ;

TYPEDEF: uint time_t

BEGIN-STRUCT: tm
    FIELD: int sec     ! Seconds: 0-59 (K&R says 0-61?)
    FIELD: int min     ! Minutes: 0-59
    FIELD: int hour    ! Hours since midnight: 0-23
    FIELD: int mday    ! Day of the month: 1-31
    FIELD: int mon     ! Months *since* january: 0-11
    FIELD: int year    ! Years since 1900
    FIELD: int wday    ! Days since Sunday (0-6)
    FIELD: int yday    ! Days since Jan. 1: 0-365
    FIELD: int isdst   ! +1 Daylight Savings Time, 0 No DST,
    FIELD: long gmtoff
    FIELD: char* zone
END-STRUCT

FUNCTION: time_t time ( time_t* t ) ;
FUNCTION: tm* localtime ( time_t* clock ) ;

BEGIN-STRUCT: t
    FIELD: long tv_sec
    FIELD: long tv_usec
END-STRUCT

: timezone-name
    get-time tm-zone ;

: gmt-offset
    get-time tm-gmtoff 3600 / ;

