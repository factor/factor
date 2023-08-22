! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: literals simple-flat-file ;
IN: unicode.script

CONSTANT: script-table $[
    "vocab:unicode/Scripts.txt" load-interval-file
]
