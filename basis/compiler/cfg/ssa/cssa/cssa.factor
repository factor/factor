! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel locals fry
cpu.architecture
compiler.cfg.rpo
compiler.cfg.utilities
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.representations ;
IN: compiler.cfg.ssa.cssa

! Convert SSA to conventional SSA.

:: insert-copy ( bb src rep -- bb dst )
    rep next-vreg :> dst
    bb [ dst src rep src rep>> emit-conversion ] add-instructions
    bb dst ;

: convert-phi ( ##phi -- )
    dup dst>> rep>> '[ [ _ insert-copy ] assoc-map ] change-inputs drop ;

: construct-cssa ( cfg -- )
    [ [ convert-phi ] each-phi ] each-basic-block ;