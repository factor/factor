! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors command-line io kernel namespaces sequences
sequences.extras slides ui.gadgets vocabs words ;

IN: slides.cli

: clear-screen ( -- )
    "\033[2J\033[H" print flush ;

: title. ( title -- )
    80 CHAR: - pad-center print nl ;

: slide. ( slide -- )
    <page> gadget-text print flush ;

: slides. ( slides title -- )
    '[ clear-screen _ title. slide. readln drop ] each ;

MAIN: [
    command-line get [
        ?load-vocab main>> def>> first2
        [ dup word? [ execute( -- slides ) ] when ]
        [ slides. ] bi*
    ] each
]
