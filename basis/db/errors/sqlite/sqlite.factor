! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db.errors db.sqlite.private kernel
sequences peg.ebnf strings ;
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

M: sqlite-db-connection parse-db-error
    dup n>> {
        { 1 [ string>> parse-sqlite-sql-error ] }
        [ drop ]
    } case ;