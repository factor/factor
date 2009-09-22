! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors math sequences grouping namespaces
compiler.cfg.linearization.order ;
IN: compiler.cfg.linear-scan.numbering

ERROR: already-numbered insn ;

: number-instruction ( n insn -- n' )
    [ nip dup insn#>> [ already-numbered ] [ drop ] if ]
    [ (>>insn#) ]
    [ drop 2 + ]
    2tri ;

: number-instructions ( cfg -- )
    linearization-order
    0 [ instructions>> [ number-instruction ] each ] reduce
    drop ;

SYMBOL: check-numbering?

ERROR: bad-numbering bb ;

: check-block-numbering ( bb -- )
    dup instructions>> [ insn#>> ] map sift [ <= ] monotonic?
    [ drop ] [ bad-numbering ] if ;

: check-numbering ( cfg -- )
    check-numbering? get
    [ linearization-order [ check-block-numbering ] each ] [ drop ] if ;