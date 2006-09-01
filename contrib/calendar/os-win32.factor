IN: calendar
USING: alien kernel math win32-api ;




: tz "_TIME_ZONE_INFORMATION" <c-object> dup GetTimeZoneInformation
    TIME_ZONE_ID_INVALID = [
        win32-error
    ] when alien-address 4 + <alien> alien>u16-string ;








! TYPEDEF: longlong time_t
! TYPEDEF: longlong __time64_t
! TYPEDEF: int errno_t
! 
! BEGIN-STRUCT: tm
    ! FIELD: int tm_sec;     ! Seconds: 0-59 (K&R says 0-61?)
    ! FIELD: int tm_min;     ! Minutes: 0-59
    ! FIELD: int tm_hour;    ! Hours since midnight: 0-23
    ! FIELD: int tm_mday;    ! Day of the month: 1-31
    ! FIELD: int tm_mon;     ! Months *since* january: 0-11
    ! FIELD: int tm_year;    ! Years since 1900
    ! FIELD: int tm_wday;    ! Days since Sunday (0-6)
    ! FIELD: int tm_yday;    ! Days since Jan. 1: 0-365
    ! FIELD: int tm_isdst    ! +1 Daylight Savings Time, 0 No DST,
! END-STRUCT
! 
! FUNCTION: errno_t _localtime64_s ( tm* _tm, __time64_t *time ) ;

