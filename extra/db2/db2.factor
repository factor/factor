! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations db2.result-sets db2.sqlite.lib
db2.sqlite.result-sets db2.sqlite.statements db2.statements
destructors fry kernel math namespaces sequences strings
db2.sqlite.types ;
IN: db2

GENERIC: sql-command ( object -- )
GENERIC: sql-query ( object -- sequence )
GENERIC: sql-bind-command* ( sequence object -- )
GENERIC: sql-bind-query* ( sequence object -- sequence )
GENERIC: sql-bind-typed-command* ( sequence object -- )
GENERIC: sql-bind-typed-query* ( sequence object -- sequence )

GENERIC: sql-bind-command ( object -- )
GENERIC: sql-bind-query ( object -- sequence )
GENERIC: sql-bind-typed-command ( object -- )
GENERIC: sql-bind-typed-query ( object -- sequence )

M: string sql-command ( sql -- )
    f f <statement> [ execute-statement ] with-disposal ;

M: string sql-query ( sql -- sequence )
    f f <statement> [ statement>result-sequence ] with-disposal ;

M: string sql-bind-command* ( sequence string -- )
    f f <statement> [
        prepare-statement
        [ bind-sequence ] [ statement>result-set drop ] bi
    ] with-disposal ;

M: string sql-bind-query* ( in-sequence string -- out-sequence )
    f f <statement> [
        prepare-statement
        [ bind-sequence ] [ statement>result-sequence ] bi
    ] with-disposal ;

M: string sql-bind-typed-command* ( in-sequence string -- )
    f f <statement> [
        prepare-statement
        [ bind-typed-sequence ] [ statement>result-set drop ] bi
    ] with-disposal ;

M: string sql-bind-typed-query* ( in-sequence string -- out-sequence )
    f f <statement> [
        prepare-statement
        [ bind-typed-sequence ] [ statement>result-sequence ] bi
    ] with-disposal ;

M: sequence sql-command [ sql-command ] each ;
M: sequence sql-query [ sql-query ] map ;
M: sequence sql-bind-command* [ sql-bind-command* ] with each ;
M: sequence sql-bind-query* [ sql-bind-query* ] with map ;
M: sequence sql-bind-typed-command* [ sql-bind-typed-command* ] with each ;
M: sequence sql-bind-typed-query* [ sql-bind-typed-query* ] with map ;
