! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar.format combinators io.files
kernel math.parser sequences splitting system tools.files
generalizations tools.files.private io.files.info ;
IN: tools.files.windows

<PRIVATE

: directory-or-size ( file-info -- str )
    dup directory? [
        drop "<DIR>" 20 CHAR: \s pad-right
    ] [
        size>> number>string 20 CHAR: \s pad-left
    ] if ;

M: windows (directory.) ( entries -- lines )
    [
        dup file-info {
            [ modified>> timestamp>ymdhms ]
            [ directory-or-size ]
        } cleave 2 narray swap suffix " " join
    ] map ;

PRIVATE>
