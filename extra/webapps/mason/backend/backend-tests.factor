USING: continuations io.directories io.files.temp tools.test
webapps.mason.backend webapps.utils db2.transactions db2.connections ;
IN: webapps.mason.backend.tests

[ "resource:mason-test.db" temp-file delete-file ] ignore-errors

{ 0 1 2 } [
    ! Do it in a with-transaction to simulate semantics of
    ! with-mason-db
    "resource:mason-test.db" <temp-sqlite-db> [
        [
            init-mason-db

            counter-value
            increment-counter-value
            increment-counter-value
        ] with-transaction
    ] with-db
] unit-test
