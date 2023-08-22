! Copyright (C) 2022 Cat Stevens.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax kernel sequences ;
IN: unix.scheduler

! Note: Feature "_POSIX_PRIORITY_SCHEDULING"
! Scheduling policy values from <sched.h>
CONSTANT: SCHED_OTHER 0
CONSTANT: SCHED_FIFO  1
CONSTANT: SCHED_RR    2

! Note: Feature "__USE_GNU"
CONSTANT: SCHED_BATCH    3
CONSTANT: SCHED_ISO      4
CONSTANT: SCHED_IDLE     5
CONSTANT: SCHED_DEADLINE 6

CONSTANT: SCHED_RESET_ON_FORK 0x40000000
! end __USE_GNU

CONSTANT: MOST_IDLE_SCHED_POLICY 5

FUNCTION: int sched_get_priority_min ( int policy )
FUNCTION: int sched_get_priority_max ( int policy )

: policy-priority-range ( policy -- high low )
    [ sched_get_priority_max ] [ sched_get_priority_min ] bi ;

: priority-allowed? ( policy -- ? )
    { SCHED_IDLE SCHED_OTHER SCHED_BATCH } member? not ;
