USING: kernel namespaces db.sql sequences math ;
IN: db.sql.tests

TUPLE: person name age ;
: insert-1
    { insert
        { table "person" }
        { columns "name" "age" }
        { values "erg" 26 }
    } ;

: update-1
    { update "person"
       { set { "name" "erg" }
             { "age" 6 } }
       { where { "age" 6 } }
    } ;

: select-1
    { select
        { columns
                "branchno"
                { count "staffno" as "mycount" }
                { sum "salary" as "mysum" } }
        { from "staff" "lol" }
        { where
                { "salary" > all
                    { select
                        { columns "salary" }
                        { from "staff" }
                        { where { "branchno" "b003" } }
                    }
                }
                { "branchno" > 3 } }
        { group-by "branchno" "lol2" }
        { having { count "staffno" > 1 } }
        { order-by "branchno" }
        { offset 40 }
        { limit 20 }
    } ;
