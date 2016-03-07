! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax classes.struct
combinators system alien.libraries ;
IN: mysql.db2.ffi

! Mysql 5.7.11, 3/6/2016
<< "mysql" {
    { [ os windows? ]  [ "libmysql.dll" ] }
    { [ os macosx? ] [ "libmysqlclient.dylib" ] }
    { [ os unix?  ]  [ "libmysqlclient.so" ] }
} cond cdecl add-library >>

LIBRARY: mysql

TYPEDEF: int my_socket
TYPEDEF: char my_bool

CONSTANT: MYSQL_ERRMSG_SIZE 512
CONSTANT: SCRAMBLE_LENGTH 20

ENUM: mysql_status
    MYSQL_STATUS_READY
    MYSQL_STATUS_GET_RESULT
    MYSQL_STATUS_USE_RESULT ;

CONSTANT: MYSQL_NO_DATA 100
CONSTANT: MYSQL_DATA_TRUNCATED 101

ENUM: mysql_option
    MYSQL_OPT_CONNECT_TIMEOUT
    MYSQL_OPT_COMPRESS
    MYSQL_OPT_NAMED_PIPE
    MYSQL_INIT_COMMAND
    MYSQL_READ_DEFAULT_FILE
    MYSQL_READ_DEFAULT_GROUP
    MYSQL_SET_CHARSET_DIR
    MYSQL_SET_CHARSET_NAME
    MYSQL_OPT_LOCAL_INFILE
    MYSQL_OPT_PROTOCOL
    MYSQL_SHARED_MEMORY_BASE_NAME
    MYSQL_OPT_READ_TIMEOUT
    MYSQL_OPT_WRITE_TIMEOUT
    MYSQL_OPT_USE_RESULT
    MYSQL_OPT_USE_REMOTE_CONNECTION
    MYSQL_OPT_USE_EMBEDDED_CONNECTION
    MYSQL_OPT_GUESS_CONNECTION
    MYSQL_SET_CLIENT_IP
    MYSQL_SECURE_AUTH
    MYSQL_REPORT_DATA_TRUNCATION
    MYSQL_OPT_RECONNECT
    MYSQL_OPT_SSL_VERIFY_SERVER_CERT ;

ENUM: mysql_protocol_type
    MYSQL_PROTOCOL_DEFAULT
    MYSQL_PROTOCOL_TCP
    MYSQL_PROTOCOL_SOCKET
    MYSQL_PROTOCOL_PIPE
    MYSQL_PROTOCOL_MEMORY ;

ENUM: mysql_rpl_type
    MYSQL_RPL_MASTER
    MYSQL_RPL_SLAVE
    MYSQL_RPL_ADMIN ;

ENUM: enum_field_types
    MYSQL_TYPE_DECIMAL
    MYSQL_TYPE_TINY
    MYSQL_TYPE_SHORT
    MYSQL_TYPE_LONG
    MYSQL_TYPE_FLOAT
    MYSQL_TYPE_DOUBLE
    MYSQL_TYPE_NULL
    MYSQL_TYPE_TIMESTAMP
    MYSQL_TYPE_LONGLONG
    MYSQL_TYPE_INT24
    MYSQL_TYPE_DATE
    MYSQL_TYPE_TIME
    MYSQL_TYPE_DATETIME
    MYSQL_TYPE_YEAR
    MYSQL_TYPE_NEWDATE
    MYSQL_TYPE_VARCHAR
    MYSQL_TYPE_BIT
    { MYSQL_TYPE_NEWDECIMAL 246 }
    { MYSQL_TYPE_ENUM 247 }
    { MYSQL_TYPE_SET 248 }
    { MYSQL_TYPE_TINY_BLOB 249 }
    { MYSQL_TYPE_MEDIUM_BLOB 250 }
    { MYSQL_TYPE_LONG_BLOB 251 }
    { MYSQL_TYPE_BLOB 252 }
    { MYSQL_TYPE_VAR_STRING 253 }
    { MYSQL_TYPE_STRING 254 }
    { MYSQL_TYPE_GEOMETRY 255 } ;

ENUM: enum_mysql_stmt_state
    { MYSQL_STMT_INIT_DONE 1 }
    MYSQL_STMT_PREPARE_DONE
    MYSQL_STMT_EXECUTE_DONE
    MYSQL_STMT_FETCH_DONE ;

ENUM: enum_stmt_attr_type
    STMT_ATTR_UPDATE_MAX_LENGTH
    STMT_ATTR_CURSOR_TYPE
    STMT_ATTR_PREFETCH_ROWS ;

! st_list
STRUCT: LIST
    { prev LIST* }
    { next LIST* }
    { data void* } ;


STRUCT: USED_MEM
    { next USED_MEM* }
    { left uint }
    { size uint } ;

TYPEDEF: uint PSI_memory_key

STRUCT: MEM_ROOT
    { free USED_MEM* }
    { used USED_MEM* }
    { pre_alloc USED_MEM* }
    { min_malloc size_t }
    { block_size size_t }
    { block_num uint }
    { first_block_usage uint }
    { max_capacity size_t }
    { allocated_size size_t }
    { error_for_capacity_exceeded my_bool }
    { error_handler void* }
    { m_psi_key PSI_memory_key } ;

! st_mysql_field
STRUCT: MYSQL_FIELD
    { name c-string }
    { org_name c-string }
    { table c-string }
    { org_table c-string }
    { db c-string }
    { catalog c-string }
    { def c-string }
    { length ulong }
    { max_length ulong }
    { name_length uint }
    { org_name_length uint }
    { table_length uint }
    { org_table_length uint }
    { db_length uint }
    { catalog_length uint }
    { def_length uint }
    { flags uint }
    { decimals uint }
    { charsetnr uint }
    { type enum_field_types }
    { extension void* } ;

STRUCT: st_dynamic_array
    { buffer uchar* }
    { elements uint }
    { max_element uint }
    { alloc_increment uint }
    { size_of_element uint } ;

STRUCT: st_mysql_options
    { connect_timeout uint }
    { read_timeout uint }
    { write_timeout uint }
    { port uint }
    { protocol uint }
    { client_flag ulong }
    { host c-string }
    { user c-string }
    { password c-string }
    { unix_socket c-string }
    { db c-string }
    { init_commands st_dynamic_array* }
    { my_cnf_file c-string }
    { my_cnf_group c-string }
    { charset_dir c-string }
    { charset_name c-string }
    { ssl_key c-string }
    { ssl_cert c-string }
    { ssl_ca c-string }
    { ssl_capath c-string }
    { ssl_cipher c-string }
    { shared_memory_base_name c-string }
    { max_allowed_packet ulong }
    { use_ssl my_bool }
    { compress my_bool }
    { named_pipe my_bool }
    { rpl_probe my_bool }
    { rpl_parse my_bool }
    { no_master_reads my_bool }
    { methods_to_use mysql_option }
    { client_ip c-string }
    { secure_auth my_bool }
    { report_data_truncation my_bool }
    { local_infile_init void* }
    { local_infile_read void* }
    { local_infile_end void* }
    { local_infile_error void* }
    { local_infile_userdata void* }
    { extension void* } ;

! my_uni_idx_st
STRUCT: MY_UNI_IDX
    { from ushort }
    { to ushort }
    { tab uchar* } ;

! unicase_info_st
STRUCT: MY_UNICASE_INFO
    { toupper ushort }
    { tolower ushort }
    { sort ushort } ;

STRUCT: charset_info_st
    { number uint }
    { primary_number uint }
    { binary_number uint }
    { state uint }
    { csname c-string }
    { name c-string }
    { comment c-string }
    { tailoring c-string }
    { ctype c-string }
    { to_lower c-string }
    { to_upper c-string }
    { sort_order c-string }
    { contractions ushort* }
    { sort_order_big ushort** }
    { tab_to_uni ushort* }
    { tab_from_uni MY_UNI_IDX* }
    { caseinfo MY_UNICASE_INFO** }
    { state_map c-string }
    { ident_map c-string }
    { strxfrm_multiply uint }
    { caseup_multiply uchar }
    { casedn_multiply uchar }
    { mbminlen uint }
    { mbmaxlen uint }
    { min_sort_char ushort }
    { max_sort_char ushort }
    { pad_char uchar }
    { escape_with_backslash_is_dangerous char }
    { cset void* }
    { coll void* } ;

C-TYPE: Vio
! st_net
STRUCT: NET
    { vio Vio* }
    { buff uchar* }
    { buff_end uchar* }
    { write_pos uchar* }
    { read_pos uchar* }
    { fd my_socket }
    { remain_in_buf ulong }
    { length ulong }
    { buf_length ulong }
    { where_b ulong }
    { max_packet ulong }
    { max_packet_size ulong }
    { pkt_nr uint }
    { compress_pkt_nr uint }
    { write_timeout uint }
    { read_timeout uint }
    { retry_count uint }
    { fcntl int }
    { return_status uint* }
    { reading_or_writing uchar }
    { save_char char }
    { unused1 my_bool }
    { unused2 my_bool }
    { compress my_bool }
    { unused3 my_bool }
    { query_cache_query uchar* }
    { last_errno uint }
    { error uchar }
    { unused4 my_bool }
    { unused5 my_bool }
    { last_error char[512] }
    { sqlstate char[6] }
    { extension void* } ;

STRUCT: MYSQL
    { net NET }
    { connector_fd uchar* }
    { host c-string }
    { user c-string }
    { passwd c-string }
    { unix_socket c-string }
    { server_version c-string }
    { host_info c-string }
    { info c-string }
    { db c-string }
    { charset charset_info_st* }
    { fields MYSQL_FIELD* }
    { field_alloc MEM_ROOT }
    { affected_rows ulonglong }
    { insert_id ulonglong }
    { extra_info ulonglong }
    { thread_id ulong }
    { packet_length ulong }
    { port uint }
    { client_flag ulong }
    { server_capabilities ulong }
    { protocol_version uint }
    { field_count uint }
    { server_status uint }
    { server_language uint }
    { warning_count uint }
    { options st_mysql_options }
    { status mysql_status }
    { free_me bool }
    { reconnect bool }
    { scramble char[21] }
    { rpl_pivot my_bool }
    { master MYSQL* }
    { next_slave MYSQL* }
    { last_used_slave MYSQL* }
    { last_used_con MYSQL* }
    { stmts LIST* }
    { methods void* }
    { thd void* }
    { unbuffered_fetch_owner bool* }
    { info_buffer c-string }
    { extension void* } ;

TYPEDEF: c-string* MYSQL_ROW

STRUCT: MYSQL_ROWS
    { next MYSQL_ROWS* }
    { data MYSQL_ROW }
    { length ulong } ;

TYPEDEF: MYSQL_ROWS* MYSQL_ROW_OFFSET

STRUCT: MYSQL_DATA
    { data MYSQL_ROWS* }
    { embedded_info void* }
    { alloc MEM_ROOT }
    { rows ulonglong }
    { fields uint }
    { extension void* } ;

STRUCT: MYSQL_RES
    { row_count ulonglong }
    { fields MYSQL_FIELD* }
    { data MYSQL_DATA* }
    { data_cursor MYSQL_ROWS* }
    { lengths ulong* }
    { handle MYSQL* }
    { methods void* }
    { row MYSQL_ROW }
    { current_row MYSQL_ROW }
    { field_alloc MEM_ROOT }
    { field_count uint }
    { current_field uint }
    { eof bool }
    { unbuffered_fetch_cancelled bool }
    { extension void* } ;


STRUCT: MYSQL_BIND
    { length ulong* }
    { is_null bool* }
    { buffer void* }
    { error bool* }
    { row_ptr uchar* }
    { store_param_func void* }
    { fetch_result void* }
    { skip_result void* }
    { buffer_length ulong }
    { offset ulong }
    { length_value ulong }
    { param_number uint }
    { pack_length uint }
    { buffer_type enum_field_types }
    { error_value bool }
    { is_unsigned bool }
    { long_data_used bool }
    { is_null_value bool }
    { extension void* } ;



! FIXME: Replace with TYPEDEF: void* MYSQL_STMT
! since no fields are supposed to be used by application?

STRUCT: MYSQL_STMT
    { mem_root MEM_ROOT }
    { list LIST }
    { mysql MYSQL* }
    { params MYSQL_BIND* }
    { bind MYSQL_BIND* }
    { fields MYSQL_FIELD* }
    { result MYSQL_DATA }
    { data_cursor MYSQL_ROWS* }
    { read_row_func void* }
    { affected_rows ulonglong }
    { insert_id ulonglong }
    { stmt_id ulong }
    { flags ulong }
    { prefetch_rows ulong }
    { server_status uint }
    { last_errno uint }
    { param_count uint }
    { field_count uint }
    { state enum_mysql_stmt_state }
    { last_error char[MYSQL_ERRMSG_SIZE] }
    { sqlstate char[6] }
    { send_types_to_server bool }
    { bind_param_done bool }
    { bind_result_done uchar }
    { unbuffered_fetch_cancelled bool }
    { update_max_length bool }
    { extension void* } ;


ENUM: enum_mysql_timestamp_type
    { MYSQL_TIMESTAMP_NONE -2 }
    { MYSQL_TIMESTAMP_ERROR -1 }
    { MYSQL_TIMESTAMP_DATE 0 }
    { MYSQL_TIMESTAMP_DATETIME 1 }
    { MYSQL_TIMESTAMP_TIME 2 } ;


STRUCT: MYSQL_TIME
    { year uint }
    { month uint }
    { day uint }
    { hour uint }
    { minute uint }
    { second uint }
    { second_part ulong }
    { neg bool }
    { time_type enum_mysql_timestamp_type } ;



FUNCTION: MYSQL* mysql_init ( MYSQL* mysql )


FUNCTION: c-string mysql_info ( MYSQL* mysql )



FUNCTION: uint mysql_errno ( MYSQL* mysql )

FUNCTION: c-string mysql_error ( MYSQL* mysql )


FUNCTION: c-string mysql_get_client_info ( )

FUNCTION: ulong mysql_get_client_version ( )

FUNCTION: c-string mysql_get_host_info ( MYSQL* mysql )

FUNCTION: c-string mysql_get_server_info ( MYSQL* mysql )

FUNCTION: ulong mysql_get_server_version ( MYSQL* mysql )

FUNCTION: uint mysql_get_proto_info ( MYSQL* mysql )

FUNCTION: MYSQL_RES* mysql_list_dbs (
    MYSQL* mysql,
    c-string wild
)

FUNCTION: MYSQL_RES* mysql_list_tables (
    MYSQL* mysql,
    c-string wild
)

FUNCTION: MYSQL_RES* mysql_list_processes ( MYSQL* mysql )




FUNCTION: MYSQL* mysql_real_connect (
    MYSQL* mysql,
    c-string host,
    c-string user,
    c-string passwd,
    c-string db,
    uint port,
    c-string unix_socket,
    ulong client_flag
)

FUNCTION: void mysql_close ( MYSQL* mysql )



FUNCTION: bool mysql_commit ( MYSQL* mysql )

FUNCTION: bool mysql_rollback ( MYSQL* mysql )

FUNCTION: bool mysql_autocommit (
    MYSQL* mysql,
    bool auto_mode
)

FUNCTION: bool mysql_more_results ( MYSQL* mysql )

FUNCTION: int mysql_next_result ( MYSQL* mysql )


! <OLD-FUNCTIONS
FUNCTION: MYSQL* mysql_connect (
    MYSQL* mysql,
    c-string host,
    c-string user,
    c-string passwd
)

FUNCTION: int mysql_create_db ( MYSQL* mysql, c-string db )

FUNCTION: int mysql_drop_db ( MYSQL* mysql, c-string db )
! OLD-FUNCTIONS>




FUNCTION: int mysql_select_db ( MYSQL* mysql, c-string db )



FUNCTION: int mysql_query ( MYSQL* mysql, c-string stmt_str )

FUNCTION: int mysql_send_query (
    MYSQL* mysql,
    c-string stmt_str,
    ulong length
)

FUNCTION: int mysql_real_query (
    MYSQL* mysql,
    c-string stmt_str,
    ulong length
)

FUNCTION: MYSQL_RES* mysql_store_result ( MYSQL* mysql )

FUNCTION: MYSQL_RES* mysql_use_result ( MYSQL* mysql )


FUNCTION: int mysql_ping ( MYSQL* mysql )




FUNCTION: ulonglong mysql_num_rows ( MYSQL_RES* mysql )

FUNCTION: uint mysql_num_fields ( MYSQL_RES* mysql )

FUNCTION: bool mysql_eof ( MYSQL_RES* result )

FUNCTION: MYSQL_FIELD* mysql_fetch_field_direct (
    MYSQL_RES* result,
    uint fieldnr
)

FUNCTION: MYSQL_FIELD* mysql_fetch_fields ( MYSQL_RES* result )


FUNCTION: uint mysql_field_count ( MYSQL* mysql )



FUNCTION: MYSQL_ROW mysql_fetch_row ( MYSQL_RES* result )

FUNCTION: MYSQL_FIELD* mysql_fetch_field ( MYSQL_RES* result )

FUNCTION: void mysql_free_result ( MYSQL_RES* result )








FUNCTION: MYSQL_STMT* mysql_stmt_init ( MYSQL* mysql )

FUNCTION: int mysql_stmt_prepare (
    MYSQL_STMT* stmt,
    c-string query,
    ulong length
)

FUNCTION: int mysql_stmt_execute ( MYSQL_STMT* stmt )

FUNCTION: int mysql_stmt_fetch ( MYSQL_STMT* stmt )

FUNCTION: int mysql_stmt_fetch_column (
    MYSQL_STMT* stmt,
    MYSQL_BIND* bind_arg,
    uint column,
    ulong offset
)

FUNCTION: int mysql_stmt_store_result ( MYSQL_STMT* stmt )

FUNCTION: ulong mysql_stmt_param_count ( MYSQL_STMT* stmt )

FUNCTION: bool mysql_stmt_attr_set (
    MYSQL_STMT* stmt,
    enum_stmt_attr_type attr_type,
    void* attr
)

FUNCTION: bool mysql_stmt_attr_get (
    MYSQL_STMT* stmt,
    enum_stmt_attr_type attr_type,
    void* attr
)

FUNCTION: bool mysql_stmt_bind_param (
    MYSQL_STMT* stmt,
    MYSQL_BIND* bnd
)

FUNCTION: bool mysql_stmt_bind_result (
    MYSQL_STMT* stmt,
    MYSQL_BIND* bnd
)

FUNCTION: bool mysql_stmt_close ( MYSQL_STMT* stmt )

FUNCTION: bool mysql_stmt_reset ( MYSQL_STMT* stmt )

FUNCTION: bool mysql_stmt_free_result ( MYSQL_STMT* stmt )

FUNCTION: bool mysql_stmt_send_long_data (
    MYSQL_STMT* stmt,
    uint param_number,
    c-string data,
    ulong length
)

FUNCTION: MYSQL_RES* mysql_stmt_result_metadata ( MYSQL_STMT* stmt )

FUNCTION: MYSQL_RES* mysql_stmt_param_metadata ( MYSQL_STMT* stmt )

FUNCTION: uint mysql_stmt_errno ( MYSQL_STMT* stmt )

FUNCTION: c-string mysql_stmt_error ( MYSQL_STMT* stmt )

FUNCTION: c-string mysql_stmt_sqlstate ( MYSQL_STMT* stmt )

FUNCTION: MYSQL_ROW_OFFSET mysql_stmt_row_seek (
    MYSQL_STMT* stmt,
    MYSQL_ROW_OFFSET offset
)

FUNCTION: MYSQL_ROW_OFFSET mysql_stmt_row_tell (
    MYSQL_STMT* stmt,
    MYSQL_ROW_OFFSET offset
)

FUNCTION: void mysql_stmt_data_seek (
    MYSQL_STMT* stmt,
    ulonglong offset
)

FUNCTION: ulonglong mysql_stmt_num_rows ( MYSQL_STMT* stmt )

FUNCTION: ulonglong mysql_stmt_affected_rows ( MYSQL_STMT* stmt )

FUNCTION: ulonglong mysql_stmt_insert_id ( MYSQL_STMT* stmt )

FUNCTION: uint mysql_stmt_field_count ( MYSQL_STMT* stmt )

