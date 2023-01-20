! Copyright (C) 2008, 2010 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit
compiler.cfg.instructions compiler.cfg.rpo kernel namespaces
sequences sets ;
IN: compiler.cfg.write-barrier

! This pass must run after GC check insertion and scheduling.

SYMBOL: fresh-allocations

SYMBOL: mutated-objects

SYMBOL: copies

: resolve-copy ( src -- dst )
    copies get ?at drop ;

GENERIC: eliminate-write-barrier ( insn -- ? )

: fresh-allocation ( vreg -- )
    fresh-allocations get adjoin ;

M: ##allot eliminate-write-barrier
    dst>> fresh-allocation t ;

: mutated-object ( vreg -- )
    resolve-copy mutated-objects get adjoin ;

M: ##set-slot eliminate-write-barrier
    obj>> mutated-object t ;

M: ##set-slot-imm eliminate-write-barrier
    obj>> mutated-object t ;

: needs-write-barrier? ( insn -- ? )
    resolve-copy {
        [ fresh-allocations get in? not ]
        [ mutated-objects get in? ]
    } 1&& ;

M: ##write-barrier eliminate-write-barrier
    src>> needs-write-barrier? ;

M: ##write-barrier-imm eliminate-write-barrier
    src>> needs-write-barrier? ;

M: gc-map-insn eliminate-write-barrier
    fresh-allocations get clear-set ;

M: ##copy eliminate-write-barrier
    [ src>> resolve-copy ] [ dst>> ] bi copies get set-at t ;

M: insn eliminate-write-barrier drop t ;

: write-barriers-step ( insns -- insns' )
    HS{ } clone fresh-allocations namespaces:set
    HS{ } clone mutated-objects namespaces:set
    H{ } clone copies namespaces:set
    [ eliminate-write-barrier ] filter! ;

: eliminate-write-barriers ( cfg -- )
    [ write-barriers-step ] simple-optimization ;
