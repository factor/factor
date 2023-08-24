! Copyright (C) 2005, 2008 Chris Double, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple combinators db db.private db.queries
db.sqlite.errors db.sqlite.ffi db.sqlite.lib db.tuples
db.tuples.private db.types destructors interpolate kernel math
math.parser namespaces nmake random sequences sequences.deep ;
IN: db.sqlite

TUPLE: sqlite-db path ;

: <sqlite-db> ( path -- sqlite-db )
    sqlite-db new
        swap >>path ;

<PRIVATE

TUPLE: sqlite-db-connection < db-connection ;

: <sqlite-db-connection> ( handle -- db-connection )
    sqlite-db-connection new-db-connection
        swap >>handle ;

PRIVATE>

M: sqlite-db db-open
    path>> sqlite-open <sqlite-db-connection> ;

M: sqlite-db-connection db-close sqlite-close ;

TUPLE: sqlite-statement < statement ;

TUPLE: sqlite-result-set < result-set has-more? ;

M: sqlite-db-connection <simple-statement>
    <prepared-statement> ;

M: sqlite-db-connection <prepared-statement>
    sqlite-statement new-statement ;

: sqlite-maybe-prepare ( statement -- statement )
    dup handle>> [
        db-connection get handle>> over sql>> sqlite-prepare
        >>handle
    ] unless ;

M: sqlite-statement dispose
    handle>>
    [ [ sqlite3_reset drop ] keep sqlite-finalize ] when* ;

M: sqlite-result-set dispose
    f >>handle drop ;

: reset-bindings ( statement -- )
    sqlite-maybe-prepare
    handle>> [ sqlite3_reset drop ] [ sqlite3_clear_bindings drop ] bi ;

M: sqlite-statement low-level-bind
    [ handle>> ] [ bind-params>> ] bi
    [ [ key>> ] [ value>> ] [ type>> ] tri sqlite-bind-type ] with each ;

M: sqlite-statement bind-statement*
    sqlite-maybe-prepare
    dup bound?>> [ dup reset-bindings ] when
    low-level-bind ;

GENERIC: sqlite-bind-conversion ( tuple obj -- array )

TUPLE: sqlite-low-level-binding < low-level-binding key type ;
: <sqlite-low-level-binding> ( key value type -- obj )
    sqlite-low-level-binding new
        swap >>type
        swap >>value
        swap >>key ;

M: sql-spec sqlite-bind-conversion
    [ column-name>> ":" prepend ]
    [ slot-name>> rot get-slot-named ]
    [ type>> ] tri <sqlite-low-level-binding> ;

M: literal-bind sqlite-bind-conversion
    nip [ key>> ] [ value>> ] [ type>> ] tri
    <sqlite-low-level-binding> ;

M:: generator-bind sqlite-bind-conversion ( tuple generate-bind -- array )
    generate-bind generator-singleton>> eval-generator :> obj
    generate-bind slot-name>> :> name
    obj name tuple set-slot-named
    generate-bind key>> obj generate-bind type>> <sqlite-low-level-binding> ;

M: sqlite-statement bind-tuple
    [
        in-params>> [ sqlite-bind-conversion ] with map
    ] keep bind-statement ;

ERROR: sqlite-last-id-fail ;

: last-insert-id ( -- id )
    db-connection get handle>> sqlite3_last_insert_rowid
    dup zero? [ sqlite-last-id-fail ] when ;

M: sqlite-db-connection insert-tuple-set-key
    execute-statement last-insert-id swap set-primary-key ;

M: sqlite-result-set #columns
    handle>> sqlite-#columns ;

M: sqlite-result-set row-column
    [ handle>> ] [ sqlite-column ] bi* ;

M: sqlite-result-set row-column-typed
    dup pick out-params>> nth type>>
    [ handle>> ] 2dip sqlite-column-typed ;

M: sqlite-result-set advance-row
    dup handle>> sqlite-next >>has-more? drop ;

M: sqlite-result-set more-rows?
    has-more?>> ;

M: sqlite-statement query-results
    sqlite-maybe-prepare
    dup handle>> sqlite-result-set new-result-set
    dup advance-row ;

M: sqlite-db-connection <insert-db-assigned-statement>
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

M: sqlite-db-connection <insert-user-assigned-statement>
    <insert-db-assigned-statement> ;

M: sqlite-db-connection bind#
    [
        [ column-name>> ":" next-sql-counter surround dup 0% ]
        [ type>> ] bi
    ] dip <literal-bind> 1, ;

M: sqlite-db-connection bind%
    dup 1, column-name>> ":" prepend 0% ;

M: sqlite-db-connection persistent-table
    H{
        { +db-assigned-id+ { "integer" "integer" f } }
        { +user-assigned-id+ { f f f } }
        { +random-id+ { "integer" "integer" f } }
        { +foreign-id+ { "integer" "integer" "references" } }
        { +primary-key+ { f f "primary key" } }

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
    "
        CREATE TRIGGER fki_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE INSERT ON ${table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'insert on table \"${table-name}\" violates foreign key constraint \"fki_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id\"')
            WHERE  (SELECT ${foreign-table-id} FROM ${foreign-table-name} WHERE ${foreign-table-id} = NEW.${table-id}) IS NULL;
        END;
    " interpolate>string ;

: insert-trigger-not-null ( -- string )
    "
        CREATE TRIGGER fki_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE INSERT ON ${table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'insert on table \"${table-name}\" violates foreign key constraint \"fki_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id\"')
            WHERE NEW.${table-id} IS NOT NULL
                AND (SELECT ${foreign-table-id} FROM ${foreign-table-name} WHERE ${foreign-table-id} = NEW.${table-id}) IS NULL;
        END;
    " interpolate>string ;

: update-trigger ( -- string )
    "
        CREATE TRIGGER fku_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE UPDATE ON ${table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'update on table \"${table-name}\" violates foreign key constraint \"fku_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id\"')
            WHERE (SELECT ${foreign-table-id} FROM ${foreign-table-name} WHERE ${foreign-table-id} = NEW.${table-id}) IS NULL;
        END;
    " interpolate>string ;

: update-trigger-not-null ( -- string )
    "
        CREATE TRIGGER fku_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE UPDATE ON ${table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'update on table \"${table-name}\" violates foreign key constraint \"fku_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id\"')
            WHERE NEW.${table-id} IS NOT NULL
                AND (SELECT ${foreign-table-id} FROM ${foreign-table-name} WHERE ${foreign-table-id} = NEW.${table-id}) IS NULL;
        END;
    " interpolate>string ;

: delete-trigger-restrict ( -- string )
    "
        CREATE TRIGGER fkd_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE DELETE ON ${foreign-table-name}
        FOR EACH ROW BEGIN
            SELECT RAISE(ROLLBACK, 'delete on table \"${foreign-table-name}\" violates foreign key constraint \"fkd_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id\"')
            WHERE (SELECT ${table-id} FROM ${table-name} WHERE ${table-id} = OLD.${foreign-table-id}) IS NOT NULL;
        END;
    " interpolate>string ;

: delete-trigger-cascade ( -- string )
    "
        CREATE TRIGGER fkd_${table-name}_${table-id}_${foreign-table-name}_${foreign-table-id}_id
        BEFORE DELETE ON ${foreign-table-name}
        FOR EACH ROW BEGIN
            DELETE from ${table-name} WHERE ${table-id} = OLD.${foreign-table-id};
        END;
    " interpolate>string ;

: can-be-null? ( -- ? )
    "sql-spec" get modifiers>> [ +not-null+ = ] none? ;

: delete-cascade? ( -- ? )
    "sql-spec" get modifiers>> { +on-delete+ +cascade+ } subseq-of? ;

: sqlite-trigger, ( string -- )
    { } { } <simple-statement> 3, ;

: create-sqlite-triggers ( -- )
    can-be-null? [
        insert-trigger sqlite-trigger,
        update-trigger sqlite-trigger,
    ] [
        insert-trigger-not-null sqlite-trigger,
        update-trigger-not-null sqlite-trigger,
    ] if
    delete-cascade? [
        delete-trigger-cascade sqlite-trigger,
    ] [
        delete-trigger-restrict sqlite-trigger,
    ] if ;

: create-db-triggers ( sql-specs -- )
    [ modifiers>> [ +foreign-id+ = ] deep-any? ] filter
    [
        [ "sql-spec" set ]
        [ column-name>> "table-id" set ]
        [ ] tri
        modifiers>> [ [ +foreign-id+ = ] deep-any? ] filter
        [
            [ second db-table-name "foreign-table-name" set ]
            [ third "foreign-table-id" set ] bi
            create-sqlite-triggers
        ] each
    ] each ;

: sqlite-create-table ( sql-specs class-name -- )
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

M: sqlite-db-connection create-sql-statement
    [
        [ sqlite-create-table ]
        [ drop create-db-triggers ] 2bi
    ] query-make ;

M: sqlite-db-connection drop-sql-statement
    [ nip "drop table " 0% 0% ";" 0% ] query-make ;

M: sqlite-db-connection compound
    over {
        { "default" [ first number>string " " glue ] }
        { "references" [ >reference-string ] }
        [ 2drop ]
    } case ;

M: sqlite-db-connection parse-db-error
    dup sqlite-error? [
        dup n>> {
            { 1 [ string>> parse-sqlite-sql-error ] }
            [ drop ]
        } case
    ] when ;
