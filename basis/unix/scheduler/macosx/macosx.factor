! Copyright (C) 2022 Cat Stevens.
! See https://factorcode.org/license.txt for BSD license.
USING: system vocabs.metadata ;
IN: unix.scheduler

CONSTANT: MOST_IDLE_SCHED_POLICY f

: policy-priority-range ( policy -- high low )
    os bad-platform ;

: priority-allowed? ( policy -- ? )
    os bad-platform ;
