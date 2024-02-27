USING: db db.sqlite io.files.temp tools.test webapps.mason.backend
webapps.mason.status-update ;
IN: webapps.mason.status-update.tests

! find-builder
{
    T{ builder { host-name "hej" } { os "os" } { cpu "cpu" } }
} [
    "mason-test.db" temp-file <sqlite3-db> [
        [
            init-mason-db
            "hej" "os" "cpu" find-builder
        ] with-transaction
    ] with-db
] unit-test
