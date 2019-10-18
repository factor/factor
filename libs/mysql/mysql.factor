! See http://factorcode.org/license.txt for license.
! Copyright (C) 2007 Berlin Brown
! Date: 1/17/2007
!
! libs/mysql/mysql.factor
!
! Adapted from mysql.h and mysql.c
! Tested with MySQL version - 5.0.24a

IN: mysql
USING: kernel alien errors io prettyprint 
    sequences namespaces arrays math tools generic ;

SYMBOL: my-conn

TUPLE: mysql-connection mysqlconn host user password db port handle resulthandle ;

: init-mysql ( -- conn )
    f mysql_init ;
    
C: mysql-connection ( host user password db port -- mysql-connection )
    [ set-mysql-connection-port ] keep
    [ set-mysql-connection-db ] keep
    [ set-mysql-connection-password ] keep
    [ set-mysql-connection-user ] keep
    [ set-mysql-connection-host ] keep ;

: (mysql-error) ( mysql-connection -- str )
    mysql-connection-mysqlconn mysql_error ;

: connect-error-msg ( mysql-connection -- s ) 
    mysql-connection-mysqlconn mysql_error
    [
        "Couldn't connect to mysql database.\n" %
        "Message: " % %
    ] "" make ;

: mysql-connect ( mysql-connection -- )
    init-mysql swap
    [ set-mysql-connection-mysqlconn ] 2keep
    [ mysql-connection-host ] keep
    [ mysql-connection-user ] keep
    [ mysql-connection-password ] keep
    [ mysql-connection-db ] keep
    [ mysql-connection-port f 0 mysql_real_connect ] keep
    [ set-mysql-connection-handle ] keep 
    dup mysql-connection-handle 
    [ connect-error-msg throw ] unless ;

! =========================================================
! Low level mysql utility definitions
! =========================================================

: (mysql-query) ( mysql-connection query -- ret )
    >r mysql-connection-mysqlconn r> mysql_query ;

: (mysql-result) ( mysql-connection -- ret )
    [ mysql-connection-mysqlconn mysql_use_result ] keep 
    [ set-mysql-connection-resulthandle ] keep ;
    
: (mysql-affected-rows) ( mysql-connection -- n )
    mysql-connection-mysqlconn mysql_affected_rows ;

: (mysql-free-result) ( mysql-connection -- )
    mysql-connection-resulthandle drop ;

: (mysql-row) ( mysql-connection -- row )
    mysql-connection-resulthandle mysql_fetch_row ;

: (mysql-num-cols) ( mysql-connection -- n )
    mysql-connection-resulthandle mysql_num_fields ;
   
: mysql-char*-nth ( index object -- str )
    #! Utility based on 'char*-nth' to perform an additional sanity check on the value
    #! extracted from the array of strings.
    void*-nth [ alien>char-string ] [ "" ] if* ;
        
: mysql-row>seq ( object n -- seq )
    [ swap mysql-char*-nth ] map-with ;
    
: (mysql-result>seq) ( seq -- seq )
    my-conn get (mysql-row) dup [       
        my-conn get (mysql-num-cols) mysql-row>seq
        over push
        (mysql-result>seq)
    ] [ drop ] if 
    ! Perform needed cleanup on fetched results
    my-conn get (mysql-free-result) ;
            
! =========================================================
!  Public Word Definitions
! =========================================================

: mysql-close ( mysql-connection -- )
    mysql-connection-mysqlconn mysql_close ;

: mysql-print-table ( seq -- )
    [ [ write bl ] each "\n" write ] each ;
    
: mysql-query ( query -- ret )
    >r my-conn get r> (mysql-query) drop
    my-conn get (mysql-result) ;

: mysql-command ( query -- n )
    mysql-query drop
    my-conn get (mysql-affected-rows) ;

: mysql-error ( -- s )
    #! Get the last mysql error
    my-conn get (mysql-error) ; 

: mysql-result>seq ( -- seq )
    V{ } clone (mysql-result>seq) ;
        
: with-mysql ( host user password db port quot -- )
    [ 
        >r <mysql-connection> my-conn set 
            my-conn get mysql-connect drop r> 
        [ my-conn get mysql-close ] cleanup
    ] with-scope ; inline
    
: with-mysql-catch ( host user password db port quot -- )
    [ with-mysql ] catch [ "Caught: " write print ] when* ;
    