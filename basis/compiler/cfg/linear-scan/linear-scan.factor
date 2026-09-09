! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.resolve compiler.cfg.utilities cpu.architecture
kernel locals namespaces sequences ;
IN: compiler.cfg.linear-scan

: admissible-registers ( cfg -- regs )
    machine-registers swap frame-pointer?>> [
        [ [ frame-reg = ] reject ] assoc-map
    ] when ;

:: allocate-and-assign-with-registers ( cfg registers -- )
    cfg compute-live-intervals :> input
    check-allocation? get [ input required-register-uses ] [ f ] if :> uses
    input registers allocate-registers :> intervals
    check-allocation? get [
        intervals registers check-allocated-intervals
        intervals uses check-register-uses
    ] when
    cfg intervals assign-registers ;

: allocate-and-assign-registers ( cfg -- )
    dup admissible-registers allocate-and-assign-with-registers ;

:: linear-scan-with-registers ( cfg registers -- )
    cfg number-instructions
    cfg registers allocate-and-assign-with-registers
    cfg resolve-data-flow
    cfg check-numbering ;

: linear-scan ( cfg -- )
    {
        number-instructions
        allocate-and-assign-registers
        resolve-data-flow
        check-numbering
    } apply-passes ;
