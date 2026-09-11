USING: accessors calendar concurrency.promises continuations db
furnace.alloy.private kernel locals logging math namespaces timers
tools.test ;
IN: furnace.alloy.tests

TUPLE: failing-expiry-db attempts promise ;

M: failing-expiry-db db-open
    dup [ 1 + ] change-attempts
    dup attempts>> 2 = [ dup promise>> t swap fulfill ] when
    drop "temporary database failure" throw ;

! A database failure must not terminate the periodic cleanup task.
{ t } [
    CRITICAL log-level [
        0 <promise> failing-expiry-db boa [| db |
            [ db expire-sessions ] 10 milliseconds every :> timer
            [ db promise>> 5 seconds ?promise-timeout ]
            [ timer stop-timer ] finally
        ] call
    ] with-variable
] unit-test
