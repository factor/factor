! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
! can be run as : factor -run=tools.image-uncompressor
! with command-line options, see documentation

USING: byte-arrays command-line.parser help.markup help.syntax io.files.unique
kernel memory namespaces strings system tools.image tools.image.compression ;
IN: tools.image.uncompressor

! uncompress factor image
: uncompress-factor-image ( compressed-image-file uncompressed-file  -- )
    [ load-factor-image uncompress-image ] dip [ save-factor-image ] with safe-overwrite-file ;

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
