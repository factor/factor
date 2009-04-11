! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations destructors fry kernel
namespaces sequences strings db2.statements ;
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
