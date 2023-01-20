! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.linearization grouping kernel math
namespaces sequences ;
IN: compiler.cfg.linear-scan.numbering

: number-instruction ( n insn -- n' )
    [ insn#<< ] [ drop 2 + ] 2bi ;

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
