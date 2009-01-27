! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: words assocs kernel accessors parser sequences summary
lexer splitting fry ;
IN: xml.dispatch

TUPLE: process-missing process tag ;
M: process-missing summary
    drop "Tag not implemented on process" ;

: run-process ( tag word -- )
    2dup "xtable" word-prop
    [ dup main>> ] dip at* [ 2nip call ] [
        drop \ process-missing boa throw
    ] if ;

: PROCESS:
    CREATE
    dup H{ } clone "xtable" set-word-prop
    dup '[ _ run-process ] define ; parsing

: TAG:
    scan scan-word
    parse-definition
    swap "xtable" word-prop
    rot "/" split [ [ 2dup ] dip swap set-at ] each 2drop ;
    parsing
