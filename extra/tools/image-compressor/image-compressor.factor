! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
! can be run as : factor -run=binary.image.factor.compressor

USING: accessors byte-arrays classes.struct compression.zstd io
io.encodings.binary io.files kernel kernel.private locals math
namespaces sequences system tools.image-analyzer
tools.image-analyzer.vm vm ;
IN: tools.image-compressor

TUPLE: image
  { header image-header }
  { data byte-array }
  { code byte-array } ;

! converts to compression compatible header if needed
: >compression-header ( headerv4 -- headerv4+ )
  dup data-size>> zero?
  [ dup data-size>> [ >>escaped-data-size ] [ >>compressed-data-size ] 2bi
    code-size>> >>compressed-code-size 0 >>data-size
  ] unless
;

: sync-header ( image -- image' )
  dup data>> length over header>> compressed-data-size<<
  dup code>> length over header>> compressed-code-size<<
;

! load factor image
: load-factor-image ( filename -- image )
  binary [
    image-header read-struct >compression-header dup
    [ compressed-data-size>> read ]
    [ compressed-code-size>> read ] bi
  ] with-file-reader image boa
;

! save factor image
: save-factor-image ( image filename -- )
  binary [
   [ header>> ] [ data>> ] [ code>> ] tri [ write ] tri@
  ] with-file-writer
;

SYMBOL: compression-level
12 compression-level set-global ! level 12 seems the right balance between compression factor and compression speed

: compress ( byte-array -- compressed ) compression-level get zstd-compress-level ;
: uncompressed-data? ( image -- ? ) header>> [ escaped-data-size>> ] [ compressed-data-size>> ] bi = ;
: uncompressed-code? ( image -- ? ) header>> [ code-size>> ]         [ compressed-code-size>> ] bi = ;
: compress-data ( image -- image' ) dup uncompressed-data? [ dup data>> compress >>data ] when ; ! only compress uncompressed data
: compress-code ( image -- image' ) dup uncompressed-code? [ dup code>> compress >>code ] when ; ! only compress uncompressed code
: compress-image ( image -- image' ) compress-data compress-code sync-header ;

! compress factor image
: compress-factor-image ( image-file compressed-file  -- )
  [ load-factor-image compress-image ] dip save-factor-image
;

: compress-current-image ( -- ) image-path dup compress-factor-image ;
MAIN: compress-current-image
