USING: accessors namespaces kernel combinators.short-circuit
db.tuples db.types furnace.auth furnace.sessions furnace.cache ;
IN: furnace.auth.login.permits

TUPLE: permit < server-state session uid ;

permit "PERMITS" {
    { "session" "SESSION" BIG-INTEGER +not-null+ }
    { "uid" "UID" { VARCHAR 255 } +not-null+ }
} define-persistent

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
