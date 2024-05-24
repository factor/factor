! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
! can be run as : factor -run=tools.image-uncompressor
! with command-line options, see documentation

USING: accessors assocs byte-arrays classes.struct combinators
command-line command-line.parser compression.zstd
generalizations io io.encodings.binary io.files kernel
kernel.private locals math math.order math.parser namespaces
sequences system image.factor ;
IN: tools.image-uncompressor

: uncompress ( byte-array -- uncompressed ) zstd-uncompress ; inline
: uncompress-data ( image -- image' ) dup uncompressed-data? [ dup data>> uncompress >>data ] unless ; ! only uncompress compressed data
: uncompress-code ( image -- image' ) dup uncompressed-code? [ dup code>> uncompress >>code ] unless ; ! only uncompress compressed code
: uncompress-image ( image -- image' ) uncompress-data uncompress-code sync-header ;

! uncompress factor image
: uncompress-factor-image ( compressed-image-file uncompressed-file  -- )
  [ load-factor-image uncompress-image ] dip save-factor-image
;

: uncompress-current-image ( -- ) image-path dup uncompress-factor-image ;

<PRIVATE

CONSTANT: command-options
{
  T{ option { name "input" } { #args 1 } { help "the input factor image path" } }
  T{ option { name "output" } { #args 1 } { help "the output factor image path" } }
}

: uncompress-command ( -- )
  command-options [
      "input" get "output" get uncompress-factor-image
  ] with-options
;

PRIVATE>

MAIN: uncompress-command
