! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db2.introspection db2.types kernel orm.persistent
orm.tuples sqlite.db2.connections accessors sequences ;
IN: sqlite.db2.introspection

TUPLE: sqlite-object type name tbl-name rootpage sql ;
TUPLE: temporary-sqlite-object < sqlite-object ;

PERSISTENT: { sqlite-object "sqlite_master" }
    { "type" TEXT }
    { "name" TEXT }
    { "tbl-name" TEXT }
    { "rootpage" INTEGER }
    { "sql" TEXT } ;

PERSISTENT: { temporary-sqlite-object "sqlite_temp_master" } ;

M: sqlite-db-connection all-db-objects
    sqlite-object new select-tuples ;

M: sqlite-db-connection all-tables
    all-db-objects [ type>> "table" = ] filter ;

M: sqlite-db-connection all-indices
    all-db-objects [ type>> "index" = ] filter ;

M: sqlite-db-connection temporary-db-objects
    temporary-sqlite-object new select-tuples ;

