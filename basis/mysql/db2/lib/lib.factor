! Copyright (C) 2010 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data alien.strings
calendar.format classes.struct combinators db2.errors db2.types
fry generalizations io.encodings.utf8 kernel layouts locals
make math math.parser mysql.db2.ffi present sequences serialize ;
FROM: alien.c-types => short ;
IN: mysql.db2.lib

ERROR: mysql-error < db-error n string ;
ERROR: mysql-sql-error < sql-error n string ;

: mysql-check-result ( mysql n -- )
    dup { 0 f } member? [ 2drop ] [
        swap mysql_error mysql-error
    ] if ;

ERROR: mysql-connect-fail string mysql ;

: mysql-check-connect ( mysql1 mysql2 -- )
    dup net>> last_errno>> 0 = [
        2drop
    ] [
        [ mysql_error ] dip mysql-connect-fail
    ] if ;

: mysql-stmt-check-result ( stmt n -- )
    dup { 0 f } member? [ 2drop ] [
        swap mysql_stmt_error mysql-error ! FIXME: mysql-sql-error
    ] if ;

:: mysql-connect ( host user passwd db port -- mysql/f )
    f mysql_init :> mysql
    mysql host user passwd db port f 0 mysql_real_connect :> handle
    mysql dup mysql-check-connect handle ;

: mysql-#rows ( result -- n )
    mysql_num_rows ;

: mysql-#columns ( result -- n )
    mysql_num_fields ;

: mysql-next ( result -- ? )
    mysql_fetch_row ;


: mysql-column ( result n -- value )
    swap [ cell * ] [ current_row>> ] bi* <displaced-alien>
    void* deref utf8 alien>string ;

: mysql-row ( result -- seq )
    [ current_row>> ] [ mysql-#columns ] bi [
        [ void* deref utf8 alien>string ]
        [ cell swap <displaced-alien> ] bi swap
    ] replicate nip ;

! returns a result or f
: mysql-query ( mysql query -- result/f )
    dupd mysql_query dupd mysql-check-result mysql_store_result ;

! Throws if fails
: mysql-command ( mysql query -- )
    dupd mysql_query mysql-check-result ;

: mysql-reset-statement ( statement -- )
    handle>> dup mysql_stmt_reset mysql-stmt-check-result ;

: mysql-free-statement ( statement -- )
    handle>> dup mysql_stmt_free_result mysql-stmt-check-result ;

: mysql-free-result ( result -- )
    handle>> mysql_free_result ;


: <mysql-time> ( timestamp -- MYSQL_TIME )
    MYSQL_TIME <struct>
        over year>> >>year
        over month>> >>month
        over day>> >>day
        over hour>> >>hour
        over minute>> >>minute
        swap second>> >>second ;

:: <mysql-bind> ( index key value type -- mysql_BIND )
    MYSQL_BIND <struct>
        index >>param_number
        value type {
            { INTEGER [ MYSQL_TYPE_LONG ] }
            { BIG-INTEGER [ MYSQL_TYPE_LONGLONG ] }
            { SIGNED-BIG-INTEGER [ MYSQL_TYPE_LONGLONG ] }
            { UNSIGNED-BIG-INTEGER [ MYSQL_TYPE_LONGLONG ] }
            { BOOLEAN [ MYSQL_TYPE_BIT ] }
            { TEXT [ MYSQL_TYPE_VARCHAR ] }
            { VARCHAR [ MYSQL_TYPE_VARCHAR ] }
            { DOUBLE [ MYSQL_TYPE_DOUBLE ] }
            { DATE [ timestamp>ymd MYSQL_TYPE_DATE ] }
            { TIME [ timestamp>hms MYSQL_TYPE_TIME ] }
            { DATETIME [ timestamp>ymdhms MYSQL_TYPE_DATETIME ] }
            { TIMESTAMP [ timestamp>ymdhms MYSQL_TYPE_DATETIME ] }
            { BLOB [ MYSQL_TYPE_BLOB ] }
            { FACTOR-BLOB [ object>bytes MYSQL_TYPE_BLOB ] }
            { URL [ present MYSQL_TYPE_VARCHAR ] }
            { +db-assigned-key+ [ MYSQL_TYPE_LONG ] }
            { +random-key+ [ MYSQL_TYPE_LONGLONG ] }
            { NULL [ MYSQL_TYPE_NULL ] }
            [ no-sql-type ]
        } case >>buffer_type >>buffer
        ! FIXME: buffer_length
        ! FIXME: is_null
    ;




<PRIVATE

CONSTANT: MIN_CHAR -255
CONSTANT: MAX_CHAR 256

CONSTANT: MIN_SHORT -65535
CONSTANT: MAX_SHORT 65536

CONSTANT: MIN_INT -4294967295
CONSTANT: MAX_INT 4294967296

CONSTANT: MIN_LONG -18446744073709551615
CONSTANT: MAX_LONG 18446744073709551616

FROM: alien.c-types => short ;

: fixnum>c-ptr ( n -- c-ptr )
    dup 0 < [ abs 1 + ] when {
        { [ dup MAX_CHAR  <= ] [ char <ref> ] }
        { [ dup MAX_SHORT <= ] [ short <ref> ] }
        { [ dup MAX_INT   <= ] [ int <ref> ] }
        { [ dup MAX_LONG  <= ] [ longlong <ref> ] }
        [ "too big" throw ]
    } cond ;

PRIVATE>


! : mysql-stmt-query ( stmt -- result )
!     dup mysql_stmt_execute dupd mysql-stmt-check-result
!     mysql_stmt_store_result ;


: mysql-column-typed ( result n -- value )
    [ mysql-column ] [ mysql_fetch_field_direct ] 2bi type>> {
        { MYSQL_TYPE_DECIMAL  [ string>number ] }
        { MYSQL_TYPE_SHORT    [ string>number ] }
        { MYSQL_TYPE_LONG     [ string>number ] }
        { MYSQL_TYPE_FLOAT    [ string>number ] }
        { MYSQL_TYPE_DOUBLE   [ string>number ] }
        { MYSQL_TYPE_LONGLONG [ string>number ] }
        { MYSQL_TYPE_INT24    [ string>number ] }
        [ drop ]
    } case ;




: create-db ( mysql db -- )
    dupd mysql_create_db mysql-check-result ;

: drop-db ( mysql db -- )
    dupd mysql_drop_db mysql-check-result ;

: select-db ( mysql db -- )
    dupd mysql_select_db mysql-check-result ;

<PRIVATE

: cols ( result n -- cols )
    [ dup mysql_fetch_field name>> ] replicate nip ;

: row ( result n -- row/f )
    swap mysql_fetch_row [
        swap [
            [ void* deref utf8 alien>string ]
            [ cell swap <displaced-alien> ] bi swap
        ] replicate nip
    ] [ drop f ] if* ;

: rows ( result n -- rows )
    [ '[ _ _ row dup ] [ , ] while drop ] { } make ;

PRIVATE>

: list-dbs ( mysql -- seq )
    f mysql_list_dbs dup mysql_num_fields rows concat ;

: list-tables ( mysql -- seq )
    f mysql_list_tables dup mysql_num_fields rows concat ;

: list-processes ( mysql -- seq )
    mysql_list_processes dup mysql_num_fields rows ;

: query-db ( mysql sql -- cols rows )
    mysql-query [
        dup mysql_num_fields [ cols ] [ rows ] 2bi
    ] [ mysql_free_result ] bi ;

