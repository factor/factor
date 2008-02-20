! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes continuations kernel math
namespaces sequences sequences.lib tuples words strings ;
IN: db

TUPLE: db handle insert-statements update-statements delete-statements ;
: <db> ( handle -- obj )
    H{ } clone H{ } clone H{ } clone
    db construct-boa ;

GENERIC: db-open ( db -- )
HOOK: db-close db ( handle -- )

: dispose-statements ( seq -- )
    [ dispose drop ] assoc-each ;

: dispose-db ( db -- ) 
    dup db [
        dup db-insert-statements dispose-statements
        dup db-update-statements dispose-statements
        dup db-delete-statements dispose-statements
        db-handle db-close
    ] with-variable ;

TUPLE: statement handle sql slot-names bound? in-params out-params ;
TUPLE: simple-statement ;
TUPLE: prepared-statement ;

HOOK: <simple-statement> db ( str -- statement )
HOOK: <prepared-statement> db ( str slot-names -- statement )
GENERIC: prepare-statement ( statement -- )
GENERIC: bind-statement* ( obj statement -- )
GENERIC: reset-statement ( statement -- )
GENERIC: insert-statement ( statement -- id )

TUPLE: result-set sql params handle n max ;
GENERIC: query-results ( query -- result-set )
GENERIC: #rows ( result-set -- n )
GENERIC: #columns ( result-set -- n )
GENERIC# row-column 1 ( result-set n -- obj )
GENERIC: advance-row ( result-set -- )
GENERIC: more-rows? ( result-set -- ? )

: execute-statement ( statement -- ) query-results dispose ;

: bind-statement ( obj statement -- )
    dup statement-bound? [ dup reset-statement ] when
    [ bind-statement* ] 2keep
    [ set-statement-in-params ] keep
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

: with-db ( db quot -- )
    [
        over db-open
        [ db swap with-variable ] curry with-disposal
    ] with-scope ;

: do-query ( query -- result-set )
    query-results [ [ sql-row ] query-map ] with-disposal ;

: do-bound-query ( obj query -- rows )
    [ bind-statement ] keep do-query ;

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
    <simple-statement> [ do-query ] with-disposal ;

: sql-command ( sql -- )
    dup string? [
        <simple-statement> [ execute-statement ] with-disposal
    ] [
        ! [
            [ sql-command ] each
        ! ] with-transaction
    ] if ;
