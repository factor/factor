! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences vocabs.loader vocabs ;
IN: postgresql.db2

TUPLE: postgresql-db
    host port pgopts pgtty database username password ;

: <postgresql-db> ( -- postgresql-db )
    postgresql-db new ; inline

{
    "postgresql.db2.connections"
    "postgresql.db2.errors"
    "postgresql.db2.ffi"
    "postgresql.db2.lib"
    "postgresql.db2.result-sets"
    "postgresql.db2.statements"
    "postgresql.db2.types"
    "postgresql.db2.queries"
    ! "postgresql.db2.introspection"

    "postgresql.orm"
} [ require ] each
