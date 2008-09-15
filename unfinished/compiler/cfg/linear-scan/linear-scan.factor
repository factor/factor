! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors
compiler.backend
compiler.cfg
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.assignment ;
IN: compiler.cfg.linear-scan

! See http://www.cs.ucla.edu/~palsberg/course/cs132/linearscan.pdf
! and http://www.ssw.uni-linz.ac.at/Research/Papers/Wimmer04Master/

: linear-scan ( mr -- mr' )
    [
        dup compute-live-intervals
        machine-registers allocate-registers
        assign-registers
    ] change-instructions ;
