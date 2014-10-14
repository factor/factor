! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors assocs sequences namespaces make locals
cpu.architecture
compiler.cfg
compiler.cfg.rpo
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.resolve ;
FROM: assocs => change-at ;
IN: compiler.cfg.linear-scan

! References:

! Linear Scan Register Allocation
! by Massimiliano Poletto and Vivek Sarkar
! http://www.cs.ucla.edu/~palsberg/course/cs132/linearscan.pdf

! Linear Scan Register Allocation for the Java HotSpot Client Compiler
! by Christian Wimmer
! and http://www.ssw.uni-linz.ac.at/Research/Papers/Wimmer04Master/

! Quality and Speed in Linear-scan Register Allocation
! by Omri Traub, Glenn Holloway, Michael D. Smith
! http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.34.8435

! SSA liveness must have been computed already

:: (linear-scan) ( cfg machine-registers -- )
    cfg number-instructions
    cfg compute-live-intervals machine-registers allocate-registers
    cfg assign-registers
    cfg resolve-data-flow
    cfg check-numbering ;

: admissible-registers ( cfg -- regs )
    drop machine-registers ;

: linear-scan ( cfg -- cfg' )
    dup dup admissible-registers (linear-scan) ;
