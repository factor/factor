! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar.format combinators combinators.cleave
io.files kernel math.parser sequences splitting system ls sequences.lib ;
IN: ls.windows

: directory-or-size ( file-info -- str )
    dup directory? [
        drop "<DIR>" 20 CHAR: \s pad-right
    ] [
        size>> number>string 20 CHAR: \s pad-left
    ] if ;

M: windows (directory.) ( entries -- lines )
    [
        dup file-info {
            [ modified>> timestamp>ymdhms " " split1 "  " splice ]
            [ directory-or-size ]
        } <arr> swap suffix " " join
    ] map ;