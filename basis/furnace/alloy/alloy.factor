! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar db db.tuples furnace.asides
furnace.auth.login.permits furnace.auth.providers furnace.cache
furnace.conversations furnace.db furnace.sessions kernel
sequences timers ;
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
