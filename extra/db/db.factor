! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes continuations kernel math
namespaces sequences sequences.lib tuples words strings
tools.walker new-slots accessors ;
IN: db

TUPLE: db
    handle
    insert-statements
    update-statements
    delete-statements ;

: <db> ( handle -- obj )
    H{ } clone H{ } clone H{ } clone
    db construct-boa ;

GENERIC: make-db* ( seq class -- db )
GENERIC: db-open ( db -- )
HOOK: db-close db ( handle -- )
: make-db ( seq class -- db ) construct-empty make-db* ;

: dispose-statements ( seq -- ) [ dispose drop ] assoc-each ;

: dispose-db ( db -- ) 
    dup db [
        dup insert-statements>> dispose-statements
        dup update-statements>> dispose-statements
        dup delete-statements>> dispose-statements
        handle>> db-close
    ] with-variable ;

TUPLE: statement handle sql in-params out-params bind-params bound? ;
TUPLE: simple-statement ;
TUPLE: prepared-statement ;
TUPLE: result-set sql in-params out-params handle n max ;
: <statement> ( sql in out -- statement )
    { (>>sql) (>>in-params) (>>out-params) } statement construct ;

HOOK: <simple-statement> db ( str in out -- statement )
HOOK: <prepared-statement> db ( str in out -- statement )
GENERIC: prepare-statement ( statement -- )
GENERIC: bind-statement* ( statement -- )
GENERIC: bind-tuple ( tuple statement -- )
GENERIC: query-results ( query -- result-set )
GENERIC: #rows ( result-set -- n )
GENERIC: #columns ( result-set -- n )
GENERIC# row-column 1 ( result-set column -- obj )
GENERIC# row-column-typed 1 ( result-set column -- sql )
GENERIC: advance-row ( result-set -- )
GENERIC: more-rows? ( result-set -- ? )

: execute-statement ( statement -- )
    dup sequence? [
        [ execute-statement ] each
    ] [
        query-results dispose
    ] if ;

: bind-statement ( obj statement -- )
    swap >>bind-params
    [ bind-statement* ] keep
    t >>bound? drop ;

: init-result-set ( result-set -- )
    dup #rows >>max
    0 >>n drop ;

: <result-set> ( query handle tuple -- result-set )
    >r >r { sql>> in-params>> out-params>> } get-slots r>
    { (>>sql) (>>in-params) (>>out-params) (>>handle) } result-set
    construct r> construct-delegate ;

: sql-row ( result-set -- seq )
    dup #columns [ row-column ] with map ;

: sql-row-typed ( result-set -- seq )
    dup #columns [ row-column-typed ] with map ;

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
