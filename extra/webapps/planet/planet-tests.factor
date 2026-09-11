USING: accessors calendar concurrency.promises continuations db
kernel locals logging math namespaces timers tools.test
webapps.planet.private ;
IN: webapps.planet.tests

TUPLE: failing-planet-db attempts promise ;

M: failing-planet-db db-open
    dup [ 1 + ] change-attempts
    dup attempts>> 2 = [ dup promise>> t swap fulfill ] when
    drop "temporary database failure" throw ;

! Feed refresh must still run after the previous database open failed.
{ t } [
    CRITICAL log-level [
        0 <promise> failing-planet-db boa [| db |
            [ db update-planet ] 10 milliseconds every :> timer
            [ db promise>> 5 seconds ?promise-timeout ]
            [ timer stop-timer ] finally
        ] call
    ] with-variable
] unit-test
