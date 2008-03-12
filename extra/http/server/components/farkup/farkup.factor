! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: splitting http.server.components kernel io sequences
farkup ;
IN: http.server.components.farkup

TUPLE: farkup ;

: <farkup> ( id -- component )
    <text> farkup construct-delegate ;

M: farkup render-view*
    drop string-lines "\n" join convert-farkup write ;
