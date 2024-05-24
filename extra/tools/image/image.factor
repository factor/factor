! Copyright (C) 2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays classes.struct combinators
generalizations io io.encodings.binary io.files kernel
kernel.private math sequences vm ;
IN: tools.image

! These structs and constants correspond to vm/image.hpp
! support multiple image formats if needed in here

CONSTANT: image-magic   0x0f0e0d0c
CONSTANT: image-version 4

STRUCT: image-header
    { magic cell_t }
    { version cell_t }
    { data-relocation-base cell_t }
    { data-size cell_t }
    { code-relocation-base cell_t }
    { code-size cell_t }
    { escaped-data-size cell_t }
    { compressed-data-size cell_t initial: 0 }
    { compressed-code-size cell_t initial: 0 }
    { reserved-4 cell_t }
    { special-objects cell_t[special-object-count] } ;

STRUCT: embedded-image-footer
    { magic cell_t }
    { image-offset cell_t } ! offset from beginning of file
;

TUPLE: image
  { footer }              ! located at the end of a file in case of embedded images
  { leader byte-array }   ! file starts with leader (for embedded images), then
  { header image-header } ! Factor image header
  { data byte-array }     ! Factor image data heap
  { code byte-array }     ! Factor image code heap
  { trailer byte-array }  ! trailing data
;

: valid-header? ( header -- ? )
  [ magic>> image-magic = ] [ version>> image-version = ] bi and ;

: valid-footer? ( footer -- ? )
  magic>> image-magic = ;

ERROR: unsupported-image-header ;

: check-header ( header -- header/* )
  [ valid-header? [ unsupported-image-header ] unless ] keep ;

: uncompressed-data? ( image -- ? ) header>> [ escaped-data-size>> ] [ compressed-data-size>> ] bi = ;
: uncompressed-code? ( image -- ? ) header>> [ code-size>> ]         [ compressed-code-size>> ] bi = ;

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

! return empty sequence instead of f
: read* ( n -- bytes )
  read [ B{ } clone ] unless* ; inline

: read-header ( -- header/* )
  image-header read-struct check-header >compression-header ;

: read-footer ( -- footer-offset footer )
  tell-input [
    embedded-image-footer [ struct-size neg seek-end seek-input tell-input ] [ read-struct ] bi
  ] dip seek-absolute seek-input ;

: read-footer* ( -- footer-offset footer/f )
  read-footer dup valid-footer? [ drop embedded-image-footer struct-size + f ] unless ;

! load factor image or embedded image
: load-factor-image ( filename -- image )
  binary [
    read-footer* [ dup image-offset>> read* ] [ B{ } clone B{ } clone ] if*
    read-header dup
    [ compressed-data-size>> read* ]
    [ compressed-code-size>> read* ] bi
    6 nrot tell-input - read*
  ] with-file-reader image boa
;

! save factor image or embedded image
: save-factor-image ( image filename -- )
  binary [
   { [ leader>> ] [ header>> ] [ data>> ] [ code>> ] [ trailer>> ] [ footer>> ] } cleave [ write ] 6 napply
  ] with-file-writer
;
