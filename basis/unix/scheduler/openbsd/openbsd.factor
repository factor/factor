! Copyright (C) 2022 Cat Stevens.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax kernel ;
IN: unix.scheduler

CONSTANT: SCHED_FIFO  1
CONSTANT: SCHED_OTHER 2
CONSTANT: SCHED_RR    3

CONSTANT: MOST_IDLE_SCHED_POLICY 2

FUNCTION: int sched_get_priority_min ( int policy )
FUNCTION: int sched_get_priority_max ( int policy )

: policy-priority-range ( policy -- high low )
    [ sched_get_priority_max ] [ sched_get_priority_min ] bi ;

: priority-allowed? ( policy -- ? )
    SCHED_OTHER = not ;
