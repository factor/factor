! Copyright (C) 2024 nomennescio.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compression.zstd kernel math namespaces
sequences tools.image ;
IN: tools.image.compression

! level 12 seems the right balance between compression factor and compression speed
INITIALIZED-SYMBOL: compression-level [ 12 ]

: (compress) ( byte-array -- compressed ) compression-level get zstd-compress-level ;
: compress ( byte-array -- compressed ) [ (compress) ] keep [ [ length ] bi@ < ] 2keep ? ;
: uncompress ( byte-array -- uncompressed ) zstd-uncompress ; inline

<PRIVATE

: compress-data ( image -- image' ) dup uncompressed-data? [ dup data>> compress >>data ] when ; ! only compress uncompressed data
: compress-code ( image -- image' ) dup uncompressed-code? [ dup code>> compress >>code ] when ; ! only compress uncompressed code
: uncompress-data ( image -- image' ) dup uncompressed-data? [ dup data>> uncompress >>data ] unless ; ! only uncompress compressed data
: uncompress-code ( image -- image' ) dup uncompressed-code? [ dup code>> uncompress >>code ] unless ; ! only uncompress compressed code

PRIVATE>

GENERIC: compress-image ( image -- image' )
M: image compress-image uncompressable-image ;
M: compressable-image compress-image compress-data compress-code sync-header ;

: uncompress-image ( image -- image' ) uncompress-data uncompress-code sync-header ;
