! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sets sequences
compiler.vops compiler.cfg ;
IN: compiler.cfg.write-barrier

! Eliminate redundant write barrier hits.
SYMBOL: hits

GENERIC: eliminate-write-barrier* ( insn -- insn' )

M: %%allot eliminate-write-barrier*
    dup out>> hits get conjoin ;

M: %write-barrier eliminate-write-barrier*
    dup in>> hits get key?
    [ drop nop ] [ dup in>> hits get conjoin ] if ;

M: %copy eliminate-write-barrier*
    dup in/out hits get copy-at ;

M: vop eliminate-write-barrier* ;

: eliminate-write-barrier ( insns -- insns )
    H{ } clone hits set
    [ eliminate-write-barrier* ] map ;
