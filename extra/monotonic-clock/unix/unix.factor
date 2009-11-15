! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax calendar.unix classes.struct
kernel monotonic-clock system unix unix.time unix.types ;
IN: monotonic-clock.unix

LIBRARY: librt

FUNCTION: int clock_settime ( clockid_t clock_id, timespec* tp ) ;
FUNCTION: int clock_gettime ( clockid_t clock_id, timespec* tp ) ;
FUNCTION: int clock_getres ( clockid_t clock_id, timespec* res ) ;

CONSTANT: CLOCK_REALTIME 0
CONSTANT: CLOCK_MONOTONIC 1
CONSTANT: CLOCK_PROCESS_CPUTIME_ID 2
CONSTANT: CLOCK_THREAD_CPUTIME_ID 3

CONSTANT: TIMER_ABSTIME 1

M: unix monotonic-count
    CLOCK_MONOTONIC timespec <struct> [ clock_gettime io-error ] keep
    timespec>nanoseconds ;
