! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: splitting kernel io sequences inspector accessors
http.server.components xml.entities html ;
IN: http.server.components.inspector

SINGLETON: inspector-renderer

M: inspector-renderer render-view*
    drop [ describe ] with-html-stream ;

TUPLE: inspector < component ;

M: inspector component-string drop ;

: <inspector> ( id -- component )
    inspector inspector-renderer new-component ;
