! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien.syntax alien.c-types math unix.types ;
IN: unix.time

C-STRUCT: timeval
    { "long" "sec" }
    { "long" "usec" } ;

C-STRUCT: timespec
    { "time_t" "sec" }
    { "long" "nsec" } ;

: make-timeval ( us -- timeval )
    1000000 /mod
    "timeval" <c-object>
    [ set-timeval-usec ] keep
    [ set-timeval-sec ] keep ;

: make-timespec ( us -- timespec )
    1000000 /mod 1000 *
    "timespec" <c-object>
    [ set-timespec-nsec ] keep
    [ set-timespec-sec ] keep ;

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
FUNCTION: int gettimeofday ( timespec* TP, void* TZP ) ;
