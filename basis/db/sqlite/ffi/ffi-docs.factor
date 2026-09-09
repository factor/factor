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
