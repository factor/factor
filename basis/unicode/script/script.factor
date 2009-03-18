! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors values kernel sequences assocs io.files
io.encodings ascii math.ranges io splitting math.parser
namespaces make byte-arrays locals math sets io.encodings.ascii
words words.symbol compiler.units arrays interval-maps
unicode.data ;
IN: unicode.script

<PRIVATE

SYMBOL: interned

: parse-script ( filename -- assoc )
    ! assoc is code point/range => name
    ascii file-lines filter-comments [ split-; ] map ;

: range, ( value key -- )
    swap interned get
    [ = ] with find nip 2array , ;

: expand-ranges ( assoc -- interval-map )
    [
        [
            swap CHAR: . over member? [
                ".." split1 [ hex> ] bi@ 2array
            ] [ hex> ] if range,
        ] assoc-each
    ] { } make <interval-map> ;

: process-script ( ranges -- table )
    dup values prune interned
    [ expand-ranges ] with-variable ;

: load-script ( filename -- table )
    parse-script process-script ;

VALUE: script-table

"vocab:unicode/script/Scripts.txt" load-script
to: script-table

PRIVATE>

: script-of ( char -- script )
    script-table interval-at ;
