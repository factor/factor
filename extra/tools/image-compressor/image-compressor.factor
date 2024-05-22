! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
! can be run as : factor -run=binary.image.factor.compressor
! with command-line options, see documentation

USING: accessors assocs byte-arrays classes.struct combinators
command-line command-line.parser compression.zstd
generalizations io io.encodings.binary io.files kernel
kernel.private locals math math.order math.parser namespaces
prettyprint sequences system tools.image-analyzer
tools.image-analyzer.vm vm ;
IN: tools.image-compressor

! support multiple image formats if needed
CONSTANT: image-header-magic   0x0f0e0d0c
CONSTANT: image-header-version 4

ERROR: unsupported-image-header ;

: check-header ( header -- header/* )
  [ [ magic>> image-header-magic = ] [ version>> image-header-version = ] bi and [ unsupported-image-header ] unless ] keep ;

STRUCT: image-footer
    { magic cell_t }
    { image_offset cell_t } ! offset from beginning of file
;

: valid-footer? ( footer -- ? )
  magic>> image-header-magic = ;

<PRIVATE

! return empty sequence instead of f
: read* ( n -- bytes )
  read [ B{ } clone ] unless* ; inline

: read-footer ( -- footer )
  tell-input
  image-footer [ struct-size neg seek-end seek-input ] [ read-struct ] bi
  swap seek-absolute seek-input ;

: read-footer* ( -- footer/f )
  read-footer dup valid-footer? [ drop f ] unless ;

PRIVATE>

TUPLE: image
  { footer }
  { leader byte-array }
  { header image-header }
  { data byte-array }
  { code byte-array }
;

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
    read-footer* [ dup image_offset>> read* ] [ B{ } clone B{ } clone ] if*
    image-header read-struct check-header >compression-header dup
    [ compressed-data-size>> read* ]
    [ compressed-code-size>> read* ] bi
  ] with-file-reader image boa
;

! save factor image
: save-factor-image ( image filename -- )
  binary [
   { [ leader>> ] [ header>> ] [ data>> ] [ code>> ] [ footer>> ] } cleave [ write ] 5 napply
  ] with-file-writer
;

: uncompressed-data? ( image -- ? ) header>> [ escaped-data-size>> ] [ compressed-data-size>> ] bi = ;
: uncompressed-code? ( image -- ? ) header>> [ code-size>> ]         [ compressed-code-size>> ] bi = ;

! level 12 seems the right balance between compression factor and compression speed
INITIALIZED-SYMBOL: compression-level [ 12 ]

: (compress) ( byte-array -- compressed ) compression-level get zstd-compress-level ;
: compress ( byte-array -- compressed ) [ (compress) ] keep [ [ length ] bi@ < ] 2keep ? ;
: compress-data ( image -- image' ) dup uncompressed-data? [ dup data>> compress >>data ] when ; ! only compress uncompressed data
: compress-code ( image -- image' ) dup uncompressed-code? [ dup code>> compress >>code ] when ; ! only compress uncompressed code
: compress-image ( image -- image' ) compress-data compress-code sync-header ;

! compress factor image
: compress-factor-image ( image-file compressed-file  -- )
  [ load-factor-image compress-image ] dip save-factor-image
;

: compress-current-image ( -- ) image-path dup compress-factor-image ;

CONSTANT: command-options
{
  T{ option { name "-c" } { type integer } { convert [ dec> ] } { default 12 } { validate [ 1 22 between? ] } { #args 1 } { variable compression-level } { help "set the compression level between 1 and 22" } }
  T{ option { name "input" } { #args "?" } { help "the input factor image path (default: image-path)" } }
  T{ option { name "output" } { #args "?" } { help "the output factor image path (default: input)" } }
}

: compress-command ( -- )
  command-options [
      "input" get image-path or
      "output" get over or
      compress-factor-image
  ] with-options
;

MAIN: compress-command
