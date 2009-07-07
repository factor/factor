! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math sequences grouping namespaces ;
IN: compiler.cfg.linear-scan.numbering

: number-instructions ( rpo -- )
    [ 0 ] dip [
        instructions>> [
            [ (>>insn#) ] [ drop 2 + ] 2bi
        ] each
    ] each drop ;

SYMBOL: check-numbering?

ERROR: bad-numbering bb ;

: check-block-numbering ( bb -- )
    dup instructions>> [ insn#>> ] map sift [ <= ] monotonic?
    [ drop ] [ bad-numbering ] if ;

: check-numbering ( rpo -- )
    check-numbering? get [ [ check-block-numbering ] each ] [ drop ] if ;