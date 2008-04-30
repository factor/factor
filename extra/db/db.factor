! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes continuations kernel math
namespaces sequences sequences.lib classes.tuple words strings
tools.walker accessors combinators.lib ;
IN: db

TUPLE: db
    handle
    insert-statements
    update-statements
    delete-statements ;

: new-db ( class -- obj )
    new
        H{ } clone >>insert-statements
        H{ } clone >>update-statements
        H{ } clone >>delete-statements ;

GENERIC: make-db* ( seq class -- db )

: make-db ( seq class -- db )
    new-db make-db* ;

GENERIC: db-open ( db -- db )
HOOK: db-close db ( handle -- )

: dispose-statements ( seq -- ) [ dispose drop ] assoc-each ;

: dispose-db ( db -- ) 
    dup db [
        dup insert-statements>> dispose-statements
        dup update-statements>> dispose-statements
        dup delete-statements>> dispose-statements
        handle>> db-close
    ] with-variable ;

TUPLE: statement handle sql in-params out-params bind-params bound? type ;
TUPLE: simple-statement < statement ;
TUPLE: prepared-statement < statement ;

SINGLETON: throwable
SINGLETON: nonthrowable

: make-throwable ( obj -- obj' )
    dup sequence? [
        [ make-throwable ] map
    ] [
        throwable >>type
    ] if ;

: make-nonthrowable ( obj -- obj' )
    dup sequence? [
        [ make-nonthrowable ] map
    ] [
        nonthrowable >>type
    ] if ;

TUPLE: result-set sql in-params out-params handle n max ;

: construct-statement ( sql in out class -- statement )
    new
        swap >>out-params
        swap >>in-params
        swap >>sql
        throwable >>type ;

HOOK: <simple-statement> db ( str in out -- statement )
HOOK: <prepared-statement> db ( str in out -- statement )
GENERIC: prepare-statement ( statement -- )
GENERIC: bind-statement* ( statement -- )
GENERIC: low-level-bind ( statement -- )
GENERIC: bind-tuple ( tuple statement -- )
GENERIC: query-results ( query -- result-set )
GENERIC: #rows ( result-set -- n )
GENERIC: #columns ( result-set -- n )
GENERIC# row-column 1 ( result-set column -- obj )
GENERIC# row-column-typed 1 ( result-set column -- sql )
GENERIC: advance-row ( result-set -- )
GENERIC: more-rows? ( result-set -- ? )

GENERIC: execute-statement* ( statement type -- )

M: throwable execute-statement* ( statement type -- )
    drop query-results dispose ;

M: nonthrowable execute-statement* ( statement type -- )
    drop [ query-results dispose ] [ 2drop ] recover ;

: execute-statement ( statement -- )
    dup sequence? [
        [ execute-statement ] each
    ] [
        dup type>> execute-statement*
    ] if ;

: bind-statement ( obj statement -- )
    swap >>bind-params
    [ bind-statement* ] keep
    t >>bound? drop ;

: init-result-set ( result-set -- )
    dup #rows >>max
    0 >>n drop ;

: construct-result-set ( query handle class -- result-set )
    new
        swap >>handle
        >r [ sql>> ] [ in-params>> ] [ out-params>> ] tri r>
        swap >>out-params
        swap >>in-params
        swap >>sql ;
    
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
    >r make-db db-open db r>
    [ db get swap [ drop ] prepose with-disposal ] curry with-variable ;
    inline

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
