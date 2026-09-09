USING: alien.varargs help.markup help.syntax lua ;
IN: lua

HELP: lua_pushfstring
{ $description "Pushes a formatted Lua string and returns its contents as a Factor string. This base declaration has no anonymous arguments. Define a typed " { $snippet "FUNCTION-ALIAS:" } " for each argument shape, with " { $snippet "..." } " after the state and format parameters." }
{ $notes "Lua 5.1 accepts only %s (C string), %d (int), %f (lua_Number), %c (int), %p (pointer), and %%. Width, precision, and printf length modifiers are not supported. The format must match the alias's types and argument count." } ;

HELP: lua_pushvfstring
{ $description "Pushes a formatted Lua string using an existing C variable argument list and returns its contents as a Factor string. Uses the canonical " { $link va_list } " C type." }
{ $notes "On ARM64 a callback receives a borrowed cursor for its va_list parameter. Forwarding it to this function creates an independent native list position, so the same cursor may be forwarded repeatedly. Reading with va-arg advances the cursor before subsequent forwarding."
"The cursor and its copies expire when the originating callback returns. Use them only on that callback's current Factor thread. The returned Factor string owns its contents and may be retained afterward." } ;

HELP: luaL_error
{ $description "The variadic Lua error entry point. The base declaration has no anonymous arguments; typed aliases use the same format rules as " { $link lua_pushfstring } "." }
{ $warning "This function never returns: it raises a Lua error with longjmp. Do not call it from a Factor callback, even if the callback was invoked beneath lua_pcall. The jump would bypass Factor's callback cleanup. Raise errors in a C shim whose lua_pcall protection and error-producing call are entirely inside C, then return the status and message to Factor." } ;

ARTICLE: "lua-variadic-formatting" "Lua 5.1 variadic formatting"
"Declare the anonymous arguments needed by a format string:"
{ $code
"USING: alien.c-types alien.syntax io.encodings.ascii lua ;"
"LIBRARY: liblua5.1"
"FUNCTION-ALIAS: lua-push-message c-string[ascii] lua_pushfstring"
"    ( lua_State* L, c-string[ascii] fmt, ... c-string[ascii] name, int count )"
"! Given a live Lua state on the stack:"
"\"%s: %d\" \"items\" 3 lua-push-message"
}
"The call returns a Factor string and leaves the corresponding Lua string on the Lua stack. Manage the Lua stack using the usual Lua API. The ordinary lua_pushfstring declaration can format a literal or %% without anonymous arguments."
{ $subsections lua_pushfstring lua_pushvfstring luaL_error }
"These are Lua 5.1 formats, not the complete printf format language."
{ $url "https://www.lua.org/manual/5.1/manual.html#lua_pushfstring" } ;
