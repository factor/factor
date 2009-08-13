! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sets sequences
compiler.cfg compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.dataflow-analysis fry combinators.short-circuit ;
IN: compiler.cfg.write-barrier

! Eliminate redundant write barrier hits.

! Objects which have already been marked, as well as
! freshly-allocated objects
SYMBOL: safe

! Objects which have been mutated
SYMBOL: mutated

GENERIC: eliminate-write-barrier ( insn -- ? )

M: ##allot eliminate-write-barrier
    dst>> safe get conjoin t ;

M: ##write-barrier eliminate-write-barrier
    src>> dup [ safe get key? not ] [ mutated get key? ] bi and
    [ safe get conjoin t ] [ drop f ] if ;

M: ##set-slot eliminate-write-barrier
    obj>> mutated get conjoin t ;

M: ##set-slot-imm eliminate-write-barrier
    obj>> mutated get conjoin t ;

M: insn eliminate-write-barrier drop t ;

FORWARD-ANALYSIS: safe

: has-allocation? ( bb -- ? )
    instructions>> [ { [ ##allocation? ] [ ##call? ] } 1|| ] any? ;

M: safe-analysis transfer-set
    drop [ H{ } assoc-clone-like ] dip
    instructions>> over '[
        dup ##write-barrier? [
            src>> _ conjoin
        ] [ drop ] if
    ] each ;

M: safe-analysis join-sets
    drop has-allocation? [ drop H{ } clone ] [ assoc-refine ] if ;

: write-barriers-step ( bb -- )
    dup safe-in H{ } assoc-clone-like safe set
    H{ } clone mutated set
    instructions>> [ eliminate-write-barrier ] filter-here ;

: eliminate-write-barriers ( cfg -- cfg' )
     dup compute-safe-sets
    dup [ write-barriers-step ] each-basic-block ;
