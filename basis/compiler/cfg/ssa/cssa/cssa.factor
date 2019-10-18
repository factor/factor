! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel locals fry sequences
cpu.architecture
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.representations ;
IN: compiler.cfg.ssa.cssa

! Convert SSA to conventional SSA. This pass runs after representation
! selection, so it must keep track of representations when introducing
! new values.

: insert-copy? ( bb vreg -- ? )
    ! If the last instruction defines a value (which means it is
    ! ##fixnum-add, ##fixnum-sub or ##fixnum-mul) then we don't
    ! need to insert a copy since in fact doing so will result
    ! in incorrect code.
    [ instructions>> last defs-vreg ] dip eq? not ;

:: insert-copy ( bb src rep -- bb dst )
    bb src insert-copy? [
        rep next-vreg-rep :> dst
        bb [ dst src rep src rep-of emit-conversion ] add-instructions
        bb dst
    ] [ bb src ] if ;

: convert-phi ( ##phi -- )
    dup dst>> rep-of '[ [ _ insert-copy ] assoc-map ] change-inputs drop ;

: construct-cssa ( cfg -- )
    [ [ convert-phi ] each-phi ] each-basic-block ;