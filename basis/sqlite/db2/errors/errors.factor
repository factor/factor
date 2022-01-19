! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db2.connections db2.errors
sqlite.db2.ffi kernel locals namespaces peg.ebnf sequences
strings ;
IN: sqlite.db2.errors

ERROR: sqlite-error < db-error n string ;
ERROR: sqlite-sql-error < sql-error n string ;

: sqlite-statement-error ( -- * )
    SQLITE_ERROR
    db-connection get handle>> sqlite3_errmsg sqlite-sql-error ;

TUPLE: unparsed-sqlite-error error ;
C: <unparsed-sqlite-error> unparsed-sqlite-error

EBNF: parse-sqlite-sql-error [=[

TableMessage = " already exists"
SyntaxError = ": syntax error"

SqliteError =
    "table " (!(TableMessage).)+:table TableMessage:message
      => [[ table >string <sql-table-exists> ]]
    | "near " (!(SyntaxError).)+:syntax SyntaxError:message
      => [[ syntax >string <sql-syntax-error> ]]
    | "no such table: " .+:table
      => [[ table >string <sql-table-missing> ]]
    | .*:error
      => [[ error >string <unparsed-sqlite-error> ]]
]=]

: throw-sqlite-error ( n -- * )
    dup sqlite-error-messages nth sqlite-error ;
