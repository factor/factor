! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations db2.result-sets db2.sqlite.lib
db2.sqlite.result-sets db2.sqlite.statements db2.statements
destructors fry kernel math namespaces sequences strings
db2.sqlite.types ;
IN: db2

ERROR: no-in-types statement ;
ERROR: no-out-types statement ;

: guard-in ( statement -- statement )
    dup in>> [ no-in-types ] unless ;

: guard-out ( statement -- statement )
    dup out>> [ no-out-types ] unless ;

GENERIC: sql-command ( object -- )
GENERIC: sql-query ( object -- sequence )
GENERIC: sql-bind-command ( object -- )
GENERIC: sql-bind-query ( object -- sequence )
GENERIC: sql-bind-typed-command ( object -- )
GENERIC: sql-bind-typed-query ( object -- sequence )

M: string sql-command ( string -- )
    f f <statement> sql-command ;

M: string sql-query ( string -- sequence )
    f f <statement> sql-query ;

M: statement sql-command ( statement -- )
    [ execute-statement ] with-disposal ;

M: statement sql-query ( statement -- sequence )
    [ statement>result-sequence ] with-disposal ;

M: statement sql-bind-command ( statement -- )
    [
        guard-in
        prepare-statement
        [ bind-sequence ] [ statement>result-set drop ] bi
    ] with-disposal ;

M: statement sql-bind-query ( statement -- sequence )
    [
        guard-in
        prepare-statement
        [ bind-sequence ] [ statement>result-sequence ] bi
    ] with-disposal ;

M: statement sql-bind-typed-command ( statement -- )
    [
        guard-in
        prepare-statement
        [ bind-typed-sequence ] [ statement>result-set drop ] bi
    ] with-disposal ;

M: statement sql-bind-typed-query ( statement -- sequence )
    [
        guard-in
        guard-out
        prepare-statement
        [ bind-typed-sequence ] [ statement>typed-result-sequence ] bi
    ] with-disposal ;

M: sequence sql-command [ sql-command ] each ;
M: sequence sql-query [ sql-query ] map ;
M: sequence sql-bind-command [ sql-bind-command ] each ;
M: sequence sql-bind-query [ sql-bind-query ] map ;
M: sequence sql-bind-typed-command [ sql-bind-typed-command ] each ;
M: sequence sql-bind-typed-query [ sql-bind-typed-query ] map ;

M: integer sql-command throw ;
M: integer sql-query throw ;
M: integer sql-bind-command throw ;
M: integer sql-bind-query throw ;
M: integer sql-bind-typed-command throw ;
M: integer sql-bind-typed-query throw ;
