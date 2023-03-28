! Copyright (C) 2007 Berlin Brown, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for license.
! Adapted from mysql.h and mysql.c
! Tested with MySQL version - 5.0.24a
USING: kernel alien io prettyprint sequences
namespaces arrays math db.mysql.ffi system accessors ;
IN: db.mysql.lib

SYMBOL: my-conn

TUPLE: mysql-db handle host user password db port ;
TUPLE: mysql-statement ;
TUPLE: mysql-result-set ;

: new-mysql ( -- conn )
    f mysql_init ;

: mysql-error ( mysql -- )
    [ mysql_error throw ] when* ;

: mysql-connect ( mysql-connection -- )
    new-mysql over set-mysql-db-handle
    dup {
        mysql-db-handle
        mysql-db-host
        mysql-db-user
        mysql-db-password
        mysql-db-db
        mysql-db-port
    } get-slots f 0 mysql_real_connect mysql-error ;

! =========================================================
! Low level mysql utility definitions
! =========================================================

: (mysql-query) ( mysql-connection query -- ret )
    >r db-handle>> r> mysql_query ;

! : (mysql-result) ( mysql-connection -- ret )
    ! [ mysql-db-handle mysql_use_result ] keep 
    ! [ set-mysql-connection-resulthandle ] keep ;

! : (mysql-affected-rows) ( mysql-connection -- n )
    ! mysql-connection-mysqlconn mysql_affected_rows ;

! : (mysql-free-result) ( mysql-connection -- )
    ! mysql-connection-resulthandle drop ;

! : (mysql-row) ( mysql-connection -- row )
    ! mysql-connection-resulthandle mysql_fetch_row ;

! : (mysql-num-cols) ( mysql-connection -- n )
    ! mysql-connection-resulthandle mysql_num_fields ;
   
! : mysql-char*-nth ( index object -- str )
    ! #! Utility based on 'char*-nth' to perform an additional sanity check on the value
    ! #! extracted from the array of strings.
    ! void*-nth [ alien>char-string ] [ "" ] if* ;

! : mysql-row>seq ( object n -- seq )
    ! [ swap mysql-char*-nth ] map-with ;

! : (mysql-result>seq) ( seq -- seq )
    ! my-conn get (mysql-row) dup [       
        ! my-conn get (mysql-num-cols) mysql-row>seq
        ! over push
        ! (mysql-result>seq)
    ! ] [ drop ] if 
    ! ! Perform needed cleanup on fetched results
    ! my-conn get (mysql-free-result) ;

! : mysql-query ( query -- ret )
    ! >r my-conn get r> (mysql-query) drop
    ! my-conn get (mysql-result) ;

! : mysql-command ( query -- n )
    ! mysql-query drop
    ! my-conn get (mysql-affected-rows) ;
