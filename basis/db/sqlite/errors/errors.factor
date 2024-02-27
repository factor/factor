! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: db.errors kernel multiline peg.ebnf sequences strings ;
IN: db.sqlite.errors

TUPLE: unparsed-sqlite3-error error ;
C: <unparsed-sqlite3-error> unparsed-sqlite3-error

EBNF: parse-sqlite3-sql-error [=[

AlreadyExists = " already exists"

SqliteError =
    "table " (!(AlreadyExists).)+:table AlreadyExists
      => [[ table >string <sql-table-exists> ]]
    | "index " (!(AlreadyExists).)+:name AlreadyExists
      => [[ name >string <sql-index-exists> ]]
    | "no such table: " .+:table
      => [[ table >string <sql-table-missing> ]]
    | .*:error
      => [[ error >string <unparsed-sqlite3-error> ]]
]=]
