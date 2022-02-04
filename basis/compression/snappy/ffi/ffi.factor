! Copyright (C) 2014 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators system ;
IN: compression.snappy.ffi

LIBRARY-UNIX: snappy cdecl "libsnappy.so"
LIBRARY-MACOSX: snappy cdecl "libsnappy.dylib"
LIBRARY-WINDOWS: snappy cdecl "snappy.dll"

LIBRARY: snappy

ENUM: snappy_status SNAPPY_OK SNAPPY_INVALID_INPUT SNAPPY_BUFFER_TOO_SMALL ;

FUNCTION: snappy_status snappy_compress ( char* input,
                                          size_t input_length,
                                          char* compressed,
                                          size_t* compressed_length )

FUNCTION: snappy_status snappy_uncompress ( char* compressed,
                                            size_t compressed_length,
                                            char* uncompressed,
                                            size_t* uncompressed_length )

FUNCTION: size_t snappy_max_compressed_length ( size_t source_length )

FUNCTION: snappy_status snappy_uncompressed_length ( char* compressed,
                                                     size_t compressed_length,
                                                     size_t* result )

FUNCTION: snappy_status snappy_validate_compressed_buffer ( char* compressed,
                                                            size_t compressed_length )
