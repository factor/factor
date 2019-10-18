! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint
USING: alien arrays generic hashtables io kernel math
namespaces parser sequences strings styles vectors words ;

! Configuration
SYMBOL: tab-size
SYMBOL: margin
SYMBOL: nesting-limit
SYMBOL: length-limit
SYMBOL: line-limit
SYMBOL: string-limit

! Special trick to highlight a word in a quotation
SYMBOL: hilite-quotation
SYMBOL: hilite-index
SYMBOL: hilite-next?

IN: prettyprint-internals

! State
SYMBOL: position
SYMBOL: last-newline
SYMBOL: recursion-check
SYMBOL: line-count
SYMBOL: end-printing
SYMBOL: indent
SYMBOL: pprinter-stack

! Utility words
: line-limit? ( -- ? )
    line-limit get dup [ line-count get <= ] when ;

: do-indent ( -- ) indent get CHAR: \s <string> write ;

: fresh-line ( n -- )
    dup last-newline get = [
        drop
    ] [
        last-newline set
        line-limit? [ "..." write end-printing get continue ] when
        line-count inc
        terpri do-indent
    ] if ;

: text-fits? ( len -- ? )
    indent get + margin get <= ;

global [
    4 tab-size set
    64 margin set
    0 position set
    0 indent set
    0 last-newline set
    1 line-count set
    string-limit off
] bind
