! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

IN: !syntax
USING: kernel lists math parser sequences syntax vectors ;

! Complex numbers
: #{ f ; parsing
: }# dup first swap second rect> swons ; parsing

! Reading integers in other bases
: (BASE) ( base -- )
    #! Reads an integer in a specific base.
    scan swap base> swons ;

: HEX: 16 (BASE) ; parsing
: DEC: 10 (BASE) ; parsing
: OCT: 8 (BASE) ; parsing
: BIN: 2 (BASE) ; parsing
