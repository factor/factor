! Copyright (C) 2007, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs alien alien.syntax continuations io
kernel math math.parser namespaces prettyprint quotations
sequences debugger db db.postgresql.lib db.postgresql.ffi
db.tuples db.types tools.annotations math.ranges
combinators sequences.lib classes ;
IN: db.postgresql

TUPLE: postgresql-db host port pgopts pgtty db user pass ;
TUPLE: postgresql-statement ;
TUPLE: postgresql-result-set ;
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

M: postgresql-statement bind-statement* ( seq statement -- )
    set-statement-params ;

M: postgresql-statement reset-statement ( statement -- )
    drop ;

M: postgresql-result-set #rows ( result-set -- n )
    result-set-handle PQntuples ;

M: postgresql-result-set #columns ( result-set -- n )
    result-set-handle PQnfields ;

M: postgresql-result-set row-column ( result-set n -- obj )
    >r dup result-set-handle swap result-set-n r> PQgetvalue ;

M: postgresql-result-set row-column-typed ( result-set n type -- obj )
    >r row-column r> sql-type>factor-type ;

M: postgresql-result-set sql-type>factor-type ( obj type -- newobj )
    {
        { INTEGER [ string>number ] }
        { BIG_INTEGER [ string>number ] }
        { DOUBLE [ string>number ] }
        [ drop ]
    } case ;

M: postgresql-statement insert-statement ( statement -- id )
    query-results [ 0 row-column ] with-disposal string>number ;

M: postgresql-statement query-results ( query -- result-set )
    dup statement-params [
        over [ bind-statement ] keep
        do-postgresql-bound-statement
    ] [
        dup do-postgresql-statement
    ] if*
    postgresql-result-set <result-set>
    dup init-result-set ;

M: postgresql-result-set advance-row ( result-set -- )
    dup result-set-n 1+ swap set-result-set-n ;

M: postgresql-result-set more-rows? ( result-set -- ? )
    dup result-set-n swap result-set-max < ;

M: postgresql-statement dispose ( query -- )
    dup statement-handle PQclear
    f swap set-statement-handle ;

M: postgresql-result-set dispose ( result-set -- )
    dup result-set-handle PQclear
    0 0 f roll {
        set-result-set-n set-result-set-max set-result-set-handle
    } set-slots ;

M: postgresql-statement prepare-statement ( statement -- )
    [
        >r db get db-handle "" r>
        dup statement-sql swap statement-params
        length f PQprepare postgresql-error
    ] keep set-statement-handle ;

M: postgresql-db <simple-statement> ( sql -- statement )
    { set-statement-sql } statement construct
    <postgresql-statement> ;

M: postgresql-db <prepared-statement> ( sql -- statement )
    { set-statement-sql } statement construct
    <postgresql-statement> ;

M: postgresql-db begin-transaction ( -- )
    "BEGIN" sql-command ;

M: postgresql-db commit-transaction ( -- )
    "COMMIT" sql-command ;

M: postgresql-db rollback-transaction ( -- )
    "ROLLBACK" sql-command ;

: insert-function ( columns table -- sql types )
    [
        >r remove-id r>
        "create function add_" % dup %
        "(" %
        over [ "," % ]
        [ third dup array? [ first ] when >sql-type-string % ] interleave
        ")" %
        " returns bigint as '" %

        2dup "insert into " %
        %
        "(" %
        dup [ ", " % ] [ second % ] interleave
        ") " %
        " values (" %
        length [1,b] [ ", " % ] [ "$" % # ] interleave
        "); " %

        "select currval(''" % % "_id_seq'');' language sql;" %
        drop
    ] "" make f ;

: drop-function ( columns table -- sql )
    [
        >r remove-id r>
        "drop function add_" % %
        "(" %
        [ "," % ] [ third >sql-type-string % ] interleave
        ")" %
    ] "" nmake ;

! M: postgresql-db create-sql ( columns table -- seq )
    ! [
        ! [
            ! 2dup
            ! "create table " % %
            ! " (" % [ ", " % ] [
                ! dup second % " " %
                ! dup third >sql-type-string % " " %
                ! sql-modifiers " " join %
            ! ] interleave "); " %
        ! ] "" make ,
! 
        ! over native-id? [ insert-function , ] [ 2drop ] if
    ! ] { } make ;

M: postgresql-db drop-sql ( columns table -- seq )
    [
        [
            dup "drop table " % % ";" %
        ] "" make ,
        over native-id? [ drop-function , ] [ 2drop ] if
    ] { } make ;

M: postgresql-db insert-sql* ( columns table -- sql slots )
    [
        "select add_" % %
        "(" %
        dup length [1,b] [ ", " % ] [ "$" % # ] interleave
        ");" %
    ] "" make ;

M: postgresql-db update-sql* ( columns table -- sql slots )
    [
        "update " %
        %
        " set " %
        dup remove-id
        dup length [1,b] swap 2array flip
        [ ", " % ] [ first2 second % " = $" % # ] interleave
        " where " %
        [ primary-key? ] find nip second dup % " = $" % length 2 + #
    ] "" make ;

M: postgresql-db delete-sql* ( columns table -- slot-names sql )
    [
        "delete from " %
        %
        " where " %
        first second % " = $1" %
    ] "" make ;

: column-name% ( spec -- )
    dup sql-spec-column-name 0%
    sql-spec-type >sql-type-string 1, ;

: column-names% ( class -- )
    db-columns [ "," 0, ] [ column-name% ] interleave ;

M: postgresql-db column-bind% ( spec -- )
    
    
    ;


! : select-foreign-table-sql ( tuple relation -- )
! ! select id, name, age from puppy, basket where puppy.basket_id = basket.id
    ! "select " 0% 
    ! ;
! TODO
: select-relations-sql ( tuple -- seq )
    ! seq -- { sql types }
    dup class db-relations [
        [
            ! select-foreign-table-sql
        ] { "" { } } 2 nmake
    ] with { } map>assoc ;

! TODO
: select-by-slots-sql ( tuple -- sql )
    dup tuple>filled-slots
    ;


M: postgresql-db select-sql ( tuple -- sql slot-names )
    [
        
    ] { } 2 nmake ;

M: postgresql-db tuple>params ( columns tuple -- obj )
    [ >r dup third swap first r> get-slot-named swap ]
    curry { } map>assoc ;
    
: postgresql-db-modifiers ( -- hashtable )
    H{
        { +native-id+ "primary key" }
        { +foreign-key+ "" }
        { +assigned-id+ "primary key" }
        { +autoincrement+ "autoincrement" }
        { +unique+ "unique" }
        { +default+ "default" }
        { +null+ "null" }
        { +not-null+ "not null" }
    } ;

! M: postgresql-db sql-modifier>string ( modifier -- str )
    ! dup array? [
        ! first2
        ! >r swap at r> number>string*
        ! " " swap 3append
    ! ] [
        ! swap at
    ! ] if ;
! 
! M: postgresql-db sql-modifiers* ( modifiers -- str )
    ! postgresql-db-modifiers swap [
        ! sql-modifier>string
    ! ] with map [ ] subset ;
