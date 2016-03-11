
USING: accessors combinators.short-circuit db2.types
furnace.auth furnace.cache furnace.sessions kernel namespaces
orm.persistent orm.tuples ;
IN: furnace.auth.login.permits

TUPLE: permit < server-state session uid ;

PERSISTENT: { permit "permits" }
    { "session" BIG-INTEGER +not-null+ }
    { "uid" { VARCHAR 255 } +not-null+ } ;

: touch-permit ( permit -- )
    realm get touch-state ;

: get-permit-uid ( id -- uid )
    permit get-state {
        [ ]
        [ session>> session get id>> = ]
        [ [ touch-permit ] [ uid>> ] bi ]
    } 1&& ;

: make-permit ( uid -- id )
    permit new
        swap >>uid
        session get id>> >>session
    [ touch-permit ] [ insert-tuple ] [ id>> ] tri ;

: delete-permit ( id -- )
    permit new-server-state delete-tuples ;
