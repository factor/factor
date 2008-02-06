! Copyright (C) 2005, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs classes compiler db
hashtables io.files kernel math math.parser namespaces
prettyprint sequences strings tuples alien.c-types
continuations db.sqlite.lib db.sqlite.ffi ;
IN: db.sqlite

TUPLE: sqlite-db path ;
C: <sqlite-db> sqlite-db

M: sqlite-db db-open ( db -- )
    dup sqlite-db-path sqlite-open <db>
    swap set-delegate ;

M: sqlite-db dispose ( obj -- )
    dup db-handle sqlite-close
    f over set-db-handle
    f swap set-delegate ;

: with-sqlite ( path quot -- )
    >r <sqlite-db> r> with-db ; inline

TUPLE: sqlite-statement ;
C: <sqlite-statement> sqlite-statement

TUPLE: sqlite-result-set ;
: <sqlite-result-set> ( query -- sqlite-result-set )
    dup statement-handle sqlite-result-set <result-set> ;

M: sqlite-db <simple-statement> ( str -- obj )
    <prepared-statement> ;

M: sqlite-db <prepared-statement> ( str -- obj )
    db get db-handle over sqlite-prepare
    { set-statement-sql set-statement-handle } statement construct
    <sqlite-statement> [ set-delegate ] keep ;

M: sqlite-statement dispose ( statement -- )
    statement-handle sqlite-finalize ;

M: sqlite-result-set dispose ( result-set -- )
    f swap set-result-set-handle ;

M: sqlite-statement bind-statement* ( assoc statement -- )
    statement-handle swap sqlite-bind-assoc ;

M: sqlite-statement rebind-statement ( assoc statement -- )
    dup statement-handle sqlite-reset
    statement-handle swap sqlite-bind-assoc ;

M: sqlite-statement execute-statement ( statement -- )
    statement-handle sqlite-next drop ;

M: sqlite-result-set #columns ( result-set -- n )
    result-set-handle sqlite-#columns ;

M: sqlite-result-set row-column ( result-set n -- obj )
    >r result-set-handle r> sqlite-column ;

M: sqlite-result-set advance-row ( result-set -- handle ? )
    result-set-handle sqlite-next ;

M: sqlite-statement query-results ( query -- result-set )
    dup statement-handle sqlite-result-set <result-set> ;

M: sqlite-db begin-transaction ( -- )
    "BEGIN" sql-command ;

M: sqlite-db commit-transaction ( -- )
    "COMMIT" sql-command ;

M: sqlite-db rollback-transaction ( -- )
    "ROLLBACK" sql-command ;
