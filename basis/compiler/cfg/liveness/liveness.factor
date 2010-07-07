! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors assocs namespaces sequences sets
compiler.cfg.def-use compiler.cfg.dataflow-analysis
compiler.cfg.instructions compiler.cfg.registers
cpu.architecture ;
IN: compiler.cfg.liveness

! See http://en.wikipedia.org/wiki/Liveness_analysis
! Do not run after SSA construction; compiler.cfg.liveness.ssa
! should be used instead. The transfer-liveness word is used
! by SSA liveness too, so it handles ##phi instructions.

BACKWARD-ANALYSIS: live

GENERIC: visit-insn ( live-set insn -- live-set )

: kill-defs ( live-set insn -- live-set )
    defs-vreg [ over delete-at ] when* ; inline

: gen-uses ( live-set insn -- live-set )
    uses-vregs [ over conjoin ] each ; inline

M: vreg-insn visit-insn [ kill-defs ] [ gen-uses ] bi ;

: fill-gc-map ( live-set insn -- live-set )
    representations get [
        gc-map>> over keys
        [ rep-of tagged-rep? ] filter
        >>gc-roots
    ] when
    drop ;

M: gc-map-insn visit-insn
    [ kill-defs ] [ fill-gc-map ] [ gen-uses ] tri ;

M: ##phi visit-insn kill-defs ;

M: insn visit-insn drop ;

: transfer-liveness ( live-set instructions -- live-set' )
    [ clone ] [ <reversed> ] bi* [ visit-insn ] each ;

: local-live-in ( instructions -- live-set )
    [ H{ } ] dip transfer-liveness keys ;

M: live-analysis transfer-set
    drop instructions>> transfer-liveness ;

M: live-analysis join-sets
    2drop assoc-combine ;
