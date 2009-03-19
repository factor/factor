! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors values kernel sequences assocs io.files
io.encodings ascii math.ranges io splitting math.parser
namespaces make byte-arrays locals math sets io.encodings.ascii
words words.symbol compiler.units arrays interval-maps
unicode.data ;
IN: unicode.script

<PRIVATE

VALUE: script-table

"vocab:unicode/script/Scripts.txt" load-key-value
to: script-table

PRIVATE>

: script-of ( char -- script )
    script-table interval-at ;
