! Copyright (C) 2005, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs classes compiler db db.sql hashtables
io.files kernel math math.parser namespaces prettyprint sequences
strings sqlite.lib tuples alien.c-types continuations
db.sqlite.lib db.sqlite.ffi ;
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

M: sqlite-db <simple-statement> ( str -- obj )
    <prepared-statement> ;

M: sqlite-db <bound-statement> ( str -- obj )
    <prepared-bound-statement> ;

M: sqlite-db <prepared-statement> ( str -- obj )
    db get db-handle over sqlite-prepare
    { set-statement-sql set-statement-handle } statement construct
    <sqlite-statement> [ set-delegate ] keep ;

M: sqlite-db <prepared-bound-statement> ( str assoc -- obj )
    swap <prepared-statement> tuck bind-statement ;

M: sqlite-statement dispose ( statement -- )
    statement-handle sqlite-finalize ;

M: sqlite-statement bind-statement* ( assoc statement -- )
    statement-handle swap sqlite-bind-assoc ;

M: sqlite-statement rebind-statement ( assoc statement -- )
    dup reset-statement
    statement-handle swap sqlite-bind-assoc ;

M: sqlite-statement #columns ( statement -- n )
    statement-handle sqlite-#columns ;

M: sqlite-statement row-column ( statement n -- obj )
    >r statement-handle r> sqlite-column ;

M: sqlite-statement advance-row ( statement -- ? )
    statement-handle sqlite-next ;

M: sqlite-statement reset-statement ( statement -- )
    statement-handle sqlite-reset ;

M: sqlite-db begin-transaction ( -- )
    "BEGIN" do-simple-command ;

M: sqlite-db commit-transaction ( -- )
    "COMMIT" do-simple-command ;

M: sqlite-db rollback-transaction ( -- )
    "ROLLBACK" do-simple-command ;
