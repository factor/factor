USING: accessors calendar continuations db io.directories
io.files.temp kernel tools.test webapps.mason.backend webapps.utils ;
IN: webapps.mason.backend.tests

"mason-test.db" temp-file ?delete-file

{ 0 1 2 } [
    ! Do it in a with-transaction to simulate semantics of
    ! with-mason-db
    "mason-test.db" <temp-sqlite3-db> [
        [
            init-mason-db

            counter-value
            increment-counter-value
            increment-counter-value
        ] with-transaction
    ] with-db
] unit-test

{ f f } [
    builder new now >>heartbeat-timestamp
    [ broken? ] [ offline? ] bi
] unit-test
