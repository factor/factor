! Optional SQLite 3.53.4 integration fixture. Load using the documented runner.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.syntax classes.struct combinators continuations db.sqlite.ffi
environment kernel locals sequences system ;
IN: db.sqlite.ffi.release-tests

<< "sqlite-optional" "SQLITE_3534_LIBRARY" os-env
   [ cdecl add-library ] [ "Set SQLITE_3534_LIBRARY to the enabled 3.53.4 test library" throw ] if* >>
LIBRARY: sqlite-optional
FUNCTION: sqlite3* optional_open ( )
FUNCTION: int optional_exec ( sqlite3* db, c-string sql )
FUNCTION: sqlite3_stmt* optional_prepare ( sqlite3* db, c-string sql )
FUNCTION: int optional_sum ( sqlite3* db )
FUNCTION: void* optional_conflict ( )
FUNCTION: void* optional_array ( )
FUNCTION: void* optional_destructor ( )
FUNCTION: void* optional_destructor_context ( )
FUNCTION: int optional_destructor_calls ( )
FUNCTION: void optional_preupdate_reset ( )
FUNCTION: void optional_preupdate_record ( void* context, sqlite3* db, int op, char* schema, char* table, sqlite3_int64 oldid, sqlite3_int64 newid )
FUNCTION: int optional_preupdate_result ( )
FUNCTION: void* optional_fts5_api ( sqlite3* db )
FUNCTION: void* optional_fts5_tokenizer ( fts5_api* api )
FUNCTION: int optional_fts5_verify ( fts5_api* api, void* find, void* tokenizer, void* create, void* destroy, void* tokenize )
FUNCTION: int optional_fts5_api_size ( )
FUNCTION: int optional_fts5_tokenizer_size ( )

CALLBACK: sqlite3_file* optional_filename_callback ( sqlite3_filename filename )
FUNCTION: int optional_filename_oracle ( optional_filename_callback callback )
