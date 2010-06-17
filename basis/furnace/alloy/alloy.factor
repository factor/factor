! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences db.tuples timers calendar db fry
furnace.db
furnace.cache
furnace.asides
furnace.sessions
furnace.conversations
furnace.auth.providers
furnace.auth.login.permits ;
IN: furnace.alloy

CONSTANT: state-classes { session aside conversation permit }

: init-furnace-tables ( -- )
    state-classes ensure-tables
    user ensure-table ;

: <alloy> ( responder db -- responder' )
    [ [ init-furnace-tables ] with-db ] keep
    [
        <asides>
        <conversations>
        <sessions>
    ] dip
    <db-persistence> ;

: start-expiring ( db -- )
    '[
        _ [ state-classes [ expire-state ] each ] with-db
    ] 5 minutes every drop ;
