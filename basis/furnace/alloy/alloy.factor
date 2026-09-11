! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar continuations db db.tuples furnace.asides
furnace.auth.login.permits furnace.auth.providers furnace.cache
furnace.conversations furnace.db furnace.sessions kernel logging
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

<PRIVATE

: expire-sessions ( db -- )
    "furnace.alloy" [
        [ [ state-classes [ expire-state ] each ] with-db ]
        [ nip \ expire-sessions log-error ] recover
    ] with-logging ;

PRIVATE>

: start-expiring ( db -- )
    '[ _ expire-sessions ] 5 minutes every drop ;
