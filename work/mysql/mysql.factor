! Copyright (C) 2011 PolyMicro Systems
! See http://factorcode.org/license.txt for BSD license.

USING: accessors combinators db db.private db.queries db.tuples
db.tuples.private db.types destructors interpolate io
io.streams.string kernel locals math math.parser mysql.ffi namespaces
nmake random sequences sequences.deep slots.syntax strings syslog ;

IN: mysql

TUPLE: mysql-db
    mysqlconn
    { host string }
    { user string }
    { passwd string }
    { db string }
    { port integer }
    { unixsocket string }
    { clientflag integer }
    resulthandle ;


: <mysql-db> ( host user passwd -- mysql-db )
    { } 3sequence
    mysql-db new
    swap
    set-slots{ host user passwd }
;

: init-with-db: ( mysql-db db -- mysql-db )
    >>db ;

TUPLE: mysql-db-connection < db-connection ;

: <mysql-db-connection> ( -- db-connection )
    mysql-db-connection new-db-connection
    f mysql_init >>handle ;

M:: mysql-db db-open ( db -- db-connection )
    db <mysql-db-connection> >>mysqlconn
    mysqlconn>> handle>>
    db get[ host user passwd db port unixsocket clientflag ]
    mysql_real_connect
    db swap
        dup "db-open: " SYSLOG_VALUE
        >>resulthandle
    mysqlconn>>
    ;

M: mysql-db-connection db-close ( handle -- )
    mysql_close ;

TUPLE: mysql-statement < statement ;

TUPLE: mysql-result-set < result-set has-more? ;

M: mysql-db-connection <simple-statement> ( str in out -- obj )
    mysql-statement new-statement
    db-connection get handle>>
    >>handle
;
    ! <prepared-statement> ;

! M: mysql-db-connection <prepared-statement> ( str in out -- obj )
!     B mysql-statement new-statement ;

: mysql-maybe-prepare ( statement -- statement )
    dup handle>> [
        db-connection get handle>>
        >>handle
    ] unless ;

! M: mysql-statement dispose ( statement -- )
!     handle>>
!     [ [ mysql_reset drop ] keep mysql-finalize ] when* ;

M: mysql-statement dispose ( statement -- )
    handle>> drop ;

    ! [ [ mysql_reset drop ] keep mysql-finalize ] when* ;

M: mysql-result-set dispose ( result-set -- )
    f >>handle drop ;

! : reset-bindings ( statement -- )
!     mysql-maybe-prepare
!     handle>> mysql_stmt_reset drop ;

! M: mysql-statement low-level-bind ( statement -- )
!     [ handle>> ] [ bind-params>> ] bi
!     [ [ key>> ] [ value>> ] [ type>> ] tri mysql-bind-type ] with each ;

! M: mysql-statement bind-statement* ( statement -- )
!     mysql-maybe-prepare
!     dup bound?>> [ dup reset-bindings ] when
!     low-level-bind ;

! GENERIC: mysql-bind-conversion ( tuple obj -- array )

! TUPLE: mysql-low-level-binding < low-level-binding key type ;
! : <mysql-low-level-binding> ( key value type -- obj )
!     mysql-low-level-binding new
!         swap >>type
!         swap >>value
!         swap >>key ;

! M: sql-spec mysql-bind-conversion ( tuple spec -- array )
!     [ column-name>> ":" prepend ]
!     [ slot-name>> rot get-slot-named ]
!     [ type>> ] tri <mysql-low-level-binding> ;

! M: literal-bind mysql-bind-conversion ( tuple literal-bind -- array )
!     nip [ key>> ] [ value>> ] [ type>> ] tri
!     <mysql-low-level-binding> ;

! M:: generator-bind mysql-bind-conversion ( tuple generate-bind -- array )
!     generate-bind generator-singleton>> eval-generator :> obj
!     generate-bind slot-name>> :> name
!     obj name tuple set-slot-named
!     generate-bind key>> obj generate-bind type>> <mysql-low-level-binding> ;

! M: mysql-statement bind-tuple ( tuple statement -- )
!     [
!         in-params>> [ mysql-bind-conversion ] with map
!     ] keep bind-statement ;

ERROR: mysql-last-id-fail ;

! : last-insert-id ( -- id )
!     db-connection get handle>> mysql_last_insert_rowid
!     dup zero? [ mysql-last-id-fail ] when ;

! M: mysql-db-connection insert-tuple-set-key ( tuple statement -- )
!     execute-statement last-insert-id swap set-primary-key ;

! M: mysql-result-set #columns ( result-set -- n )
!     handle>> mysql-#columns ;

! M: mysql-result-set row-column ( result-set n -- obj )
!     [ handle>> ] [ mysql-column ] bi* ;

! M: mysql-result-set row-column-typed ( result-set n -- obj )
!     dup pick out-params>> nth type>>
!     [ handle>> ] 2dip mysql-column-typed ;

M: mysql-result-set advance-row ( result-set -- )
    dup handle>>
    mysql_next_result 0 = >>has-more? drop ;

M: mysql-result-set more-rows? ( result-set -- ? )
    has-more?>> ;

M:: mysql-result-set query-results ( result-set -- result-set )
    result-set handle>> result-set sql>>
     mysql_query result-set swap >>n
    ;

M:: mysql-statement query-results ( query -- result-set )
    SYSLOG_HERE
    query dup mysql-maybe-prepare
    handle>> mysql-result-set new-result-set
    query-results
    dup advance-row ;

M: mysql-db-connection <insert-db-assigned-statement> ( class -- statement )
    [
        "insert into " 0% 0%
        "(" 0%
        remove-db-assigned-id
        dup [ ", " 0% ] [ column-name>> 0% ] interleave
        ") values(" 0%
        [ ", " 0% ] [
            dup type>> +random-id+ = [
                [ slot-name>> ]
                [
                    column-name>> ":" prepend dup 0%
                    random-id-generator
                ] [ type>> ] tri <generator-bind> 1,
            ] [
                bind%
            ] if
        ] interleave
        ");" 0%
    ] query-make ;

M: mysql-db-connection <insert-user-assigned-statement> ( class -- statement )
    <insert-db-assigned-statement> ;

M: mysql-db-connection bind# ( spec obj -- )
    [
        [ column-name>> ":" next-sql-counter surround dup 0% ]
        [ type>> ] bi
    ] dip <literal-bind> 1, ;

M: mysql-db-connection bind% ( spec -- )
    dup 1, column-name>> ":" prepend 0% ;

M: mysql-db-connection persistent-table ( -- assoc )
    H{
        { +db-assigned-id+ { "integer" "integer" f } }
        { +user-assigned-id+ { f f f } }
        { +random-id+ { "integer" "integer" f } }
        { +foreign-id+ { "integer" "integer" "references" } }

        { +on-update+ { f f "on update" } }
        { +on-delete+ { f f "on delete" } }
        { +restrict+ { f f "restrict" } }
        { +cascade+ { f f "cascade" } }
        { +set-null+ { f f "set null" } }
        { +set-default+ { f f "set default" } }

        { BOOLEAN { "boolean" "boolean" f } }
        { INTEGER { "integer" "integer" f } }
        { BIG-INTEGER { "bigint" "bigint" f } }
        { SIGNED-BIG-INTEGER { "bigint" "bigint" f } }
        { UNSIGNED-BIG-INTEGER { "bigint" "bigint" f } }
        { TEXT { "text" "text" f } }
        { VARCHAR { "text" "text" f } }
        { DATE { "date" "date" f } }
        { TIME { "time" "time" f } }
        { DATETIME { "datetime" "datetime" f } }
        { TIMESTAMP { "timestamp" "timestamp" f } }
        { DOUBLE { "real" "real" f } }
        { BLOB { "blob" "blob" f } }
        { FACTOR-BLOB { "blob" "blob" f } }
        { URL { "text" "text" f } }
        { +autoincrement+ { f f "autoincrement" } }
        { +unique+ { f f "unique" } }
        { +default+ { f f "default" } }
        { +null+ { f f "null" } }
        { +not-null+ { f f "not null" } }
        { system-random-generator { f f f } }
        { secure-random-generator { f f f } }
        { random-generator { f f f } }
    } ;

: insert-trigger ( -- string )
    [
    """
        CREATE TRIGGER fki_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE INSERT ON ${table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'insert on table "${table-name}" violates foreign key constraint "fki_${table-name}_$table-id}_${foreign-table-name}_${foreign-table-id}_id"')
            WHERE  (SELECT ${foreign-table-id} FROM ${foreign-table-name} WHERE ${foreign-table-id} = NEW.${table-id}) IS NULL;
        END;
    """ interpolate
    ] with-string-writer ;

: insert-trigger-not-null ( -- string )
    [
    """
        CREATE TRIGGER fki_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE INSERT ON ${table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'insert on table "${table-name}" violates foreign key constraint "fki_${table-name}_$table-id}_${foreign-table-name}_${foreign-table-id}_id"')
            WHERE NEW.${table-id} IS NOT NULL
                AND (SELECT ${foreign-table-id} FROM ${foreign-table-name} WHERE ${foreign-table-id} = NEW.${table-id}) IS NULL;
        END;
    """ interpolate
    ] with-string-writer ;

: update-trigger ( -- string )
    [
    """
        CREATE TRIGGER fku_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE UPDATE ON ${table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'update on table "${table-name}" violates foreign key constraint "fku_${table-name}_$table-id}_${foreign-table-name}_${foreign-table-id}_id"')
            WHERE (SELECT ${foreign-table-id} FROM ${foreign-table-name} WHERE ${foreign-table-id} = NEW.${table-id}) IS NULL;
        END;
    """ interpolate
    ] with-string-writer ;

: update-trigger-not-null ( -- string )
    [
    """
        CREATE TRIGGER fku_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE UPDATE ON ${table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'update on table "${table-name}" violates foreign key constraint "fku_${table-name}_$table-id}_${foreign-table-name}_${foreign-table-id}_id"')
            WHERE NEW.${table-id} IS NOT NULL
                AND (SELECT ${foreign-table-id} FROM ${foreign-table-name} WHERE ${foreign-table-id} = NEW.${table-id}) IS NULL;
        END;
    """ interpolate
    ] with-string-writer ;

: delete-trigger-restrict ( -- string )
    [
    """
        CREATE TRIGGER fkd_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE DELETE ON ${foreign-table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'delete on table "${foreign-table-name}" violates foreign key constraint "fkd_${table-name}_$table-id}_${foreign-table-name}_${foreign-table-id}_id"')
            WHERE (SELECT ${foreign-table-id} FROM ${foreign-table-name} WHERE ${foreign-table-id} = OLD.${foreign-table-id}) IS NOT NULL;
        END;
    """ interpolate
    ] with-string-writer ;

: delete-trigger-cascade ( -- string )
    [
    """
        CREATE TRIGGER fkd_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE DELETE ON ${foreign-table-name}
        FOR EACH ROW BEGIN
            DELETE from ${table-name} WHERE ${table-id} = OLD.${foreign-table-id};
        END;
    """ interpolate
    ] with-string-writer ;

: can-be-null? ( -- ? )
    "sql-spec" get modifiers>> [ +not-null+ = ] any? not ;

: delete-cascade? ( -- ? )
    "sql-spec" get modifiers>> { +on-delete+ +cascade+ } swap subseq? ;

: mysql-trigger, ( string -- )
    { } { } <simple-statement> 3, ;

: create-mysql-triggers ( -- )
    can-be-null? [
        insert-trigger mysql-trigger,
        update-trigger mysql-trigger,
    ] [ 
        insert-trigger-not-null mysql-trigger,
        update-trigger-not-null mysql-trigger,
    ] if
    delete-cascade? [
        delete-trigger-cascade mysql-trigger,
    ] [
        delete-trigger-restrict mysql-trigger,
    ] if ;

: create-db-triggers ( sql-specs -- )
    [ modifiers>> [ +foreign-id+ = ] deep-any? ] filter
    [
        [ class>> db-table-name "db-table" set ]
        [
            [ "sql-spec" set ]
            [ column-name>> "table-id" set ]
            [ ] tri
            modifiers>> [ [ +foreign-id+ = ] deep-any? ] filter
            [
                [ second db-table-name "foreign-table-name" set ]
                [ third "foreign-table-id" set ] bi
                create-mysql-triggers
            ] each
        ] bi
    ] each ;

: mysql-create-table ( sql-specs class-name -- )
    [
        "create table " 0% 0%
        "(" 0% [ ", " 0% ] [
            dup "sql-spec" set
            dup column-name>> [ "table-id" set ] [ 0% ] bi
            " " 0%
            dup type>> lookup-create-type 0%
            modifiers 0%
        ] interleave
    ] [
        drop
        find-primary-key [
            ", " 0%
            "primary key(" 0%
            [ "," 0% ] [ column-name>> 0% ] interleave
            ")" 0%
        ] unless-empty
        ");" 0%
    ] 2bi ;

M: mysql-db-connection create-sql-statement ( class -- statement )
    [
        [ mysql-create-table ]
        [ drop create-db-triggers ] 2bi
    ] query-make ;

M: mysql-db-connection drop-sql-statement ( class -- statements )
    [ nip "drop table " 0% 0% ";" 0% ] query-make ;

M: mysql-db-connection compound ( string seq -- new-string )
    over {
        { "default" [ first number>string " " glue ] }
        { "references" [ >reference-string ] }
        [ 2drop ]
    } case ;

M: mysql-db-connection parse-db-error
    dup n>> {
        ! { 1 [ string>> parse-mysql-sql-error drop ] }
        { 1 [ string>> ] }
        [ drop ]
    } case ;

: db-args ( -- {host user passwd} ) "localhost" "davec" "ac130" ;
: mysql-test ( -- )
    db-args <mysql-db>  "test" init-with-db:
    [
        "create table person (name varchar(30), country varchar(30))" sql-command
        "insert into person values('John', 'America')" sql-command
        "insert into person values('Jane', 'New Zealand')" sql-command
    ] with-db
;

: mysql-dbs ( -- )
    SYSLOG_HERE
    db-args <mysql-db>  "pms_test" init-with-db:
    [
        "select * from person" B sql-query print
    ] with-db
;
