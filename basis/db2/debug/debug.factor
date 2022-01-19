! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db2.connections postgresql.db2
sqlite.db2 fry io.files.temp kernel namespaces system tools.test ;
IN: db2.debug

: sqlite-test-db ( -- sqlite-db )
    "tuples-test.db" temp-file <sqlite-db> ;

! These words leak resources, but are useful for interactivel testing
: set-sqlite-db ( -- )
    sqlite-db db>db-connection db-connection set ;

: test-sqlite-quot ( quot -- quot' )
    '[ sqlite-test-db _ with-db ] ; inline

: test-sqlite ( quot -- ) test-sqlite-quot call ; inline
: test-sqlite0 ( quot -- ) test-sqlite-quot call( -- ) ; inline

: postgresql-test-db ( -- postgresql-db )
    <postgresql-db>
        "localhost" >>host
        "erg" >>username
        "thepasswordistrust" >>password
        "factor-test" >>database ;

: set-postgresql-db ( -- )
    postgresql-db db>db-connection db-connection set ;

: test-postgresql-quot ( quot -- quot' )
    '[
        os windows? cpu x86.64? and [
            [ ] [ postgresql-test-db _ with-db ] unit-test
        ] unless
    ] ; inline

: test-postgresql ( quot -- ) test-postgresql-quot call ; inline
: test-postgresql0 ( quot -- ) test-postgresql-quot call( -- ) ; inline

: test-dbs ( quot -- )
    {
        [ test-sqlite0 ]
        [ test-postgresql0 ]
    } cleave ;

: with-dummy-postgresql ( quot -- )
    [ postgresql-test-db ] dip with-db ; inline

: with-dummy-sqlite ( quot -- )
    [ sqlite-test-db ] dip with-db ; inline
