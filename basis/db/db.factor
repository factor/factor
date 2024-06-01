! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations destructors kernel
namespaces sequences strings ;
IN: db

TUPLE: db-connection < disposable
    handle
    insert-statements
    update-statements
    delete-statements ;

<PRIVATE

: new-db-connection ( class -- obj )
    new
        H{ } clone >>insert-statements
        H{ } clone >>update-statements
        H{ } clone >>delete-statements ; inline

PRIVATE>

GENERIC: db-open ( db -- db-connection )
HOOK: db-close db-connection ( handle -- )
HOOK: parse-db-error db-connection ( error -- error' )

: dispose-statements ( assoc -- ) values dispose-each ;

M: db-connection dispose*
    dup db-connection [
        [ dispose-statements H{ } clone ] change-insert-statements
        [ dispose-statements H{ } clone ] change-update-statements
        [ dispose-statements H{ } clone ] change-delete-statements
        [ db-close f ] change-handle
        drop
    ] with-variable ;

TUPLE: result-set sql < disposable in-params out-params handle n max ;

M: result-set dispose* drop ;

GENERIC: query-results ( query -- result-set )
GENERIC: #rows ( result-set -- n )
GENERIC: #columns ( result-set -- n )
GENERIC#: row-column 1 ( result-set column -- obj )
GENERIC#: row-column-typed 1 ( result-set column -- sql )
GENERIC: advance-row ( result-set -- )
GENERIC: more-rows? ( result-set -- ? )

: init-result-set ( result-set -- )
    dup #rows >>max
    0 >>n drop ;

: new-result-set ( query handle class -- result-set )
    new
        swap >>handle
        [ [ sql>> ] [ in-params>> ] [ out-params>> ] tri ] dip
        swap >>out-params
        swap >>in-params
        swap >>sql ;

TUPLE: statement < disposable handle sql in-params out-params bind-params bound? type retries ;
TUPLE: simple-statement < statement ;
TUPLE: prepared-statement < statement ;

M: statement dispose* drop ;

: new-statement ( sql in out class -- statement )
    new
        swap >>out-params
        swap >>in-params
        swap >>sql ;

HOOK: <simple-statement> db-connection ( string in out -- statement )
HOOK: <prepared-statement> db-connection ( string in out -- statement )
GENERIC: prepare-statement ( statement -- )
GENERIC: bind-statement* ( statement -- )
GENERIC: low-level-bind ( statement -- )
GENERIC: bind-tuple ( tuple statement -- )

GENERIC: execute-statement* ( statement type -- )

M: object execute-statement*
    '[
        _ _ drop query-results dispose
    ] [
        parse-db-error rethrow
    ] recover ;

: execute-one-statement ( statement -- )
    dup type>> execute-statement* ;

: execute-statement ( statement -- )
    dup sequence? [
        [ execute-one-statement ] each
    ] [
        execute-one-statement
    ] if ;

: bind-statement ( obj statement -- )
    swap >>bind-params
    [ bind-statement* ] keep
    t >>bound? drop ;

: sql-row ( result-set -- seq )
    dup #columns [ row-column ] with map-integers ;

: sql-row-typed ( result-set -- seq )
    dup #columns [ row-column-typed ] with map-integers ;

: query-each ( result-set quot: ( row -- ) -- )
    over more-rows? [
        [ call ] 2keep over advance-row query-each
    ] [
        2drop
    ] if ; inline recursive

: query-map ( result-set quot: ( row -- row' ) -- seq )
    collector [ query-each ] dip { } like ; inline

: with-db ( db quot -- )
    [ db-open db-connection ] dip
    '[ db-connection get [ drop @ ] with-disposal ] with-variable ; inline

! Words for working with raw SQL statements
: default-query ( query -- result-set )
    query-results [ [ sql-row ] query-map ] with-disposal ;

: sql-query ( sql -- rows )
    f f <simple-statement> [ default-query ] with-disposal ;

: (sql-command) ( string -- )
    f f <simple-statement> [ execute-statement ] with-disposal ;

: sql-command ( sql -- )
    dup string? [ (sql-command) ] [ [ (sql-command) ] each ] if ;

! Transactions
SYMBOL: in-transaction

HOOK: begin-transaction db-connection ( -- )
HOOK: commit-transaction db-connection ( -- )
HOOK: rollback-transaction db-connection ( -- )

M: db-connection begin-transaction "BEGIN" sql-command ;
M: db-connection commit-transaction "COMMIT" sql-command ;
M: db-connection rollback-transaction "ROLLBACK" sql-command ;

: in-transaction? ( -- ? ) in-transaction get ;

: with-transaction ( quot -- )
    in-transaction? [
        call
    ] [
        t in-transaction [
            begin-transaction
            [ ] [ rollback-transaction ] cleanup commit-transaction
        ] with-variable
    ] if ; inline
