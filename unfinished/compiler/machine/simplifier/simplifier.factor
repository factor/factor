! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces sequences.next compiler.lvops ;
IN: compiler.machine.simplifier

: useless-branch? ( next insn -- ? )
    2dup [ _label? ] [ _b? ] bi* and
    [ [ label>> ] bi@ = ] [ 2drop f ] if ;

: simplify-mr ( insns -- insns )
    #! Remove unconditional branches to labels immediately
    #! following.
    [
        [
            tuck useless-branch?
            [ drop ] [ , ] if
        ] each-next
    ] { } make ;
