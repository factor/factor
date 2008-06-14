! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences db.tuples alarms calendar db fry
furnace.cache
furnace.asides
furnace.flash
furnace.sessions
furnace.db
furnace.auth.providers ;
IN: furnace.alloy

: <alloy> ( responder db params -- responder' )
    [ <asides> <flash-scopes> <sessions> ] 2dip <db-persistence> ;

: state-classes { session flash-scope aside } ; inline

: init-furnace-tables ( -- )
    state-classes ensure-tables
    user ensure-table ;

: start-expiring ( db params -- )
    '[
        , , [ state-classes [ expire-state ] each ] with-db
    ] 5 minutes every drop ;
