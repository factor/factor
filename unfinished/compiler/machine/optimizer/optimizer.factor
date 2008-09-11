! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math namespaces make sequences
sequences.next
compiler.instructions
compiler.instructions.syntax
compiler.machine ;
IN: compiler.machine.optimizer

: frame-required ( insns -- n/f )
    [ %frame-required? ] filter
    [ f ] [ [ n>> ] map supremum ] if-empty ;

GENERIC: optimize* ( next insn -- )

: useless-branch? ( next insn -- ? )
    over _label? [ [ label>> ] bi@ = ] [ 2drop f ] if ;

M: _branch optimize*
    #! Remove unconditional branches to labels immediately
    #! following.
    tuck useless-branch? [ drop ] [ , ] if ;

M: %prologue optimize*
    2drop \ frame-required get [ _prologue ] when* ;

M: %epilogue optimize*
    2drop \ frame-required get [ _epilogue ] when* ;

M: %frame-required optimize* 2drop ;

M: insn optimize* nip , ;

: optimize-machine ( insns -- insns )
    [
        [ frame-required \ frame-required set ]
        [ [ optimize* ] each-next ]
        bi
    ] { } make ;
