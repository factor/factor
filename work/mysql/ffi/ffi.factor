! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax combinators
system ;

IN: mysql.ffi

! "mysql" "/opt/local/lib/mysql5/mysql/libmysqlclient.dylib"  stdcall add-library

<< "mysql" {
        { [ os windows? ]  [ "mysql.dll" ] }  ! ok for windows?
        { [ os macosx? ] [ "/opt/local/lib/mysql5/mysql/libmysqlclient.dylib" ] }
        { [ os unix? ]  [ "libmysql.so" ] }   ! ok for unix?
    } cond cdecl add-library >>

! Return values from mysql functions
CONSTANT: MYSQL_OK           0 ! Successful result
CONSTANT: MYSQL_ERROR        1 ! SQL error or missing database
CONSTANT: MYSQL_INTERNAL     2 ! An internal logic error in Mysql 
CONSTANT: MYSQL_PERM         3 ! Access permission denied 
CONSTANT: MYSQL_ABORT        4 ! Callback routine requested an abort 
CONSTANT: MYSQL_BUSY         5 ! The database file is locked 
CONSTANT: MYSQL_LOCKED       6 ! A table in the database is locked 
CONSTANT: MYSQL_NOMEM        7 ! A malloc() failed 
CONSTANT: MYSQL_READONLY     8 ! Attempt to write a readonly database 
CONSTANT: MYSQL_INTERRUPT    9 ! Operation terminated by mysql_interrupt() 
CONSTANT: MYSQL_IOERR       10 ! Some kind of disk I/O error occurred 
CONSTANT: MYSQL_CORRUPT     11 ! The database disk image is malformed 
CONSTANT: MYSQL_NOTFOUND    12 ! (Internal Only) Table or record not found 
CONSTANT: MYSQL_FULL        13 ! Insertion failed because database is full 
CONSTANT: MYSQL_CANTOPEN    14 ! Unable to open the database file 
CONSTANT: MYSQL_PROTOCOL    15 ! Database lock protocol error 
CONSTANT: MYSQL_EMPTY       16 ! (Internal Only) Database table is empty 
CONSTANT: MYSQL_SCHEMA      17 ! The database schema changed 
CONSTANT: MYSQL_TOOBIG      18 ! Too much data for one row of a table 
CONSTANT: MYSQL_CONSTRAINT  19 ! Abort due to contraint violation 
CONSTANT: MYSQL_MISMATCH    20 ! Data type mismatch 
CONSTANT: MYSQL_MISUSE      21 ! Library used incorrectly 
CONSTANT: MYSQL_NOLFS       22 ! Uses OS features not supported on host 
CONSTANT: MYSQL_AUTH        23 ! Authorization denied 
CONSTANT: MYSQL_FORMAT      24 ! Auxiliary database format error
CONSTANT: MYSQL_RANGE       25 ! 2nd parameter to mysql_bind out of range
CONSTANT: MYSQL_NOTADB      26 ! File opened that is not a database file

: mysql-error-messages ( -- seq ) {
    "Successful result"
    "SQL error or missing database"
    "An internal logic error in Mysql"
    "Access permission denied"
    "Callback routine requested an abort"
    "The database file is locked"
    "A table in the database is locked"
    "A malloc() failed"
    "Attempt to write a readonly database"
    "Operation terminated by mysql_interrupt()"
    "Some kind of disk I/O error occurred"
    "The database disk image is malformed"
    "(Internal Only) Table or record not found"
    "Insertion failed because database is full"
    "Unable to open the database file"
    "Database lock protocol error"
    "(Internal Only) Database table is empty"
    "The database schema changed"
    "Too much data for one row of a table"
    "Abort due to contraint violation"
    "Data type mismatch"
    "Library used incorrectly"
    "Uses OS features not supported on host"
    "Authorization denied"
    "Auxiliary database format error"
    "2nd parameter to mysql_bind out of range"
    "File opened that is not a database file"
} ;

! Return values from mysql_step
CONSTANT: MYSQL_ROW_MAX     100
CONSTANT: MYSQL_DONE        101

! Return values from the mysql_column_type function
CONSTANT: MYSQL_INTEGER     1
CONSTANT: MYSQL_FLOAT       2
CONSTANT: MYSQL_TEXT        3
CONSTANT: MYSQL_BLOB        4
CONSTANT: MYSQL_NULL        5

! Values for the 'destructor' parameter of the 'bind' routines. 
CONSTANT: MYSQL_STATIC      0
CONSTANT: MYSQL_TRANSIENT   -1

CONSTANT: MYSQL_OPEN_READONLY         0x00000001
CONSTANT: MYSQL_OPEN_READWRITE        0x00000002
CONSTANT: MYSQL_OPEN_CREATE           0x00000004
CONSTANT: MYSQL_OPEN_DELETEONCLOSE    0x00000008
CONSTANT: MYSQL_OPEN_EXCLUSIVE        0x00000010
CONSTANT: MYSQL_OPEN_MAIN_DB          0x00000100
CONSTANT: MYSQL_OPEN_TEMP_DB          0x00000200
CONSTANT: MYSQL_OPEN_TRANSIENT_DB     0x00000400
CONSTANT: MYSQL_OPEN_MAIN_JOURNAL     0x00000800
CONSTANT: MYSQL_OPEN_TEMP_JOURNAL     0x00001000
CONSTANT: MYSQL_OPEN_SUBJOURNAL       0x00002000
CONSTANT: MYSQL_OPEN_MASTER_JOURNAL   0x00004000

C-TYPE: mysql
C-TYPE: mysql_stmt
TYPEDEF: longlong mysql_int64
TYPEDEF: ulonglong mysql_uint64

TYPEDEF: void* MYSQL
TYPEDEF: void* MYSQL_ROW_OFFSET
TYPEDEF: void* MYSQL_FIELD_OFFSET
TYPEDEF: void* MYSQL_FIELD
TYPEDEF: void* MYSQL_MANAGER
TYPEDEF: void* MYSQL_RES
TYPEDEF: void* MYSQL_PARAMETERS
TYPEDEF: void* MY_CHARSET_INFO
TYPEDEF: void* MYSQL_STMT
TYPEDEF: void* MYSQL_BIND
TYPEDEF: char** MYSQL_ROW
TYPEDEF: int enumint

LIBRARY: mysql

! mysql.h
  ! Set up and bring down the server; to ensure that applications will
  ! work when linked against either the standard client library or the
  ! embedded server library, these functions should be called.

FUNCTION: int mysql_server_init ( int argc char **argv char **groups ) ;
FUNCTION: void mysql_server_end ;

  ! mysql_server_init/end need to be called when using libmysqld or
  ! libmysqlclient (exactly, mysql_server_init() is called by mysql_init() so
  ! you don't need to call it explicitely; but you need to call
  ! mysql_server_end() to free memory). The names are a bit misleading
  ! (mysql_SERVER* to be used when using libmysqlCLIENT). So we add more general
  ! names which suit well whether you're using libmysqld or libmysqlclient. We
  ! intend to promote these aliases over the mysql_server* ones.

FUNCTION: MYSQL_PARAMETERS* mysql_get_parameters ;

  ! Set up and bring down a thread; these function should be called
  ! for each thread in an application which opens at least one MySQL
  ! connection. All uses of the connection(s) should be between these
  ! function calls.

FUNCTION: bool mysql_thread_init ;
FUNCTION: void mysql_thread_end ;

  ! Functions to get information from the MYSQL and MYSQL_RES structures
  ! Should definitely be used if one uses shared libraries.

FUNCTION: longlong mysql_num_rows ( MYSQL_RES* res ) ;
FUNCTION: uint mysql_num_fields ( MYSQL_RES* res ) ;
FUNCTION: bool mysql_eof ( MYSQL_RES* res ) ;
FUNCTION: MYSQL_FIELD* mysql_fetch_field_direct ( MYSQL_RES* res uint fieldnr ) ;
FUNCTION: MYSQL_FIELD* mysql_fetch_fields ( MYSQL_RES* res ) ;
FUNCTION: MYSQL_ROW_OFFSET mysql_row_tell ( MYSQL_RES* res ) ;
FUNCTION: MYSQL_FIELD_OFFSET mysql_field_tell ( MYSQL_RES* res ) ;

FUNCTION: uint mysql_field_count ( MYSQL* mysql ) ;
FUNCTION: longlong mysql_affected_rows ( MYSQL* mysql ) ;
FUNCTION: longlong mysql_insert_id ( MYSQL* mysql ) ;
FUNCTION: uint mysql_errno ( MYSQL* mysql ) ;
FUNCTION: c-string mysql_error ( MYSQL* mysql ) ;
FUNCTION: c-string mysql_sqlstate ( MYSQL* mysql ) ;
FUNCTION: uint mysql_warning_count ( MYSQL* mysql ) ;
FUNCTION: c-string mysql_info ( MYSQL* mysql ) ;
FUNCTION: ulong mysql_thread_id ( MYSQL* mysql ) ;
FUNCTION: c-string mysql_character_set_name ( MYSQL* mysql ) ;
FUNCTION: int mysql_set_character_set ( MYSQL* mysql c-string csname ) ;
FUNCTION: MYSQL* mysql_init ( MYSQL* mysql ) ;
FUNCTION: bool mysql_ssl_set ( MYSQL* mysql c-string key c-string cert c-string ca c-string capath c-string cipher ) ;
FUNCTION: c-string mysql_get_ssl_cipher ( MYSQL* mysql ) ;
FUNCTION: bool mysql_change_user ( MYSQL* mysql c-string user c-string passwd c-string db ) ;
FUNCTION: MYSQL* mysql_real_connect ( MYSQL* mysql c-string host c-string user c-string passwd c-string db uint port c-string unix_socket ulong clientflag ) ;
FUNCTION: int mysql_select_db ( MYSQL* mysql c-string db ) ;
FUNCTION: int mysql_query ( MYSQL* mysql c-string q ) ;
FUNCTION: int mysql_send_query ( MYSQL* mysql c-string q ulong length ) ;
FUNCTION: int mysql_real_query ( MYSQL* mysql c-string q ulong length ) ;
FUNCTION: MYSQL_RES* mysql_store_result ( MYSQL* mysql ) ;
FUNCTION: MYSQL_RES* mysql_use_result ( MYSQL* mysql ) ;

! /* perform query on master */
FUNCTION: bool mysql_master_query ( MYSQL* mysql c-string q ulong length ) ;
FUNCTION: bool mysql_master_send_query ( MYSQL* mysql c-string q ulong length ) ;

! /* perform query on slave */ 
FUNCTION: bool mysql_slave_query ( MYSQL* mysql c-string q ulong length ) ;
FUNCTION: bool mysql_slave_send_query ( MYSQL* mysql c-string q ulong length ) ;
FUNCTION: void mysql_get_character_set_info ( MYSQL* mysql MY_CHARSET_INFO *charset ) ;

FUNCTION: void mysql_set_local_infile_default ( MYSQL* mysql ) ;

! enable/disable parsing of all queries to decide if they go on master or slave
FUNCTION: void mysql_enable_rpl_parse ( MYSQL* mysql ) ;
FUNCTION: void mysql_disable_rpl_parse ( MYSQL* mysql ) ;

! /* get the value of the parse flag */ 
FUNCTION: int mysql_rpl_parse_enabled ( MYSQL* mysql ) ;

! /* enable/disable reads from master */
FUNCTION: void mysql_enable_reads_from_master ( MYSQL* mysql ) ;
FUNCTION: void mysql_disable_reads_from_master ( MYSQL* mysql ) ;

! /* get the value of the master read flag */ 
FUNCTION: bool mysql_reads_from_master_enabled ( MYSQL* mysql ) ;
FUNCTION: enumint mysql_rpl_query_type ( c-string q int len ) ; 

! /* discover the master and its slaves */ 
FUNCTION: bool mysql_rpl_probe ( MYSQL* mysql ) ;

! /* set the master close/free the old one if it is not a pivot */
FUNCTION: int mysql_set_master ( MYSQL* mysql c-string host uint port c-string user c-string passwd ) ;
FUNCTION: int mysql_add_slave ( MYSQL* mysql c-string host uint port c-string user c-string passwd ) ;
FUNCTION: int mysql_shutdown ( MYSQL* mysql enumint shutdown_level ) ;
FUNCTION: int mysql_dump_debug_info ( MYSQL* mysql ) ;
FUNCTION: int mysql_refresh ( MYSQL* mysql uint refresh_options ) ;
FUNCTION: int mysql_kill ( MYSQL* mysql ulong pid ) ;
FUNCTION: int mysql_set_server_option ( MYSQL* mysql enumint option ) ;
FUNCTION: int mysql_ping ( MYSQL* mysql ) ;
FUNCTION: c-string mysql_stat ( MYSQL* mysql ) ;
FUNCTION: c-string mysql_get_server_info ( MYSQL* mysql ) ;
FUNCTION: c-string mysql_get_client_info ;
FUNCTION: ulong mysql_get_client_version ;
FUNCTION: c-string mysql_get_host_info ( MYSQL* mysql ) ;
FUNCTION: ulong mysql_get_server_version ( MYSQL* mysql ) ;
FUNCTION: uint mysql_get_proto_info ( MYSQL* mysql ) ;
FUNCTION: MYSQL_RES* mysql_list_dbs ( MYSQL* mysql c-string wild ) ;
FUNCTION: MYSQL_RES* mysql_list_tables ( MYSQL* mysql c-string wild ) ;
FUNCTION: MYSQL_RES* mysql_list_processes ( MYSQL* mysql ) ;
FUNCTION: int mysql_options ( MYSQL* mysql enumint option void* arg ) ;
FUNCTION: void mysql_free_result ( MYSQL_RES* result ) ;
FUNCTION: void mysql_data_seek ( MYSQL_RES* result longlong offset ) ;
FUNCTION: MYSQL_ROW_OFFSET mysql_row_seek ( MYSQL_RES* result MYSQL_ROW_OFFSET offset ) ;
FUNCTION: MYSQL_FIELD_OFFSET mysql_field_seek ( MYSQL_RES* result MYSQL_FIELD_OFFSET offset ) ;
FUNCTION: MYSQL_ROW mysql_fetch_row ( MYSQL_RES* result ) ;
FUNCTION: ulong* mysql_fetch_lengths ( MYSQL_RES* result ) ;
FUNCTION: MYSQL_FIELD* mysql_fetch_field ( MYSQL_RES* result ) ;
FUNCTION: MYSQL_RES* mysql_list_fields ( MYSQL* mysql c-string table c-string wild ) ;
FUNCTION: ulong mysql_escape_string ( c-string to c-string from ulong from_length ) ;
FUNCTION: ulong mysql_hex_string ( c-string to c-string from ulong from_length ) ;
FUNCTION: ulong mysql_real_escape_string ( MYSQL* mysql c-string to c-string from ulong length ) ;
FUNCTION: void mysql_debug ( c-string debug ) ;
FUNCTION: void myodbc_remove_escape ( MYSQL* mysql c-string name ) ;
FUNCTION: uint mysql_thread_safe ;
FUNCTION: bool mysql_embedded ;
FUNCTION: MYSQL_MANAGER* mysql_manager_init ( MYSQL_MANAGER* con ) ; 
FUNCTION: MYSQL_MANAGER* mysql_manager_connect ( MYSQL_MANAGER* con c-string host c-string user c-string passwd uint port ) ;
FUNCTION: void mysql_manager_close ( MYSQL_MANAGER* con ) ;
FUNCTION: int mysql_manager_command ( MYSQL_MANAGER* con c-string cmd int cmd_len ) ;
FUNCTION: int mysql_manager_fetch_line ( MYSQL_MANAGER* con char* res_buf int res_buf_size ) ;
FUNCTION: bool mysql_read_query_result ( MYSQL* mysql ) ;

FUNCTION: MYSQL_STMT*  mysql_stmt_init ( MYSQL* mysql ) ;
FUNCTION: int mysql_stmt_prepare ( MYSQL_STMT* stmt, c-string query, ulong length ) ;
FUNCTION: int mysql_stmt_execute ( MYSQL_STMT* stmt ) ;
FUNCTION: int mysql_stmt_fetch ( MYSQL_STMT* stmt ) ;
FUNCTION: int mysql_stmt_fetch_column ( MYSQL_STMT* stmt, MYSQL_BIND* bind_arg, uint column, ulong offset ) ;
FUNCTION: int mysql_stmt_store_result ( MYSQL_STMT* stmt ) ;
FUNCTION: ulong mysql_stmt_param_count ( MYSQL_STMT*  stmt ) ;
FUNCTION: bool mysql_stmt_attr_set ( MYSQL_STMT* stmt, int attr_type, void* attr ) ;
FUNCTION: bool mysql_stmt_attr_get ( MYSQL_STMT* stmt, int attr_type, void* attr ) ;
FUNCTION: bool mysql_stmt_bind_param ( MYSQL_STMT*  stmt, MYSQL_BIND*  bnd ) ;
FUNCTION: bool mysql_stmt_bind_result ( MYSQL_STMT*  stmt, MYSQL_BIND*  bnd ) ;
FUNCTION: bool mysql_stmt_close ( MYSQL_STMT*  stmt ) ;
FUNCTION: bool mysql_stmt_reset ( MYSQL_STMT*  stmt ) ;
FUNCTION: bool mysql_stmt_free_result ( MYSQL_STMT* stmt ) ;
FUNCTION: bool mysql_stmt_send_long_data ( MYSQL_STMT* stmt, uint param_number, c-string data, ulong length ) ;
FUNCTION: MYSQL_RES* mysql_stmt_result_metadata ( MYSQL_STMT* stmt ) ;
FUNCTION: MYSQL_RES* mysql_stmt_param_metadata ( MYSQL_STMT* stmt ) ;
FUNCTION: uint mysql_stmt_errno ( MYSQL_STMT*  stmt ) ;
FUNCTION: c-string mysql_stmt_error ( MYSQL_STMT*  stmt ) ;
FUNCTION: c-string mysql_stmt_sqlstate ( MYSQL_STMT*  stmt ) ;
FUNCTION: MYSQL_ROW_OFFSET mysql_stmt_row_seek ( MYSQL_STMT* stmt, MYSQL_ROW_OFFSET offset ) ;
FUNCTION: MYSQL_ROW_OFFSET mysql_stmt_row_tell ( MYSQL_STMT* stmt ) ;
FUNCTION: void mysql_stmt_data_seek ( MYSQL_STMT* stmt, ulonglong offset ) ;
FUNCTION: ulonglong mysql_stmt_num_rows ( MYSQL_STMT* stmt ) ;
FUNCTION: ulonglong mysql_stmt_affected_rows ( MYSQL_STMT* stmt ) ;
FUNCTION: ulonglong mysql_stmt_insert_id ( MYSQL_STMT* stmt ) ;
FUNCTION: uint mysql_stmt_field_count ( MYSQL_STMT* stmt ) ;
FUNCTION: bool mysql_commit ( MYSQL*  mysql ) ;
FUNCTION: bool mysql_rollback ( MYSQL*  mysql ) ;
FUNCTION: bool mysql_autocommit ( MYSQL*  mysql, bool auto_mode ) ;
FUNCTION: bool mysql_more_results ( MYSQL* mysql ) ;
FUNCTION: int mysql_next_result ( MYSQL* mysql ) ;
FUNCTION: void mysql_close ( MYSQL* sock ) ;
