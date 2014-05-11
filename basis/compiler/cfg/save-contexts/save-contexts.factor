! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.rpo cpu.architecture kernel sequences vectors
combinators.short-circuit ;
IN: compiler.cfg.save-contexts

! Insert context saves.

GENERIC: needs-save-context? ( insn -- ? )

M: gc-map-insn needs-save-context? drop t ;
M: insn needs-save-context? drop f ;

: bb-needs-save-context? ( bb -- ? )
    {
        [ kill-block?>> not ]
        [ instructions>> [ needs-save-context? ] any? ]
    } 1&& ;

GENERIC: modifies-context? ( insn -- ? )

M: ##phi modifies-context? drop t ;
M: ##inc-d modifies-context? drop t ;
M: ##inc-r modifies-context? drop t ;
M: ##callback-inputs modifies-context? drop t ;
M: insn modifies-context? drop f ;

: save-context-offset ( bb -- n )
    ! ##save-context must be placed after instructions that
    ! modify the context, or instructions that read parameter
    ! registers.
    instructions>> [ modifies-context? not ] find drop ;

: insert-save-context ( bb -- )
    dup bb-needs-save-context? [
        [
            int-rep next-vreg-rep
            int-rep next-vreg-rep
            ##save-context new-insn
        ] dip
        [ save-context-offset ] keep
        [ insert-nth ] change-instructions drop
    ] [ drop ] if ;

: insert-save-contexts ( cfg -- cfg' )
    dup [ insert-save-context ] each-basic-block ;
