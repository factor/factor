! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations db2.result-sets db2.sqlite.lib
db2.sqlite.result-sets db2.sqlite.statements db2.statements
destructors fry kernel math namespaces sequences strings ;
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
            handle>> '[ [ _ ] 2dip 1+ swap sqlite-bind-text ] each-index
        ] [
            sqlite-result-set new-result-set advance-row
        ] bi
    ] with-disposal ;

: sql-bind-query ( in-sequence string -- out-sequence )
    f f <statement> [
        sqlite-maybe-prepare [
            handle>> '[ [ _ ] 2dip 1+ swap sqlite-bind-text ] each-index
        ] [
            statement>result-sequence
        ] bi
    ] with-disposal ;
