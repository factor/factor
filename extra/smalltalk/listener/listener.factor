! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: colors debugger io io.styles kernel smalltalk.ast
smalltalk.eval smalltalk.printer ;
IN: smalltalk.listener

: eval-interactively ( string -- )
    '[
        _ eval-smalltalk
        dup nil? [ drop ] [ "Result: " write smalltalk>string print ] if
    ] try ;

: smalltalk-listener ( -- )
    "Smalltalk>" { { background COLOR: light-blue } } format bl flush readln
    [ eval-interactively smalltalk-listener ] when* ;

MAIN: smalltalk-listener
