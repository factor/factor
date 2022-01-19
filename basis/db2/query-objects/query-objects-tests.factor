! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db2.binders db2.connections
postgresql.db2.connections
postgresql.db2.connections.private db2.query-objects
sqlite.db2.connections db2.statements db2.types namespaces
tools.test ;
IN: db2.query-objects.tests

! TOC - table ordinal column

! Test expansion of insert
TUPLE: qdog id age ;

! Test joins
TUPLE: user id name ;
TUPLE: address id user-id street city state zip ;

[
T{ statement
    { sql "INSERT INTO qdog (id) VALUES(?);" }
    { in
        {
            T{ in-binder
                { toc TOC{ "qdog" "0" "id" } }
                { type INTEGER }
                { value 0 }
            }
        }
    }
    { out V{ } }
    { errors V{ } }
}
] [
    T{ sqlite-db-connection } db-connection [
        T{ insert
            { in
                {
                    T{ in-binder
                        { toc TOC{ "qdog" "0" "id" } }
                        { type INTEGER }
                        { value 0 }
                    }
                }
            }
        } query-object>statement
    ] with-variable
] unit-test

[
T{ statement
    { sql "INSERT INTO qdog (id) VALUES($1);" }
    { in
        {
            T{ in-binder
                { toc TOC{ "qdog" "0" "id" } }
                { type INTEGER }
                { value 0 }
            }
        }
    }
    { out V{ } }
    { errors V{ } }
}
] [
    T{ postgresql-db-connection } db-connection
    [
        T{ insert
            { in
                {
                    T{ in-binder
                        { toc TOC{ "qdog" "0" "id" } }
                        { type INTEGER }
                        { value 0 }
                    }
                }
            }
        } query-object>statement
    ] with-variable
] unit-test






[
T{ statement
    { sql "SELECT qdog0.id, qdog0.age FROM qdog AS qdog0 WHERE qdog0.age = ?;" }
    { in
        {
            T{ equal-binder
                { toc TOC{ "qdog" "0" "age" } }
                { type INTEGER }
                { value 0 }
            }
        }
    }
    { out
        {
            T{ out-binder
                { toc TOC{ "qdog" "0" "id" } }
                { type INTEGER }
            }
            T{ out-binder
                { toc TOC{ "qdog" "0" "age" } }
                { type INTEGER }
            }
        }
    }
    { errors V{ } }
}
] [
    T{ sqlite-db-connection } db-connection
    [
        T{ select
            { from { TO{ "qdog" "0" } } }
            { out
                {
                    T{ out-binder
                        { toc TOC{ "qdog" "0" "id" } }
                        { type INTEGER }
                    }
                    T{ out-binder
                        { toc TOC{ "qdog" "0" "age" } }
                        { type INTEGER }
                    }
                }
            }
            { in
                {
                    T{ equal-binder
                        { toc TOC{ "qdog" "0" "age" } }
                        { type INTEGER }
                        { value 0 }
                    }
                }
            }
        } query-object>statement
    ] with-variable
] unit-test




[
T{ statement
    { sql "UPDATE qdog SET age = ? WHERE age = ?;" }
    { in
        {
            T{ equal-binder
                { toc TOC{ "qdog" "0" "age" } }
                { type INTEGER }
                { value 1 }
            }
            T{ equal-binder
                { toc TOC{ "qdog" "0" "age" } }
                { type INTEGER }
                { value 0 }
            }
        }
    }
    { out V{ } }
    { errors V{ } }
}
] [
    T{ sqlite-db-connection } db-connection
    [
        T{ update
            { in
                {
                    T{ equal-binder
                        { toc TOC{ "qdog" "0" "age" } }
                        { type INTEGER }
                        { value 1 }
                    }
                }
            }
            { where
                {
                    T{ equal-binder
                        { toc TOC{ "qdog" "0" "age" } }
                        { type INTEGER }
                        { value 0 }
                    }
                }
            }
        } query-object>statement
    ] with-variable
] unit-test

[
T{ statement
    { sql "DELETE FROM qdog WHERE age = ?;" }
    { in
        {
            T{ equal-binder
                { toc TOC{ "qdog" "0" "age" } }
                { type INTEGER }
                { value 0 }
            }
        }
    }
    { out V{ } }
    { errors V{ } }
}
] [
    T{ sqlite-db-connection } db-connection
    [
        T{ delete
            { where
                {
                    T{ equal-binder
                        { toc TOC{ "qdog" "0" "age" } }
                        { type INTEGER }
                        { value 0 }
                    }
                }
            }
        } query-object>statement
    ] with-variable
] unit-test



[
T{ statement
    { sql "SELECT COUNT(qdog0.id) FROM qdog AS qdog0;" }
    { in { } }
    { out
        {
            T{ count-function
                { toc TOC{ "qdog" "0" "id" } }
                { type INTEGER }
            }
        }
    }
    { errors V{ } }
}
] [
    T{ sqlite-db-connection } db-connection
    [
        T{ select
            { from { TO{ "qdog" "0" } } }
            { out
                {
                    T{ count-function
                        { toc TOC{ "qdog" "0" "id" } }
                        { type INTEGER }
                    }
                }
            }
        } query-object>statement
    ] with-variable
] unit-test




[
T{ statement
    { sql "SELECT COUNT(qdog0.id) FROM qdog AS qdog0 WHERE qdog0.age = ?;" }
    { in
        {
            T{ equal-binder
                { toc TOC{ "qdog" "0" "age" } }
                { type INTEGER }
                { value 0 }
            }
        }
    }
    { out
        {
            T{ count-function
                { toc TOC{ "qdog" "0" "id" } }
                { type INTEGER }
            }
        }
    }
    { errors V{ } }
}
] [
    T{ sqlite-db-connection } db-connection
    [
        T{ select
            { from { TO{ "qdog" "0" } } }
            { out
                {
                    T{ count-function
                        { toc TOC{ "qdog" "0" "id" } }
                        { type INTEGER }
                    }
                }
            }
            { in
                {
                    T{ equal-binder
                        { toc TOC{ "qdog" "0" "age" } }
                        { type INTEGER }
                        { value 0 }
                    }
                }
            }
        } query-object>statement
    ] with-variable
] unit-test


[
T{ statement
    { sql
        "SELECT user0.id, user0.name, address0.id, address0.user_id, address0.street, address0.city, address0.zip FROM user AS user0 LEFT JOIN address AS address0 ON user0.id = address0.user_id;"
    }
    { in { } }
    { out
        {
            T{ out-binder
                { toc TOC{ "user" "0" "id" } }
                { type INTEGER }
            }
            T{ out-binder
                { toc TOC{ "user" "0" "name" } }
                { type VARCHAR }
            }
            T{ out-binder
                { toc TOC{ "address" "0" "id" } }
                { type INTEGER }
            }
            T{ out-binder
                { toc TOC{ "address" "0" "user_id" } }
                { type INTEGER }
            }
            T{ out-binder
                { toc TOC{ "address" "0" "street" } }
                { type VARCHAR }
            }
            T{ out-binder
                { toc TOC{ "address" "0" "city" } }
                { type VARCHAR }
            }
            T{ out-binder
                { toc TOC{ "address" "0" "zip" } }
                { type INTEGER }
            }
        }
    }
    { errors V{ } }
}
] [
    T{ sqlite-db-connection } db-connection
    [
        T{ select
            { out
                {
                    T{ out-binder
                        { toc TOC{ "user" "0" "id" } }
                        { type INTEGER }
                    }
                    T{ out-binder
                        { toc TOC{ "user" "0" "name" } }
                        { type VARCHAR }
                    }
                    T{ out-binder
                        { toc TOC{ "address" "0" "id" } }
                        { type INTEGER }
                    }
                    T{ out-binder
                        { toc TOC{ "address" "0" "user_id" } }
                        { type INTEGER }
                    }
                    T{ out-binder
                        { toc TOC{ "address" "0" "street" } }
                        { type VARCHAR }
                    }
                    T{ out-binder
                        { toc TOC{ "address" "0" "city" } }
                        { type VARCHAR }
                    }
                    T{ out-binder
                        { toc TOC{ "address" "0" "zip" } }
                        { type INTEGER }
                    }
                }
            }
            { from { TO{ "user" "0" } } }
            { join
                {
                    T{ join-binder
                        { toc1 TOC{ "user" "0" "id" } }
                        { toc2 TOC{ "address" "0" "user_id" } }
                    }
                }
            }
        } query-object>statement
    ] with-variable
] unit-test


[
T{ statement
    { sql
        "SELECT user0.id, user0.name FROM user AS user0 WHERE (user0.id = ? AND user0.id = ?);"
    }
    { in
        {
            T{ equal-binder
                { toc TOC{ "user" "0" "id" } }
                { type INTEGER }
                { value 0 }
            }
            T{ equal-binder
                { toc TOC{ "user" "0" "id" } }
                { type INTEGER }
                { value 1 }
            }
        }
    }
    { out
        {
            T{ out-binder
                { toc TOC{ "user" "0" "id" } }
                { type INTEGER }
            }
            T{ out-binder
                { toc TOC{ "user" "0" "name" } }
                { type VARCHAR }
            }
        }
    }
    { errors V{ } }
}
] [
    T{ sqlite-db-connection } db-connection
    [
        T{ select
            { in
                {
                    T{ and-binder
                        { binders
                            {
                                T{ equal-binder
                                    { toc TOC{ "user" "0" "id" } }
                                    { type INTEGER }
                                    { value 0 }
                                }
                                T{ equal-binder
                                    { toc TOC{ "user" "0" "id" } }
                                    { type INTEGER }
                                    { value 1 }
                                }
                            }
                        }
                    }
                }
            }
            { out
                {
                    T{ out-binder
                        { toc TOC{ "user" "0" "id" } }
                        { type INTEGER }
                    }
                    T{ out-binder
                        { toc TOC{ "user" "0" "name" } }
                        { type VARCHAR }
                    }
                }
            }
            { from { TO{ "user" "0" } } }
        } query-object>statement
    ] with-variable
] unit-test

[
T{ statement
    { sql
        "SELECT user0.id, user0.name FROM user AS user0 WHERE (qdog0.id > ? AND qdog0.id <= ?);"
    }
    { in
        {
            T{ greater-than-binder
                { toc TOC{ "qdog" "0" "id" } }
                { type INTEGER }
                { value 0 }
            }
            T{ less-than-equal-binder
                { toc TOC{ "qdog" "0" "id" } }
                { type INTEGER }
                { value 5 }
            }
        }
    }
    { out
        {
            T{ out-binder
                { toc TOC{ "user" "0" "id" } }
                { type INTEGER }
            }
            T{ out-binder
                { toc TOC{ "user" "0" "name" } }
                { type VARCHAR }
            }
        }
    }
    { errors V{ } }
}
] [
    T{ sqlite-db-connection } db-connection
    [
        T{ select
            { in
                {
                    T{ and-binder
                        { binders
                            {
                                T{ greater-than-binder
                                    { toc TOC{ "qdog" "0" "id" } }
                                    { type INTEGER }
                                    { value 0 }
                                }
                                T{ less-than-equal-binder
                                    { toc TOC{ "qdog" "0" "id" } }
                                    { type INTEGER }
                                    { value 5 }
                                }
                            }
                        }
                    }
                }
            }
            { out
                {
                    T{ out-binder
                        { toc TOC{ "user" "0" "id" } }
                        { type INTEGER }
                    }
                    T{ out-binder
                        { toc TOC{ "user" "0" "name" } }
                        { type VARCHAR }
                    }
                }
            }
            { from { TO{ "user" "0" } } }
        } query-object>statement
    ] with-variable
] unit-test
