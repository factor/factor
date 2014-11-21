! (c)2010 Joe Groff bsd license
USING: alien.c-types alien.data alien.destructors alien.strings
alien.syntax combinators destructors io.encodings.ascii kernel
libc locals sequences ;
IN: alien.cxx.demangle.libstdcxx

FUNCTION: char* __cxa_demangle ( char* mangled_name, char* output_buffer, size_t* length, int* status ) ;

ERROR: demangle-memory-allocation-failure ;
ERROR: invalid-mangled-name name ;
ERROR: invalid-demangle-args name ;

: demangle-error ( name status -- )
    {
        {  0 [ drop ] }
        { -1 [ drop demangle-memory-allocation-failure ] }
        { -2 [ invalid-mangled-name ] }
        { -3 [ invalid-demangle-args ] }
    } case ;

: mangled-name? ( name -- ? )
    "_Z" head? ;

DESTRUCTOR: (free)

:: demangle ( mangled-name -- c++-name )
    0 ulong <ref> :> length
    0 int <ref> :> status [
        mangled-name ascii string>alien f length status __cxa_demangle &(free) :> demangled-buf
        mangled-name status int deref demangle-error
        demangled-buf ascii alien>string
    ] with-destructors ;
