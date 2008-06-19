! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences db.tuples alarms calendar db fry
furnace.cache
furnace.asides
furnace.flash
furnace.sessions
furnace.referrer
furnace.db
furnace.auth.providers
furnace.auth.login.permits ;
IN: furnace.alloy

: <alloy> ( responder db params -- responder' )
    '[
        <asides>
        <flash-scopes>
        <sessions>
        , , <db-persistence>
        <check-form-submissions>
    ] call ;

: state-classes { session flash-scope aside permit } ; inline

: init-furnace-tables ( -- )
    state-classes ensure-tables
    user ensure-table ;

: start-expiring ( db params -- )
    '[
        , , [ state-classes [ expire-state ] each ] with-db
    ] 5 minutes every drop ;
