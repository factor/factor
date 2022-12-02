USING: alien alien.libraries alien.c-types alien.data alien.syntax endian
       kernel io.encodings.string byte-arrays sequences combinators
       compression.bzip3.ffi locals math math.order summary pair-rocket ;
IN: compression.bzip3

ERROR: invalid-block-size size ;
M: invalid-block-size summary drop "Block size must be between 65 KiB and 511 MiB" ;
ERROR: internal-error msg ;
M: internal-error summary drop "bzip3: Internal Error" ;

<PRIVATE
CONSTANT: dsize 1048576 ! placeholder block size

: throw-internal-error ( code -- msg ) {
    -1 => [ "BZ3_ERR_OUT_OF_BOUNDS" ]
    -2 => [ "BZ3_ERR_BWT" ]
    -3 => [ "BZ3_ERR_CRC" ]
    -4 => [ "BZ3_ERR_MALFORMED_HEADER" ]
    -5 => [ "BZ3_ERR_TRUNCATED_DATA" ]
    -6 => [ "BZ3_ERR_DATA_TOO_BIG" ]
    -7 => [ "BZ3_ERR_INIT" ]
    [ drop "UNDEFINED_ERR" ]
  } case internal-error
;

: KiB ( b -- kib ) 1024 * ;
: MiB ( b -- mib ) 1024 * 1024 * ;
: validate-block-size ( b -- b ) dup 65 KiB 511 MiB between? 
  [ invalid-block-size ] unless ;
PRIVATE>

ALIAS: version bz3_version
:: compress ( byte-array block-size/f -- byte-array' )
  byte-array length :> in-size
  in-size bz3_bound :> out-size
  out-size <byte-array> :> out
  block-size/f [ dsize ] unless* validate-block-size
  byte-array out in-size out-size size_t <ref> bz3_compress
  dup 0 = [ drop in-size 8 >be out append ] [ throw-internal-error ] if
;

:: decompress ( byte-array -- byte-array' )
  byte-array 8 cut-slice :> ( head in )
  in length :> in-size
  head be> :> out-size
  out-size <byte-array> :> out
  in out in-size out-size size_t <ref> bz3_decompress
  dup 0 = [ drop out ] [ throw-internal-error ] if
;
