! Copyright (C) 2024 nomennescio.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.struct io io.encodings.binary
io.files kernel kernel.private literals namespaces sequences
specialized-arrays.instances.alien.c-types.u32
specialized-arrays.instances.alien.c-types.u64
specialized-arrays.instances.alien.c-types.u8 tools.image
tools.test ;
IN: tools.image.tests

<<
CONSTANT: dummy-leader  $[ "dummy headABCDEF" B{ } like ]
CONSTANT: dummy-data    $[ "dummy dataABCDEF" B{ } like ]                 ! is incompressable
CONSTANT: dummy-code    $[ "dummy code######################" B{ } like ] ! is   compressable
CONSTANT: dummy-trailer $[ "dummy tailABCDEF01234567" B{ } like ]

CONSTANT: dummy-objects.32 $[ special-object-count [ <iota> ] [ drop 0 ] [ <u32-array> ] tri [ copy ] keep ]
CONSTANT: dummy-objects.64 $[ special-object-count [ <iota> ] [ drop 0 ] [ <u64-array> ] tri [ copy ] keep ]
>>

CONSTANT: dummy-trailer.64 $[ dummy-trailer 24 head ]
CONSTANT: dummy-trailer.32 $[ dummy-trailer 8 head* ]

CONSTANT: dummy-header.32 S{ image-header.32 f $[ image-magic image-version 0 0 0 dummy-code length dummy-data length dup pick 0 dummy-objects.32 ] }
CONSTANT: dummy-header.64 S{ image-header.64 f $[ image-magic image-version 0 0 0 dummy-code length dummy-data length dup pick 0 dummy-objects.64 ] }

CONSTANT: dummy-footer.32 S{ embedded-image-footer.32 f $[ dummy-trailer 8 tail* 0 8 <u8-array> [ copy ] keep image-magic dummy-leader length ] }
CONSTANT: dummy-footer.64 S{ embedded-image-footer.64 f $[ image-magic dummy-leader length ] }

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

CONSTANT: dummy-file.32 "vocab:tools/image/dummy.32.image"
CONSTANT: dummy-file.64 "vocab:tools/image/dummy.64.image"

SYMBOL: 32|64

: with-dummy ( quot -- ) [ 32|64 get binary ] dip with-file-reader ; inline

dummy-file.64 32|64 set-global

{ t } [ [ tell-input [ 0 seek-end seek-input ] with-position tell-input = ] with-dummy ] unit-test
{ t } [ [ 0 seek-end seek-input tell-input [ 0 seek-absolute seek-input ] with-position tell-input = ] with-dummy ] unit-test

{ t } [ [ dummy-footer.32 [ skip-struct tell-input ] [ class-of struct-size ] bi = ] with-dummy ] unit-test
{ t } [ [ dummy-header.64 [ skip-struct tell-input ] [ class-of struct-size ] bi = ] with-dummy ] unit-test

! test file integrity

: skip ( bytes -- ) length seek-relative seek-input ; inline

{ $ dummy-file.32 $ dummy-file.64 } [ 32|64 [
    { t } [ [ dummy-leader dup length read* = ] with-dummy ] unit-test
    { t } [ [ dummy-leader skip read-header [ dummy-header.32 = ] [ dummy-header.64 = ] bi or ] with-dummy ] unit-test
    { t } [ [ dummy-leader skip read-header drop dummy-data dup length read* = ] with-dummy ] unit-test
    { t } [ [ dummy-leader skip read-header drop dummy-data skip dummy-code dup length read* = ] with-dummy ] unit-test
    { t } [ [ dummy-leader skip read-header drop dummy-data skip dummy-code skip dummy-trailer dup length read* = ] with-dummy ] unit-test
] with-variable ] each
