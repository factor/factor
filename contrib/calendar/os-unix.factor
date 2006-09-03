IN: calendar
USING: alien arrays compiler errors kernel math ;

TYPEDEF: uint time_t
BEGIN-STRUCT: t
    FIELD: long tv_sec
    FIELD: long tv_usec
END-STRUCT

FUNCTION: time_t time ( time_t* t ) ;
FUNCTION: tm* localtime ( time_t* clock ) ;

: get-time
    f time <uint> localtime ;







! BEGIN-STRUCT: tz
    ! FIELD: int tz_minuteswest
    ! FIELD: int tz_dsttime
! END-STRUCT

! FUNCTION: int gettimeofday ( t* timeval, tz* timezone ) ;

! : machine-gmt-offset
    ! "t" <c-object> "tz" <c-object> 2dup gettimeofday
    ! zero? [ nip tz-tz_minuteswest 60 / neg ] [ 2drop 0 ] if ;

