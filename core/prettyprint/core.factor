! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint
USING: alien arrays generic assocs io kernel math
namespaces sequences strings styles vectors words ;

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

IN: prettyprint-internals

! State
SYMBOL: position
SYMBOL: recursion-check
SYMBOL: pprinter-stack

SYMBOL: last-newline
SYMBOL: line-count
SYMBOL: end-printing
SYMBOL: indent

! We record vocabs of all words
SYMBOL: pprinter-in
SYMBOL: pprinter-use

: record-vocab ( word -- )
    word-vocabulary [ dup pprinter-use get set-at ] when* ;

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
        nl do-indent
    ] if ;

: text-fits? ( len -- ? )
    margin get dup zero?
    [ 2drop t ] [ >r indent get + r> <= ] if ;

global [
    4 tab-size set
    64 margin set
    string-limit off
] bind
