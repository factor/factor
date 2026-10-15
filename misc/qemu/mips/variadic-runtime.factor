USING: alien alien.c-types alien.libraries alien.syntax alien.varargs
byte-arrays compiler.units io kernel libc locals math memory namespaces
prettyprint sequences ;
IN: mips.variadic-runtime

<< "mips-variadic-runtime" "mips-variadic-library" get cdecl add-library >>
LIBRARY: mips-variadic-runtime
CALLBACK: double mips-variadic-callback ( int tag, ... )
CALLBACK: double mips-list-callback ( int tag, va_list args )
FUNCTION: double mips_invoke_variadic ( mips-variadic-callback callback )
FUNCTION: double mips_invoke_list ( mips-list-callback callback )

LIBRARY: libc
FUNCTION: int vsnprintf ( void* dst, size_t size, c-string fmt, va_list args )

:: read-variadic ( tag cursor -- value )
    gc tag cursor int va-arg + cursor double va-arg + cursor int va-arg +
    cursor int va-arg + cursor int va-arg + cursor int va-arg +
    cursor int va-arg + cursor int va-arg + cursor double va-arg + ;

:: forward-cursor ( tag cursor -- value )
    80 <byte-array> :> bytes
    bytes 80 "%d %.1f %d" cursor vsnprintf 9 = [ "FAIL vsnprintf length" throw ] unless
    bytes 9 head B{ 49 49 32 50 46 53 32 49 51 } = [ "FAIL vsnprintf bytes" throw ] unless
    gc tag cursor int va-arg + cursor double va-arg + cursor int va-arg + ;

: invoke-variadic-runtime ( -- n ) [ read-variadic ] mips-variadic-callback mips_invoke_variadic ;
: invoke-list-runtime ( -- n ) [ forward-cursor ] mips-list-callback mips_invoke_list ;

{ mips_invoke_variadic mips_invoke_list vsnprintf invoke-variadic-runtime invoke-list-runtime } compile
invoke-variadic-runtime dup . 156.0 = [ "FAIL variadic mixed register/stack tail" throw ] unless
invoke-list-runtime dup . 33.5 = [ "FAIL native va_list forwarding" throw ] unless
"MIPS variadic callbacks and va_list forwarding passed" print flush
