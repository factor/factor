USING: accessors calendar db db.sqlite db.tuples furnace.auth
furnace.auth.login furnace.auth.login.permits furnace.cache
furnace.sessions kernel locals math namespaces tools.test ;
IN: furnace.auth.login.permits.tests

: with-permit-db ( quot -- )
    '[
        "permits.db" <sqlite-db> [
            permit ensure-table
            123 <session> session set
            f "Test realm" <login-realm> realm set
            @
        ] with-db
    ] with-test-directory ; inline

:: stored-permit ( expires -- id )
    permit new
        "alice" >>uid
        123 >>session
        expires >>expires
    [ insert-tuple ] [ id>> ] bi ;

! Lookup must enforce expiry even when the cleanup timer has not run.
{ f } [
    [ 1 minutes ago timestamp>micros stored-permit get-permit-uid ]
    with-permit-db
] unit-test

! Activity extends the stored deadline, not just a temporary tuple.
{ "alice" t } [
    [ [let
        1 minutes hence timestamp>micros :> old-expiry
        old-expiry stored-permit :> id
        id get-permit-uid
        id permit new-server-state select-tuple expires>> old-expiry >
    ] ] with-permit-db
] unit-test

! A permit for a different session must not be renewed or accepted.
{ f t } [
    [ [let
        1 minutes hence timestamp>micros :> old-expiry
        old-expiry stored-permit :> id
        456 <session> session set
        id get-permit-uid
        id permit new-server-state select-tuple expires>> old-expiry =
    ] ] with-permit-db
] unit-test

{ f } [ [ 999 get-permit-uid ] with-permit-db ] unit-test
