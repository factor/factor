! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
! can be run as : factor -run=tools.image-compressor
! with command-line options, see documentation

USING: accessors assocs byte-arrays classes.struct combinators
command-line command-line.parser compression.zstd
generalizations io io.encodings.binary io.files kernel
kernel.private locals math math.order math.parser namespaces
sequences system tools.image ;
IN: tools.image.compressor

! level 12 seems the right balance between compression factor and compression speed
INITIALIZED-SYMBOL: compression-level [ 12 ]

: (compress) ( byte-array -- compressed ) compression-level get zstd-compress-level ;
: compress ( byte-array -- compressed ) [ (compress) ] keep [ [ length ] bi@ < ] 2keep ? ;

<PRIVATE

: compress-data ( image -- image' ) dup uncompressed-data? [ dup data>> compress >>data ] when ; ! only compress uncompressed data
: compress-code ( image -- image' ) dup uncompressed-code? [ dup code>> compress >>code ] when ; ! only compress uncompressed code

PRIVATE>

GENERIC: compress-image ( image -- image' )
M: image compress-image uncompressable-image ;
M: compressable-image compress-image compress-data compress-code sync-header ;

INITIALIZED-SYMBOL: force-compression [ f ]

! compress factor image
: compress-factor-image ( image-file compressed-file  -- )
  [ load-factor-image force-compression get [ >compressable ] when compress-image ] dip save-factor-image
;

! try hard to ensure the currently running version of Factor will be able to read the current image
: compress-current-image ( -- ) image-path dup f force-compression [ compress-factor-image ] with-variable ;

<PRIVATE

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

PRIVATE>

MAIN: compress-command
