! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces io ;
IN: xml.state

TUPLE: spot char line column next check ;

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

SYMBOL: xml-stack

SYMBOL: prolog-data

SYMBOL: depth
