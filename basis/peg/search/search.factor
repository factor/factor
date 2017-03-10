! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators continuations io io.streams.string kernel
math memoize namespaces peg sequences strings ;
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

MEMO: any-char-parser ( -- parser )
    [ drop t ] satisfy ;

: search ( string parser -- seq )
    any-char-parser [ drop f ] action 2choice repeat0
    [ parse sift ] [ 3drop { } ] recover ;

: (replace) ( string parser -- seq )
    any-char-parser 2choice repeat0 parse sift ;

: replace ( string parser -- result )
    [ (replace) tree-write ] with-string-writer ;
