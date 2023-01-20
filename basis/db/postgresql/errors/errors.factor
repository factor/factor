! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors db.errors kernel math math.parser multiline
peg.ebnf quoting sequences strings ;
IN: db.postgresql.errors

EBNF: parse-postgresql-sql-error [=[

Error = "ERROR:" [ ]+

TableError =
    Error ("relation "|"table ")(!(" already exists").)+:table " already exists"
        => [[ table >string unquote <sql-table-exists> ]]
    | Error ("relation "|"table ")(!(" does not exist").)+:table " does not exist"
        => [[ table >string unquote <sql-table-missing> ]]

DatabaseError =
    Error ("database")(!(" already exists").)+:database " already exists"
        => [[ database >string <sql-database-exists> ]]

FunctionError =
    Error "function" (!(" already exists").)+:table " already exists"
        => [[ table >string <sql-function-exists> ]]
    | Error "function" (!(" does not exist").)+:table " does not exist"
        => [[ table >string <sql-function-missing> ]]

SyntaxError =
    Error "syntax error at end of input":error
        => [[ error >string <sql-syntax-error> ]]
    | Error "syntax error at or near " .+:syntaxerror
        => [[ syntaxerror >string unquote <sql-syntax-error> ]]

UnknownError = .* => [[ >string <sql-unknown-error> ]]

PostgresqlSqlError = (TableError | DatabaseError | FunctionError | SyntaxError | UnknownError) 

]=]


TUPLE: parse-postgresql-location column line text ;
C: <parse-postgresql-location> parse-postgresql-location

EBNF: parse-postgresql-line-error [=[

Line = "LINE " [0-9]+:line ": " .+:sql
    => [[ f line >string string>number sql >string <parse-postgresql-location> ]] 

]=]

:: set-caret-position ( error caret-line -- error )
    caret-line length
    error line>> number>string length "LINE : " length +
    - [ error ] dip >>column ;

: postgresql-location ( line column -- obj )
    [ parse-postgresql-line-error ] dip
    set-caret-position ;
