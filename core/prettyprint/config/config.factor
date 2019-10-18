! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint.config
USING: alien arrays generic assocs io kernel math
namespaces sequences strings io.styles vectors words
continuations ;

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

global [
    4 tab-size set
    64 margin set
    string-limit off
] bind
