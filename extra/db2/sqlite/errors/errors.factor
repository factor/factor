! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db2.connections db2.errors
db2.sqlite.ffi kernel locals namespaces peg.ebnf sequences
strings ;
IN: db2.sqlite.errors

ERROR: sqlite-error < db-error n string ;
ERROR: sqlite-sql-error < sql-error n string ;

: throw-sqlite-error ( n -- * )
    dup sqlite-error-messages nth sqlite-error ;

: sqlite-statement-error ( -- * )
    SQLITE_ERROR
    db-connection get handle>> sqlite3_errmsg sqlite-sql-error ;

TUPLE: unparsed-sqlite-error error ;
C: <unparsed-sqlite-error> unparsed-sqlite-error

: sqlite-table-error ( table message -- error )
    {
        { sql-table-exists [ <sql-table-exists> ] }
    } case ;

EBNF: parse-sqlite-sql-error

TableMessage = " already exists" => [[ sql-table-exists ]]

SqliteError =
    "table " (!(TableMessage).)+:table TableMessage:message
      => [[ table >string message sqlite-table-error ]]
    | "no such table: " .+:table
      => [[ table >string <sql-table-missing> ]]
    | .*:error
      => [[ error >string <unparsed-sqlite-error> ]]
;EBNF
