! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.endian classes.struct io
io.encodings.binary io.streams.byte-array kernel tools.test ;
IN: alien.endian.tests

STRUCT: endian-struct
    { a ule16 }
    { b le16 }
    { c ube16 }
    { d be16 }
    { e ule32 }
    { f le32 }
    { g ube32 }
    { h be32 }
    { i ule64 }
    { j le64 }
    { k ube64 }
    { l be64 } ;

CONSTANT: endian-bytes-0f B{
        0x0 0xff
        0x0 0xff
        0x0 0xff
        0x0 0xff

        0x0 0x0 0x0 0xff
        0x0 0x0 0x0 0xff
        0x0 0x0 0x0 0xff
        0x0 0x0 0x0 0xff

        0x0 0x0 0x0 0x0 0x0 0x0 0x0 0xff
        0x0 0x0 0x0 0x0 0x0 0x0 0x0 0xff
        0x0 0x0 0x0 0x0 0x0 0x0 0x0 0xff
        0x0 0x0 0x0 0x0 0x0 0x0 0x0 0xff
    }

CONSTANT: endian-bytes-f0 B{
        0xff 0x0
        0xff 0x0
        0xff 0x0
        0xff 0x0

        0xff 0x0 0x0 0x0
        0xff 0x0 0x0 0x0
        0xff 0x0 0x0 0x0
        0xff 0x0 0x0 0x0

        0xff 0x0 0x0 0x0 0x0 0x0 0x0 0x0
        0xff 0x0 0x0 0x0 0x0 0x0 0x0 0x0
        0xff 0x0 0x0 0x0 0x0 0x0 0x0 0x0
        0xff 0x0 0x0 0x0 0x0 0x0 0x0 0x0
    }

: endian-test-struct-0f ( -- obj )
    endian-bytes-0f endian-struct memory>struct ;

: endian-test-struct-f0 ( -- obj )
    endian-bytes-f0 endian-struct memory>struct ;

{ 0xff00 } [ endian-test-struct-0f a>> ] unit-test
{ -256 } [ endian-test-struct-0f b>> ] unit-test
{ 0x00ff } [ endian-test-struct-0f c>> ] unit-test
{ 0x00ff } [ endian-test-struct-0f d>> ] unit-test

{ 0xff000000 } [ endian-test-struct-0f e>> ] unit-test
{ -16777216 } [ endian-test-struct-0f f>> ] unit-test
{ 0x000000ff } [ endian-test-struct-0f g>> ] unit-test
{ 0x000000ff } [ endian-test-struct-0f h>> ] unit-test

{ 0xff00000000000000 } [ endian-test-struct-0f i>> ] unit-test
{ -72057594037927936 } [ endian-test-struct-0f j>> ] unit-test
{ 0x00000000000000ff } [ endian-test-struct-0f k>> ] unit-test
{ 0x00000000000000ff } [ endian-test-struct-0f l>> ] unit-test


{ 0xff00 } [ endian-test-struct-f0 c>> ] unit-test
{ -256 } [ endian-test-struct-f0 d>> ] unit-test
{ 0x00ff } [ endian-test-struct-f0 a>> ] unit-test
{ 0x00ff } [ endian-test-struct-f0 b>> ] unit-test

{ 0xff000000 } [ endian-test-struct-f0 g>> ] unit-test
{ -16777216 } [ endian-test-struct-f0 h>> ] unit-test
{ 0x000000ff } [ endian-test-struct-f0 e>> ] unit-test
{ 0x000000ff } [ endian-test-struct-f0 f>> ] unit-test

{ 0xff00000000000000 } [ endian-test-struct-f0 k>> ] unit-test
{ -72057594037927936 } [ endian-test-struct-f0 l>> ] unit-test
{ 0x00000000000000ff } [ endian-test-struct-f0 i>> ] unit-test
{ 0x00000000000000ff } [ endian-test-struct-f0 j>> ] unit-test

{ t }
[ endian-test-struct-0f binary [ write ] with-byte-writer endian-bytes-0f = ] unit-test

{ t }
[ endian-test-struct-f0 binary [ write ] with-byte-writer endian-bytes-f0 = ] unit-test

LE-STRUCT: le-endian-struct
    { a ule16 }
    { b le16 }
    { c ube16 }
    { d be16 }
    { e ule32 }
    { f le32 }
    { g ube32 }
    { h be32 }
    { i ule64 }
    { j le64 }
    { k ube64 }
    { l be64 } ;

{ t }
[
    endian-bytes-0f le-endian-struct memory>struct
    binary [ write ] with-byte-writer endian-bytes-0f =
] unit-test

{ t }
[
    endian-bytes-f0 le-endian-struct memory>struct
    binary [ write ] with-byte-writer endian-bytes-f0 =
] unit-test


BE-STRUCT: be-endian-struct
    { a ule16 }
    { b le16 }
    { c ube16 }
    { d be16 }
    { e ule32 }
    { f le32 }
    { g ube32 }
    { h be32 }
    { i ule64 }
    { j le64 }
    { k ube64 }
    { l be64 } ;

{ t }
[
    endian-bytes-0f be-endian-struct memory>struct
    binary [ write ] with-byte-writer endian-bytes-0f =
] unit-test

{ t }
[
    endian-bytes-f0 be-endian-struct memory>struct
    binary [ write ] with-byte-writer endian-bytes-f0 =
] unit-test

LE-STRUCT: le-override-struct
    { a ushort }
    { b short }
    { c ube16 }
    { d be16 }
    { e uint }
    { f int }
    { g ube32 }
    { h be32 }
    { i ulonglong }
    { j longlong }
    { k ube64 }
    { l be64 } ;

{ t }
[
    endian-bytes-0f le-override-struct memory>struct
    binary [ write ] with-byte-writer endian-bytes-0f =
] unit-test

{ t }
[
    endian-bytes-f0 le-override-struct memory>struct
    binary [ write ] with-byte-writer endian-bytes-f0 =
] unit-test

BE-STRUCT: be-override-struct
    { a ule16 }
    { b le16 }
    { c ushort }
    { d short }
    { e ule32 }
    { f le32 }
    { g uint }
    { h int }
    { i ule64 }
    { j le64 }
    { k ulonglong }
    { l longlong } ;

{ t }
[
    endian-bytes-0f be-override-struct memory>struct
    binary [ write ] with-byte-writer endian-bytes-0f =
] unit-test

{ t }
[
    endian-bytes-f0 be-override-struct memory>struct
    binary [ write ] with-byte-writer endian-bytes-f0 =
] unit-test


LE-PACKED-STRUCT: le-packed-struct
    { a char[7] }
    { b int } ;

{ t }
[
    B{ 0 0 0 0 0 0 0  3 0 0 0 } [
        le-packed-struct memory>struct
        binary [ write ] with-byte-writer
    ] keep =
] unit-test

{ 3 }
[
    B{ 0 0 0 0 0 0 0  3 0 0 0 } le-packed-struct memory>struct
    b>>
] unit-test


BE-PACKED-STRUCT: be-packed-struct
    { a char[7] }
    { b int } ;

{ t }
[
    B{ 0 0 0 0 0 0 0  0 0 0 3 } [
        be-packed-struct memory>struct
        binary [ write ] with-byte-writer
    ] keep =
] unit-test

{ 3 }
[
    B{ 0 0 0 0 0 0 0  0 0 0 3 } be-packed-struct memory>struct
    b>>
] unit-test
