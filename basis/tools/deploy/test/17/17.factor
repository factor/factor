USING: accessors calendar db db.sqlite db.tuples db.types
io.files.temp kernel urls ;
IN: tools.deploy.test.17

TUPLE: person name birthday homepage occupation ;

person "PEOPLE" {
    { "name" "NAME" { VARCHAR 256 } +not-null+ +user-assigned-id+ }
    { "birthday" "BIRTHDAY" DATETIME +not-null+ }
    { "homepage" "HOMEPAGE" URL +not-null+ }
    { "occupation" "OCCUPATION" { VARCHAR 256 } +not-null+ }
} define-persistent

: db-deploy-test ( -- )
    "test.db" temp-file <sqlite3-db> [
        person recreate-table

        person new
            "Stephen Hawking" >>name
            timestamp new 8 >>day 0 >>month 1942 >>year >>birthday
            "http://en.wikipedia.org/wiki/Stephen_Hawking" >url >>homepage
            "Dope MC" >>occupation
        dup
        insert-tuple
        person new
            "Stephen Hawking" >>name
        select-tuple
        assert=
    ] with-db ;

MAIN: db-deploy-test
