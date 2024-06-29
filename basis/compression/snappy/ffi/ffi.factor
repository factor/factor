! Copyright (C) 2014 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators system ;
IN: compression.snappy.ffi

<< "snappy" {
    { [ os windows? ] [ "snappy.dll" ] }
    { [ os macos? ] [ "libsnappy.dylib" ] }
    { [ os unix? ] [ "libsnappy.so" ] }
} cond cdecl add-library >>

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
