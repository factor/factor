! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators continuations io io.streams.string kernel
literals math namespaces peg sequences strings ;
IN: peg.search

: stream-tree-write ( object stream -- )
    {
        { [ over number? ] [ stream-write1 ] }
        { [ over string? ] [ stream-write ] }
        { [ over sequence? ] [ [ stream-tree-write ] curry each ] }
        [ stream-write ]
    } cond ;

: tree-write ( object -- )
    output-stream get stream-tree-write ;

<PRIVATE

CONSTANT: any-char-parser $[ [ drop t ] satisfy ]

PRIVATE>

: peg-search ( string parser -- seq )
    any-char-parser [ drop f ] action 2choice repeat0
    [ parse sift ] [ 3drop { } ] recover ;

: peg-replace ( string parser -- result )
    [
        any-char-parser 2choice repeat0
        parse sift tree-write
    ] with-string-writer ;
