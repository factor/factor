! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: values interval-maps simple-flat-file ;
IN: unicode.script

<PRIVATE

VALUE: script-table

"vocab:unicode/script/Scripts.txt" load-interval-file
to: script-table

PRIVATE>

: script-of ( char -- script )
    script-table interval-at ;
