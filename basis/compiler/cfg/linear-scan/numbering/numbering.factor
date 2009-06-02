! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math sequences ;
IN: compiler.cfg.linear-scan.numbering

: number-instructions ( rpo -- )
    [ 0 ] dip [
        instructions>> [
            [ (>>insn#) ] [ drop 2 + ] 2bi
        ] each
    ] each drop ;