! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math accessors ;
IN: cursors

GENERIC: key ( cursor -- key )
GENERIC: value ( cursor -- value )
GENERIC: next ( cursor -- cursor/f )

TUPLE: sequence-cursor { i read-only } { seq read-only } ;

: (sequence-cursor) ( i seq -- cursor/f )
    2dup bounds-check? [ sequence-cursor boa ] [ 2drop f ] if ;
    inline

: <sequence-cursor> ( seq -- cursor/f )
    0 swap (sequence-cursor) ; inline

: >sequence-cursor< ( cursor -- i seq ) [ i>> ] [ seq>> ] bi ;

M: sequence-cursor key
    i>> ;

M: sequence-cursor value
    >sequence-cursor< nth ;

M: sequence-cursor next
    >sequence-cursor< [ 1+ ] dip (sequence-cursor) ;

: cursor-iterate ( cursor quot: ( cursor -- cursor' ) -- )
    over [ call cursor-iterate ] [ 2drop ] if ; inline recursive

: cursor-each ( cursor quot -- )
    [ keep ] curry cursor-iterate ; inline
