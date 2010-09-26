USING: continuations db db.sqlite io.directories io.files.temp
webapps.mason.backend tools.test ;
IN: webapps.mason.backend.tests

[ "test.db" temp-file delete-file ] ignore-errors

[ 0 1 2 ] [
    "test.db" temp-file <sqlite-db> [
        init-mason-db

        counter-value
        increment-counter-value
        increment-counter-value
    ] with-db
] unit-test
