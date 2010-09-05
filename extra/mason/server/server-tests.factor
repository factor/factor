USING: continuations db db.sqlite io.directories io.files.temp
mason.server tools.test ;
IN: mason.server.tests

[ "test.db" temp-file delete-file ] ignore-errors

[ 0 2 ] [
    "test.db" temp-file <sqlite-db> [
        init-mason-db

        counter-value
        increment-counter-value
        increment-counter-value
        counter-value
    ] with-db
] unit-test
