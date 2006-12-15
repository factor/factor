PROVIDE: libs/sql
{ +files+ {
    "sql.factor"
    "utils.factor"
    "simple.factor"
    "mappings.factor"
    "execute.factor"

    "sqlite/libsqlite.factor"
    "sqlite/sqlite.factor"
    "sqlite/simple.factor"
    "sqlite/execute.factor"
    "postgresql/libpq.factor"
    "postgresql/postgresql.factor"
    "postgresql/simple.factor"
    "postgresql/execute.factor"

    "tupledb.factor"

    "thewebsite.factor"
} }
{ +tests+ {
    "test/data.factor"
    "test/insert.factor"
    "test/util.factor"
} } ;

