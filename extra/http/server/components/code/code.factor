! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: splitting kernel io sequences xmode.code2html accessors
http.server.components xml.entities ;
IN: http.server.components.code

TUPLE: code-renderer < text-renderer mode ;

: <code-renderer> ( mode -- renderer )
    code-renderer new-text-renderer
        swap >>mode ;

M: code-renderer render-view*
    [ string-lines ] [ mode>> value ] bi* htmlize-lines ;

: <code> ( id mode -- component )
    swap <text>
        swap <code-renderer> >>renderer ;
