! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar db.tuples db.types http.server.filters
kernel math.intervals random ;
IN: furnace.cache

TUPLE: server-state id expires ;

: new-server-state ( id class -- server-state )
    new swap >>id ; inline

server-state f
{
    { "id" "ID" +random-id+ system-random-generator }
    { "expires" "EXPIRES" BIG-INTEGER +not-null+ }
} define-persistent

: get-state ( id class -- state )
    new-server-state select-tuple ;

: expire-state ( class -- )
    new
        -1/0. now timestamp>micros [a,b] >>expires
    delete-tuples ;

TUPLE: server-state-manager < filter-responder timeout ;

: new-server-state-manager ( responder class -- responder' )
    new
        swap >>responder
        20 minutes >>timeout ; inline

: touch-state ( state manager -- )
    timeout>> hence timestamp>micros >>expires drop ;
