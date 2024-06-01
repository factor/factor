! Copyright (C) 2008 Doug Coleman, 2021 Giftpflanze.
! See https://factorcode.org/license.txt for license.
USING: accessors alien.c-types alien.data arrays byte-arrays
combinators db db.mysql.ffi db.private destructors
io.encodings.string io.encodings.utf8 kernel math namespaces
sequences specialized-arrays ;
IN: db.mysql

SPECIALIZED-ARRAYS: char ulong void* ;

TUPLE: mysql-db host user password db port ;
TUPLE: mysql-db-connection < db-connection ;
TUPLE: mysql-statement < statement ;
TUPLE: mysql-result-set < result-set
    #columns has-more? pointers lengths ;

: <mysql-db> ( -- mysql-db )
    mysql-db new ;

M: mysql-db db-open ( db -- conn )
    f mysql_init
    dup [ "Not enough memory to allocate mysql handle." throw ]
    unless
    dup 20 1 int <ref> mysql_options drop ! MYSQL_OPT_RECONNECT
    dup rot {
        [ host>> ]
        [ user>> ]
        [ password>> ]
        [ db>> ]
        [ port>> 0 or ]
    } cleave f 0 mysql_real_connect
    [ mysql_error throw ] unless
    mysql-db-connection new-db-connection swap >>handle ;

M: mysql-db-connection db-close ( h -- )
    mysql_close ;

M: mysql-db-connection parse-db-error ;

M: mysql-db-connection <simple-statement> ( str in out -- stmt )
    mysql-statement new-statement ;

M: mysql-db-connection <prepared-statement> <simple-statement> ;

M: mysql-statement query-results ( stmt -- rs )
    db-connection get handle>> dup pick sql>> mysql_query
    zero? [ mysql_error throw ] unless dup mysql_use_result
    dup [
        nip dup mysql_num_fields
        [ mysql-result-set new-result-set ] dip
        >>#columns dup advance-row
    ] [
        swap dup mysql_field_count
        zero? [ drop ] [ mysql_error throw ] if
        mysql-result-set new-result-set
    ] if ;

M: mysql-result-set #columns ( rs -- #c )
    #columns>> ;

M: mysql-result-set advance-row ( rs -- )
    dup handle>> dup mysql_fetch_row
    [
        swap mysql_fetch_lengths pick #columns>>
        [ <direct-void*-array> >>pointers ]
        [ <direct-ulong-array> >>lengths ] bi-curry bi*
        t >>has-more?
    ] [
        db-connection get handle>> dup mysql_errno zero?
        [ 2drop f >>has-more? f >>pointers f >>lengths ]
        [ mysql_error throw ] if
    ] if* drop ;

M: mysql-result-set dispose*
    [ mysql_free_result f ] change-handle drop ;

M: mysql-result-set more-rows? ( rs -- ? )
    has-more?>> ;

M: mysql-result-set row-column ( rs i -- str )
    swap [ pointers>> ] [ lengths>> ] bi
    [ nth ] bi-curry@ bi <direct-char-array>
    >byte-array utf8 decode ;
