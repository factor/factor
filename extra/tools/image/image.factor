! Copyright (C) 2024 nomennescio
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types byte-arrays classes
classes.struct combinators continuations debugger
generalizations io io.encodings.binary io.files kernel
kernel.private math sequences ;
IN: tools.image

! These structs and constants correspond to vm/image.hpp
! support multiple image formats if needed in here

CONSTANT: image-magic   0x0f0e0d0c
CONSTANT: image-version 4

STRUCT: image-header.32
    { magic u32 }
    { version u32 }
    { data-relocation-base u32 }
    { data-size u32 }
    { code-relocation-base u32 }
    { code-size u32 }
    { escaped-data-size u32 }
    { compressed-data-size u32 initial: 0 }
    { compressed-code-size u32 initial: 0 }
    { reserved-4 u32 }
    { special-objects u32[special-object-count] } ;

STRUCT: image-footer.32
    { trailing u8[8] }     ! trailing bytes
    { magic u32 }
    { image-offset u32 } ; ! offset from beginning of file

STRUCT: image-header.64
    { magic u64 }
    { version u64 }
    { data-relocation-base u64 }
    { data-size u64 }
    { code-relocation-base u64 }
    { code-size u64 }
    { escaped-data-size u64 }
    { compressed-data-size u64 initial: 0 }
    { compressed-code-size u64 initial: 0 }
    { reserved-4 u64 }
    { special-objects u64[special-object-count] } ;

STRUCT: image-footer.64
    { magic u64 }
    { image-offset u64 } ; ! offset from beginning of file

UNION-STRUCT: image-header.union { b32 image-header.32 } { b64 image-header.64 } ;
UNION-STRUCT: image-footer.union { b32 image-footer.32 } { b64 image-footer.64 } ;

UNION: image-header image-header.32 image-header.64 ;
UNION: image-footer image-footer.32 image-footer.64 POSTPONE: f ;

TUPLE: image
  { footer maybe{ image-footer } } ! located at the end of a file in case of embedded images
  { leader maybe{ byte-array } }   ! file starts with leader (for embedded images), then
  { header maybe{ image-header } } ! Factor image header
  { data maybe{ byte-array } }     ! Factor image data heap
  { code maybe{ byte-array } }     ! Factor image code heap
  { trailer maybe{ byte-array } }  ! trailing data
;

PREDICATE: compressable-image < image header>> data-size>> zero? ;

ERROR: uncompressable-image ;

M: uncompressable-image error. drop "This image format does not support compression" print ;

: valid-header? ( header -- ? )
  [ magic>> image-magic = ] [ version>> image-version = ] bi and ;

: valid-footer? ( footer -- ? )
  magic>> image-magic = ;

ERROR: unsupported-image-header ;

M: unsupported-image-header error. drop "Could not detect a valid image header" print ;

: check-image-header ( header -- header.32/header.64/* )
  dup b32>> dup valid-header? [ nip ] [ drop b64>> dup valid-header? [ unsupported-image-header ] unless ] if ;

: valid-image-footer? ( footer -- footer.32/footer.64/f )
  dup b32>> dup valid-footer? [ nip ] [ drop b64>> [ valid-footer? ] 1guard ] if ;

: uncompressed-data? ( image -- ? ) header>> [ escaped-data-size>> ] [ compressed-data-size>> ] bi = ;
: uncompressed-code? ( image -- ? ) header>> [ code-size>> ]         [ compressed-code-size>> ] bi = ;

! converts to compression compatible header if needed, while preserving variant identity
: >compression-header ( headerv4 -- headerv4+ )
  dup data-size>> zero?
  [ dup data-size>> [ >>escaped-data-size ] [ >>compressed-data-size ] 2bi
    code-size>> >>compressed-code-size
  ] unless
;

: sync-header ( image -- image' )
  dup data>> length over header>> compressed-data-size<<
  dup code>> length over header>> compressed-code-size<<
;

: >compressable ( uncompressable-image -- compressable-image )
  [ header>> [ >compression-header drop ] [ 0 >>data-size drop ] bi ] keep ;

: with-position ( quot -- )
  tell-input [ seek-absolute seek-input ] curry finally ; inline

! always read exactly n bytes. return empty sequence instead of f. beyond EOF read 0.
: read* ( n -- bytes )
  dup read [ B{ } clone ] unless* resize-byte-array ; inline

: skip-struct ( struct -- )
  class-of heap-size seek-relative seek-input ; inline

: read-struct* ( class -- struct )
  [ heap-size read* ] [ memory>struct ] bi ;

: read-header ( -- header.32/header.64/* )
  [ image-header.union read-struct* check-image-header >compression-header ] with-position dup skip-struct ;

: read-union-footer ( -- footer-offset footer )
  [
    image-footer.union [ struct-size neg seek-end seek-input tell-input ] [ read-struct* ] bi
  ] with-position ;

: read-footer ( -- footer-offset footer.32/footer.64/f )
  read-union-footer valid-image-footer? [ image-footer.union struct-size + f ] unless* ;

! load factor image or embedded image
: load-factor-image ( filename -- image )
  binary [
    read-footer [ dup image-offset>> read* ] [ f f ] if*
    read-header dup
    [ compressed-data-size>> read* ]
    [ compressed-code-size>> read* ] bi
    6 nrot tell-input - read*
  ] with-file-reader image boa
;

<PRIVATE

: clean-header ( header -- header' )
  dup data-size>> zero? [ 0 >>escaped-data-size 0 >>compressed-data-size 0 >>compressed-code-size ] unless ;

PRIVATE>

! save factor image or embedded image
: save-factor-image ( image filename -- )
   binary [
     { [ leader>> write ]
       [ header>> clone clean-header write ]
       [ data>> write ]
       [ code>> write ]
       [ trailer>> write ]
       [ footer>> write ] } cleave
   ] with-file-writer ;
