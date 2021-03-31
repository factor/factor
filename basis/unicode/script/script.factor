! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: interval-maps simple-flat-file ;
IN: unicode.script

CONSTANT: script-table $[
    "vocab:unicode/UCD/Scripts.txt" load-interval-file
]
