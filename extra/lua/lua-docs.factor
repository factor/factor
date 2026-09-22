USING: alien alien.c-types alien.varargs help.markup help.syntax lua strings ;
IN: lua

HELP: lua_pushfstring
{ $values { "L" c-ptr } { "fmt" string } { "c-string" string } }
{ $description "Pushes a formatted Lua string and returns its contents as a Factor string. This base declaration has no anonymous arguments. Define a typed " { $snippet "FUNCTION-ALIAS:" } " for each argument shape, with " { $snippet "..." } " after the state and format parameters." }
{ $notes "Lua 5.5 accepts only %s (C string), %d (int), %f (lua_Number), %I (lua_Integer), %c (int), %U (unsigned long Unicode code point), %p (pointer), and %%. Width, precision, and printf length modifiers are not supported. The format must match the alias's types and argument count." } ;

HELP: lua_pushvfstring
{ $values { "L" c-ptr } { "fmt" string } { "argp" va_list } { "c-string" { $maybe string } } }
{ $description "Pushes a formatted Lua string using an existing C variable argument list and returns its contents as a Factor string. On failure, Lua 5.5 pushes an error message and returns f. Uses the canonical " { $link va_list } " C type." }
{ $notes "On ARM64 a callback receives a borrowed cursor for its va_list parameter. Forwarding it to this function creates an independent native list position, so the same cursor may be forwarded repeatedly. Reading with va-arg advances the cursor before subsequent forwarding."
 $nl
"The cursor and its copies expire when the originating callback returns. Use them only on that callback's current Factor thread. The returned Factor string owns its contents and may be retained afterward." } ;

HELP: luaL_error
{ $values { "L" c-ptr } { "fmt" string } { "int" int } }
{ $description "The variadic Lua error entry point. The base declaration has no anonymous arguments; typed aliases use the same format rules as " { $link lua_pushfstring } "." }
{ $warning "This function never returns: it raises a Lua error with longjmp. Do not call it from a Factor callback, even if the callback was invoked beneath lua_pcall. The jump would bypass Factor's callback cleanup. Raise errors in a C shim whose lua_pcall protection and error-producing call are entirely inside C, then return the status and message to Factor." } ;

ARTICLE: "lua-variadic-formatting" "Lua 5.5 variadic formatting"
"Declare the anonymous arguments needed by a format string:"
{ $code
"USING: alien.c-types alien.syntax io.encodings.ascii lua ;"
"LIBRARY: liblua5.5"
"FUNCTION-ALIAS: lua-push-message c-string[ascii] lua_pushfstring"
"    ( lua_State* L, c-string[ascii] fmt, ... c-string[ascii] name, int count )"
"! Given a live Lua state on the stack:"
"\"%s: %d\" \"items\" 3 lua-push-message"
}
"The call returns a Factor string and leaves the corresponding Lua string on the Lua stack. Manage the Lua stack using the usual Lua API. The ordinary lua_pushfstring declaration can format a literal or %% without anonymous arguments."
{ $subsections lua_pushfstring lua_pushvfstring luaL_error }
"These are Lua 5.5 formats, not the complete printf format language."
{ $url "https://www.lua.org/manual/5.5/manual.html#lua_pushfstring" } ;

HELP: lua_gc
{ $values { "L" c-ptr } { "what" int } { "int" int } }
{ $description "Controls garbage collection. This base declaration takes no anonymous arguments. For LUA_GCSTEP, declare a typed variadic alias with a size_t argument. For LUA_GCPARAM, declare an alias with two int arguments (parameter and value). Passing -1 as the value queries a parameter without changing it." } ;

ARTICLE: "lua" "Lua 5.5"
"Bindings for Lua 5.5's public C API and auxiliary and standard libraries. They require the default Lua numeric configuration: 64-bit lua_Integer and double lua_Number. Lua 5.1 through 5.4 libraries are not ABI-compatible with these bindings."
$nl
"The library identifier for typed aliases is liblua5.5. Platform library names are lua55.dll on Windows, liblua5.5.dylib on macOS, liblua5.5.so.0 on Linux, and liblua-5.5.so on other Unix systems. The library must be on the system's dynamic-library search path. For an Apple Silicon Homebrew installation, set DYLD_LIBRARY_PATH to /opt/homebrew/lib when launching Factor."
{ $heading "Running Lua code" }
{ $code
"USING: continuations kernel locals lua prettyprint ;"
"[let"
"    luaL_newstate :> L"
"    ["
"        L luaL_openlibs"
"        L \"return 6 * 7\" luaL_dostring ."
"        L -1 lua_tointeger ."
"    ] [ L lua_close ] finally"
"]"
}
{ $heading "Changes from the former Lua 5.1 bindings" }
{ $list
    "lua_newstate now takes an unsigned random seed after the allocator and user data. lua_resume takes the originating state and an int* result count. lua_load takes a mode; lua_dump takes a strip flag."
    "Get operations such as lua_getglobal, lua_getfield and lua_rawgeti return the pushed value's type. lua_pushstring and lua_pushlstring return the pushed string. lua_sethook returns no value."
    "The registry index, registry entries, hook masks, GC options, lua_Debug and luaL_Buffer follow the 5.5 headers. Hook masks are constants. lua_gc is variadic and its extra argument types depend on the selected option."
    "Removed 5.1 environment indices and functions, lua_cpcall, lua_setlevel, luaI_openlib, luaL_register and luaL_findtable are no longer declared as exports. Use globals, upvalues, luaL_setfuncs and luaL_requiref as appropriate."
    "Operations that became C macros, including lua_call, lua_pcall, lua_tonumber, lua_insert and luaL_openlibs, are Factor wrappers around current exported functions."
}
{ $heading "Strings and native storage" }
"Text parameters and copied string results use UTF-8. Lua strings may also hold arbitrary bytes: use lua_tolstring-raw and its size_t output for a borrowed pointer and exact byte length. lua_pushlstring, lua_pushexternalstring, luaL_addlstring and luaL_loadbufferx accept raw buffers and explicit byte lengths."
$nl
"Allocate luaL_Buffer with malloc-struct and release it with free after finishing the buffer operation. Its internal pointer can refer to the struct's own embedded storage, so it must not move with Factor's garbage collector. External strings likewise need stable native storage that remains valid for as long as Lua retains it."
$nl
"Lua errors and yields must not unwind through a Factor callback. Use a C shim for callbacks that can raise Lua errors or yield; keep the protected call and the nonlocal jump inside C."
{ $subsections "lua-variadic-formatting" }
{ $url "https://www.lua.org/manual/5.5/" } ;

ABOUT: "lua"
