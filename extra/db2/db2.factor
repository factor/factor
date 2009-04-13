! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations db2.result-sets db2.sqlite.lib
db2.sqlite.result-sets db2.sqlite.statements db2.statements
destructors fry kernel math namespaces sequences strings
db2.sqlite.types ;
IN: db2

<PRIVATE

: execute-sql-string ( string -- )
    f f <statement> [ execute-statement ] with-disposal ;

PRIVATE>

: sql-command ( sql -- )
    dup string?
    [ execute-sql-string ]
    [ [ execute-sql-string ] each ] if ;

: sql-query ( sql -- sequence )
    f f <statement> [ statement>result-sequence ] with-disposal ;

: sql-bind-command ( sequence string -- )
    f f <statement> [
        sqlite-maybe-prepare [
            handle>> swap sqlite-bind-sequence
        ] [
            >sqlite-result-set drop
        ] bi
    ] with-disposal ;

: sql-bind-query ( in-sequence string -- out-sequence )
    f f <statement> [
        sqlite-maybe-prepare [
            handle>> swap sqlite-bind-sequence
        ] [
            statement>result-sequence
        ] bi
    ] with-disposal ;

: sql-bind-typed-command ( in-sequence string -- )
    f f <statement> [
        sqlite-maybe-prepare [
            handle>> swap sqlite-bind-typed-sequence
        ] [
            >sqlite-result-set drop
        ] bi
    ] with-disposal ;

: sql-bind-typed-query ( in-sequence string -- out-sequence )
    f f <statement> [
        sqlite-maybe-prepare [
            handle>> swap sqlite-bind-typed-sequence
        ] [
            statement>result-sequence
        ] bi
    ] with-disposal ;
