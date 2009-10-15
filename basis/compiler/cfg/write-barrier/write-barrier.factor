! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit
compiler.cfg.instructions compiler.cfg.rpo kernel namespaces
sequences sets ;
IN: compiler.cfg.write-barrier

SYMBOL: fresh-allocations

SYMBOL: mutated-objects

GENERIC: eliminate-write-barrier ( insn -- ? )

M: ##allot eliminate-write-barrier
    dst>> fresh-allocations get conjoin t ;

M: ##set-slot eliminate-write-barrier
    obj>> mutated-objects get conjoin t ;

M: ##set-slot-imm eliminate-write-barrier
    obj>> mutated-objects get conjoin t ;

: needs-write-barrier? ( insn -- ? )
    { [ fresh-allocations get key? not ] [ mutated-objects get key? ] } 1&& ;

M: ##write-barrier eliminate-write-barrier
    src>> needs-write-barrier? ;

M: ##write-barrier-imm eliminate-write-barrier
    src>> needs-write-barrier? ;

M: ##copy eliminate-write-barrier
    "Run copy propagation first" throw ;

M: insn eliminate-write-barrier drop t ;

: write-barriers-step ( bb -- )
    H{ } clone fresh-allocations set
    H{ } clone mutated-objects set
    instructions>> [ eliminate-write-barrier ] filter-here ;

: eliminate-write-barriers ( cfg -- cfg' )
    dup [ write-barriers-step ] each-basic-block ;
