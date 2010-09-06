! Copyright (C) 2008, 2010 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit
compiler.cfg.instructions compiler.cfg.rpo kernel namespaces
sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.write-barrier

! This pass must run after GC check insertion and scheduling.

SYMBOL: fresh-allocations

SYMBOL: mutated-objects

SYMBOL: copies

: resolve-copy ( src -- dst )
    copies get ?at drop ;

GENERIC: eliminate-write-barrier ( insn -- ? )

: fresh-allocation ( vreg -- )
    fresh-allocations get conjoin ;

M: ##allot eliminate-write-barrier
    dst>> fresh-allocation t ;

: mutated-object ( vreg -- )
    resolve-copy mutated-objects get conjoin ;

M: ##set-slot eliminate-write-barrier
    obj>> mutated-object t ;

M: ##set-slot-imm eliminate-write-barrier
    obj>> mutated-object t ;

: needs-write-barrier? ( insn -- ? )
    resolve-copy {
        [ fresh-allocations get key? not ]
        [ mutated-objects get key? ]
    } 1&& ;

M: ##write-barrier eliminate-write-barrier
    src>> needs-write-barrier? ;

M: ##write-barrier-imm eliminate-write-barrier
    src>> needs-write-barrier? ;

M: gc-map-insn eliminate-write-barrier
    fresh-allocations get clear-assoc ;

M: ##copy eliminate-write-barrier
    [ src>> ] [ dst>> ] bi copies get set-at t ;

M: insn eliminate-write-barrier drop t ;

: write-barriers-step ( insns -- insns' )
    H{ } clone fresh-allocations set
    H{ } clone mutated-objects set
    H{ } clone copies set
    [ eliminate-write-barrier ] filter! ;

: eliminate-write-barriers ( cfg -- cfg )
    dup [ write-barriers-step ] simple-optimization ;
