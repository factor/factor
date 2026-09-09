USING: alien.c-types alien.syntax alien.varargs db.sqlite.ffi help.markup help.syntax ;
IN: db.sqlite.ffi

ARTICLE: "sqlite-formatting" "SQLite formatting and variadic calls"
"SQLite's formatting and configuration functions use the C variadic calling convention. The bindings ending in a terminal ellipsis describe calls with no anonymous arguments. For other call shapes, define a typed alias with every argument required by the format string or operation code:"
{ $code
    "LIBRARY: sqlite"
    "FUNCTION-ALIAS: sql-format char* sqlite3_mprintf ("
    "    c-string format, ... c-string name, int count, double value )"
    "\"%Q:%d:%.2f\" \"O'Brien\" 42 1.25 sql-format"
}
"The result is an owned pointer. Decode it with alien>string and release it with sqlite3_free, including on exceptional exits. SQLite's %Q conversion quotes SQL string literals. The FFI does not infer argument types from format strings."
$nl
"sqlite3_vmprintf, sqlite3_vsnprintf, and sqlite3_str_vappendf accept the canonical va_list type from alien.varargs. On ARM64, pass a cursor borrowed from a callback; forwarding preserves the Factor cursor's position by passing an independent native copy."
$nl
"Compatibility: sqlite3_mprintf and sqlite3_str_finish now return raw owned char* pointers instead of copied Factor strings, so callers can release their allocations. sqlite3_snprintf now declares its writable buffer and result as char*; the returned pointer aliases the supplied buffer. Their stack arities are unchanged. sqlite3_str_value continues to copy SQLite's borrowed string."
$nl
"sqlite3_config, sqlite3_db_config, sqlite3_vtab_config, sqlite3_test_control, and sqlite3_log also have terminal ellipses. Supply typed aliases for operations or formats that require arguments. The zero-tail bindings do not supply missing parameters. SQLite's threading, initialization, and operation-specific restrictions still apply."
{ $subsections sqlite3_mprintf sqlite3_vmprintf sqlite3_snprintf sqlite3_vsnprintf sqlite3_str_finish sqlite3_str_appendf sqlite3_str_vappendf } ;

HELP: sqlite3_mprintf
{ $values { "format" "a UTF-8 format string requiring no anonymous arguments" } { "char*" "an owned C string pointer, or f on allocation failure" } }
{ $description "Formats a string in SQLite-allocated memory. Release a non-null result with sqlite3_free. Define a typed FUNCTION-ALIAS for formats requiring anonymous arguments." } ;

HELP: sqlite3_vmprintf
{ $values { "format" "a UTF-8 format string" } { "args" "a native argument list; a borrowed cursor on ARM64" } { "char*" "an owned C string pointer, or f on allocation failure" } }
{ $description "Formats a native argument list in SQLite-allocated memory. Release the result with sqlite3_free. On ARM64, forwarding uses an independent copy of the cursor position." } ;

HELP: sqlite3_snprintf
{ $values { "size" "the buffer capacity in bytes, including its terminator" } { "buffer" "a writable C buffer or byte array" } { "format" "a UTF-8 format string requiring no anonymous arguments" } { "char*" "the supplied buffer pointer" } }
{ $description "Writes into the caller's buffer, returning that same pointer. Unlike C snprintf, SQLite takes the capacity before the buffer and returns a pointer rather than a character count. Positive capacities always produce a zero-terminated result. Define a typed FUNCTION-ALIAS for formats requiring anonymous arguments." } ;

HELP: sqlite3_vsnprintf
{ $values { "size" "the buffer capacity in bytes, including its terminator" } { "buffer" "a writable C buffer or byte array" } { "format" "a UTF-8 format string" } { "args" "a native argument list; a borrowed cursor on ARM64" } { "char*" "the supplied buffer pointer" } }
{ $description "Formats the supplied native argument list into the caller's writable buffer. It has the capacity, termination, and return-pointer semantics of sqlite3_snprintf. On ARM64, forwarding preserves the cursor position." } ;

HELP: sqlite3_str_finish
{ $values { "builder" "a SQLite dynamic string builder" } { "char*" "an owned C string pointer, or f for an empty result or error" } }
{ $description "Destroys the builder and transfers its result allocation to the caller. Release a non-null result with sqlite3_free." } ;

HELP: sqlite3_str_appendf
{ $values { "builder" "a SQLite dynamic string builder" } { "format" "a UTF-8 format string requiring no anonymous arguments" } }
{ $description "Appends formatted text. Define a typed FUNCTION-ALIAS for formats requiring anonymous arguments. Inspect sqlite3_str_errcode for errors and finish the builder with sqlite3_str_finish." } ;

HELP: sqlite3_str_vappendf
{ $values { "builder" "a SQLite dynamic string builder" } { "format" "a UTF-8 format string" } { "args" "a native argument list; a borrowed cursor on ARM64" } }
{ $description "Appends text formatted from a native argument list. On ARM64, forwarding preserves the cursor position. Inspect sqlite3_str_errcode for errors and finish the builder with sqlite3_str_finish." } ;

ABOUT: "sqlite-formatting"

ARTICLE: "sqlite-native-interfaces" "SQLite native interfaces and ownership"
"The db.sqlite.ffi declarations cover the public sqlite3.h interfaces through SQLite 3.53.4, including the session, Rtree, carray, and FTS5 interfaces. SQLITE_VERSION and SQLITE_VERSION_NUMBER describe this reference header. Use sqlite3_libversion and sqlite3_compileoption_used to inspect the library actually loaded. Optional declarations do not enable their corresponding library features."
$nl
"Session requires SQLITE_ENABLE_SESSION and SQLITE_ENABLE_PREUPDATE_HOOK. Other facilities, including carray, FTS5, scanstatus, normalization, snapshots, and column metadata, depend on the linked library's build options. A missing optional symbol is a library capability limitation; applications must select a build containing the features they use."
$nl
"Compatibility: sqlite3_expanded_sql now returns an owned char* instead of a copied string. Decode it explicitly and release it with sqlite3_free. sqlite3_serialize now returns a raw uchar* and writes the binary length through piSize. Copy exactly that length when needed; database bytes are not a zero-terminated string. The usual serialization result must be freed with sqlite3_free; SQLITE_SERIALIZE_NOCOPY instead returns a borrowed buffer."
$nl
"sqlite3_deserialize takes a raw uchar* buffer that remains valid until the connection closes. The buffer may be modified unless SQLITE_DESERIALIZE_READONLY is specified. FREEONCLOSE and RESIZEABLE require SQLite-allocated memory because SQLite may free or reallocate it, including freeing it after a failed deserialize call. Do not pass a temporary encoded string or movable Factor storage as a retained buffer."
$nl
"sqlite3_prepare16 now takes a raw pointer to UTF-16 bytes, consistently with sqlite3_prepare16_v2 and sqlite3_prepare16_v3. Its byte count is measured in bytes."
$nl
"sqlite3_filename is a raw char* alias. sqlite3_db_filename and sqlite3_filename_database/journal/wal preserve SQLite filename object identity; decode only when a display string is wanted. sqlite3_create_filename returns an owned filename object released by sqlite3_free_filename. URI lookup functions require the original SQLite filename object. db.sqlite.lib's current-sqlite-filename continues returning a Factor string."
$nl
"FTS5 phrase-iterator fields retain raw byte positions. The extended FTS5 API structs and sqlite3_module include all members in the reference header. Respect each interface's iVersion when using older runtimes, and initialize versioned structs consistently with the callbacks supplied."
$nl
"The session streaming, changeset-filter/conflict, preupdate, and tokenizer callback types expose raw pointers. Decode text explicitly and honor any accompanying byte length. Keep callback objects and any retained native data alive for as long as SQLite may use them. sqlite3_destructor_type is a typed callback accepting void*; SQLITE_STATIC and SQLITE_TRANSIENT remain valid pointer sentinels where SQLite documents those conventions." ;

HELP: sqlite3_expanded_sql
{ $values { "pStmt" "a prepared statement" } { "char*" "an owned UTF-8 string pointer, or f" } }
{ $description "Returns expanded SQL in SQLite-allocated memory. Decode the result explicitly and release it with sqlite3_free." } ;

HELP: sqlite3_serialize
{ $values { "db" "a database connection" } { "zSchema" "a schema name or f" } { "piSize" "a pointer receiving the byte length" } { "mFlags" "serialization flags" } { "uchar*" "a binary buffer pointer, or f" } }
{ $description "Returns length-delimited database bytes. With ordinary flags the caller owns the result and must call sqlite3_free. SQLITE_SERIALIZE_NOCOPY instead requests a borrowed buffer. Never decode the database buffer as a C string." } ;

HELP: sqlite3_deserialize
{ $values { "db" "a database connection" } { "zSchema" "a schema name or f" } { "pData" "a retained native binary buffer" } { "szDb" "database bytes" } { "szBuf" "buffer capacity" } { "mFlags" "deserialization flags" } { "int" "a SQLite result code" } }
{ $description "Reopens a schema using a buffer that must remain valid until the connection closes. SQLite may write the buffer and, with FREEONCLOSE or RESIZEABLE, free or reallocate it. Those flags require SQLite-allocated memory. See sqlite-native-interfaces for ownership details." } ;
