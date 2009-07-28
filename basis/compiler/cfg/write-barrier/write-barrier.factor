! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sets sequences
compiler.cfg compiler.cfg.instructions compiler.cfg.rpo ;
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

: write-barriers-step ( bb -- )
    H{ } clone safe set
    H{ } clone mutated set
    instructions>> [ eliminate-write-barrier ] filter-here ;

: eliminate-write-barriers ( cfg -- cfg' )
    dup [ write-barriers-step ] each-basic-block ;
