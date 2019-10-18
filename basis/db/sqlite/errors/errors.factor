! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db kernel sequences peg.ebnf
strings db.errors multiline ;
IN: db.sqlite.errors

TUPLE: unparsed-sqlite-error error ;
C: <unparsed-sqlite-error> unparsed-sqlite-error

EBNF: parse-sqlite-sql-error [=[

AlreadyExists = " already exists"

SqliteError =
    "table " (!(AlreadyExists).)+:table AlreadyExists
      => [[ table >string <sql-table-exists> ]]
    | "index " (!(AlreadyExists).)+:name AlreadyExists
      => [[ name >string <sql-index-exists> ]]
    | "no such table: " .+:table
      => [[ table >string <sql-table-missing> ]]
    | .*:error
      => [[ error >string <unparsed-sqlite-error> ]]
]=]
