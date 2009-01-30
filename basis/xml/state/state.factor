! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces io ;
IN: xml.state

TUPLE: spot char line column next check version-1.0? ;

C: <spot> spot

: get-char ( -- char ) spot get char>> ;
: set-char ( char -- ) spot get swap >>char drop ;
: get-line ( -- line ) spot get line>> ;
: set-line ( line -- ) spot get swap >>line drop ;
: get-column ( -- column ) spot get column>> ;
: set-column ( column -- ) spot get swap >>column drop ;
: get-next ( -- char ) spot get next>> ;
: set-next ( char -- ) spot get swap >>next drop ;
: get-check ( -- ? ) spot get check>> ;
: check ( -- ) spot get t >>check drop ;
: version-1.0? ( -- ? ) spot get version-1.0?>> ;
: set-version ( string -- )
    spot get swap "1.0" = >>version-1.0? drop ;

SYMBOL: xml-stack

SYMBOL: depth

SYMBOL: interpolating?

SYMBOL: in-dtd?

SYMBOL: pe-table

SYMBOL: extra-entities
