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

M: postgresql-statement #rows ( statement -- n )
    statement-handle PQntuples ;

M: postgresql-statement #columns ( statement -- n )
    statement-handle PQnfields ;

M: postgresql-statement row-column ( statement n -- obj )
    >r dup statement-handle swap statement-n r> PQgetvalue ;

: init-statement ( statement -- )
    dup statement-max [
        dup do-postgresql-statement over set-statement-handle
        dup #rows over set-statement-max
        -1 over set-statement-n
    ] unless drop ;

: increment-n ( statement -- n )
    dup statement-n 1+ dup rot set-statement-n ;

M: postgresql-statement advance-row ( statement -- ? )
    dup init-statement
    dup increment-n swap statement-max >= ;

M: postgresql-statement dispose ( query -- )
    dup statement-handle PQclear
    0 0 rot { set-statement-n set-statement-max } set-slots ;

M: postgresql-statement prepare-statement ( statement -- )
    [
        >r db get db-handle "" r>
        dup statement-sql swap statement-params
        dup assoc-size swap PQprepare postgresql-error
    ] keep set-statement-handle ;

M: postgresql-db <simple-statement> ( sql -- statement )
    { set-statement-sql } statement construct
    <postgresql-statement> ;

M: postgresql-db <bound-statement> ( sql array -- statement )
    { set-statement-sql set-statement-params } statement construct
    <postgresql-statement> ;

M: postgresql-db <prepared-statement> ( sql -- statement )
    ;

M: postgresql-db <prepared-bound-statement> ( sql seq -- statement )
    ;
