! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes continuations kernel math
namespaces sequences sequences.lib tuples words strings
tools.walker ;
IN: db

TUPLE: db handle ;
! TUPLE: db handle insert-statements update-statements delete-statements ;
: <db> ( handle -- obj )
    ! H{ } clone H{ } clone H{ } clone
    db construct-boa ;

GENERIC: make-db* ( seq class -- db )
: make-db ( seq class -- db ) construct-empty make-db* ;
GENERIC: db-open ( db -- )
HOOK: db-close db ( handle -- )

: dispose-statements ( seq -- )
    [ dispose drop ] assoc-each ;

: dispose-db ( db -- ) 
    dup db [
        ! dup db-insert-statements dispose-statements
        ! dup db-update-statements dispose-statements
        ! dup db-delete-statements dispose-statements
        db-handle db-close
    ] with-variable ;

TUPLE: statement handle sql in-params out-params bind-params bound? ;
: <statement> ( sql in out -- statement )
    {
        set-statement-sql
        set-statement-in-params
        set-statement-out-params
    } statement construct ;

TUPLE: simple-statement ;
TUPLE: prepared-statement ;

HOOK: <simple-statement> db ( str in out -- statement )
HOOK: <prepared-statement> db ( str in out -- statement )
GENERIC: prepare-statement ( statement -- )
GENERIC: bind-statement* ( obj statement -- )
GENERIC: reset-statement ( statement -- )
GENERIC: bind-tuple ( tuple statement -- )

TUPLE: result-set sql params handle n max ;
GENERIC: query-results ( query -- result-set )
GENERIC: #rows ( result-set -- n )
GENERIC: #columns ( result-set -- n )
GENERIC# row-column 1 ( result-set n -- obj )
GENERIC: advance-row ( result-set -- )
GENERIC: more-rows? ( result-set -- ? )

: execute-statement ( statement -- )
    dup sequence? [
        [ execute-statement ] each
    ] [
        query-results dispose
    ] if ;

: bind-statement ( obj statement -- )
    dup statement-bound? [ dup reset-statement ] when
    [ bind-statement* ] 2keep
    [ set-statement-bind-params ] keep
    t swap set-statement-bound? ;

: init-result-set ( result-set -- )
    dup #rows over set-result-set-max
    0 swap set-result-set-n ;

: <result-set> ( query handle tuple -- result-set )
    >r >r { statement-sql statement-in-params } get-slots r>
    {
        set-result-set-sql
        set-result-set-params
        set-result-set-handle
    } result-set construct r> construct-delegate ;

: sql-row ( result-set -- seq )
    dup #columns [ row-column ] with map ;

: query-each ( statement quot -- )
    over more-rows? [
        [ call ] 2keep over advance-row query-each
    ] [
        2drop
    ] if ; inline

: query-map ( statement quot -- seq )
    accumulator >r query-each r> { } like ; inline

: with-db ( db seq quot -- )
    >r make-db dup db-open db r>
    [ db get swap [ drop ] swap compose with-disposal ] curry with-variable ;

: default-query ( query -- result-set )
    query-results [ [ sql-row ] query-map ] with-disposal ;

: do-bound-query ( obj query -- rows )
    [ bind-statement ] keep default-query ;

: do-bound-command ( obj query -- )
    [ bind-statement ] keep execute-statement ;


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

: sql-query ( sql -- rows )
    f f <simple-statement> [ default-query ] with-disposal ;

: sql-command ( sql -- )
    dup string? [
        f f <simple-statement> [ execute-statement ] with-disposal
    ] [
        ! [
            [ sql-command ] each
        ! ] with-transaction
    ] if ;
