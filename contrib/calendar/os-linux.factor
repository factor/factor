IN: calendar


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
END-STRUCT

