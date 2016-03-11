! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: constructors db2.connections kernel sequences vocabs
vocabs.loader ;
IN: sqlite.db2

TUPLE: sqlite-db path ;

CONSTRUCTOR: <sqlite-db> sqlite-db ( path -- db ) ;

{
    "sqlite.db2.connections"
    "sqlite.db2.errors"
    "sqlite.db2.ffi"
    "sqlite.db2.lib"
    "sqlite.db2.result-sets"
    "sqlite.db2.statements"
    "sqlite.db2.types"
    "sqlite.db2.queries"
    ! "sqlite.db2.introspection"

    "sqlite.orm"
} [ require ] each
