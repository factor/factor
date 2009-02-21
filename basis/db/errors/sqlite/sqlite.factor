! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db kernel sequences peg.ebnf
strings db.errors ;
IN: db.errors.sqlite

ERROR: unparsed-sqlite-error error ;

SINGLETONS: table-exists table-missing ;

: sqlite-table-error ( table message -- error )
    {
        { table-exists [ <sql-table-exists> ] }
    } case ;

EBNF: parse-sqlite-sql-error

TableMessage = " already exists" => [[ table-exists ]]

SqliteError =
    "table " (!(TableMessage).)+:table TableMessage:message
      => [[ table >string message sqlite-table-error ]]
    | "no such table: " .+:table
      => [[ table >string <sql-table-missing> ]]
;EBNF
