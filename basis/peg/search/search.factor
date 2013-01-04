! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math io io.streams.string sequences strings
combinators peg memoize arrays continuations ;
IN: peg.search

: tree-write ( object -- )
    {
        { [ dup number? ] [ write1 ] }
        { [ dup string? ] [ write ] }
        { [ dup sequence? ] [ [ tree-write ] each ] }
        { [ t ] [ write ] }
    } cond ;

MEMO: any-char-parser ( -- parser )
    [ drop t ] satisfy ;

: search ( string parser -- seq )
    any-char-parser [ drop f ] action 2choice repeat0
    [ parse sift ] [ 3drop { } ] recover ;

: (replace) ( string parser -- seq )
    any-char-parser 2choice repeat0 parse sift ;

: replace ( string parser -- result )
    [ (replace) [ tree-write ] each ] with-string-writer ;


