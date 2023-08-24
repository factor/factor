! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.rpo cpu.architecture kernel sequences ;
IN: compiler.cfg.save-contexts

UNION: context-modifier ##phi ##inc ##callback-inputs ;

: save-context-offset ( insns -- n )
    [ context-modifier? not ] find drop ;

UNION: needs-save-context-insn
    ##alien-invoke
    ##alien-indirect
    ##box-long-long
    ##box ;

: insns-needs-save-context? ( insns -- ? )
    [ needs-save-context-insn? ] any? ;

: insert-save-context ( insns -- insns' )
    dup insns-needs-save-context? [
        [
            int-rep next-vreg-rep
            int-rep next-vreg-rep
            ##save-context new-insn
        ] dip
        [ save-context-offset ] keep
        insert-nth
    ] when ;

: insert-save-contexts ( cfg -- )
    [ insert-save-context ] simple-optimization ;
