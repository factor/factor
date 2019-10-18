! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: interval-maps namespaces simple-flat-file ;
IN: unicode.script

<PRIVATE

SYMBOL: script-table

"vocab:unicode/script/Scripts.txt" load-interval-file
script-table set-global

PRIVATE>

: script-of ( char -- script )
    script-table get-global interval-at ;
