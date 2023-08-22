! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces ;
IN: xml.state

TUPLE: spot char line column next check version-1.0? stream ;

C: <spot> spot

: get-char ( -- char ) spot get char>> ; inline
: get-line ( -- line ) spot get line>> ; inline
: get-column ( -- column ) spot get column>> ; inline
: get-next ( -- char ) spot get next>> ; inline
: get-check ( -- ? ) spot get check>> ; inline
: check ( -- ) spot get t >>check drop ; inline
: version-1.0? ( -- ? ) spot get version-1.0?>> ; inline
: set-version ( string -- )
    spot get swap "1.0" = >>version-1.0? drop ; inline

SYMBOL: xml-stack
SYMBOL: depth
SYMBOL: interpolating?
SYMBOL: in-dtd?
SYMBOL: pe-table
SYMBOL: extra-entities
