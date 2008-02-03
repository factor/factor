! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! adapted from libpq-fe.h version 7.4.7
! tested on debian linux with postgresql 7.4.7

USING: arrays assocs alien alien.syntax continuations io
kernel math namespaces prettyprint quotations
sequences debugger db db.postgresql.lib db.postgresql.ffi ;
IN: db.postgresql

TUPLE: postgresql-db host port pgopts pgtty db user pass ;
TUPLE: postgresql-statement ;
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


M: postgresql-result-set #rows ( statement -- n )
    statement-handle PQntuples ;

M: postgresql-result-set #columns ( statement -- n )
    statement-handle PQnfields ;

M: postgresql-result-set row-column ( statement n -- obj )
    >r dup statement-handle swap statement-n r> PQgetvalue ;


: init-result-set ( result-set -- )
    dup result-set-max [
        dup do-postgresql-statement over set-result-set-handle
        dup #rows over set-result-set-max
        -1 over set-result-set-n
    ] unless drop ;

: increment-n ( result-set -- n )
    dup result-set-n 1+ dup rot set-result-set-n ;

M: postgresql-result-set advance-row ( result-set -- ? )
    dup init-result-set
    dup increment-n swap result-set-max >= ;


M: postgresql-statement dispose ( query -- )
    dup statement-handle PQclear
    f swap set-statement-handle ;

M: postgresql-result-set dispose ( result-set -- )
    dup result-set-handle PQclear
    0 0 f roll {
        set-statement-n set-statement-max set-statement-handle
    } set-slots ;

M: postgresql-statement prepare-statement ( statement -- )
    [
        >r db get db-handle "" r>
        dup statement-sql swap statement-params
        dup assoc-size swap PQprepare postgresql-error
    ] keep set-statement-handle ;

M: postgresql-db <simple-statement> ( sql -- statement )
    { set-statement-sql } statement construct
    <postgresql-statement> ;

M: postgresql-db <prepared-statement> ( sql -- statement )
    { set-statement-sql } statement construct
    <postgresql-statement> ;
