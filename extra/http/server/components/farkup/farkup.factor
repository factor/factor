! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: splitting kernel io sequences farkup accessors
http.server.components ;
IN: http.server.components.farkup

TUPLE: farkup-renderer < text-renderer ;

: <farkup-renderer> ( -- renderer )
    farkup-renderer new-text-renderer ;

M: farkup-renderer render-view*
    drop string-lines "\n" join convert-farkup write ;

: <farkup> ( id -- component )
    <text>
        <farkup-renderer> >>renderer ;
