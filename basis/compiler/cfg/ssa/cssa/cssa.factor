! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel locals
compiler.cfg.rpo
compiler.cfg.hats
compiler.cfg.utilities
compiler.cfg.instructions ;
IN: compiler.cfg.ssa.cssa

! Convert SSA to conventional SSA.

:: insert-copy ( bb src -- bb dst )
    i :> dst
    bb [ dst src ##copy ] add-instructions
    bb dst ;

: convert-phi ( ##phi -- )
    [ [ insert-copy ] assoc-map ] change-inputs drop ;

: construct-cssa ( cfg -- )
    [ [ convert-phi ] each-phi ] each-basic-block ;