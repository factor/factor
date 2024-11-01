! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators system ;
IN: duckdb.ffi

C-LIBRARY: duckdb {
    { windows "duckdb.dll" }
    { macos "libduckdb.dylib" }
    { unix "libduckdb.so" }
}

LIBRARY: duckdb

CONSTANT: DUCKDB_API_0_3_2 2

TYPEDEF: uint64_t idx_t

ENUM: duckdb_type
    { DUCKDB_TYPE_INVALID 0 }
    { DUCKDB_TYPE_BOOLEAN 1 }
    { DUCKDB_TYPE_TINYINT 2 }
    { DUCKDB_TYPE_SMALLINT 3 }
    { DUCKDB_TYPE_INTEGER 4 }
    { DUCKDB_TYPE_BIGINT 5 }
    { DUCKDB_TYPE_UTINYINT 6 }
    { DUCKDB_TYPE_USMALLINT 7 }
    { DUCKDB_TYPE_UINTEGER 8 }
    { DUCKDB_TYPE_UBIGINT 9 }
    { DUCKDB_TYPE_FLOAT 10 }
    { DUCKDB_TYPE_DOUBLE 11 }
    { DUCKDB_TYPE_TIMESTAMP 12 }
    { DUCKDB_TYPE_DATE 13 }
    { DUCKDB_TYPE_TIME 14 }
    { DUCKDB_TYPE_INTERVAL 15 }
    { DUCKDB_TYPE_HUGEINT 16 }
    { DUCKDB_TYPE_VARCHAR 17 }
    { DUCKDB_TYPE_BLOB 18 }
    { DUCKDB_TYPE_DECIMAL 19 }
    { DUCKDB_TYPE_TIMESTAMP_S 20 }
    { DUCKDB_TYPE_TIMESTAMP_MS 21 }
    { DUCKDB_TYPE_TIMESTAMP_NS 22 }
    { DUCKDB_TYPE_ENUM 23 }
    { DUCKDB_TYPE_LIST 24 }
    { DUCKDB_TYPE_STRUCT 25 }
    { DUCKDB_TYPE_MAP 26 }
    { DUCKDB_TYPE_UUID 27 }
    { DUCKDB_TYPE_UNION 28 }
    { DUCKDB_TYPE_BIT 29 } ;

STRUCT: duckdb_date
    { days int32_t } ;

STRUCT: duckdb_date_struct
    { year int32_t }
    { month int8_t }
    { day int8_t } ;

STRUCT: duckdb_time
    { micros int64_t } ;

STRUCT: duckdb_time_struct
    { hour  int8_t }
    { min int8_t }
    { sec int8_t }
    { micros int32_t } ;

STRUCT: duckdb_timestamp
    { micros int64_t } ;

STRUCT: duckdb_timestamp_struct
    { date duckdb_date_struct }
    { time duckdb_time_struct } ;

STRUCT: duckdb_interval
    { months int32_t }
    { days int32_t }
    { micros int64_t } ;

STRUCT: duckdb_hugeint
    { lower uint64_t }
    { upper int64_t } ;

STRUCT: duckdb_decimal
    { width uint8_t }
    { scale uint8_t }
    { value duckdb_hugeint } ;

STRUCT: duckdb_string
    { data char* }
    { size idx_t } ;

STRUCT: duckdb-string-pointer
    { length uint32_t }
    { prefix char[4] }
    { ptr char* } ;

STRUCT: inlined-duckdb-string
    { length uint32_t }
    { inlined char[4] } ;

UNION-STRUCT: duckdb_string_t
    { pointer duckdb-string-pointer }
    { inlined inlined-duckdb-string } ;

STRUCT: duckdb_blob
    { data void* }
    { size idx_t } ;

STRUCT: duckdb_list_entry
    { offset uint64_t }
    { length uint64_t } ;

STRUCT: duckdb_column
    { internal_data void* } ;

STRUCT: duckdb_result
    { internal_data void* } ;

STRUCT: duckdb_database
    { __db void* } ;

STRUCT: duckdb_connection
    { __conn void* } ;

STRUCT: duckdb_prepared_statement
    { __prep void* } ;

STRUCT: duckdb_extracted_statements
    { __extrac void* } ;

STRUCT: duckdb_pending_result
    { __pend void* } ;

STRUCT: duckdb_appender
    { __appn void* } ;

STRUCT: duckdb_arrow
    { __arrw void* } ;

STRUCT: duckdb_config
    { __cnfg void* } ;

STRUCT: duckdb_arrow_schema
    { __arrs void* } ;

STRUCT: duckdb_arrow_array
    { __arra void* } ;

STRUCT: duckdb_logical_type
    { __lglt void* } ;

STRUCT: duckdb_data_chunk
    { __dtck void* } ;

STRUCT: duckdb_vector
    { __vctr void* } ;

STRUCT: duckdb_value
    { __val void* } ;

ENUM: duckdb_state
    { DuckDBSuccess 0 }
    { DuckDBError 1 } ;

ENUM: duckdb_pending_state
    { DUCKDB_PENDING_RESULT_READY 0 }
    { DUCKDB_PENDING_RESULT_NOT_READY 1 } 
    { DUCKDB_PENDING_ERROR 2 } ;

FUNCTION: duckdb_state duckdb_open ( c-string path, duckdb_database *out_database )
FUNCTION: duckdb_state duckdb_open_ext ( c-string path, duckdb_database *out_database, duckdb_config config, char **out_error )
FUNCTION: void duckdb_close ( duckdb_database *database )
FUNCTION: duckdb_state duckdb_connect ( duckdb_database database, duckdb_connection *out_connection )
FUNCTION: void duckdb_disconnect ( duckdb_connection *connection )
FUNCTION: c-string duckdb_library_version ( )
FUNCTION: duckdb_state duckdb_create_config ( duckdb_config *out_config )
FUNCTION: size_t duckdb_config_count ( )
FUNCTION: duckdb_state duckdb_get_config_flag ( size_t index, c-string *out_name, c-string *out_description )
FUNCTION: duckdb_state duckdb_set_config ( duckdb_config config, c-string name, c-string option )
FUNCTION: void duckdb_destroy_config ( duckdb_config *config )
FUNCTION: duckdb_state duckdb_query ( duckdb_connection connection, c-string query, duckdb_result *out_result )
FUNCTION: void duckdb_destroy_result ( duckdb_result *result )
FUNCTION: c-string duckdb_column_name ( duckdb_result *result, idx_t col )
FUNCTION: duckdb_type duckdb_column_type ( duckdb_result *result, idx_t col )
FUNCTION: duckdb_logical_type duckdb_column_logical_type ( duckdb_result *result, idx_t col )
FUNCTION: idx_t duckdb_column_count ( duckdb_result *result )
FUNCTION: idx_t duckdb_row_count ( duckdb_result *result )
FUNCTION: idx_t duckdb_rows_changed ( duckdb_result *result )
FUNCTION: void *duckdb_column_data ( duckdb_result *result, idx_t col )
FUNCTION: bool *duckdb_nullmask_data ( duckdb_result *result, idx_t col )
FUNCTION: c-string duckdb_result_error ( duckdb_result *result )
FUNCTION: duckdb_data_chunk duckdb_result_get_chunk ( duckdb_result result, idx_t chunk_index )
FUNCTION: bool duckdb_result_is_streaming ( duckdb_result result )
FUNCTION: idx_t duckdb_result_chunk_count ( duckdb_result result )
FUNCTION: bool duckdb_value_boolean ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: int8_t duckdb_value_int8 ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: int16_t duckdb_value_int16 ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: int32_t duckdb_value_int32 ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: int64_t duckdb_value_int64 ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: duckdb_hugeint duckdb_value_hugeint ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: duckdb_decimal duckdb_value_decimal ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: uint8_t duckdb_value_uint8 ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: uint16_t duckdb_value_uint16 ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: uint32_t duckdb_value_uint32 ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: uint64_t duckdb_value_uint64 ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: float duckdb_value_float ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: double duckdb_value_double ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: duckdb_date duckdb_value_date ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: duckdb_time duckdb_value_time ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: duckdb_timestamp duckdb_value_timestamp ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: duckdb_interval duckdb_value_interval ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: char *duckdb_value_varchar ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: duckdb_string duckdb_value_string ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: char *duckdb_value_varchar_internal ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: duckdb_string duckdb_value_string_internal ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: duckdb_blob duckdb_value_blob ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: bool duckdb_value_is_null ( duckdb_result *result, idx_t col, idx_t row )
FUNCTION: void *duckdb_malloc ( size_t size )
FUNCTION: void duckdb_free ( void *ptr )
FUNCTION: idx_t duckdb_vector_size ( )
FUNCTION: bool duckdb_string_is_inlined ( duckdb_string_t string )
FUNCTION: duckdb_date_struct duckdb_from_date ( duckdb_date date )
FUNCTION: duckdb_date duckdb_to_date ( duckdb_date_struct date )
FUNCTION: duckdb_time_struct duckdb_from_time ( duckdb_time time )
FUNCTION: duckdb_time duckdb_to_time ( duckdb_time_struct time )
FUNCTION: duckdb_timestamp_struct duckdb_from_timestamp ( duckdb_timestamp ts )
FUNCTION: duckdb_timestamp duckdb_to_timestamp ( duckdb_timestamp_struct ts )
FUNCTION: double duckdb_hugeint_to_double ( duckdb_hugeint val )
FUNCTION: duckdb_hugeint duckdb_double_to_hugeint ( double val )
FUNCTION: duckdb_decimal duckdb_double_to_decimal ( double val, uint8_t width, uint8_t scale )
FUNCTION: double duckdb_decimal_to_double ( duckdb_decimal val )
FUNCTION: duckdb_state duckdb_prepare ( duckdb_connection connection, c-string query, duckdb_prepared_statement *out_prepared_statement )
FUNCTION: void duckdb_destroy_prepare ( duckdb_prepared_statement *prepared_statement )
FUNCTION: c-string duckdb_prepare_error ( duckdb_prepared_statement prepared_statement )
FUNCTION: idx_t duckdb_nparams ( duckdb_prepared_statement prepared_statement )
FUNCTION: duckdb_type duckdb_param_type ( duckdb_prepared_statement prepared_statement, idx_t param_idx )
FUNCTION: duckdb_state duckdb_clear_bindings ( duckdb_prepared_statement prepared_statement )
FUNCTION: duckdb_state duckdb_bind_boolean ( duckdb_prepared_statement prepared_statement, idx_t param_idx, bool val )
FUNCTION: duckdb_state duckdb_bind_int8 ( duckdb_prepared_statement prepared_statement, idx_t param_idx, int8_t val )
FUNCTION: duckdb_state duckdb_bind_int16 ( duckdb_prepared_statement prepared_statement, idx_t param_idx, int16_t val )
FUNCTION: duckdb_state duckdb_bind_int32 ( duckdb_prepared_statement prepared_statement, idx_t param_idx, int32_t val )
FUNCTION: duckdb_state duckdb_bind_uint64 ( duckdb_prepared_statement prepared_statement, idx_t param_idx, uint64_t val )
FUNCTION: duckdb_state duckdb_bind_float ( duckdb_prepared_statement prepared_statement, idx_t param_idx, float val )
FUNCTION: duckdb_state duckdb_bind_double ( duckdb_prepared_statement prepared_statement, idx_t param_idx, double val )
FUNCTION: duckdb_state duckdb_bind_varchar ( duckdb_prepared_statement prepared_statement, idx_t param_idx, c-string val )
FUNCTION: duckdb_state duckdb_bind_varchar_length ( duckdb_prepared_statement prepared_statement, idx_t param_idx, c-string val, idx_t length )
FUNCTION: duckdb_state duckdb_bind_blob ( duckdb_prepared_statement prepared_statement, idx_t param_idx, void *data, idx_t length )
FUNCTION: duckdb_state duckdb_bind_null ( duckdb_prepared_statement prepared_statement, idx_t param_idx )
FUNCTION: duckdb_state duckdb_execute_prepared ( duckdb_prepared_statement prepared_statement, duckdb_result *out_result )
FUNCTION: duckdb_state duckdb_execute_prepared_arrow ( duckdb_prepared_statement prepared_statement, duckdb_arrow *out_result )
FUNCTION: idx_t duckdb_extract_statements ( duckdb_connection connection, c-string query, duckdb_extracted_statements *out_extracted_statements )
FUNCTION: duckdb_state duckdb_prepare_extracted_statement ( duckdb_connection connection, duckdb_extracted_statements extracted_statements, idx_t index, duckdb_prepared_statement *out_prepared_statement )
FUNCTION: c-string duckdb_extract_statements_error ( duckdb_extracted_statements extracted_statements )
FUNCTION: void duckdb_destroy_extracted ( duckdb_extracted_statements *extracted_statements )
FUNCTION: duckdb_state duckdb_pending_prepared ( duckdb_prepared_statement prepared_statement, duckdb_pending_result *out_result )
FUNCTION: duckdb_state duckdb_pending_prepared_streaming ( duckdb_prepared_statement prepared_statement, duckdb_pending_result *out_result )
FUNCTION: void duckdb_destroy_pending ( duckdb_pending_result *pending_result )
FUNCTION: c-string duckdb_pending_error ( duckdb_pending_result pending_result )
FUNCTION: duckdb_pending_state duckdb_pending_execute_task ( duckdb_pending_result pending_result )
FUNCTION: duckdb_state duckdb_execute_pending ( duckdb_pending_result pending_result, duckdb_result *out_result )
FUNCTION: void duckdb_destroy_value ( duckdb_value *value )
FUNCTION: duckdb_value duckdb_create_varchar ( c-string text )
FUNCTION: duckdb_value duckdb_create_varchar_length ( c-string text, idx_t length )
FUNCTION: duckdb_value duckdb_create_int64 ( int64_t val )
FUNCTION: char *duckdb_get_varchar ( duckdb_value value )
FUNCTION: int64_t duckdb_get_int64 ( duckdb_value value )
FUNCTION: duckdb_logical_type duckdb_create_logical_type ( duckdb_type type )
FUNCTION: duckdb_logical_type duckdb_create_list_type ( duckdb_logical_type type )
FUNCTION: duckdb_logical_type duckdb_create_map_type ( duckdb_logical_type key_type, duckdb_logical_type value_type )
FUNCTION: void duckdb_destroy_logical_type ( duckdb_logical_type *type )
FUNCTION: duckdb_data_chunk duckdb_create_data_chunk ( duckdb_logical_type *types, idx_t column_count )
FUNCTION: void duckdb_destroy_data_chunk ( duckdb_data_chunk *chunk )
FUNCTION: void duckdb_data_chunk_reset ( duckdb_data_chunk chunk )
FUNCTION: idx_t duckdb_data_chunk_get_column_count ( duckdb_data_chunk chunk )
FUNCTION: duckdb_vector duckdb_data_chunk_get_vector ( duckdb_data_chunk chunk, idx_t col_idx )
FUNCTION: idx_t duckdb_data_chunk_get_size ( duckdb_data_chunk chunk )
FUNCTION: void duckdb_data_chunk_set_size ( duckdb_data_chunk chunk, idx_t size )
FUNCTION: duckdb_logical_type duckdb_vector_get_column_type ( duckdb_vector vector )
FUNCTION: void *duckdb_vector_get_data ( duckdb_vector vector )
FUNCTION: uint64_t *duckdb_vector_get_validity ( duckdb_vector vector )
FUNCTION: void duckdb_vector_ensure_validity_writable ( duckdb_vector vector )
FUNCTION: void duckdb_vector_assign_string_element ( duckdb_vector vector, idx_t index, c-string str )
FUNCTION: void duckdb_vector_assign_string_element_len ( duckdb_vector vector, idx_t index, c-string str, idx_t str_len )
FUNCTION: duckdb_vector duckdb_list_vector_get_child ( duckdb_vector vector )
FUNCTION: idx_t duckdb_list_vector_get_size ( duckdb_vector vector )
FUNCTION: duckdb_state duckdb_list_vector_set_size ( duckdb_vector vector, idx_t size )
FUNCTION: duckdb_state duckdb_list_vector_reserve ( duckdb_vector vector, idx_t required_capacity )
FUNCTION: duckdb_vector duckdb_struct_vector_get_child ( duckdb_vector vector, idx_t index )
FUNCTION: bool duckdb_validity_row_is_valid ( uint64_t *validity, idx_t row )
FUNCTION: void duckdb_validity_set_row_validity ( uint64_t *validity, idx_t row, bool valid )
FUNCTION: void duckdb_validity_set_row_invalid ( uint64_t *validity, idx_t row )
FUNCTION: void duckdb_validity_set_row_valid ( uint64_t *validity, idx_t row )

TYPEDEF: void* duckdb_table_function
TYPEDEF: void* duckdb_bind_info
TYPEDEF: void* duckdb_init_info
TYPEDEF: void* duckdb_function_info

TYPEDEF: void* duckdb_table_function_bind_t
TYPEDEF: void* duckdb_table_function_init_t
TYPEDEF: void* duckdb_table_function_t
TYPEDEF: void* duckdb_delete_callback_t

FUNCTION: duckdb_table_function duckdb_create_table_function ( )
FUNCTION: void duckdb_destroy_table_function ( duckdb_table_function *table_function )
FUNCTION: void duckdb_table_function_set_name ( duckdb_table_function table_function, c-string name )
FUNCTION: void duckdb_table_function_add_parameter ( duckdb_table_function table_function, duckdb_logical_type type )
FUNCTION: void duckdb_table_function_add_named_parameter ( duckdb_table_function table_function, c-string name, duckdb_logical_type type )
FUNCTION: void duckdb_table_function_set_extra_info ( duckdb_table_function table_function, void *extra_info, duckdb_delete_callback_t destroy )
FUNCTION: void duckdb_table_function_set_bind ( duckdb_table_function table_function, duckdb_table_function_bind_t bind )
FUNCTION: void duckdb_table_function_set_init ( duckdb_table_function table_function, duckdb_table_function_init_t init )
FUNCTION: void duckdb_table_function_set_local_init ( duckdb_table_function table_function, duckdb_table_function_init_t init )
FUNCTION: void duckdb_table_function_set_function ( duckdb_table_function table_function, duckdb_table_function_t function )
FUNCTION: void duckdb_table_function_supports_projection_pushdown ( duckdb_table_function table_function, bool pushdown )
FUNCTION: duckdb_state duckdb_register_table_function ( duckdb_connection con, duckdb_table_function function )
FUNCTION: void *duckdb_bind_get_extra_info ( duckdb_bind_info info )
FUNCTION: void duckdb_bind_add_result_column ( duckdb_bind_info info, c-string name, duckdb_logical_type type )
FUNCTION: idx_t duckdb_bind_get_parameter_count ( duckdb_bind_info info )
FUNCTION: duckdb_value duckdb_bind_get_parameter ( duckdb_bind_info info, idx_t index )
FUNCTION: duckdb_value duckdb_bind_get_named_parameter ( duckdb_bind_info info, c-string name )
FUNCTION: void duckdb_bind_set_bind_data ( duckdb_bind_info info, void* bind_data, duckdb_delete_callback_t destroy )
FUNCTION: void duckdb_bind_set_cardinality ( duckdb_bind_info info, idx_t cardinality, bool is_exact )
FUNCTION: void duckdb_bind_set_error ( duckdb_bind_info info, c-string error )
FUNCTION: void* duckdb_init_get_extra_info ( duckdb_init_info info )
FUNCTION: void* duckdb_init_get_bind_data ( duckdb_init_info info )
FUNCTION: void duckdb_init_set_init_data ( duckdb_init_info info, void* init_data, duckdb_delete_callback_t destroy )
FUNCTION: idx_t duckdb_init_get_column_count ( duckdb_init_info info )
FUNCTION: idx_t duckdb_init_get_column_index ( duckdb_init_info info, idx_t column_index )
FUNCTION: void duckdb_init_set_max_threads ( duckdb_init_info info, idx_t max_threads )
FUNCTION: void duckdb_init_set_error ( duckdb_init_info info, c-string error )
FUNCTION: void* duckdb_function_get_extra_info ( duckdb_function_info info )
FUNCTION: void* duckdb_function_get_bind_data ( duckdb_function_info info )
FUNCTION: void* duckdb_function_get_init_data ( duckdb_function_info info )
FUNCTION: void* duckdb_function_get_local_init_data ( duckdb_function_info info )
FUNCTION: void duckdb_function_set_error ( duckdb_function_info info, c-string error )

TYPEDEF: void* duckdb_replacement_scan_info
TYPEDEF: void* duckdb_replacement_callback_t

FUNCTION: void duckdb_add_replacement_scan ( duckdb_database db, duckdb_replacement_callback_t replacement, void* extra_data, duckdb_delete_callback_t delete_callback )
FUNCTION: void duckdb_replacement_scan_set_function_name ( duckdb_replacement_scan_info info, c-string function_name )
FUNCTION: void duckdb_replacement_scan_add_parameter ( duckdb_replacement_scan_info info, duckdb_value parameter )
FUNCTION: void duckdb_replacement_scan_set_error ( duckdb_replacement_scan_info info, c-string error )
FUNCTION: duckdb_state duckdb_appender_create ( duckdb_connection connection, c-string schema, c-string table, duckdb_appender* out_appender )
FUNCTION: c-string duckdb_appender_error ( duckdb_appender appender )
FUNCTION: duckdb_state duckdb_appender_flush ( duckdb_appender appender )
FUNCTION: duckdb_state duckdb_appender_close ( duckdb_appender appender )
FUNCTION: duckdb_state duckdb_appender_destroy ( duckdb_appender* appender )
FUNCTION: duckdb_state duckdb_appender_begin_row ( duckdb_appender appender )
FUNCTION: duckdb_state duckdb_appender_end_row ( duckdb_appender appender )
FUNCTION: duckdb_state duckdb_append_bool ( duckdb_appender appender, bool value )
FUNCTION: duckdb_state duckdb_append_int8 ( duckdb_appender appender, int8_t value )
FUNCTION: duckdb_state duckdb_append_int16 ( duckdb_appender appender, int16_t value )
FUNCTION: duckdb_state duckdb_append_int32 ( duckdb_appender appender, int32_t value )
FUNCTION: duckdb_state duckdb_append_int64 ( duckdb_appender appender, int64_t value )
FUNCTION: duckdb_state duckdb_append_hugeint ( duckdb_appender appender, duckdb_hugeint value )
FUNCTION: duckdb_state duckdb_append_uint8 ( duckdb_appender appender, uint8_t value )
FUNCTION: duckdb_state duckdb_append_uint16 ( duckdb_appender appender, uint16_t value )
FUNCTION: duckdb_state duckdb_append_uint32 ( duckdb_appender appender, uint32_t value )
FUNCTION: duckdb_state duckdb_append_uint64 ( duckdb_appender appender, uint64_t value )
FUNCTION: duckdb_state duckdb_append_float ( duckdb_appender appender, float value )
FUNCTION: duckdb_state duckdb_append_double ( duckdb_appender appender, double value )
FUNCTION: duckdb_state duckdb_append_date ( duckdb_appender appender, duckdb_date value )
FUNCTION: duckdb_state duckdb_append_time ( duckdb_appender appender, duckdb_time value )
FUNCTION: duckdb_state duckdb_append_timestamp ( duckdb_appender appender, duckdb_timestamp value )
FUNCTION: duckdb_state duckdb_append_interval ( duckdb_appender appender, duckdb_interval value )
FUNCTION: duckdb_state duckdb_append_varchar ( duckdb_appender appender, c-string val )
FUNCTION: duckdb_state duckdb_append_varchar_length ( duckdb_appender appender, c-string val, idx_t length )
FUNCTION: duckdb_state duckdb_append_blob ( duckdb_appender appender, void* data, idx_t length )
FUNCTION: duckdb_state duckdb_append_null ( duckdb_appender appender )
FUNCTION: duckdb_state duckdb_append_data_chunk ( duckdb_appender appender, duckdb_data_chunk chunk )
FUNCTION: duckdb_state duckdb_query_arrow ( duckdb_connection connection, c-string query, duckdb_arrow* out_result )
FUNCTION: duckdb_state duckdb_query_arrow_schema ( duckdb_arrow result, duckdb_arrow_schema* out_schema )
FUNCTION: duckdb_state duckdb_query_arrow_array ( duckdb_arrow result, duckdb_arrow_array* out_array )
FUNCTION: idx_t duckdb_arrow_column_count ( duckdb_arrow result )
FUNCTION: idx_t duckdb_arrow_row_count ( duckdb_arrow result )
FUNCTION: idx_t duckdb_arrow_rows_changed ( duckdb_arrow result )
FUNCTION: c-string duckdb_query_arrow_error ( duckdb_arrow result )
FUNCTION: void duckdb_destroy_arrow ( duckdb_arrow* result )

TYPEDEF: void* duckdb_task_state

FUNCTION: void duckdb_execute_tasks ( duckdb_database database, idx_t max_tasks )
FUNCTION: duckdb_task_state duckdb_create_task_state ( duckdb_database database )
FUNCTION: void duckdb_execute_tasks_state ( duckdb_task_state state )
FUNCTION: idx_t duckdb_execute_n_tasks_state ( duckdb_task_state state, idx_t max_tasks )
FUNCTION: void duckdb_finish_execution ( duckdb_task_state state )
FUNCTION: bool duckdb_task_state_is_finished ( duckdb_task_state state )
FUNCTION: void duckdb_destroy_task_state ( duckdb_task_state state )
FUNCTION: bool duckdb_execution_is_finished ( duckdb_connection con )
FUNCTION: duckdb_data_chunk duckdb_stream_fetch_chunk ( duckdb_result result )
