! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes continuations kernel math
namespaces sequences sequences.lib tuples words ;
IN: db

TUPLE: db handle ;
C: <db> db ( handle -- obj )

! HOOK: db-create db ( str -- )
! HOOK: db-drop db ( str -- )
GENERIC: db-open ( db -- )
GENERIC: db-close ( db -- )

TUPLE: statement sql params handle bound? n max ;

TUPLE: simple-statement ;
TUPLE: bound-statement ;
TUPLE: prepared-statement ;
TUPLE: prepared-bound-statement ;

HOOK: <simple-statement> db ( str -- statement )
HOOK: <bound-statement> db ( str obj -- statement )
HOOK: <prepared-statement> db ( str -- statement )
HOOK: <prepared-bound-statement> db ( str obj -- statement )

! TUPLE: result sql params handle n max ;

GENERIC: #rows ( statement -- n )
GENERIC: #columns ( statement -- n )
GENERIC# row-column 1 ( statement n -- obj )
GENERIC: advance-row ( statement -- ? )

GENERIC: prepare-statement ( statement -- )
GENERIC: reset-statement ( statement -- )
GENERIC: bind-statement* ( obj statement -- )
GENERIC: rebind-statement ( obj statement -- )

: bind-statement ( obj statement -- )
    2dup dup statement-bound? [
        rebind-statement
    ] [
        bind-statement*
    ] if
    tuck set-statement-params
    t swap set-statement-bound? ;

: sql-row ( statement -- seq )
    dup #columns [ row-column ] with map ;

: query-each ( statement quot -- )
    over advance-row [
        2drop
    ] [
        [ call ] 2keep query-each
    ] if ; inline

: query-map ( statement quot -- seq )
    accumulator >r query-each r> { } like ; inline

: with-db ( db quot -- )
    [
        over db-open
        [ db swap with-variable ] curry with-disposal
    ] with-scope ;

: do-statement ( statement -- )
    [ advance-row drop ] with-disposal ;

: do-query ( query -- rows )
    [ [ sql-row ] query-map ] with-disposal ;

: do-simple-query ( sql -- rows )
    <simple-statement> do-query ;

: do-bound-query ( sql obj -- rows )
    <bound-statement> do-query ;

: do-simple-command ( sql -- )
    <simple-statement> do-statement ;

: do-bound-command ( sql obj -- )
    <bound-statement> do-statement ;

SYMBOL: in-transaction
HOOK: begin-transaction db ( -- )
HOOK: commit-transaction db ( -- )
HOOK: rollback-transaction db ( -- )

: in-transaction? ( -- ? ) in-transaction get ;

: with-transaction ( quot -- )
    t in-transaction [
        begin-transaction
        [ ] [ rollback-transaction ] cleanup commit-transaction
    ] with-variable ;
