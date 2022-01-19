! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data classes.struct
combinators db2.result-sets destructors kernel locals
mysql.db2.connections mysql.db2.ffi mysql.db2.lib libc
specialized-arrays sequences ;
IN: mysql.db2.result-sets

SPECIALIZED-ARRAY: MYSQL_BIND
SPECIALIZED-ARRAY: bool
SPECIALIZED-ARRAY: ulong

TUPLE: mysql-result-set < result-set bind #columns nulls lengths errors ;

M: mysql-result-set dispose ( result-set -- )
    ! the handle is a stmt handle here, not a result_set handle
    [ mysql-free-statement ]
    [ f >>handle drop ] bi ;

M: mysql-result-set #columns ( result-set -- n ) #columns>> ;

M: mysql-result-set advance-row ( result-set -- ) drop ;

M: mysql-result-set column
    B
    3drop f
    ;

M: mysql-result-set more-rows? ( result-set -- ? )
    handle>> [
        mysql_stmt_fetch {
            { 0 [ t ] }
            { MYSQL_NO_DATA [ f ] }
            { MYSQL_DATA_TRUNCATED [ "truncated, bailing out.." throw ] }
        } case
    ] [
        f
    ] if* ;


! Reference: http://dev.mysql.com/doc/refman/5.6/en/mysql-stmt-fetch.html
M:: mysql-db-connection statement>result-set ( statement -- result-set )
    statement handle>> :> handle
    [
        ! 0 int <ref> malloc-byte-array |free :> buffer0
        256 malloc :> buffer0
        256 :> buffer_length0
        0 ulong <ref> malloc-byte-array |free :> length0
        f bool <ref> malloc-byte-array |free :> error0
        f bool <ref> malloc-byte-array |free :> is_null0

        handle mysql_stmt_execute
        [ handle ] dip mysql-stmt-check-result

        statement handle \ mysql-result-set new-result-set :> result-set

        handle mysql_stmt_result_metadata :> metadata
        metadata field_count>> :> #columns

        #columns MYSQL_BIND malloc-array |free :> binds
        #columns ulong malloc-array |free :> lengths
        #columns bool malloc-array |free :> is_nulls
        #columns bool malloc-array |free :> errors

        binds [
            MYSQL_TYPE_STRING >>buffer_type
            256 malloc >>buffer
            256 >>buffer_length
            is_null0 >>is_null
            length0 >>length
            error0 >>error
        ] map drop
        


        MYSQL_BIND malloc-struct |free
            ! MYSQL_TYPE_LONG >>buffer_type
            MYSQL_TYPE_STRING >>buffer_type
            buffer0 >>buffer
            buffer_length0 >>buffer_length
            is_null0 >>is_null
            length0 >>length
            error0 >>error
        :> bind0


        bind0 result-set bind<<
        
        handle bind0 mysql_stmt_bind_result
            f = [ handle mysql_stmt_error throw ] unless
        handle mysql_stmt_store_result
            0 = [ "mysql store_result error" throw ] unless

        ! handle mysql_stmt_fetch .
        ! bind0 buffer>> alien>native-string .

        ! handle mysql_stmt_fetch .
        ! bind0 buffer>> alien>native-string .

        result-set
    ] with-destructors
    ;
    ! TODO: bind data here before more-rows? calls mysql_stmt_fetch

