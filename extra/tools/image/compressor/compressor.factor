! Copyright (C) 2022-2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
! can be run as : factor -run=tools.image-compressor
! with command-line options, see documentation

USING: byte-arrays command-line.parser help.markup help.syntax io.files.unique
kernel math math.order math.parser memory namespaces strings system
tools.image tools.image.compression  ;
IN: tools.image.compressor

INITIALIZED-SYMBOL: force-compression [ f ]

! compress factor image
: compress-factor-image ( image-file compressed-file  -- )
  [ dup load-factor-image force-compression get [ >compressable ] when compress-image ] dip
  dup reach = [ [ save-factor-image ] safe-replace-file ] [ save-factor-image ] if
;

! try hard to ensure the currently running version of Factor will be able to read the current image
: compress-current-image ( -- ) image-path dup f force-compression [ compress-factor-image ] with-variable ;

<PRIVATE

CONSTANT: command-options
{
  T{ option { name "-F" } { const t } { variable force-compression } { help "force compress uncompressable image\nWARNING: experts only! Use only for a Factor executable\nthat supports compression" } }
  T{ option { name "-c" } { type integer } { convert [ dec> ] } { default 12 } { validate [ 1 22 between? ] } { #args 1 } { variable compression-level } { help "set the compression level between 1 and 22" } }
  T{ option { name "input" } { #args "?" } { help "the input factor image path (default: image-path)" } }
  T{ option { name "output" } { #args "?" } { help "the output factor image path (default: input)" } }
}

CONSTANT: command-help
"Compresses the given Factor image, which can be an .image file or an embedded image inside an executable, such as a deployed application. By default only images created with a Factor version that supports compression are compressed, else an error is generated."

: compress-command ( -- )
  command-help program-prolog set
  command-options [
      "input" get image-path or
      "output" get over or
      compress-factor-image
  ] with-options
;

PRIVATE>

MAIN: compress-command
