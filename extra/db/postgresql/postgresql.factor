! Copyright (C) 2007, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs alien alien.syntax continuations io
kernel math namespaces prettyprint quotations
sequences debugger db db.postgresql.lib db.postgresql.ffi ;
IN: db.postgresql

TUPLE: postgresql-db host port pgopts pgtty db user pass ;
TUPLE: postgresql-statement ;
TUPLE: postgresql-result-set ;
: <postgresql-statement> ( statement -- postgresql-statement )
    postgresql-statement construct-delegate ;

: <postgresql-db> ( host user pass db -- obj )
    {
        set-postgresql-db-host
        set-postgresql-db-user
        set-postgresql-db-pass
        set-postgresql-db-db
    } postgresql-db construct ;

M: postgresql-db db-open ( db -- )
    dup {
        postgresql-db-host
        postgresql-db-port
        postgresql-db-pgopts
        postgresql-db-pgtty
        postgresql-db-db
        postgresql-db-user
        postgresql-db-pass
    } get-slots connect-postgres <db> swap set-delegate ;

M: postgresql-db dispose ( db -- )
    db-handle PQfinish ;

: with-postgresql ( host ust pass db quot -- )
    >r <postgresql-db> r> with-disposal ;

M: postgresql-statement bind-statement* ( seq statement -- )
    set-statement-params ;

M: postgresql-statement rebind-statement ( seq statement -- )
    bind-statement* ;

M: postgresql-result-set #rows ( result-set -- n )
    result-set-handle PQntuples ;

M: postgresql-result-set #columns ( result-set -- n )
    result-set-handle PQnfields ;

M: postgresql-result-set row-column ( result-set n -- obj )
    >r dup result-set-handle swap result-set-n r> PQgetvalue ;

M: postgresql-statement execute-statement ( statement -- )
    query-results dispose ;

: increment-n ( result-set -- n )
    dup result-set-n 1+ dup rot set-result-set-n ;

M: postgresql-statement query-results ( query -- result-set )
    dup statement-params [
        over [ bind-statement ] keep
        do-postgresql-bound-statement
    ] [
        dup do-postgresql-statement
    ] if*
    postgresql-result-set <result-set>
    dup init-result-set ;

M: postgresql-result-set advance-row ( result-set -- ? )
    dup increment-n swap result-set-max >= ;

M: postgresql-statement dispose ( query -- )
    dup statement-handle PQclear
    f swap set-statement-handle ;

M: postgresql-result-set dispose ( result-set -- )
    dup result-set-handle PQclear
    0 0 f roll {
        set-result-set-n set-result-set-max set-result-set-handle
    } set-slots ;

M: postgresql-statement prepare-statement ( statement -- )
    [
        >r db get db-handle "" r>
        dup statement-sql swap statement-params
        length f PQprepare postgresql-error
    ] keep set-statement-handle ;

M: postgresql-db <simple-statement> ( sql -- statement )
    { set-statement-sql } statement construct
    <postgresql-statement> ;

M: postgresql-db <prepared-statement> ( sql -- statement )
    { set-statement-sql } statement construct
    <postgresql-statement> ;

M: postgresql-db begin-transaction ( -- )
    "BEGIN" sql-command ;

M: postgresql-db commit-transaction ( -- )
    "COMMIT" sql-command ;

M: postgresql-db rollback-transaction ( -- )
    "ROLLBACK" sql-command ;
