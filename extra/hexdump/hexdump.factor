USING: arrays io io.streams.string kernel math math.parser namespaces
    prettyprint sequences sequences.lib splitting strings ascii ;
IN: hexdump

<PRIVATE

: header. ( len -- )
    "Length: " write dup unparse write ", " write >hex write "h" write nl ;

: offset. ( lineno -- )
    16 * >hex 8 CHAR: 0 pad-left write "h: " write ;

: h-pad. ( digit -- )
    >hex 2 CHAR: 0 pad-left write ;

: line. ( str n -- )
    offset.
    dup [ h-pad. " " write ] each
    16 over length - 3 * CHAR: \s <string> write
    [ dup printable? [ drop CHAR: . ] unless write1 ] each
    nl ;

PRIVATE>
: hexdump ( seq -- str )
    [
        dup length header.
        16 <sliced-groups> [ line. ] each-index
    ] with-string-writer ;

: hexdump. ( seq -- )
    hexdump write ;
