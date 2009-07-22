! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math sequences grouping namespaces
compiler.cfg.rpo ;
IN: compiler.cfg.linear-scan.numbering

: number-instructions ( rpo -- )
    [ 0 ] dip [
        instructions>> [
            [ (>>insn#) ] [ drop 2 + ] 2bi
        ] each
    ] each-basic-block drop ;

SYMBOL: check-numbering?

ERROR: bad-numbering bb ;

: check-block-numbering ( bb -- )
    dup instructions>> [ insn#>> ] map sift [ <= ] monotonic?
    [ drop ] [ bad-numbering ] if ;

: check-numbering ( cfg -- )
    check-numbering? get [ [ check-block-numbering ] each-basic-block ] [ drop ] if ;