! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: http.server.crud
USING: kernel namespaces db.tuples math.parser
http.server.actions accessors ;

: by-id ( class -- tuple )
    construct-empty "id" get >>id ;

: <delete-action> ( class -- action )
    <action>
        { { "id" [ string>number ] } } >>post-params
        swap [ by-id delete-tuple f ] curry >>post ;
