! Copyright (C) 2024 nomennescio.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes classes.struct io
io.encodings.binary io.files kernel kernel.private literals math
namespaces sequences tools.image tools.test
specialized-arrays.instances.alien.c-types.u8
specialized-arrays.instances.alien.c-types.u32
specialized-arrays.instances.alien.c-types.u64 ;
IN: tools.image.tests

<<
CONSTANT: dummy-leader  $[ "dummy headABCDEF" B{ } like ]
CONSTANT: dummy-data    $[ "dummy dataABCDEF" B{ } like ]                 ! is incompressable
CONSTANT: dummy-code    $[ "dummy code######################" B{ } like ] ! is   compressable
CONSTANT: dummy-trailer $[ "dummy tailABCDEF01234567" B{ } like ]

! special-objects array in header
CONSTANT: dummy-objects.32 $[ special-object-count [ <iota> ] [ drop 0 ] [ <u32-array> ] tri [ copy ] keep ]
CONSTANT: dummy-objects.64 $[ special-object-count [ <iota> ] [ drop 0 ] [ <u64-array> ] tri [ copy ] keep ]
>>

CONSTANT: dummy-header.32 S{ image-header.32 f $[ image-magic image-version 0 0 0 dummy-code length dummy-data length dup pick 0 dummy-objects.32 ] }
CONSTANT: dummy-header.64 S{ image-header.64 f $[ image-magic image-version 0 0 0 dummy-code length dummy-data length dup pick 0 dummy-objects.64 ] }

! account for overlap in embedded-image-footer.union
CONSTANT: dummy-trailer.64 $[ dummy-trailer ]
CONSTANT: dummy-trailer.32 $[ dummy-trailer 8 head* ]
CONSTANT: dummy-footer.32 S{ embedded-image-footer.32 f $[ dummy-trailer 8 tail* 0 8 <u8-array> [ copy ] keep image-magic dummy-leader length ] }
CONSTANT: dummy-footer.64 S{ embedded-image-footer.64 f $[ image-magic dummy-leader length ] }

CONSTANT: dummy-image.32 T{ image f $ dummy-footer.32 $ dummy-leader $ dummy-header.32 $ dummy-data $ dummy-code $ dummy-trailer.32 }
CONSTANT: dummy-image.64 T{ image f $ dummy-footer.64 $ dummy-leader $ dummy-header.64 $ dummy-data $ dummy-code $ dummy-trailer.64 }

CONSTANT: dummy-file.32 "vocab:tools/image/dummy.32.image"
CONSTANT: dummy-file.64 "vocab:tools/image/dummy.64.image"

{ t } [ dummy-header.32 valid-header? ] unit-test
{ t } [ dummy-header.64 valid-header? ] unit-test
{ t } [ dummy-footer.32 valid-footer? ] unit-test
{ t } [ dummy-footer.64 valid-footer? ] unit-test

{ t } [ image-header.union <struct> dummy-header.32 >>b32 check-image-header dummy-header.32 = ] unit-test
{ f } [ image-header.union <struct> dummy-header.64 >>b64 check-image-header dummy-header.32 = ] unit-test
{ f } [ image-header.union <struct> dummy-header.32 >>b32 check-image-header dummy-header.64 = ] unit-test
{ t } [ image-header.union <struct> dummy-header.64 >>b64 check-image-header dummy-header.64 = ] unit-test

[ image-header.union <struct> check-image-header ] must-fail
[ image-header.union <struct> check-image-header ] [ unsupported-image-header? ] must-fail-with

{ t } [ embedded-image-footer.union <struct> dummy-footer.32 >>b32 valid-image-footer? dummy-footer.32 = ] unit-test
{ f } [ embedded-image-footer.union <struct> dummy-footer.64 >>b64 valid-image-footer? dummy-footer.32 = ] unit-test
{ f } [ embedded-image-footer.union <struct> dummy-footer.32 >>b32 valid-image-footer? dummy-footer.64 = ] unit-test
{ t } [ embedded-image-footer.union <struct> dummy-footer.64 >>b64 valid-image-footer? dummy-footer.64 = ] unit-test
{ f } [ embedded-image-footer.union <struct> valid-image-footer? ] unit-test

INITIALIZED-SYMBOL: 32|64 [ dummy-file.64 ]

: with-dummy ( quot -- ) [ 32|64 get binary ] dip with-file-reader ; inline

{ t } [ [ tell-input [ 0 seek-end seek-input ] with-position tell-input = ] with-dummy ] unit-test
{ t } [ [ 0 seek-end seek-input tell-input [ 0 seek-absolute seek-input ] with-position tell-input = ] with-dummy ] unit-test

{ t } [ [ dummy-footer.32 [ skip-struct tell-input ] [ class-of struct-size ] bi = ] with-dummy ] unit-test
{ t } [ [ dummy-header.64 [ skip-struct tell-input ] [ class-of struct-size ] bi = ] with-dummy ] unit-test

! test dummy file integrity first and test some functions along the way

: skip ( bytes -- ) length seek-relative seek-input ; inline
: eof ( -- filesize ) 0 seek-end seek-input tell-input ; inline

{ $ dummy-file.32 $ dummy-file.64 } [ 32|64 [ [
    { t } [ read-footer [ class-of heap-size + [ eof ] with-position = ] [ dummy-footer.32 = ] [ dummy-footer.64 = ] tri or and ] unit-test
    { t } [ dummy-leader dup length read* = ] unit-test
    { t } [ read-header [ dummy-header.32 = ] [ dummy-header.64 = ] bi or ] unit-test
    { t } [ dummy-data dup length read* = ] unit-test
    { t } [ dummy-code dup length read* = ] unit-test
  [ { t } [ dummy-trailer dup length read* = ] unit-test ] with-position
    { t } [
            [ dummy-trailer.32 skip dummy-footer.32 dup class-of read-struct* = ] with-position
              dummy-trailer.64 skip dummy-footer.64 dup class-of read-struct* =   or
          ] unit-test
    { t } [ tell-input eof = ] unit-test ! the whole file is checked at this point
] with-dummy ] with-variable ] each

! tests dependent on dummy files

{ t } [ dummy-image.32 dummy-file.32 load-factor-image = ] unit-test
{ t } [ dummy-image.64 dummy-file.64 load-factor-image = ] unit-test

{ t } [ dummy-image.32 dup [ [ save-factor-image ] [ load-factor-image ] bi ] with-test-file = ] unit-test
{ t } [ dummy-image.64 dup [ [ save-factor-image ] [ load-factor-image ] bi ] with-test-file = ] unit-test

{ $ dummy-file.32 $ dummy-file.64 } [ 32|64 [
  { t } [ 32|64 get load-factor-image compressable-image? ] unit-test
  { t } [ [ [ drop 32|64 get load-factor-image ] [ save-factor-image ] [ 32|64 get [ binary file-contents ] bi@ = ] tri ] with-test-file ] unit-test
] with-variable ] each
