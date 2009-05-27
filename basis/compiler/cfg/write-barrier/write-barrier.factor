! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sets sequences locals
compiler.cfg compiler.cfg.instructions compiler.cfg.copy-prop
compiler.cfg.rpo ;
IN: compiler.cfg.write-barrier

! Eliminate redundant write barrier hits.

! Objects which have already been marked, as well as
! freshly-allocated objects
SYMBOL: safe

! Objects which have been mutated
SYMBOL: mutated

GENERIC: eliminate-write-barrier ( insn -- insn' )

M: ##allot eliminate-write-barrier
    dup dst>> safe get conjoin ;

M: ##write-barrier eliminate-write-barrier
    dup src>> resolve dup
    [ safe get key? not ]
    [ mutated get key? ] bi and
    [ safe get conjoin ] [ 2drop f ] if ;

M: ##copy eliminate-write-barrier
    dup record-copy ;

M: ##set-slot eliminate-write-barrier
    dup obj>> resolve mutated get conjoin ;

M: ##set-slot-imm eliminate-write-barrier
    dup obj>> resolve mutated get conjoin ;

M: insn eliminate-write-barrier ;

: write-barriers-step ( insns -- insns' )
    H{ } clone safe set
    H{ } clone mutated set
    H{ } clone copies set
    [ eliminate-write-barrier ] map sift ;

: eliminate-write-barriers ( rpo -- )
    [ ] [ write-barriers-step ] local-optimization ;
