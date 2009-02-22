! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel db.errors peg.ebnf strings sequences math
combinators.short-circuit accessors math.parser ;
IN: db.errors.postgresql

! ERROR:  relation "foo" does not exist

: quote? ( ch -- ? ) "'\"" member? ;

: quoted? ( str -- ? )
    {
        [ length 1 > ]
        [ first quote? ]
        [ [ first ] [ peek ] bi = ]
    } 1&& ;

: unquote ( str -- newstr )
    dup quoted? [ but-last-slice rest-slice >string ] when ;


EBNF: parse-postgresql-sql-error

Error = "ERROR:" [ ]+

TableError =
    Error "relation " (!(" already exists").)+:table " already exists"
        => [[ table >string unquote <sql-table-exists> ]]
    | Error "relation " (!(" does not exist").)+:table " does not exist"
        => [[ table >string unquote <sql-table-missing> ]]

SyntaxError =
    Error "syntax error at end of input":error
        => [[ error >string <sql-syntax-error> ]]
    | Error "syntax error at or near " .+:syntaxerror
        => [[ syntaxerror >string unquote <sql-syntax-error> ]]

PostgresqlSqlError = (TableError | SyntaxError) 

;EBNF


ERROR: parse-postgresql-location column line text ;
C: <parse-postgresql-location> parse-postgresql-location

EBNF: parse-postgresql-line-error

Line = "LINE " [0-9]+:line ": " .+:sql
    => [[ f line >string string>number sql >string <parse-postgresql-location> ]] 

;EBNF

:: set-caret-position ( error caret-line -- error )
    caret-line length
    error line>> number>string length "LINE : " length +
    - [ error ] dip >>column ;

: postgresql-location ( line column -- obj )
    [ parse-postgresql-line-error ] dip
    set-caret-position ;
