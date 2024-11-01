! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators system ;
IN: rocksdb.ffi

! https://github.com/facebook/rocksdb/blob/master/include/rocksdb/c.h
! v6.14.5

C-LIBRARY: rockdb cdecl {
    { windows "librocksdb.dll" }
    { macos "librocksdb.dylib" }
    { unix "librocksdb.so" }
}

! Exported types

LIBRARY: rocksdb

C-TYPE: rocksdb_t
C-TYPE: rocksdb_backup_engine_t
C-TYPE: rocksdb_backup_engine_info_t
C-TYPE: rocksdb_backupable_db_options_t
C-TYPE: rocksdb_restore_options_t
C-TYPE: rocksdb_cache_t
C-TYPE: rocksdb_compactionfilter_t
C-TYPE: rocksdb_compactionfiltercontext_t
C-TYPE: rocksdb_compactionfilterfactory_t
C-TYPE: rocksdb_comparator_t
C-TYPE: rocksdb_dbpath_t
C-TYPE: rocksdb_env_t
C-TYPE: rocksdb_fifo_compaction_options_t
C-TYPE: rocksdb_filelock_t
C-TYPE: rocksdb_filterpolicy_t
C-TYPE: rocksdb_flushoptions_t
C-TYPE: rocksdb_iterator_t
C-TYPE: rocksdb_logger_t
C-TYPE: rocksdb_mergeoperator_t
C-TYPE: rocksdb_options_t
C-TYPE: rocksdb_compactoptions_t
C-TYPE: rocksdb_block_based_table_options_t
C-TYPE: rocksdb_cuckoo_table_options_t
C-TYPE: rocksdb_randomfile_t
C-TYPE: rocksdb_readoptions_t
C-TYPE: rocksdb_seqfile_t
C-TYPE: rocksdb_slicetransform_t
C-TYPE: rocksdb_snapshot_t
C-TYPE: rocksdb_writablefile_t
C-TYPE: rocksdb_writebatch_t
C-TYPE: rocksdb_writebatch_wi_t
C-TYPE: rocksdb_writeoptions_t
C-TYPE: rocksdb_universal_compaction_options_t
C-TYPE: rocksdb_livefiles_t
C-TYPE: rocksdb_column_family_handle_t
C-TYPE: rocksdb_envoptions_t
C-TYPE: rocksdb_ingestexternalfileoptions_t
C-TYPE: rocksdb_sstfilewriter_t
C-TYPE: rocksdb_ratelimiter_t
C-TYPE: rocksdb_perfcontext_t
C-TYPE: rocksdb_pinnableslice_t
C-TYPE: rocksdb_transactiondb_options_t
C-TYPE: rocksdb_transactiondb_t
C-TYPE: rocksdb_transaction_options_t
C-TYPE: rocksdb_optimistictransactiondb_t
C-TYPE: rocksdb_optimistictransaction_options_t
C-TYPE: rocksdb_transaction_t
C-TYPE: rocksdb_checkpoint_t
C-TYPE: rocksdb_wal_iterator_t
C-TYPE: rocksdb_wal_readoptions_t
C-TYPE: rocksdb_memory_consumers_t
C-TYPE: rocksdb_memory_usage_t

! DB operations

FUNCTION: rocksdb_t* rocksdb_open (
    rocksdb_options_t* options, c-string name, char** errptr )

FUNCTION: rocksdb_t* rocksdb_open_with_ttl (
    rocksdb_options_t* options, c-string name, int ttl, char** errptr )

FUNCTION: rocksdb_t* rocksdb_open_for_read_only (
    rocksdb_options_t* options, c-string name,
    uchar error_if_log_file_exist, char** errptr )

FUNCTION: rocksdb_t* rocksdb_open_as_secondary (
    rocksdb_options_t* options, c-string name,
    char* secondary_path, char** errptr )

FUNCTION: rocksdb_backup_engine_t* rocksdb_backup_engine_open (
    rocksdb_options_t* options, char* path, char** errptr )

FUNCTION: rocksdb_backup_engine_t*
rocksdb_backup_engine_open_opts ( rocksdb_backupable_db_options_t* options,
    rocksdb_env_t* env, char** errptr )

FUNCTION: void rocksdb_backup_engine_create_new_backup (
    rocksdb_backup_engine_t* be, rocksdb_t* db, char** errptr )

FUNCTION: void rocksdb_backup_engine_create_new_backup_flush (
    rocksdb_backup_engine_t* be, rocksdb_t* db, uchar flush_before_backup,
    char** errptr )

FUNCTION: void rocksdb_backup_engine_purge_old_backups (
    rocksdb_backup_engine_t* be, uint32_t num_backups_to_keep, char** errptr )

FUNCTION: rocksdb_restore_options_t*
rocksdb_restore_options_create ( )
FUNCTION: void rocksdb_restore_options_destroy (
    rocksdb_restore_options_t* opt )
FUNCTION: void rocksdb_restore_options_set_keep_log_files (
    rocksdb_restore_options_t* opt, int v )

FUNCTION: void
rocksdb_backup_engine_verify_backup ( rocksdb_backup_engine_t* be,
    uint32_t backup_id, char** errptr )

FUNCTION: void
rocksdb_backup_engine_restore_db_from_latest_backup (
    rocksdb_backup_engine_t* be, char* db_dir, char* wal_dir,
    rocksdb_restore_options_t* restore_options, char** errptr )

FUNCTION: void rocksdb_backup_engine_restore_db_from_backup (
    rocksdb_backup_engine_t* be, char* db_dir, char* wal_dir,
    rocksdb_restore_options_t* restore_options, uint32_t backup_id,
    char** errptr )

FUNCTION: rocksdb_backup_engine_info_t*
rocksdb_backup_engine_get_backup_info ( rocksdb_backup_engine_t* be )

FUNCTION: int rocksdb_backup_engine_info_count (
    rocksdb_backup_engine_info_t* info )

FUNCTION: int64_t
rocksdb_backup_engine_info_timestamp ( rocksdb_backup_engine_info_t* info,
                                     int index )

FUNCTION: uint32_t
rocksdb_backup_engine_info_backup_id ( rocksdb_backup_engine_info_t* info,
                                     int index )

FUNCTION: uint64_t
rocksdb_backup_engine_info_size ( rocksdb_backup_engine_info_t* info,
                                int index )

FUNCTION: uint32_t rocksdb_backup_engine_info_number_files (
    rocksdb_backup_engine_info_t* info, int index )

FUNCTION: void rocksdb_backup_engine_info_destroy (
    rocksdb_backup_engine_info_t* info )

FUNCTION: void rocksdb_backup_engine_close (
    rocksdb_backup_engine_t* be )


! BackupableDBOptions
FUNCTION: rocksdb_backupable_db_options_t*
rocksdb_backupable_db_options_create ( char* backup_dir )

FUNCTION: void rocksdb_backupable_db_options_set_backup_dir (
    rocksdb_backupable_db_options_t* options, char* backup_dir )

FUNCTION: void rocksdb_backupable_db_options_set_env (
    rocksdb_backupable_db_options_t* options, rocksdb_env_t* env )

FUNCTION: void
rocksdb_backupable_db_options_set_share_table_files (
    rocksdb_backupable_db_options_t* options, uchar val )

FUNCTION: uchar
rocksdb_backupable_db_options_get_share_table_files (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void rocksdb_backupable_db_options_set_sync (
    rocksdb_backupable_db_options_t* options, uchar val )

FUNCTION: uchar rocksdb_backupable_db_options_get_sync (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void
rocksdb_backupable_db_options_set_destroy_old_data (
    rocksdb_backupable_db_options_t* options, uchar val )

FUNCTION: uchar
rocksdb_backupable_db_options_get_destroy_old_data (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void
rocksdb_backupable_db_options_set_backup_log_files (
    rocksdb_backupable_db_options_t* options, uchar val )

FUNCTION: uchar
rocksdb_backupable_db_options_get_backup_log_files (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void
rocksdb_backupable_db_options_set_backup_rate_limit (
    rocksdb_backupable_db_options_t* options, uint64_t limit )

FUNCTION: uint64_t
rocksdb_backupable_db_options_get_backup_rate_limit (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void
rocksdb_backupable_db_options_set_restore_rate_limit (
    rocksdb_backupable_db_options_t* options, uint64_t limit )

FUNCTION: uint64_t
rocksdb_backupable_db_options_get_restore_rate_limit (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void
rocksdb_backupable_db_options_set_max_background_operations (
    rocksdb_backupable_db_options_t* options, int val )

FUNCTION: int
rocksdb_backupable_db_options_get_max_background_operations (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void
rocksdb_backupable_db_options_set_callback_trigger_interval_size (
    rocksdb_backupable_db_options_t* options, uint64_t size )

FUNCTION: uint64_t
rocksdb_backupable_db_options_get_callback_trigger_interval_size (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void
rocksdb_backupable_db_options_set_max_valid_backups_to_open (
    rocksdb_backupable_db_options_t* options, int val )

FUNCTION: int
rocksdb_backupable_db_options_get_max_valid_backups_to_open (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void
rocksdb_backupable_db_options_set_share_files_with_checksum_naming (
    rocksdb_backupable_db_options_t* options, int val )

FUNCTION: int
rocksdb_backupable_db_options_get_share_files_with_checksum_naming (
    rocksdb_backupable_db_options_t* options )

FUNCTION: void rocksdb_backupable_db_options_destroy (
    rocksdb_backupable_db_options_t* options )


! Checkpoint
FUNCTION: rocksdb_checkpoint_t*
rocksdb_checkpoint_object_create ( rocksdb_t* db, char** errptr )

FUNCTION: void rocksdb_checkpoint_create (
    rocksdb_checkpoint_t* checkpoint, char* checkpoint_dir,
    uint64_t log_size_for_flush, char** errptr )

FUNCTION: void rocksdb_checkpoint_object_destroy (
    rocksdb_checkpoint_t* checkpoint )

FUNCTION: rocksdb_t* rocksdb_open_column_families (
    rocksdb_options_t* options, c-string name, int num_column_families,
    char** column_family_names,
    rocksdb_options_t** column_family_options,
    rocksdb_column_family_handle_t** column_family_handles, char** errptr )

FUNCTION: rocksdb_t* rocksdb_open_column_families_with_ttl (
    rocksdb_options_t* options, char* name, int num_column_families,
    char** column_family_names,
    rocksdb_options_t** column_family_options,
    rocksdb_column_family_handle_t** column_family_handles, int* ttls,
    char** errptr )

FUNCTION: rocksdb_t*
rocksdb_open_for_read_only_column_families (
    rocksdb_options_t* options, c-string name, int num_column_families,
    char** column_family_names,
    rocksdb_options_t** column_family_options,
    rocksdb_column_family_handle_t** column_family_handles,
    uchar error_if_log_file_exist, char** errptr )

FUNCTION: rocksdb_t* rocksdb_open_as_secondary_column_families (
    rocksdb_options_t* options, c-string name,
    char* secondary_path, int num_column_families,
    char** column_family_names,
    rocksdb_options_t** column_family_options,
    rocksdb_column_family_handle_t** colummn_family_handles, char** errptr )

FUNCTION: char** rocksdb_list_column_families (
    rocksdb_options_t* options, c-string name, size_t* lencf,
    char** errptr )

FUNCTION: void rocksdb_list_column_families_destroy (
    char** list, size_t len )

FUNCTION: rocksdb_column_family_handle_t*
rocksdb_create_column_family ( rocksdb_t* db,
                             rocksdb_options_t* column_family_options,
                             char* column_family_name, char** errptr )

FUNCTION: rocksdb_column_family_handle_t*
rocksdb_create_column_family_with_ttl (
    rocksdb_t* db, rocksdb_options_t* column_family_options,
    char* column_family_name, int ttl, char** errptr )

FUNCTION: void rocksdb_drop_column_family (
    rocksdb_t* db, rocksdb_column_family_handle_t* handle, char** errptr )

FUNCTION: void rocksdb_column_family_handle_destroy (
    rocksdb_column_family_handle_t* dummy )

FUNCTION: void rocksdb_close ( rocksdb_t* db )

FUNCTION: void rocksdb_put (
    rocksdb_t* db, rocksdb_writeoptions_t* options, char* key,
    size_t keylen, char* val, size_t vallen, char** errptr )

FUNCTION: void rocksdb_put_cf (
    rocksdb_t* db, rocksdb_writeoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key,
    size_t keylen, char* val, size_t vallen, char** errptr )

FUNCTION: void rocksdb_delete (
    rocksdb_t* db, rocksdb_writeoptions_t* options, char* key,
    size_t keylen, char** errptr )

FUNCTION: void rocksdb_delete_cf (
    rocksdb_t* db, rocksdb_writeoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key,
    size_t keylen, char** errptr )

FUNCTION: void rocksdb_delete_range_cf (
    rocksdb_t* db, rocksdb_writeoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* start_key,
    size_t start_key_len, char* end_key, size_t end_key_len,
    char** errptr )

FUNCTION: void rocksdb_merge (
    rocksdb_t* db, rocksdb_writeoptions_t* options, char* key,
    size_t keylen, char* val, size_t vallen, char** errptr )

FUNCTION: void rocksdb_merge_cf (
    rocksdb_t* db, rocksdb_writeoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key,
    size_t keylen, char* val, size_t vallen, char** errptr )

FUNCTION: void rocksdb_write (
    rocksdb_t* db, rocksdb_writeoptions_t* options,
    rocksdb_writebatch_t* batch, char** errptr )

! Returns NULL if not found.  A malloc()ed array otherwise.
!   Stores the length of the array in *vallen.
FUNCTION: char* rocksdb_get (
    rocksdb_t* db, rocksdb_readoptions_t* options, char* key,
    size_t keylen, size_t* vallen, char** errptr )

FUNCTION: char* rocksdb_get_cf (
    rocksdb_t* db, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key,
    size_t keylen, size_t* vallen, char** errptr )

!  if values_list[i] == NULL and errs[i] == NULL,
!  then we got status.IsNotFound ( ), which we will not return.
!  all errors except status status.ok ( ) and status.IsNotFound ( ) are returned.
! 
!  errs, values_list and values_list_sizes must be num_keys in length,
!  allocated by the caller.
!  errs is a list of strings as opposed to the conventional one error,
!  where errs[i] is the status for retrieval of keys_list[i].
!  each non-NULL errs entry is a malloc()ed, null terminated string.
!  each non-NULL values_list entry is a malloc()ed array, with
!  the length for each stored in values_list_sizes[i].
FUNCTION: void rocksdb_multi_get (
    rocksdb_t* db, rocksdb_readoptions_t* options, size_t num_keys,
    char* keys_list, size_t* keys_list_sizes,
    char** values_list, size_t* values_list_sizes, char** errs )

FUNCTION: void rocksdb_multi_get_cf (
    rocksdb_t* db, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_families,
    size_t num_keys, char* keys_list,
    size_t* keys_list_sizes, char** values_list,
    size_t* values_list_sizes, char** errs )

! The value is only allocated (using malloc) and returned if it is found and
! value_found isn't NULL. In that case the user is responsible for freeing it.
FUNCTION: uchar rocksdb_key_may_exist (
    rocksdb_t* db, rocksdb_readoptions_t* options, char* key,
    size_t key_len, char** value, size_t* val_len, char* timestamp,
    size_t timestamp_len, uchar* value_found )

! The value is only allocated (using malloc) and returned if it is found and
! value_found isn't NULL. In that case the user is responsible for freeing it.
FUNCTION: uchar rocksdb_key_may_exist_cf (
    rocksdb_t* db, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key,
    size_t key_len, char** value, size_t* val_len, char* timestamp,
    size_t timestamp_len, uchar* value_found )

FUNCTION: rocksdb_iterator_t* rocksdb_create_iterator (
    rocksdb_t* db, rocksdb_readoptions_t* options )

FUNCTION: rocksdb_wal_iterator_t* rocksdb_get_updates_since (
        rocksdb_t* db, uint64_t seq_number,
        rocksdb_wal_readoptions_t* options,
        char** errptr
)

FUNCTION: rocksdb_iterator_t* rocksdb_create_iterator_cf (
    rocksdb_t* db, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family )

FUNCTION: void rocksdb_create_iterators (
    rocksdb_t *db, rocksdb_readoptions_t* opts,
    rocksdb_column_family_handle_t** column_families,
    rocksdb_iterator_t** iterators, size_t size, char** errptr )

FUNCTION: rocksdb_snapshot_t* rocksdb_create_snapshot (
    rocksdb_t* db )

FUNCTION: void rocksdb_release_snapshot (
    rocksdb_t* db, rocksdb_snapshot_t* snapshot )

! Returns NULL if property name is unknown.
!   Else returns a pointer to a malloc()-ed null-terminated value.
FUNCTION: char* rocksdb_property_value ( rocksdb_t* db,
                                                        char* propname )
! returns 0 on success, -1 otherwise
FUNCTION: int rocksdb_property_int (
    rocksdb_t* db,
    char* propname, uint64_t *out_val )

! returns 0 on success, -1 otherwise
FUNCTION: int rocksdb_property_int_cf (
    rocksdb_t* db, rocksdb_column_family_handle_t* column_family,
    char* propname, uint64_t *out_val )

FUNCTION: char* rocksdb_property_value_cf (
    rocksdb_t* db, rocksdb_column_family_handle_t* column_family,
    char* propname )

FUNCTION: void rocksdb_approximate_sizes (
    rocksdb_t* db, int num_ranges, char* range_start_key,
    size_t* range_start_key_len, char* range_limit_key,
    size_t* range_limit_key_len, uint64_t* sizes )

FUNCTION: void rocksdb_approximate_sizes_cf (
    rocksdb_t* db, rocksdb_column_family_handle_t* column_family,
    int num_ranges, char* range_start_key,
    size_t* range_start_key_len, char* range_limit_key,
    size_t* range_limit_key_len, uint64_t* sizes )

FUNCTION: void rocksdb_compact_range ( rocksdb_t* db,
                                                      char* start_key,
                                                      size_t start_key_len,
                                                      char* limit_key,
                                                      size_t limit_key_len )

FUNCTION: void rocksdb_compact_range_cf (
    rocksdb_t* db, rocksdb_column_family_handle_t* column_family,
    char* start_key, size_t start_key_len, char* limit_key,
    size_t limit_key_len )

FUNCTION: void rocksdb_compact_range_opt (
    rocksdb_t* db, rocksdb_compactoptions_t* opt, char* start_key,
    size_t start_key_len, char* limit_key, size_t limit_key_len )

FUNCTION: void rocksdb_compact_range_cf_opt (
    rocksdb_t* db, rocksdb_column_family_handle_t* column_family,
    rocksdb_compactoptions_t* opt, char* start_key, size_t start_key_len,
    char* limit_key, size_t limit_key_len )

FUNCTION: void rocksdb_delete_file ( rocksdb_t* db,
                                                    c-string name )

FUNCTION: rocksdb_livefiles_t* rocksdb_livefiles (
    rocksdb_t* db )

FUNCTION: void rocksdb_flush (
    rocksdb_t* db, rocksdb_flushoptions_t* options, char** errptr )

FUNCTION: void rocksdb_flush_cf (
    rocksdb_t* db, rocksdb_flushoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char** errptr )

FUNCTION: void rocksdb_disable_file_deletions ( rocksdb_t* db,
                                                               char** errptr )

FUNCTION: void rocksdb_enable_file_deletions (
    rocksdb_t* db, uchar force, char** errptr )

! Management operations

FUNCTION: void rocksdb_destroy_db (
    rocksdb_options_t* options, c-string name, char** errptr )

FUNCTION: void rocksdb_repair_db (
    rocksdb_options_t* options, c-string name, char** errptr )

! Iterator

FUNCTION: void rocksdb_iter_destroy ( rocksdb_iterator_t* dummy )
FUNCTION: uchar rocksdb_iter_valid (
    rocksdb_iterator_t* dummy )
FUNCTION: void rocksdb_iter_seek_to_first ( rocksdb_iterator_t* dummy )
FUNCTION: void rocksdb_iter_seek_to_last ( rocksdb_iterator_t* dummy )
FUNCTION: void rocksdb_iter_seek ( rocksdb_iterator_t* dummy_ptr,
                                                  char* k, size_t klen )
FUNCTION: void rocksdb_iter_seek_for_prev ( rocksdb_iterator_t* dummy_ptr,
                                                           char* k,
                                                           size_t klen )
FUNCTION: void rocksdb_iter_next ( rocksdb_iterator_t* dummy )
FUNCTION: void rocksdb_iter_prev ( rocksdb_iterator_t* dummy )
FUNCTION: char* rocksdb_iter_key (
    rocksdb_iterator_t* dummy_ptr, size_t* klen )
FUNCTION: char* rocksdb_iter_value (
    rocksdb_iterator_t* dummy_ptr, size_t* vlen )
FUNCTION: void rocksdb_iter_get_error (
    rocksdb_iterator_t* dummy_ptr, char** errptr )

FUNCTION: void rocksdb_wal_iter_next ( rocksdb_wal_iterator_t* iter )
FUNCTION: uchar rocksdb_wal_iter_valid (
        rocksdb_wal_iterator_t* dummy )
FUNCTION: void rocksdb_wal_iter_status ( rocksdb_wal_iterator_t* iter, char** errptr )
FUNCTION: rocksdb_writebatch_t* rocksdb_wal_iter_get_batch ( rocksdb_wal_iterator_t* iter, uint64_t* seq )
FUNCTION: uint64_t rocksdb_get_latest_sequence_number ( rocksdb_t *db )
FUNCTION: void rocksdb_wal_iter_destroy ( rocksdb_wal_iterator_t* iter )

! Write batch

FUNCTION: rocksdb_writebatch_t* rocksdb_writebatch_create ( )
FUNCTION: rocksdb_writebatch_t* rocksdb_writebatch_create_from (
    char* rep, size_t size )
FUNCTION: void rocksdb_writebatch_destroy (
    rocksdb_writebatch_t* dummy )
FUNCTION: void rocksdb_writebatch_clear ( rocksdb_writebatch_t* dummy )
FUNCTION: int rocksdb_writebatch_count ( rocksdb_writebatch_t* dummy )
FUNCTION: void rocksdb_writebatch_put ( rocksdb_writebatch_t* dummy_ptr,
                                                       char* key,
                                                       size_t klen,
                                                       char* val,
                                                       size_t vlen )
FUNCTION: void rocksdb_writebatch_put_cf (
    rocksdb_writebatch_t* dummy_ptr, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen, char* val, size_t vlen )
FUNCTION: void rocksdb_writebatch_putv (
    rocksdb_writebatch_t* b, int num_keys, char* keys_list,
    size_t* keys_list_sizes, int num_values,
    char* values_list, size_t* values_list_sizes )
FUNCTION: void rocksdb_writebatch_putv_cf (
    rocksdb_writebatch_t* b, rocksdb_column_family_handle_t* column_family,
    int num_keys, char* keys_list, size_t* keys_list_sizes,
    int num_values, char* values_list,
    size_t* values_list_sizes )
FUNCTION: void rocksdb_writebatch_merge ( rocksdb_writebatch_t* dummy_ptr,
                                                         char* key,
                                                         size_t klen,
                                                         char* val,
                                                         size_t vlen )
FUNCTION: void rocksdb_writebatch_merge_cf (
    rocksdb_writebatch_t* dummy_ptr, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen, char* val, size_t vlen )
FUNCTION: void rocksdb_writebatch_mergev (
    rocksdb_writebatch_t* b, int num_keys, char* keys_list,
    size_t* keys_list_sizes, int num_values,
    char* values_list, size_t* values_list_sizes )
FUNCTION: void rocksdb_writebatch_mergev_cf (
    rocksdb_writebatch_t* b, rocksdb_column_family_handle_t* column_family,
    int num_keys, char* keys_list, size_t* keys_list_sizes,
    int num_values, char* values_list,
    size_t* values_list_sizes )
FUNCTION: void rocksdb_writebatch_delete ( rocksdb_writebatch_t* dummy_ptr,
                                                          char* key,
                                                          size_t klen )
FUNCTION: void rocksdb_writebatch_delete_cf (
    rocksdb_writebatch_t* dummy_ptr, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen )
FUNCTION: void rocksdb_writebatch_singledelete_cf (
    rocksdb_writebatch_t* b, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen )
FUNCTION: void rocksdb_writebatch_deletev (
    rocksdb_writebatch_t* b, int num_keys, char* keys_list,
    size_t* keys_list_sizes )
FUNCTION: void rocksdb_writebatch_deletev_cf (
    rocksdb_writebatch_t* b, rocksdb_column_family_handle_t* column_family,
    int num_keys, char* keys_list, size_t* keys_list_sizes )
FUNCTION: void rocksdb_writebatch_delete_range (
    rocksdb_writebatch_t* b, char* start_key, size_t start_key_len,
    char* end_key, size_t end_key_len )
FUNCTION: void rocksdb_writebatch_delete_range_cf (
    rocksdb_writebatch_t* b, rocksdb_column_family_handle_t* column_family,
    char* start_key, size_t start_key_len, char* end_key,
    size_t end_key_len )
FUNCTION: void rocksdb_writebatch_delete_rangev (
    rocksdb_writebatch_t* b, int num_keys, char* start_keys_list,
    size_t* start_keys_list_sizes, char* end_keys_list,
    size_t* end_keys_list_sizes )
FUNCTION: void rocksdb_writebatch_delete_rangev_cf (
    rocksdb_writebatch_t* b, rocksdb_column_family_handle_t* column_family,
    int num_keys, char* start_keys_list,
    size_t* start_keys_list_sizes, char* end_keys_list,
    size_t* end_keys_list_sizes )
FUNCTION: void rocksdb_writebatch_put_log_data (
    rocksdb_writebatch_t* dummy_ptr, char* blob, size_t len )
FUNCTION: void rocksdb_writebatch_iterate (
    rocksdb_writebatch_t* dummy_ptr,
    void* state,
    void* fn1, ! void (*put)(void* dummy_ptr, char* k, size_t klen, char* v, size_t vlen),
    void* fn2 ! void (*deleted)(void* dummy_ptr, char* k, size_t klen)
)
FUNCTION: char* rocksdb_writebatch_data (
    rocksdb_writebatch_t* dummy_ptr, size_t* size )
FUNCTION: void rocksdb_writebatch_set_save_point (
    rocksdb_writebatch_t* dummy )
FUNCTION: void rocksdb_writebatch_rollback_to_save_point (
    rocksdb_writebatch_t* dummy_ptr, char** errptr )
FUNCTION: void rocksdb_writebatch_pop_save_point (
    rocksdb_writebatch_t* dummy_ptr, char** errptr )

! Write batch with index

FUNCTION: rocksdb_writebatch_wi_t* rocksdb_writebatch_wi_create (
                                                       size_t reserved_bytes,
                                                       uchar overwrite_keys )
FUNCTION: rocksdb_writebatch_wi_t* rocksdb_writebatch_wi_create_from (
    char* rep, size_t size )
FUNCTION: void rocksdb_writebatch_wi_destroy (
    rocksdb_writebatch_wi_t* dummy )
FUNCTION: void rocksdb_writebatch_wi_clear ( rocksdb_writebatch_wi_t* dummy )
FUNCTION: int rocksdb_writebatch_wi_count ( rocksdb_writebatch_wi_t* b )
FUNCTION: void rocksdb_writebatch_wi_put ( rocksdb_writebatch_wi_t* dummy_ptr,
                                                       char* key,
                                                       size_t klen,
                                                       char* val,
                                                       size_t vlen )
FUNCTION: void rocksdb_writebatch_wi_put_cf (
    rocksdb_writebatch_wi_t* dummy_ptr, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen, char* val, size_t vlen )
FUNCTION: void rocksdb_writebatch_wi_putv (
    rocksdb_writebatch_wi_t* b, int num_keys, char* keys_list,
    size_t* keys_list_sizes, int num_values,
    char* values_list, size_t* values_list_sizes )
FUNCTION: void rocksdb_writebatch_wi_putv_cf (
    rocksdb_writebatch_wi_t* b, rocksdb_column_family_handle_t* column_family,
    int num_keys, char* keys_list, size_t* keys_list_sizes,
    int num_values, char* values_list,
    size_t* values_list_sizes )
FUNCTION: void rocksdb_writebatch_wi_merge ( rocksdb_writebatch_wi_t* dummy_ptr,
                                                         char* key,
                                                         size_t klen,
                                                         char* val,
                                                         size_t vlen )
FUNCTION: void rocksdb_writebatch_wi_merge_cf (
    rocksdb_writebatch_wi_t* dummy_ptr, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen, char* val, size_t vlen )
FUNCTION: void rocksdb_writebatch_wi_mergev (
    rocksdb_writebatch_wi_t* b, int num_keys, char* keys_list,
    size_t* keys_list_sizes, int num_values,
    char* values_list, size_t* values_list_sizes )
FUNCTION: void rocksdb_writebatch_wi_mergev_cf (
    rocksdb_writebatch_wi_t* b, rocksdb_column_family_handle_t* column_family,
    int num_keys, char* keys_list, size_t* keys_list_sizes,
    int num_values, char* values_list,
    size_t* values_list_sizes )
FUNCTION: void rocksdb_writebatch_wi_delete ( rocksdb_writebatch_wi_t* dummy_ptr,
                                                          char* key,
                                                          size_t klen )
FUNCTION: void rocksdb_writebatch_wi_singledelete (
    rocksdb_writebatch_wi_t* dummy_otr,  char* key, size_t klen )
FUNCTION: void rocksdb_writebatch_wi_delete_cf (
    rocksdb_writebatch_wi_t* dummy_ptr, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen )
FUNCTION: void rocksdb_writebatch_wi_singledelete_cf (
    rocksdb_writebatch_wi_t* dummy_ptr, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen )
FUNCTION: void rocksdb_writebatch_wi_deletev (
    rocksdb_writebatch_wi_t* b, int num_keys, char* keys_list,
    size_t* keys_list_sizes )
FUNCTION: void rocksdb_writebatch_wi_deletev_cf (
    rocksdb_writebatch_wi_t* b, rocksdb_column_family_handle_t* column_family,
    int num_keys, char* keys_list, size_t* keys_list_sizes )

! DO NOT USE - rocksdb_writebatch_wi_delete_range is not yet supported
FUNCTION: void rocksdb_writebatch_wi_delete_range (
    rocksdb_writebatch_wi_t* b, char* start_key, size_t start_key_len,
    char* end_key, size_t end_key_len )
! DO NOT USE - rocksdb_writebatch_wi_delete_range_cf is not yet supported
FUNCTION: void rocksdb_writebatch_wi_delete_range_cf (
    rocksdb_writebatch_wi_t* b, rocksdb_column_family_handle_t* column_family,
    char* start_key, size_t start_key_len, char* end_key,
    size_t end_key_len )
! DO NOT USE - rocksdb_writebatch_wi_delete_rangev is not yet supported
FUNCTION: void rocksdb_writebatch_wi_delete_rangev (
    rocksdb_writebatch_wi_t* b, int num_keys, char* start_keys_list,
    size_t* start_keys_list_sizes, char* end_keys_list,
    size_t* end_keys_list_sizes )
! DO NOT USE - rocksdb_writebatch_wi_delete_rangev_cf is not yet supported
FUNCTION: void rocksdb_writebatch_wi_delete_rangev_cf (
    rocksdb_writebatch_wi_t* b, rocksdb_column_family_handle_t* column_family,
    int num_keys, char* start_keys_list,
    size_t* start_keys_list_sizes, char* end_keys_list,
    size_t* end_keys_list_sizes )
FUNCTION: void rocksdb_writebatch_wi_put_log_data (
    rocksdb_writebatch_wi_t* dummy_ptr, char* blob, size_t len )
FUNCTION: void rocksdb_writebatch_wi_iterate (
    rocksdb_writebatch_wi_t* b,
    void* state,
    void* fn1, ! void (*put)(void* dummy_ptr, char* k, size_t klen, char* v, size_t vlen),
    void* fn2 ! void (*deleted)(void* dummy_ptr, char* k, size_t klen)
)
FUNCTION: char* rocksdb_writebatch_wi_data (
    rocksdb_writebatch_wi_t* b,
    size_t* size )
FUNCTION: void rocksdb_writebatch_wi_set_save_point (
    rocksdb_writebatch_wi_t* dummy )
FUNCTION: void rocksdb_writebatch_wi_rollback_to_save_point (
    rocksdb_writebatch_wi_t* dummy_ptr, char** errptr )
FUNCTION: char* rocksdb_writebatch_wi_get_from_batch (
    rocksdb_writebatch_wi_t* wbwi,
    rocksdb_options_t* options,
    char* key, size_t keylen,
    size_t* vallen,
    char** errptr )
FUNCTION: char* rocksdb_writebatch_wi_get_from_batch_cf (
    rocksdb_writebatch_wi_t* wbwi,
    rocksdb_options_t* options,
    rocksdb_column_family_handle_t* column_family,
    char* key, size_t keylen,
    size_t* vallen,
    char** errptr )
FUNCTION: char* rocksdb_writebatch_wi_get_from_batch_and_db (
    rocksdb_writebatch_wi_t* wbwi,
    rocksdb_t* db,
    rocksdb_readoptions_t* options,
    char* key, size_t keylen,
    size_t* vallen,
    char** errptr )
FUNCTION: char* rocksdb_writebatch_wi_get_from_batch_and_db_cf (
    rocksdb_writebatch_wi_t* wbwi,
    rocksdb_t* db,
    rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family,
    char* key, size_t keylen,
    size_t* vallen,
    char** errptr )
FUNCTION: void rocksdb_write_writebatch_wi (
    rocksdb_t* db,
    rocksdb_writeoptions_t* options,
    rocksdb_writebatch_wi_t* wbwi,
    char** errptr )
FUNCTION: rocksdb_iterator_t* rocksdb_writebatch_wi_create_iterator_with_base (
    rocksdb_writebatch_wi_t* wbwi,
    rocksdb_iterator_t* base_iterator )
FUNCTION: rocksdb_iterator_t* rocksdb_writebatch_wi_create_iterator_with_base_cf (
    rocksdb_writebatch_wi_t* wbwi,
    rocksdb_iterator_t* base_iterator,
    rocksdb_column_family_handle_t* cf )

! Block based table options

FUNCTION: rocksdb_block_based_table_options_t*
rocksdb_block_based_options_create ( )
FUNCTION: void rocksdb_block_based_options_destroy (
    rocksdb_block_based_table_options_t* options )
FUNCTION: void rocksdb_block_based_options_set_block_size (
    rocksdb_block_based_table_options_t* options, size_t block_size )
FUNCTION: void
rocksdb_block_based_options_set_block_size_deviation (
    rocksdb_block_based_table_options_t* options, int block_size_deviation )
FUNCTION: void
rocksdb_block_based_options_set_block_restart_interval (
    rocksdb_block_based_table_options_t* options, int block_restart_interval )
FUNCTION: void
rocksdb_block_based_options_set_index_block_restart_interval (
    rocksdb_block_based_table_options_t* options, int index_block_restart_interval )
FUNCTION: void
rocksdb_block_based_options_set_metadata_block_size (
    rocksdb_block_based_table_options_t* options, uint64_t metadata_block_size )
FUNCTION: void
rocksdb_block_based_options_set_partition_filters (
    rocksdb_block_based_table_options_t* options, uchar partition_filters )
FUNCTION: void
rocksdb_block_based_options_set_use_delta_encoding (
    rocksdb_block_based_table_options_t* options, uchar use_delta_encoding )
FUNCTION: void rocksdb_block_based_options_set_filter_policy (
    rocksdb_block_based_table_options_t* options,
    rocksdb_filterpolicy_t* filter_policy )
FUNCTION: void rocksdb_block_based_options_set_no_block_cache (
    rocksdb_block_based_table_options_t* options, uchar no_block_cache )
FUNCTION: void rocksdb_block_based_options_set_block_cache (
    rocksdb_block_based_table_options_t* options, rocksdb_cache_t* block_cache )
FUNCTION: void
rocksdb_block_based_options_set_block_cache_compressed (
    rocksdb_block_based_table_options_t* options,
    rocksdb_cache_t* block_cache_compressed )
FUNCTION: void
rocksdb_block_based_options_set_whole_key_filtering (
    rocksdb_block_based_table_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: void rocksdb_block_based_options_set_format_version (
    rocksdb_block_based_table_options_t* dummy_ptr, int dummy_int )

ENUM: rocksdb_block_search_enum < uchar
  { rocksdb_block_based_table_index_type_binary_search 0 }
  { rocksdb_block_based_table_index_type_hash_search 1 }
  { rocksdb_block_based_table_index_type_two_level_index_search 2 } ;

FUNCTION: void rocksdb_block_based_options_set_index_type (
    rocksdb_block_based_table_options_t* dummy_ptr, int dummy_int )
FUNCTION: void
rocksdb_block_based_options_set_hash_index_allow_collision (
    rocksdb_block_based_table_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: void
rocksdb_block_based_options_set_cache_index_and_filter_blocks (
    rocksdb_block_based_table_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: void
rocksdb_block_based_options_set_cache_index_and_filter_blocks_with_high_priority (
    rocksdb_block_based_table_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: void
rocksdb_block_based_options_set_pin_l0_filter_and_index_blocks_in_cache (
    rocksdb_block_based_table_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: void
rocksdb_block_based_options_set_pin_top_level_index_and_filter (
    rocksdb_block_based_table_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: void rocksdb_options_set_block_based_table_factory (
    rocksdb_options_t* opt, rocksdb_block_based_table_options_t* table_options )

! Cuckoo table options

FUNCTION: rocksdb_cuckoo_table_options_t*
rocksdb_cuckoo_options_create ( )
FUNCTION: void rocksdb_cuckoo_options_destroy (
    rocksdb_cuckoo_table_options_t* options )
FUNCTION: void rocksdb_cuckoo_options_set_hash_ratio (
    rocksdb_cuckoo_table_options_t* options, double v )
FUNCTION: void rocksdb_cuckoo_options_set_max_search_depth (
    rocksdb_cuckoo_table_options_t* options, uint32_t v )
FUNCTION: void rocksdb_cuckoo_options_set_cuckoo_block_size (
    rocksdb_cuckoo_table_options_t* options, uint32_t v )
FUNCTION: void
rocksdb_cuckoo_options_set_identity_as_first_hash (
    rocksdb_cuckoo_table_options_t* options, uchar v )
FUNCTION: void rocksdb_cuckoo_options_set_use_module_hash (
    rocksdb_cuckoo_table_options_t* options, uchar v )
FUNCTION: void rocksdb_options_set_cuckoo_table_factory (
    rocksdb_options_t* opt, rocksdb_cuckoo_table_options_t* table_options )

! Options
FUNCTION: void rocksdb_set_options (
    rocksdb_t* db, int count, char* keys[], char* values[], char** errptr )

FUNCTION: void rocksdb_set_options_cf (
    rocksdb_t* db, rocksdb_column_family_handle_t* handle, int count, char* keys[], char* values[], char** errptr )

FUNCTION: rocksdb_options_t* rocksdb_options_create ( )
FUNCTION: void rocksdb_options_destroy ( rocksdb_options_t* dummy )
FUNCTION: rocksdb_options_t* rocksdb_options_create_copy (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_increase_parallelism (
    rocksdb_options_t* opt, int total_threads )
FUNCTION: void rocksdb_options_optimize_for_point_lookup (
    rocksdb_options_t* opt, uint64_t block_cache_size_mb )
FUNCTION: void rocksdb_options_optimize_level_style_compaction (
    rocksdb_options_t* opt, uint64_t memtable_memory_budget )
FUNCTION: void
rocksdb_options_optimize_universal_style_compaction (
    rocksdb_options_t* opt, uint64_t memtable_memory_budget )
FUNCTION: void
rocksdb_options_set_allow_ingest_behind ( rocksdb_options_t* dummy_ptr,
                                                   uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_allow_ingest_behind ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_compaction_filter (
    rocksdb_options_t* dummy_ptr, rocksdb_compactionfilter_t* dummy )
FUNCTION: void rocksdb_options_set_compaction_filter_factory (
    rocksdb_options_t* dummy_ptr, rocksdb_compactionfilterfactory_t* dummy )
FUNCTION: void rocksdb_options_compaction_readahead_size (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
    rocksdb_options_get_compaction_readahead_size ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_comparator (
    rocksdb_options_t* dummy_ptr, rocksdb_comparator_t* dummy )
FUNCTION: void rocksdb_options_set_merge_operator (
    rocksdb_options_t* dummy_ptr, rocksdb_mergeoperator_t* dummy )
FUNCTION: void rocksdb_options_set_uint64add_merge_operator (
    rocksdb_options_t* dummy )
FUNCTION: void rocksdb_options_set_compression_per_level (
    rocksdb_options_t* opt, int* level_values, size_t num_levels )
FUNCTION: void rocksdb_options_set_create_if_missing (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_options_get_create_if_missing (
    rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_create_missing_column_families ( rocksdb_options_t* dummy_ptr,
                                                   uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_create_missing_column_families ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_error_if_exists (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_options_get_error_if_exists (
    rocksdb_options_t* options )

FUNCTION: void rocksdb_options_set_paranoid_checks (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_options_get_paranoid_checks (
    rocksdb_options_t* options )

FUNCTION: void rocksdb_options_set_db_paths ( rocksdb_options_t* dummy_ptr,
                                                             rocksdb_dbpath_t** path_values,
                                                             size_t num_paths )
FUNCTION: void rocksdb_options_set_env ( rocksdb_options_t* dummy_ptr,
                                                        rocksdb_env_t* dummy )
FUNCTION: void rocksdb_options_set_info_log ( rocksdb_options_t* dummy_ptr,
                                                             rocksdb_logger_t* dummy )
FUNCTION: void rocksdb_options_set_info_log_level (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_info_log_level (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_write_buffer_size (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_write_buffer_size ( rocksdb_options_t* options )

FUNCTION: void rocksdb_options_set_db_write_buffer_size (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_db_write_buffer_size ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_open_files (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_max_open_files (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_file_opening_threads (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_max_file_opening_threads (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_total_wal_size (
    rocksdb_options_t* opt, uint64_t n )
FUNCTION: uint64_t
rocksdb_options_get_max_total_wal_size ( rocksdb_options_t* opt )
FUNCTION: void rocksdb_options_set_compression_options (
    rocksdb_options_t* dummy_ptr, int i1, int i2, int i3, int i4 )
FUNCTION: void
rocksdb_options_set_compression_options_zstd_max_train_bytes ( rocksdb_options_t* options,
                                                             int dummy )
FUNCTION: void
rocksdb_options_set_bottommost_compression_options ( rocksdb_options_t* options, int dummy1, int dummy2,
                                                   int dummy3, int dummy4, uchar dummy5 )
FUNCTION: void
rocksdb_options_set_bottommost_compression_options_zstd_max_train_bytes (
    rocksdb_options_t* options, int dummy1, uchar dummy2 )
FUNCTION: void rocksdb_options_set_prefix_extractor (
    rocksdb_options_t* dummy_ptr, rocksdb_slicetransform_t* dummy )
FUNCTION: void rocksdb_options_set_num_levels (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_num_levels (
    rocksdb_options_t* options )

FUNCTION: void
rocksdb_options_set_level0_file_num_compaction_trigger ( rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_options_get_level0_file_num_compaction_trigger ( rocksdb_options_t* options )

FUNCTION: void
rocksdb_options_set_level0_slowdown_writes_trigger ( rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_options_get_level0_slowdown_writes_trigger ( rocksdb_options_t* options )

FUNCTION: void rocksdb_options_set_level0_stop_writes_trigger (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_level0_stop_writes_trigger (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_mem_compaction_level (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: void rocksdb_options_set_target_file_size_base (
    rocksdb_options_t* dummy_ptr, uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_target_file_size_base ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_target_file_size_multiplier (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_target_file_size_multiplier (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_bytes_for_level_base (
    rocksdb_options_t* dummy_ptr, uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_max_bytes_for_level_base ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_level_compaction_dynamic_level_bytes ( rocksdb_options_t* dummy_ptr,
                                                         uchar dummy_uchar )

FUNCTION: uchar
rocksdb_options_get_level_compaction_dynamic_level_bytes ( rocksdb_options_t* options )

FUNCTION: void
rocksdb_options_set_max_bytes_for_level_multiplier ( rocksdb_options_t* dummy_ptr, double d1 )
FUNCTION: void
rocksdb_options_set_max_bytes_for_level_multiplier_additional (
    rocksdb_options_t* dummy_ptr, int* level_values, size_t num_levels )
FUNCTION: void rocksdb_options_enable_statistics (
    rocksdb_options_t* dummy )
FUNCTION: void
rocksdb_options_set_skip_stats_update_on_db_open ( rocksdb_options_t* opt,
                                                 uchar val )
FUNCTION: uchar
rocksdb_options_get_skip_checking_sst_file_sizes_on_db_open (
    rocksdb_options_t* opt )

! returns a pointer to a malloc()-ed, null terminated string
FUNCTION: char* rocksdb_options_statistics_get_string (
    rocksdb_options_t* opt )

FUNCTION: void rocksdb_options_set_max_write_buffer_number (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_max_write_buffer_number (
    rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_min_write_buffer_number_to_merge ( rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_options_get_min_write_buffer_number_to_merge ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_max_write_buffer_number_to_maintain ( rocksdb_options_t* dummy_ptr,
                                                        int i1 )
FUNCTION: int
rocksdb_options_get_max_write_buffer_number_to_maintain ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_max_write_buffer_size_to_maintain ( rocksdb_options_t* options,
                                                      int64_t i1 )
FUNCTION: int64_t
rocksdb_options_get_max_write_buffer_size_to_maintain ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_enable_pipelined_write (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_enable_pipelined_write ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_unordered_write (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_options_get_unordered_write (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_subcompactions (
    rocksdb_options_t* dummy_ptr, uint32_t u32_1 )
FUNCTION: uint32_t
rocksdb_options_get_max_subcompactions ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_background_jobs (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_max_background_jobs (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_background_compactions (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_max_background_compactions (
    rocksdb_options_t* options )

FUNCTION: void rocksdb_options_set_base_background_compactions (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_base_background_compactions (
    rocksdb_options_t* options )

FUNCTION: void rocksdb_options_set_max_background_flushes (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_max_background_flushes (
    rocksdb_options_t* options )

FUNCTION: void rocksdb_options_set_max_log_file_size (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_max_log_file_size ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_log_file_time_to_roll (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_log_file_time_to_roll ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_keep_log_file_num (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_keep_log_file_num ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_recycle_log_file_num (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_recycle_log_file_num ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_soft_rate_limit (
    rocksdb_options_t* dummy_ptr, double d1 )
FUNCTION: double rocksdb_options_get_soft_rate_limit (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_hard_rate_limit (
    rocksdb_options_t* dummy_ptr, double d1 )
FUNCTION: double rocksdb_options_get_hard_rate_limit (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_soft_pending_compaction_bytes_limit (
    rocksdb_options_t* opt, size_t v )
FUNCTION: size_t
rocksdb_options_get_soft_pending_compaction_bytes_limit ( rocksdb_options_t* opt )
FUNCTION: void rocksdb_options_set_hard_pending_compaction_bytes_limit (
    rocksdb_options_t* opt, size_t v )
FUNCTION: size_t
rocksdb_options_get_hard_pending_compaction_bytes_limit ( rocksdb_options_t* opt )
FUNCTION: void
rocksdb_options_set_rate_limit_delay_max_milliseconds ( rocksdb_options_t* dummy_ptr,
                                                      uint u1 )
FUNCTION: uint
rocksdb_options_get_rate_limit_delay_max_milliseconds ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_manifest_file_size (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_max_manifest_file_size ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_table_cache_numshardbits (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_table_cache_numshardbits (
    rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_table_cache_remove_scan_count_limit ( rocksdb_options_t* dummy_ptr,
                                                        int i1 )
FUNCTION: void rocksdb_options_set_arena_block_size (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_arena_block_size ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_use_fsync (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_use_fsync (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_db_log_dir (
    rocksdb_options_t* dummy_ptr, char* dummy )
FUNCTION: void rocksdb_options_set_wal_dir ( rocksdb_options_t* dummy_ptr,
                                                            char* dummy )
FUNCTION: void rocksdb_options_set_WAL_ttl_seconds (
    rocksdb_options_t* dummy_ptr, uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_WAL_ttl_seconds ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_WAL_size_limit_MB (
    rocksdb_options_t* dummy_ptr, uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_WAL_size_limit_MB ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_manifest_preallocation_size (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_manifest_preallocation_size ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_purge_redundant_kvs_while_flush ( rocksdb_options_t* dummy_ptr,
                                                    uchar dummy_uchar )
FUNCTION: void rocksdb_options_set_allow_mmap_reads (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_options_get_allow_mmap_reads (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_allow_mmap_writes (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_options_get_allow_mmap_writes (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_use_direct_reads (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_options_get_use_direct_reads (
    rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_use_direct_io_for_flush_and_compaction ( rocksdb_options_t* dummy_ptr,
                                                           uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_use_direct_io_for_flush_and_compaction ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_is_fd_close_on_exec (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_is_fd_close_on_exec ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_skip_log_error_on_recovery (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_skip_log_error_on_recovery ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_stats_dump_period_sec (
    rocksdb_options_t* dummy_ptr, uint u1 )
FUNCTION: uint
rocksdb_options_get_stats_dump_period_sec ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_stats_persist_period_sec (
    rocksdb_options_t* options, uint u1 )
FUNCTION: uint
rocksdb_options_get_stats_persist_period_sec ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_advise_random_on_open (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_advise_random_on_open ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_access_hint_on_compaction_start ( rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_options_get_access_hint_on_compaction_start ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_use_adaptive_mutex (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_options_get_use_adaptive_mutex (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_bytes_per_sync (
    rocksdb_options_t* dummy_ptr, uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_bytes_per_sync ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_wal_bytes_per_sync (
        rocksdb_options_t* dummy_ptr, uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_wal_bytes_per_sync ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_writable_file_max_buffer_size ( rocksdb_options_t* dummy_ptr, uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_writable_file_max_buffer_size ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_allow_concurrent_memtable_write ( rocksdb_options_t* dummy_ptr,
                                                    uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_allow_concurrent_memtable_write ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_enable_write_thread_adaptive_yield ( rocksdb_options_t* dummy_ptr,
                                                       uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_enable_write_thread_adaptive_yield ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_max_sequential_skip_in_iterations ( rocksdb_options_t* dummy_ptr,
                                                      uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_max_sequential_skip_in_iterations ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_disable_auto_compactions (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: uchar
rocksdb_options_get_disable_auto_compactions ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_optimize_filters_for_hits (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: uchar
rocksdb_options_get_optimize_filters_for_hits ( rocksdb_options_t* options )
FUNCTION: void
rocksdb_options_set_delete_obsolete_files_period_micros ( rocksdb_options_t* dummy_ptr,
                                                        uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_delete_obsolete_files_period_micros ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_prepare_for_bulk_load (
    rocksdb_options_t* dummy )
FUNCTION: void rocksdb_options_set_memtable_vector_rep (
    rocksdb_options_t* dummy )
FUNCTION: void rocksdb_options_set_memtable_prefix_bloom_size_ratio (
    rocksdb_options_t* dummy_ptr, double d1 )
FUNCTION: double
rocksdb_options_get_memtable_prefix_bloom_size_ratio ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_max_compaction_bytes (
    rocksdb_options_t* dummy_ptr, uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_options_get_max_compaction_bytes ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_hash_skip_list_rep (
    rocksdb_options_t* dummy_ptr, size_t s1, int32_t i1, int32_t i2 )
FUNCTION: void rocksdb_options_set_hash_link_list_rep (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: void rocksdb_options_set_plain_table_factory (
    rocksdb_options_t* dummy_ptr, uint32_t ui1, int i1, double d1, size_t dummy_size_t )

FUNCTION: void rocksdb_options_set_min_level_to_compress (
    rocksdb_options_t* opt, int level )

FUNCTION: void rocksdb_options_set_memtable_huge_page_size (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_memtable_huge_page_size ( rocksdb_options_t* options )

FUNCTION: void rocksdb_options_set_max_successive_merges (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_max_successive_merges ( rocksdb_options_t* options )

FUNCTION: void rocksdb_options_set_bloom_locality (
    rocksdb_options_t* dummy_ptr, uint32_t u32_1 )
FUNCTION: uint32_t
rocksdb_options_get_bloom_locality ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_inplace_update_support (
    rocksdb_options_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_options_get_inplace_update_support ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_inplace_update_num_locks (
    rocksdb_options_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_options_get_inplace_update_num_locks ( rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_report_bg_io_stats (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: uchar rocksdb_options_get_report_bg_io_stats (
    rocksdb_options_t* options )

ENUM: rocksdb_recovery_enum < uchar
  { rocksdb_tolerate_corrupted_tail_records_recovery 0 }
  { rocksdb_absolute_consistency_recovery 1 }
  { rocksdb_point_in_time_recovery 2 }
  { rocksdb_skip_any_corrupted_records_recovery 3 } ;

FUNCTION: void rocksdb_options_set_wal_recovery_mode (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_wal_recovery_mode (
    rocksdb_options_t* options )

ENUM: rocksdb_compression_enum < uchar
  { rocksdb_no_compression 0 }
  { rocksdb_snappy_compression 1 }
  { rocksdb_zlib_compression 2 }
  { rocksdb_bz2_compression 3 }
  { rocksdb_lz4_compression 4 }
  { rocksdb_lz4hc_compression 5 }
  { rocksdb_xpress_compression 6 }
  { rocksdb_zstd_compression 7 } ;

FUNCTION: void rocksdb_options_set_compression (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_compression (
    rocksdb_options_t* options )
FUNCTION: void rocksdb_options_set_bottommost_compression (
    rocksdb_options_t* options, int i1 )
FUNCTION: int rocksdb_options_get_bottommost_compression (
    rocksdb_options_t* options )

ENUM: rocksdb_compaction_enum < uchar
  { rocksdb_level_compaction 0 }
  { rocksdb_universal_compaction 1 }
  { rocksdb_fifo_compaction 2 } ;

FUNCTION: void rocksdb_options_set_compaction_style (
    rocksdb_options_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_options_get_compaction_style (
    rocksdb_options_t* options )

FUNCTION: void
rocksdb_options_set_universal_compaction_options (
    rocksdb_options_t* dummy_ptr, rocksdb_universal_compaction_options_t* dummy )
FUNCTION: void rocksdb_options_set_fifo_compaction_options (
    rocksdb_options_t* opt, rocksdb_fifo_compaction_options_t* fifo )
FUNCTION: void rocksdb_options_set_ratelimiter (
    rocksdb_options_t* opt, rocksdb_ratelimiter_t* limiter )
FUNCTION: void rocksdb_options_set_atomic_flush (
    rocksdb_options_t* opt, uchar u1 )
FUNCTION: uchar rocksdb_options_get_atomic_flush (
    rocksdb_options_t* opt )

FUNCTION: void rocksdb_options_set_row_cache (
    rocksdb_options_t* opt, rocksdb_cache_t* cache
)

! RateLimiter
FUNCTION: rocksdb_ratelimiter_t* rocksdb_ratelimiter_create (
    int64_t rate_bytes_per_sec, int64_t refill_period_us, int32_t fairness )
FUNCTION: void rocksdb_ratelimiter_destroy ( rocksdb_ratelimiter_t* dummy )

! PerfContext
ENUM: rocksdb_perf_context_enum < uchar
  { rocksdb_uninitialized 0 }
  { rocksdb_disable 1 }
  { rocksdb_enable_count 2 }
  { rocksdb_enable_time_except_for_mutex 3 }
  { rocksdb_enable_time 4 }
  { rocksdb_out_of_bounds 5 } ;

ENUM: rocksdb_options_enum < uchar
  rocksdb_user_key_comparison_coun
  rocksdb_block_cache_hit_count
  rocksdb_block_read_count
  rocksdb_block_read_byte
  rocksdb_block_read_time
  rocksdb_block_checksum_time
  rocksdb_block_decompress_time
  rocksdb_get_read_bytes
  rocksdb_multiget_read_bytes
  rocksdb_iter_read_bytes
  rocksdb_internal_key_skipped_count
  rocksdb_internal_delete_skipped_count
  rocksdb_internal_recent_skipped_count
  rocksdb_internal_merge_count
  rocksdb_get_snapshot_time
  rocksdb_get_from_memtable_time
  rocksdb_get_from_memtable_count
  rocksdb_get_post_process_time
  rocksdb_get_from_output_files_time
  rocksdb_seek_on_memtable_time
  rocksdb_seek_on_memtable_count
  rocksdb_next_on_memtable_count
  rocksdb_prev_on_memtable_count
  rocksdb_seek_child_seek_time
  rocksdb_seek_child_seek_count
  rocksdb_seek_min_heap_time
  rocksdb_seek_max_heap_time
  rocksdb_seek_internal_seek_time
  rocksdb_find_next_user_entry_time
  rocksdb_write_wal_time
  rocksdb_write_memtable_time
  rocksdb_write_delay_time
  rocksdb_write_pre_and_post_process_time
  rocksdb_db_mutex_lock_nanos
  rocksdb_db_condition_wait_nanos
  rocksdb_merge_operator_time_nanos
  rocksdb_read_index_block_nanos
  rocksdb_read_filter_block_nanos
  rocksdb_new_table_block_iter_nanos
  rocksdb_new_table_iterator_nanos
  rocksdb_block_seek_nanos
  rocksdb_find_table_nanos
  rocksdb_bloom_memtable_hit_count
  rocksdb_bloom_memtable_miss_count
  rocksdb_bloom_sst_hit_count
  rocksdb_bloom_sst_miss_count
  rocksdb_key_lock_wait_time
  rocksdb_key_lock_wait_count
  rocksdb_env_new_sequential_file_nanos
  rocksdb_env_new_random_access_file_nanos
  rocksdb_env_new_writable_file_nanos
  rocksdb_env_reuse_writable_file_nanos
  rocksdb_env_new_random_rw_file_nanos
  rocksdb_env_new_directory_nanos
  rocksdb_env_file_exists_nanos
  rocksdb_env_get_children_nanos
  rocksdb_env_get_children_file_attributes_nanos
  rocksdb_env_delete_file_nanos
  rocksdb_env_create_dir_nanos
  rocksdb_env_create_dir_if_missing_nanos
  rocksdb_env_delete_dir_nanos
  rocksdb_env_get_file_size_nanos
  rocksdb_env_get_file_modification_time_nanos
  rocksdb_env_rename_file_nanos
  rocksdb_env_link_file_nanos
  rocksdb_env_lock_file_nanos
  rocksdb_env_unlock_file_nanos
  rocksdb_env_new_logger_nanos
  { rocksdb_total_metric_count 68 } ;

FUNCTION: void rocksdb_set_perf_level ( int i1 )
FUNCTION: rocksdb_perfcontext_t* rocksdb_perfcontext_create ( )
FUNCTION: void rocksdb_perfcontext_reset (
    rocksdb_perfcontext_t* context )
FUNCTION: char* rocksdb_perfcontext_report (
    rocksdb_perfcontext_t* context, uchar exclude_zero_counters )
FUNCTION: uint64_t rocksdb_perfcontext_metric (
    rocksdb_perfcontext_t* context, int metric )
FUNCTION: void rocksdb_perfcontext_destroy (
    rocksdb_perfcontext_t* context )

! Compaction Filter

FUNCTION: rocksdb_compactionfilter_t*
rocksdb_compactionfilter_create (
    void* state,
    void* fn1,  ! void (*destructor)(void*),
    void* fn2, ! uchar (*filter)(void* dummy_ptr, int level, char* key,
                !            size_t key_length, char* existing_value,
                !            size_t value_length, char** new_value,
                !            size_t* new_value_length,
                !            uchar* value_changed),
    void* fn3 ! char* (*name)(void*)
)
FUNCTION: void rocksdb_compactionfilter_set_ignore_snapshots (
    rocksdb_compactionfilter_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: void rocksdb_compactionfilter_destroy (
    rocksdb_compactionfilter_t* dummy )

! Compaction Filter Context

FUNCTION: uchar
rocksdb_compactionfiltercontext_is_full_compaction (
    rocksdb_compactionfiltercontext_t* context )

FUNCTION: uchar
rocksdb_compactionfiltercontext_is_manual_compaction (
    rocksdb_compactionfiltercontext_t* context )

! Compaction Filter Factory

FUNCTION: rocksdb_compactionfilterfactory_t*
rocksdb_compactionfilterfactory_create (
    void* state,
    void* fn1, ! void (*destructor)(void*),
    void* fn2, ! rocksdb_compactionfilter_t* (*create_compaction_filter)(
        ! void* dummy_ptr, rocksdb_compactionfiltercontext_t* context),
    void* fn3 ! char* (*name)(void*)
)
FUNCTION: void rocksdb_compactionfilterfactory_destroy (
    rocksdb_compactionfilterfactory_t* dummy )

! Comparator

FUNCTION: rocksdb_comparator_t* rocksdb_comparator_create (
    void* state,
    void* fn1, ! void (*destructor)(void*),
    void* fn2, ! int (*compare)(void* dummy_ptr, char* a, size_t alen, char* b, size_t blen),
    void* fn3, ! char* (*name)(void*)
)
FUNCTION: void rocksdb_comparator_destroy (
    rocksdb_comparator_t* dummy )

! Filter policy

FUNCTION: rocksdb_filterpolicy_t* rocksdb_filterpolicy_create (
    void* state,
    void* fn1, ! void (*destructor)(void*),
    void* fn2, ! char* (*create_filter)(void* dummy_ptr, char* key_array,
    !                       size_t* key_length_array, int num_keys,
    !                       size_t* filter_length),
    void* fn3, ! uchar (*key_may_match)(void* dummy_ptr, char* key, size_t length,
               !                    char* filter, size_t filter_length),
    void* fn4, ! void (*delete_filter)(void* dummy_ptr, char* filter, size_t filter_length),
    void* fn5 ! char* (*name)(void*)
)
FUNCTION: void rocksdb_filterpolicy_destroy (
    rocksdb_filterpolicy_t* dummy )

FUNCTION: rocksdb_filterpolicy_t*
rocksdb_filterpolicy_create_bloom ( int bits_per_key )
FUNCTION: rocksdb_filterpolicy_t*
rocksdb_filterpolicy_create_bloom_full ( int bits_per_key )

! Merge Operator

FUNCTION: rocksdb_mergeoperator_t*
rocksdb_mergeoperator_create (
    void* state,
    void* fn1, ! void (*destructor)(void*),
    void* fn2, ! char* (*full_merge)(void* dummy_ptr, char* key, size_t key_length,
    !                     char* existing_value,
    !                     size_t existing_value_length,
    !                     char* operands_list,
    !                     size_t* operands_list_length, int num_operands,
    !                     uchar* success, size_t* new_value_length),
    void* fn3, ! char* (*partial_merge)(void* dummy_ptr, char* key, size_t key_length,
    !                        char* operands_list,
    !                        size_t* operands_list_length, int num_operands,
    !                        uchar* success, size_t* new_value_length),
    void* fn4, ! void (*delete_value)(void* dummy_ptr, char* value, size_t value_length),
    void* fn5 ! char* (*name)(void*)
)
FUNCTION: void rocksdb_mergeoperator_destroy (
    rocksdb_mergeoperator_t* dummy )

! Read options

FUNCTION: rocksdb_readoptions_t* rocksdb_readoptions_create ( )
FUNCTION: void rocksdb_readoptions_destroy (
    rocksdb_readoptions_t* dummy )
FUNCTION: void rocksdb_readoptions_set_verify_checksums (
    rocksdb_readoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_readoptions_get_verify_checksums ( rocksdb_readoptions_t* readoptions )
FUNCTION: void rocksdb_readoptions_set_fill_cache (
    rocksdb_readoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_readoptions_get_fill_cache (
    rocksdb_readoptions_t* readoptions )
FUNCTION: void rocksdb_readoptions_set_snapshot (
    rocksdb_readoptions_t* dummy_ptr, rocksdb_snapshot_t* dummy )
FUNCTION: void rocksdb_readoptions_set_iterate_upper_bound (
    rocksdb_readoptions_t* dummy_ptr, char* key, size_t keylen )
FUNCTION: void rocksdb_readoptions_set_iterate_lower_bound (
    rocksdb_readoptions_t* dummy_ptr, char* key, size_t keylen )
FUNCTION: void rocksdb_readoptions_set_read_tier (
    rocksdb_readoptions_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_readoptions_get_read_tier (
    rocksdb_readoptions_t* options )
FUNCTION: void rocksdb_readoptions_set_tailing (
    rocksdb_readoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_readoptions_get_tailing (
    rocksdb_readoptions_t* options )
!  The functionality that this option controlled has been removed.
FUNCTION: void rocksdb_readoptions_set_managed (
    rocksdb_readoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: void rocksdb_readoptions_set_readahead_size (
    rocksdb_readoptions_t* dummy_ptr, size_t dummy_size_t )
FUNCTION: size_t
rocksdb_readoptions_get_readahead_size ( rocksdb_readoptions_t* options )
FUNCTION: void rocksdb_readoptions_set_prefix_same_as_start (
    rocksdb_readoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_readoptions_get_prefix_same_as_start ( rocksdb_readoptions_t* options )
FUNCTION: void rocksdb_readoptions_set_pin_data (
    rocksdb_readoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_readoptions_get_pin_data (
    rocksdb_readoptions_t* options )
FUNCTION: void rocksdb_readoptions_set_total_order_seek (
    rocksdb_readoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_readoptions_get_total_order_seek ( rocksdb_readoptions_t* options )
FUNCTION: void rocksdb_readoptions_set_max_skippable_internal_keys (
    rocksdb_readoptions_t* dummy_ptr, uint64_t u64_1 )
FUNCTION: uint64_t
rocksdb_readoptions_get_max_skippable_internal_keys ( rocksdb_readoptions_t* options )
FUNCTION: void rocksdb_readoptions_set_background_purge_on_iterator_cleanup (
    rocksdb_readoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_readoptions_get_background_purge_on_iterator_cleanup (
    rocksdb_readoptions_t* options )
FUNCTION: void rocksdb_readoptions_set_ignore_range_deletions (
    rocksdb_readoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_readoptions_get_ignore_range_deletions ( rocksdb_readoptions_t* options )

! Write options

FUNCTION: rocksdb_writeoptions_t*
rocksdb_writeoptions_create ( )
FUNCTION: void rocksdb_writeoptions_destroy (
    rocksdb_writeoptions_t* dummy )
FUNCTION: void rocksdb_writeoptions_set_sync (
    rocksdb_writeoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_writeoptions_get_sync (
    rocksdb_writeoptions_t* options )

FUNCTION: void rocksdb_writeoptions_disable_WAL (
    rocksdb_writeoptions_t* opt, int disable )
FUNCTION: uchar rocksdb_writeoptions_get_disable_WAL (
    rocksdb_writeoptions_t* opt )

FUNCTION: void rocksdb_writeoptions_set_ignore_missing_column_families (
    rocksdb_writeoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_writeoptions_get_ignore_missing_column_families (
    rocksdb_writeoptions_t* options )

FUNCTION: void rocksdb_writeoptions_set_no_slowdown (
    rocksdb_writeoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_writeoptions_get_no_slowdown (
    rocksdb_writeoptions_t* options )

FUNCTION: void rocksdb_writeoptions_set_low_pri (
    rocksdb_writeoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_writeoptions_get_low_pri (
    rocksdb_writeoptions_t* options )

FUNCTION: void
rocksdb_writeoptions_set_memtable_insert_hint_per_batch ( rocksdb_writeoptions_t* options,
                                                        uchar u1 )
FUNCTION: uchar
rocksdb_writeoptions_get_memtable_insert_hint_per_batch (
    rocksdb_writeoptions_t* options )

! Compact range options

FUNCTION: rocksdb_compactoptions_t*
rocksdb_compactoptions_create ( )
FUNCTION: void rocksdb_compactoptions_destroy (
    rocksdb_compactoptions_t* dummy )
FUNCTION: void
rocksdb_compactoptions_set_exclusive_manual_compaction (
    rocksdb_compactoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_compactoptions_get_exclusive_manual_compaction (
    rocksdb_compactoptions_t* options )

FUNCTION: void
rocksdb_compactoptions_set_bottommost_level_compaction (
    rocksdb_compactoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_compactoptions_get_bottommost_level_compaction (
    rocksdb_compactoptions_t* options )

FUNCTION: void rocksdb_compactoptions_set_change_level (
    rocksdb_compactoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar
rocksdb_compactoptions_get_change_level ( rocksdb_compactoptions_t* options )
FUNCTION: void rocksdb_compactoptions_set_target_level (
    rocksdb_compactoptions_t* dummy_ptr, int dummy_int )
FUNCTION: int rocksdb_compactoptions_get_target_level (
    rocksdb_compactoptions_t* options )

! Flush options

FUNCTION: rocksdb_flushoptions_t*
rocksdb_flushoptions_create ( )
FUNCTION: void rocksdb_flushoptions_destroy (
    rocksdb_flushoptions_t* dummy )
FUNCTION: void rocksdb_flushoptions_set_wait (
    rocksdb_flushoptions_t* dummy_ptr, uchar dummy_uchar )
FUNCTION: uchar rocksdb_flushoptions_get_wait (
    rocksdb_flushoptions_t* options )

! Cache

FUNCTION: rocksdb_cache_t* rocksdb_cache_create_lru (
    size_t capacity )
FUNCTION: void rocksdb_cache_destroy ( rocksdb_cache_t* cache )
FUNCTION: void rocksdb_cache_set_capacity (
    rocksdb_cache_t* cache, size_t capacity )
FUNCTION: size_t
rocksdb_cache_get_capacity ( rocksdb_cache_t* cache )
FUNCTION: size_t
rocksdb_cache_get_usage ( rocksdb_cache_t* cache )
FUNCTION: size_t
rocksdb_cache_get_pinned_usage ( rocksdb_cache_t* cache )

! DBPath

FUNCTION: rocksdb_dbpath_t* rocksdb_dbpath_create ( char* path, uint64_t target_size )
FUNCTION: void rocksdb_dbpath_destroy ( rocksdb_dbpath_t* dummy )

! Env

FUNCTION: rocksdb_env_t* rocksdb_create_default_env ( )
FUNCTION: rocksdb_env_t* rocksdb_create_mem_env ( )
FUNCTION: void rocksdb_env_set_background_threads (
    rocksdb_env_t* env, int n )
FUNCTION: int rocksdb_env_get_background_threads (
    rocksdb_env_t* env )
FUNCTION: void
rocksdb_env_set_high_priority_background_threads ( rocksdb_env_t* env, int n )
FUNCTION: int rocksdb_env_get_high_priority_background_threads (
    rocksdb_env_t* env )
FUNCTION: void rocksdb_env_set_low_priority_background_threads (
    rocksdb_env_t* env, int n )
FUNCTION: int rocksdb_env_get_low_priority_background_threads (
    rocksdb_env_t* env )
FUNCTION: void
rocksdb_env_set_bottom_priority_background_threads ( rocksdb_env_t* env, int n )
FUNCTION: int
rocksdb_env_get_bottom_priority_background_threads ( rocksdb_env_t* env )
FUNCTION: void rocksdb_env_join_all_threads (
    rocksdb_env_t* env )
FUNCTION: void rocksdb_env_lower_thread_pool_io_priority ( rocksdb_env_t* env )
FUNCTION: void rocksdb_env_lower_high_priority_thread_pool_io_priority ( rocksdb_env_t* env )
FUNCTION: void rocksdb_env_lower_thread_pool_cpu_priority ( rocksdb_env_t* env )
FUNCTION: void rocksdb_env_lower_high_priority_thread_pool_cpu_priority ( rocksdb_env_t* env )

FUNCTION: void rocksdb_env_destroy ( rocksdb_env_t* dummy )

FUNCTION: rocksdb_envoptions_t* rocksdb_envoptions_create ( )
FUNCTION: void rocksdb_envoptions_destroy (
    rocksdb_envoptions_t* opt )

! SstFile

FUNCTION: rocksdb_sstfilewriter_t*
rocksdb_sstfilewriter_create ( rocksdb_envoptions_t* env,
                             rocksdb_options_t* io_options )
FUNCTION: rocksdb_sstfilewriter_t*
rocksdb_sstfilewriter_create_with_comparator (
    rocksdb_envoptions_t* env, rocksdb_options_t* io_options,
    rocksdb_comparator_t* comparator )
FUNCTION: void rocksdb_sstfilewriter_open (
    rocksdb_sstfilewriter_t* writer, c-string name, char** errptr )
FUNCTION: void rocksdb_sstfilewriter_add (
    rocksdb_sstfilewriter_t* writer, char* key, size_t keylen,
    char* val, size_t vallen, char** errptr )
FUNCTION: void rocksdb_sstfilewriter_put (
    rocksdb_sstfilewriter_t* writer, char* key, size_t keylen,
    char* val, size_t vallen, char** errptr )
FUNCTION: void rocksdb_sstfilewriter_merge (
    rocksdb_sstfilewriter_t* writer, char* key, size_t keylen,
    char* val, size_t vallen, char** errptr )
FUNCTION: void rocksdb_sstfilewriter_delete (
    rocksdb_sstfilewriter_t* writer, char* key, size_t keylen,
    char** errptr )
FUNCTION: void rocksdb_sstfilewriter_finish (
    rocksdb_sstfilewriter_t* writer, char** errptr )
FUNCTION: void rocksdb_sstfilewriter_file_size (
    rocksdb_sstfilewriter_t* writer, uint64_t* file_size )
FUNCTION: void rocksdb_sstfilewriter_destroy (
    rocksdb_sstfilewriter_t* writer )

FUNCTION: rocksdb_ingestexternalfileoptions_t*
rocksdb_ingestexternalfileoptions_create ( )
FUNCTION: void
rocksdb_ingestexternalfileoptions_set_move_files (
    rocksdb_ingestexternalfileoptions_t* opt, uchar move_files )
FUNCTION: void
rocksdb_ingestexternalfileoptions_set_snapshot_consistency (
    rocksdb_ingestexternalfileoptions_t* opt,
    uchar snapshot_consistency )
FUNCTION: void
rocksdb_ingestexternalfileoptions_set_allow_global_seqno (
    rocksdb_ingestexternalfileoptions_t* opt, uchar allow_global_seqno )
FUNCTION: void
rocksdb_ingestexternalfileoptions_set_allow_blocking_flush (
    rocksdb_ingestexternalfileoptions_t* opt,
    uchar allow_blocking_flush )
FUNCTION: void
rocksdb_ingestexternalfileoptions_set_ingest_behind (
    rocksdb_ingestexternalfileoptions_t* opt,
    uchar ingest_behind )
FUNCTION: void rocksdb_ingestexternalfileoptions_destroy (
    rocksdb_ingestexternalfileoptions_t* opt )

FUNCTION: void rocksdb_ingest_external_file (
    rocksdb_t* db, char* file_list, size_t list_len,
    rocksdb_ingestexternalfileoptions_t* opt, char** errptr )
FUNCTION: void rocksdb_ingest_external_file_cf (
    rocksdb_t* db, rocksdb_column_family_handle_t* handle,
    char* file_list, size_t list_len,
    rocksdb_ingestexternalfileoptions_t* opt, char** errptr )

FUNCTION: void rocksdb_try_catch_up_with_primary (
    rocksdb_t* db, char** errptr )

! SliceTransform

FUNCTION: rocksdb_slicetransform_t*
rocksdb_slicetransform_create (
    void* state,
    void* fn1 ! void (*destructor)(void*),
    void* fn2 ! char* (*transform)(void* dummy_ptr, char* key, size_t length, size_t* dst_length),
    void* fn3 ! uchar (*in_domain)(void* dummy_ptr, char* key, size_t length),
    void* fn4 ! uchar (*in_range)(void* dummy_ptr, char* key, size_t length),
    void* fn5 ! char* (*name)(void*) )
    )
FUNCTION: rocksdb_slicetransform_t*
    rocksdb_slicetransform_create_fixed_prefix ( size_t dummy_size_t )
FUNCTION: rocksdb_slicetransform_t*
rocksdb_slicetransform_create_noop ( )
FUNCTION: void rocksdb_slicetransform_destroy (
    rocksdb_slicetransform_t* dummy )

! Universal Compaction options

ENUM: rocksdb_universal_compation_options_enum
  { rocksdb_similar_size_compaction_stop_style 0 }
  { rocksdb_total_size_compaction_stop_style 1 } ;


FUNCTION: rocksdb_universal_compaction_options_t*
rocksdb_universal_compaction_options_create ( )
FUNCTION: void
rocksdb_universal_compaction_options_set_size_ratio (
    rocksdb_universal_compaction_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_universal_compaction_options_get_size_ratio (
    rocksdb_universal_compaction_options_t* options )
FUNCTION: void
rocksdb_universal_compaction_options_set_min_merge_width (
    rocksdb_universal_compaction_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_universal_compaction_options_get_min_merge_width (
    rocksdb_universal_compaction_options_t* options )
FUNCTION: void
rocksdb_universal_compaction_options_set_max_merge_width (
    rocksdb_universal_compaction_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_universal_compaction_options_get_max_merge_width (
    rocksdb_universal_compaction_options_t* options )
FUNCTION: void
rocksdb_universal_compaction_options_set_max_size_amplification_percent (
    rocksdb_universal_compaction_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_universal_compaction_options_get_max_size_amplification_percent (
    rocksdb_universal_compaction_options_t* options )
FUNCTION: void
rocksdb_universal_compaction_options_set_compression_size_percent (
    rocksdb_universal_compaction_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_universal_compaction_options_get_compression_size_percent (
    rocksdb_universal_compaction_options_t* options )
FUNCTION: void
rocksdb_universal_compaction_options_set_stop_style (
    rocksdb_universal_compaction_options_t* dummy_ptr, int dummy_int )
FUNCTION: int
rocksdb_universal_compaction_options_get_stop_style (
    rocksdb_universal_compaction_options_t* options )
FUNCTION: void rocksdb_universal_compaction_options_destroy (
    rocksdb_universal_compaction_options_t* dummy )

FUNCTION: rocksdb_fifo_compaction_options_t*
rocksdb_fifo_compaction_options_create ( )
FUNCTION: void
rocksdb_fifo_compaction_options_set_max_table_files_size (
    rocksdb_fifo_compaction_options_t* fifo_opts, uint64_t size )
FUNCTION: uint64_t
rocksdb_fifo_compaction_options_get_max_table_files_size (
    rocksdb_fifo_compaction_options_t* fifo_opts )
FUNCTION: void rocksdb_fifo_compaction_options_destroy (
    rocksdb_fifo_compaction_options_t* fifo_opts )

FUNCTION: int rocksdb_livefiles_count (
    rocksdb_livefiles_t* dummy )
FUNCTION: char* rocksdb_livefiles_name (
    rocksdb_livefiles_t* dummy_ptr, int index )
FUNCTION: int rocksdb_livefiles_level (
    rocksdb_livefiles_t* dummy_ptr, int index )
FUNCTION: size_t
rocksdb_livefiles_size ( rocksdb_livefiles_t* dummy_ptr, int index )
FUNCTION: char* rocksdb_livefiles_smallestkey (
    rocksdb_livefiles_t* dummy_ptr, int index, size_t* size )
FUNCTION: char* rocksdb_livefiles_largestkey (
    rocksdb_livefiles_t* dummy_ptr, int index, size_t* size )
FUNCTION: uint64_t rocksdb_livefiles_entries (
    rocksdb_livefiles_t* dummy_ptr, int index )
FUNCTION: uint64_t rocksdb_livefiles_deletions (
    rocksdb_livefiles_t* dummy_ptr, int index )
FUNCTION: void rocksdb_livefiles_destroy (
    rocksdb_livefiles_t* dummy )

! Utility Helpers

FUNCTION: void rocksdb_get_options_from_string (
    rocksdb_options_t* base_options, char* opts_str,
    rocksdb_options_t* new_options, char** errptr )

FUNCTION: void rocksdb_delete_file_in_range (
    rocksdb_t* db, char* start_key, size_t start_key_len,
    char* limit_key, size_t limit_key_len, char** errptr )

FUNCTION: void rocksdb_delete_file_in_range_cf (
    rocksdb_t* db, rocksdb_column_family_handle_t* column_family,
    char* start_key, size_t start_key_len, char* limit_key,
    size_t limit_key_len, char** errptr )

! Transactions

FUNCTION: rocksdb_column_family_handle_t*
rocksdb_transactiondb_create_column_family (
    rocksdb_transactiondb_t* txn_db,
    rocksdb_options_t* column_family_options,
    char* column_family_name, char** errptr )

FUNCTION: rocksdb_transactiondb_t* rocksdb_transactiondb_open (
    rocksdb_options_t* options,
    rocksdb_transactiondb_options_t* txn_db_options, c-string name,
    char** errptr )

FUNCTION: rocksdb_transactiondb_t* rocksdb_transactiondb_open_column_families (
    rocksdb_options_t* options,
    rocksdb_transactiondb_options_t* txn_db_options, c-string name,
    int num_column_families, char** column_family_names,
    rocksdb_options_t** column_family_options,
    rocksdb_column_family_handle_t** column_family_handles, char** errptr )

FUNCTION: rocksdb_snapshot_t*
rocksdb_transactiondb_create_snapshot ( rocksdb_transactiondb_t* txn_db )

FUNCTION: void rocksdb_transactiondb_release_snapshot (
    rocksdb_transactiondb_t* txn_db, rocksdb_snapshot_t* snapshot )

FUNCTION: rocksdb_transaction_t* rocksdb_transaction_begin (
    rocksdb_transactiondb_t* txn_db,
    rocksdb_writeoptions_t* write_options,
    rocksdb_transaction_options_t* txn_options,
    rocksdb_transaction_t* old_txn )

FUNCTION: void rocksdb_transaction_commit (
    rocksdb_transaction_t* txn, char** errptr )

FUNCTION: void rocksdb_transaction_rollback (
    rocksdb_transaction_t* txn, char** errptr )

FUNCTION: void rocksdb_transaction_set_savepoint (
    rocksdb_transaction_t* txn )

FUNCTION: void rocksdb_transaction_rollback_to_savepoint (
    rocksdb_transaction_t* txn, char** errptr )

FUNCTION: void rocksdb_transaction_destroy (
    rocksdb_transaction_t* txn )

!  This snapshot should be freed using rocksdb_free
FUNCTION: rocksdb_snapshot_t*
rocksdb_transaction_get_snapshot ( rocksdb_transaction_t* txn )

FUNCTION: char* rocksdb_transaction_get (
    rocksdb_transaction_t* txn, rocksdb_readoptions_t* options,
    char* key, size_t klen, size_t* vlen, char** errptr )

FUNCTION: char* rocksdb_transaction_get_cf (
    rocksdb_transaction_t* txn, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key, size_t klen,
    size_t* vlen, char** errptr )

FUNCTION: char* rocksdb_transaction_get_for_update (
    rocksdb_transaction_t* txn, rocksdb_readoptions_t* options,
    char* key, size_t klen, size_t* vlen, uchar exclusive,
    char** errptr )

FUNCTION: char* rocksdb_transaction_get_for_update_cf (
    rocksdb_transaction_t* txn, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key, size_t klen,
    size_t* vlen, uchar exclusive, char** errptr )

FUNCTION: char* rocksdb_transactiondb_get (
    rocksdb_transactiondb_t* txn_db, rocksdb_readoptions_t* options,
    char* key, size_t klen, size_t* vlen, char** errptr )

FUNCTION: char* rocksdb_transactiondb_get_cf (
    rocksdb_transactiondb_t* txn_db, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key,
    size_t keylen, size_t* vallen, char** errptr )

FUNCTION: void rocksdb_transaction_put (
    rocksdb_transaction_t* txn, char* key, size_t klen, char* val,
    size_t vlen, char** errptr )

FUNCTION: void rocksdb_transaction_put_cf (
    rocksdb_transaction_t* txn, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen, char* val, size_t vlen, char** errptr )

FUNCTION: void rocksdb_transactiondb_put (
    rocksdb_transactiondb_t* txn_db, rocksdb_writeoptions_t* options,
    char* key, size_t klen, char* val, size_t vlen, char** errptr )

FUNCTION: void rocksdb_transactiondb_put_cf (
    rocksdb_transactiondb_t* txn_db, rocksdb_writeoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key,
    size_t keylen, char* val, size_t vallen, char** errptr )

FUNCTION: void rocksdb_transactiondb_write (
    rocksdb_transactiondb_t* txn_db, rocksdb_writeoptions_t* options,
    rocksdb_writebatch_t *batch, char** errptr )

FUNCTION: void rocksdb_transaction_merge (
    rocksdb_transaction_t* txn, char* key, size_t klen, char* val,
    size_t vlen, char** errptr )

FUNCTION: void rocksdb_transaction_merge_cf (
    rocksdb_transaction_t* txn, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen, char* val, size_t vlen, char** errptr )

FUNCTION: void rocksdb_transactiondb_merge (
    rocksdb_transactiondb_t* txn_db, rocksdb_writeoptions_t* options,
    char* key, size_t klen, char* val, size_t vlen, char** errptr )

FUNCTION: void rocksdb_transactiondb_merge_cf (
    rocksdb_transactiondb_t* txn_db, rocksdb_writeoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key, size_t klen,
    char* val, size_t vlen, char** errptr )

FUNCTION: void rocksdb_transaction_delete (
    rocksdb_transaction_t* txn, char* key, size_t klen, char** errptr )

FUNCTION: void rocksdb_transaction_delete_cf (
    rocksdb_transaction_t* txn, rocksdb_column_family_handle_t* column_family,
    char* key, size_t klen, char** errptr )

FUNCTION: void rocksdb_transactiondb_delete (
    rocksdb_transactiondb_t* txn_db, rocksdb_writeoptions_t* options,
    char* key, size_t klen, char** errptr )

FUNCTION: void rocksdb_transactiondb_delete_cf (
    rocksdb_transactiondb_t* txn_db, rocksdb_writeoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key,
    size_t keylen, char** errptr )

FUNCTION: rocksdb_iterator_t*
rocksdb_transaction_create_iterator ( rocksdb_transaction_t* txn,
                                    rocksdb_readoptions_t* options )

FUNCTION: rocksdb_iterator_t*
rocksdb_transaction_create_iterator_cf (
    rocksdb_transaction_t* txn, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family )

FUNCTION: rocksdb_iterator_t*
rocksdb_transactiondb_create_iterator ( rocksdb_transactiondb_t* txn_db,
                                      rocksdb_readoptions_t* options )

FUNCTION: rocksdb_iterator_t*
rocksdb_transactiondb_create_iterator_cf (
    rocksdb_transactiondb_t* txn_db, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family )

FUNCTION: void rocksdb_transactiondb_close (
    rocksdb_transactiondb_t* txn_db )

FUNCTION: rocksdb_checkpoint_t*
rocksdb_transactiondb_checkpoint_object_create ( rocksdb_transactiondb_t* txn_db,
                                               char** errptr )

FUNCTION: rocksdb_optimistictransactiondb_t*
rocksdb_optimistictransactiondb_open ( rocksdb_options_t* options,
                                     c-string name, char** errptr )

FUNCTION: rocksdb_optimistictransactiondb_t*
rocksdb_optimistictransactiondb_open_column_families (
    rocksdb_options_t* options, c-string name, int num_column_families,
    char** column_family_names,
    rocksdb_options_t** column_family_options,
    rocksdb_column_family_handle_t** column_family_handles, char** errptr )

FUNCTION: rocksdb_t*
rocksdb_optimistictransactiondb_get_base_db (
    rocksdb_optimistictransactiondb_t* otxn_db )

FUNCTION: void rocksdb_optimistictransactiondb_close_base_db (
    rocksdb_t* base_db )

FUNCTION: rocksdb_transaction_t*
rocksdb_optimistictransaction_begin (
    rocksdb_optimistictransactiondb_t* otxn_db,
    rocksdb_writeoptions_t* write_options,
    rocksdb_optimistictransaction_options_t* otxn_options,
    rocksdb_transaction_t* old_txn )

FUNCTION: void rocksdb_optimistictransactiondb_close (
    rocksdb_optimistictransactiondb_t* otxn_db )

! Transaction Options

FUNCTION: rocksdb_transactiondb_options_t*
rocksdb_transactiondb_options_create ( )

FUNCTION: void rocksdb_transactiondb_options_destroy (
    rocksdb_transactiondb_options_t* opt )

FUNCTION: void rocksdb_transactiondb_options_set_max_num_locks (
    rocksdb_transactiondb_options_t* opt, int64_t max_num_locks )

FUNCTION: void rocksdb_transactiondb_options_set_num_stripes (
    rocksdb_transactiondb_options_t* opt, size_t num_stripes )

FUNCTION: void
rocksdb_transactiondb_options_set_transaction_lock_timeout (
    rocksdb_transactiondb_options_t* opt, int64_t txn_lock_timeout )

FUNCTION: void
rocksdb_transactiondb_options_set_default_lock_timeout (
    rocksdb_transactiondb_options_t* opt, int64_t default_lock_timeout )

FUNCTION: rocksdb_transaction_options_t*
rocksdb_transaction_options_create ( )

FUNCTION: void rocksdb_transaction_options_destroy (
    rocksdb_transaction_options_t* opt )

FUNCTION: void rocksdb_transaction_options_set_set_snapshot (
    rocksdb_transaction_options_t* opt, uchar v )

FUNCTION: void rocksdb_transaction_options_set_deadlock_detect (
    rocksdb_transaction_options_t* opt, uchar v )

FUNCTION: void rocksdb_transaction_options_set_lock_timeout (
    rocksdb_transaction_options_t* opt, int64_t lock_timeout )

FUNCTION: void rocksdb_transaction_options_set_expiration (
    rocksdb_transaction_options_t* opt, int64_t expiration )

FUNCTION: void
rocksdb_transaction_options_set_deadlock_detect_depth (
    rocksdb_transaction_options_t* opt, int64_t depth )

FUNCTION: void
rocksdb_transaction_options_set_max_write_batch_size (
    rocksdb_transaction_options_t* opt, size_t size )

FUNCTION: rocksdb_optimistictransaction_options_t*
rocksdb_optimistictransaction_options_create ( )

FUNCTION: void rocksdb_optimistictransaction_options_destroy (
    rocksdb_optimistictransaction_options_t* opt )

FUNCTION: void
rocksdb_optimistictransaction_options_set_set_snapshot (
    rocksdb_optimistictransaction_options_t* opt, uchar v )

!  referring to convention (3), this should be used by client
!  to free memory that was malloc()ed
FUNCTION: void rocksdb_free ( void* ptr )

FUNCTION: rocksdb_pinnableslice_t* rocksdb_get_pinned (
    rocksdb_t* db, rocksdb_readoptions_t* options, char* key,
    size_t keylen, char** errptr )
FUNCTION: rocksdb_pinnableslice_t* rocksdb_get_pinned_cf (
    rocksdb_t* db, rocksdb_readoptions_t* options,
    rocksdb_column_family_handle_t* column_family, char* key,
    size_t keylen, char** errptr )
FUNCTION: void rocksdb_pinnableslice_destroy (
    rocksdb_pinnableslice_t* v )
FUNCTION: char* rocksdb_pinnableslice_value (
    rocksdb_pinnableslice_t* t, size_t* vlen )

FUNCTION: rocksdb_memory_consumers_t*
    rocksdb_memory_consumers_create ( )
FUNCTION: void rocksdb_memory_consumers_add_db (
    rocksdb_memory_consumers_t* consumers, rocksdb_t* db )
FUNCTION: void rocksdb_memory_consumers_add_cache (
    rocksdb_memory_consumers_t* consumers, rocksdb_cache_t* cache )
FUNCTION: void rocksdb_memory_consumers_destroy (
    rocksdb_memory_consumers_t* consumers )
FUNCTION: rocksdb_memory_usage_t*
rocksdb_approximate_memory_usage_create ( rocksdb_memory_consumers_t* consumers,
                                       char** errptr )
FUNCTION: void rocksdb_approximate_memory_usage_destroy (
    rocksdb_memory_usage_t* usage )

FUNCTION: uint64_t
rocksdb_approximate_memory_usage_get_mem_table_total (
    rocksdb_memory_usage_t* memory_usage )
FUNCTION: uint64_t
rocksdb_approximate_memory_usage_get_mem_table_unflushed (
    rocksdb_memory_usage_t* memory_usage )
FUNCTION: uint64_t
rocksdb_approximate_memory_usage_get_mem_table_readers_total (
    rocksdb_memory_usage_t* memory_usage )
FUNCTION: uint64_t
rocksdb_approximate_memory_usage_get_cache_total (
    rocksdb_memory_usage_t* memory_usage )

FUNCTION: void rocksdb_options_set_dump_malloc_stats (
    rocksdb_options_t* options, uchar unk )

FUNCTION: void
rocksdb_options_set_memtable_whole_key_filtering (
    rocksdb_options_t* options, uchar unk )

FUNCTION: void rocksdb_cancel_all_background_work (
    rocksdb_t* db, uchar wait )
