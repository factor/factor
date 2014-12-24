! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries
alien.libraries.finder alien.syntax classes.struct kernel ;
IN: forestdb.ffi

! Functions with LIBFDB_API are exported.

<< "forestdb" dup find-library cdecl add-library >>

LIBRARY: forestdb

! Begin fdb_types.h

CONSTANT: FDB_MAX_KEYLEN 3840
CONSTANT: FDB_MAX_METALEN 65535
CONSTANT: FDB_MAX_BODYLEN 4294967295
CONSTANT: FDB_SNAPSHOT_INMEM -1

TYPEDEF: uint64_t fdb_seqnum_t
TYPEDEF: int64_t cs_off_t

TYPEDEF: void* fdb_custom_cmp_fixed
TYPEDEF: void* fdb_custom_cmp_variable
TYPEDEF: void* fdb_log_callback
TYPEDEF: void* fdb_file_handle
TYPEDEF: void* fdb_kvs_handle
TYPEDEF: void* fdb_iterator

ENUM: fdb_open_flags
    { FDB_OPEN_FLAG_CREATE 1 }
    { FDB_OPEN_FLAG_RDONLY 2 } ;

ENUM: fdb_commit_opt_t
    { FDB_COMMIT_NORMAL 0 }
    { FDB_COMMIT_MANUAL_WAL_FLUSH 1 } ;

ENUM: fdb_seqtree_opt_t
    { FDB_SEQTREE_NOT_USE 0 }
    { FDB_SEQTREE_USE 1 } ;

ENUM: fdb_durability_opt_t
    { FDB_DRB_NONE 0 }
    { FDB_DRB_ODIRECT 1 }
    { FDB_DRB_ASYNC 2 }
    { FDB_DRB_ODIRECT_ASYNC 3 } ;

ENUM: fdb_compaction_mode_t
    { FDB_COMPACTION_MANUAL 0 }
    { FDB_COMPACTION_AUTO 1 } ;

ENUM: fdb_isolation_level_t
    { FDB_ISOLATION_SERIALIZABLE 0 }
    { FDB_ISOLATION_REPEATABLE_READ 1 }
    { FDB_ISOLATION_READ_COMMITTED 2 }
    { FDB_ISOLATION_READ_UNCOMMITTED 3 } ;

ENUM: fdb_iterator_opt_t
    { FDB_ITR_NONE 0 }
    { FDB_ITR_NO_DELETES 2 }
    { FDB_ITR_SKIP_MIN_KEY 4 }
    { FDB_ITR_SKIP_MAX_KEY 8 } ;

ENUM: fdb_iterator_seek_opt_t
    { FDB_ITR_SEEK_HIGHER 0 }
    { FDB_ITR_SEEK_LOWER 1 } ;


! cmp_fixed and cmp_variable have their own open() functions
STRUCT: fdb_config
    { chunksize uint16_t }
    { blocksize uint32_t }
    { buffercache_size uint64_t }
    { wal_threshold uint64_t }
    { wal_flush_before_commit bool }
    { purging_interval uint32_t }
    { seqtree_opt fdb_seqtree_opt_t }
    { durability_opt fdb_durability_opt_t }
    { flags fdb_open_flags }
    { compaction_buf_maxsize uint32_t }
    { cleanup_cache_onclose bool }
    { compress_document_body bool }
    { compaction_mode fdb_compaction_mode_t }
    { compaction_threshold uint8_t }
    { compaction_minimum_filesize uint64_t }
    { compactor_sleep_duration uint64_t }
    { multi_kv_instances bool }
    { prefetch_duration uint64_t } ;

STRUCT: fdb_kvs_config
    { create_if_missing bool }
    { custom_cmp fdb_custom_cmp_variable } ;

STRUCT: fdb_doc
    { keylen size_t }
    { metalen size_t }
    { bodylen size_t }
    { size_ondisk size_t }
    { key void* }
    { seqnum fdb_seqnum_t }
    { offset uint64_t }
    { meta void* }
    { body void* }
    { deleted bool } ;

! filename is a pointer to the handle's filename
! new_filename is a pointer to the handle's new_file

STRUCT: fdb_file_info
    { filename char* }
    { new_filename char* }
    { doc_count uint64_t }
    { space_used uint64_t }
    { file_size uint64_t } ;

STRUCT: fdb_kvs_info
    { name char* }
    { last_seqnum fdb_seqnum_t }
    { doc_count uint64_t }
    { space_used uint64_t }
    { file fdb_file_handle* } ;

STRUCT: fdb_kvs_name_list
    { num_kvs_names size_t }
    { kvs_names char** } ;

! end fdb_types.h

! Begin fdb_errors.h
ENUM: fdb_status
    { FDB_RESULT_SUCCESS 0 }
    { FDB_RESULT_INVALID_ARGS -1 }
    { FDB_RESULT_OPEN_FAIL -2 }
    { FDB_RESULT_NO_SUCH_FILE -3 }
    { FDB_RESULT_WRITE_FAIL -4 }
    { FDB_RESULT_READ_FAIL -5 }
    { FDB_RESULT_CLOSE_FAIL -6 }
    { FDB_RESULT_COMMIT_FAIL -7 }
    { FDB_RESULT_ALLOC_FAIL -8 }
    { FDB_RESULT_KEY_NOT_FOUND -9 }
    { FDB_RESULT_RONLY_VIOLATION -10 }
    { FDB_RESULT_COMPACTION_FAIL -11 }
    { FDB_RESULT_ITERATOR_FAIL -12 }
    { FDB_RESULT_SEEK_FAIL -13 }
    { FDB_RESULT_FSYNC_FAIL -14 }
    { FDB_RESULT_CHECKSUM_ERROR -15 }
    { FDB_RESULT_FILE_CORRUPTION -16 }
    { FDB_RESULT_COMPRESSION_FAIL -17 }
    { FDB_RESULT_NO_DB_INSTANCE -18 }
    { FDB_RESULT_FAIL_BY_ROLLBACK -19 }
    { FDB_RESULT_INVALID_CONFIG -20 }
    { FDB_RESULT_MANUAL_COMPACTION_FAIL -21 }
    { FDB_RESULT_INVALID_COMPACTION_MODE -22 }
    { FDB_RESULT_FILE_IS_BUSY -23 }
    { FDB_RESULT_FILE_REMOVE_FAIL -24 }
    { FDB_RESULT_FILE_RENAME_FAIL -25 }
    { FDB_RESULT_TRANSACTION_FAIL -26 }
    { FDB_RESULT_FAIL_BY_TRANSACTION -27 }
    { FDB_RESULT_FAIL_BY_COMPACTION -28 }
    { FDB_RESULT_TOO_LONG_FILENAME -29 }
    { FDB_RESULT_INVALID_HANDLE -30 }
    { FDB_RESULT_KV_STORE_NOT_FOUND -31 }
    { FDB_RESULT_KV_STORE_BUSY -32 }
    { FDB_RESULT_INVALID_KV_INSTANCE_NAME -33 }
    { FDB_RESULT_INVALID_CMP_FUNCTION -34 }
    { FDB_RESULT_IN_USE_BY_COMPACTOR -35 } ;

! End fdb_errors.h

! Begin forestdb.h
FUNCTION: fdb_status fdb_init ( fdb_config* config ) ;
FUNCTION: fdb_config fdb_get_default_config ( ) ;
FUNCTION: fdb_kvs_config fdb_get_default_kvs_config ( ) ;

FUNCTION: fdb_status fdb_open ( fdb_file_handle** ptr_fhandle, c-string filename, fdb_config* fconfig ) ;
FUNCTION: fdb_status fdb_open_custom_cmp ( fdb_file_handle** ptr_fhandle, c-string filename, fdb_config* fconfig, size_t num_functions, char** kvs_names, fdb_custom_cmp_variable* functions ) ;

FUNCTION: fdb_status fdb_set_log_callback ( fdb_kvs_handle* handle, fdb_log_callback log_callback, void* ctx_data ) ;

! doc is calloc'd
FUNCTION: fdb_status fdb_doc_create ( fdb_doc** doc, void* key, size_t keylen, void* meta, size_t metalen, void* body, size_t bodylen ) ;
FUNCTION: fdb_status fdb_doc_update ( fdb_doc** doc, void* meta, size_t metalen, void* body, size_t bodylen ) ;
FUNCTION: fdb_status fdb_doc_free ( fdb_doc* doc ) ;

FUNCTION: fdb_status fdb_get ( fdb_kvs_handle* handle, fdb_doc* doc ) ;
FUNCTION: fdb_status fdb_get_metaonly ( fdb_kvs_handle* handle, fdb_doc* doc ) ;
FUNCTION: fdb_status fdb_get_byseq ( fdb_kvs_handle* handle, fdb_doc* doc ) ;
FUNCTION: fdb_status fdb_get_metaonly_byseq ( fdb_kvs_handle* handle, fdb_doc* doc ) ;
FUNCTION: fdb_status fdb_get_byoffset ( fdb_kvs_handle* handle, fdb_doc* doc ) ;

FUNCTION: fdb_status fdb_set ( fdb_kvs_handle* handle, fdb_doc* doc ) ;
FUNCTION: fdb_status fdb_del ( fdb_kvs_handle* handle, fdb_doc* doc ) ;

FUNCTION: fdb_status fdb_get_kv ( fdb_kvs_handle* handle, void* key, size_t keylen, void** value_out, size_t* valuelen_out ) ;
FUNCTION: fdb_status fdb_set_kv ( fdb_kvs_handle* handle, void* key, size_t keylen, void* value, size_t valuelen ) ;
FUNCTION: fdb_status fdb_del_kv ( fdb_kvs_handle* handle, void* key, size_t keylen ) ;

FUNCTION: fdb_status fdb_commit ( fdb_file_handle* fhandle, fdb_commit_opt_t opt ) ;
FUNCTION: fdb_status fdb_snapshot_open ( fdb_kvs_handle* handle_in, fdb_kvs_handle** handle_out, fdb_seqnum_t snapshot_seqnum ) ;
! Swaps out the handle for a new one
FUNCTION: fdb_status fdb_rollback ( fdb_kvs_handle** handle_ptr, fdb_seqnum_t rollback_seqnum ) ;

FUNCTION: fdb_status fdb_iterator_init ( fdb_kvs_handle* handle, fdb_iterator** iterator, void* min_key, size_t min_keylen, void* max_key, size_t max_keylen, fdb_iterator_opt_t opt ) ;
FUNCTION: fdb_status fdb_iterator_sequence_init ( fdb_kvs_handle* handle, fdb_iterator** iterator, fdb_seqnum_t min_seq, fdb_seqnum_t max_seq, fdb_iterator_opt_t opt ) ;

FUNCTION: fdb_status fdb_iterator_prev ( fdb_iterator* iterator ) ;
FUNCTION: fdb_status fdb_iterator_next ( fdb_iterator* iterator ) ;
FUNCTION: fdb_status fdb_iterator_get ( fdb_iterator* iterator, fdb_doc **doc ) ;
FUNCTION: fdb_status fdb_iterator_get_metaonly ( fdb_iterator* iterator, fdb_doc **doc ) ;

FUNCTION: fdb_status fdb_iterator_seek ( fdb_iterator* iterator, void* seek_key, size_t seek_keylen, fdb_iterator_seek_opt_t direction ) ;
FUNCTION: fdb_status fdb_iterator_seek_to_min ( fdb_iterator* iterator ) ;
FUNCTION: fdb_status fdb_iterator_seek_to_max ( fdb_iterator* iterator ) ;
FUNCTION: fdb_status fdb_iterator_close ( fdb_iterator* iterator ) ;

FUNCTION: fdb_status fdb_compact ( fdb_file_handle* handle, c-string new_filename ) ;
FUNCTION: size_t fdb_estimate_space_used ( fdb_file_handle* fhandle ) ;
FUNCTION: fdb_status fdb_get_file_info ( fdb_file_handle* handle, fdb_file_info* info ) ;
FUNCTION: fdb_status fdb_get_kvs_info ( fdb_kvs_handle* handle, fdb_kvs_info* info ) ;
FUNCTION: fdb_status fdb_get_kvs_seqnum ( fdb_kvs_handle* handle, fdb_seqnum_t* seqnum ) ;
FUNCTION: fdb_status fdb_get_kvs_name_list ( fdb_kvs_handle* handle, fdb_kvs_name_list* kvs_name_list ) ;
FUNCTION: fdb_status fdb_free_kvs_name_list ( fdb_kvs_name_list* kvs_name_list ) ;

FUNCTION: fdb_status fdb_switch_compaction_mode ( fdb_file_handle* fhandle, fdb_compaction_mode_t mode, size_t new_threshold ) ;
FUNCTION: fdb_status fdb_close ( fdb_file_handle* fhandle ) ;

FUNCTION: fdb_status fdb_destroy ( c-string filename, fdb_config* fconfig ) ;
FUNCTION: fdb_status fdb_shutdown ( ) ;

FUNCTION: fdb_status fdb_begin_transaction ( fdb_file_handle* fhandle, fdb_isolation_level_t isolation_level ) ;
FUNCTION: fdb_status fdb_end_transaction ( fdb_file_handle* fhandle, fdb_commit_opt_t opt ) ;
FUNCTION: fdb_status fdb_abort_transaction ( fdb_file_handle* fhandle ) ;
FUNCTION: fdb_status fdb_kvs_open ( fdb_file_handle* fhandle,
                        fdb_kvs_handle** ptr_handle,
                        char* kvs_name,
                        fdb_kvs_config* config ) ;


FUNCTION: fdb_status fdb_kvs_open_default ( fdb_file_handle* fhandle,
                                fdb_kvs_handle** ptr_handle,
                                fdb_kvs_config* config ) ;

FUNCTION: fdb_status fdb_kvs_close ( fdb_kvs_handle* handle ) ;

FUNCTION: fdb_status fdb_kvs_remove ( fdb_file_handle* fhandle, char* kvs_name ) ;
FUNCTION: char* fdb_error_msg ( fdb_status err_code ) ;
