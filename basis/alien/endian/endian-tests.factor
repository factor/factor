! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.endian classes.struct io
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
        HEX: 0 HEX: ff
        HEX: 0 HEX: ff
        HEX: 0 HEX: ff
        HEX: 0 HEX: ff

        HEX: 0 HEX: 0 HEX: 0 HEX: ff
        HEX: 0 HEX: 0 HEX: 0 HEX: ff
        HEX: 0 HEX: 0 HEX: 0 HEX: ff
        HEX: 0 HEX: 0 HEX: 0 HEX: ff

        HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: ff
        HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: ff
        HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: ff
        HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: ff
    }

CONSTANT: endian-bytes-f0 B{
        HEX: ff HEX: 0
        HEX: ff HEX: 0
        HEX: ff HEX: 0
        HEX: ff HEX: 0

        HEX: ff HEX: 0 HEX: 0 HEX: 0
        HEX: ff HEX: 0 HEX: 0 HEX: 0
        HEX: ff HEX: 0 HEX: 0 HEX: 0
        HEX: ff HEX: 0 HEX: 0 HEX: 0

        HEX: ff HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0
        HEX: ff HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0
        HEX: ff HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0
        HEX: ff HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0 HEX: 0
    }

: endian-test-struct-0f ( -- obj )
    endian-bytes-0f endian-struct memory>struct ;

: endian-test-struct-f0 ( -- obj )
    endian-bytes-f0 endian-struct memory>struct ;

[ HEX: ff00 ] [ endian-test-struct-0f a>> ] unit-test
[ -256 ] [ endian-test-struct-0f b>> ] unit-test
[ HEX: 00ff ] [ endian-test-struct-0f c>> ] unit-test
[ HEX: 00ff ] [ endian-test-struct-0f d>> ] unit-test

[ HEX: ff000000 ] [ endian-test-struct-0f e>> ] unit-test
[ -16777216 ] [ endian-test-struct-0f f>> ] unit-test
[ HEX: 000000ff ] [ endian-test-struct-0f g>> ] unit-test
[ HEX: 000000ff ] [ endian-test-struct-0f h>> ] unit-test

[ HEX: ff00000000000000 ] [ endian-test-struct-0f i>> ] unit-test
[ -72057594037927936 ] [ endian-test-struct-0f j>> ] unit-test
[ HEX: 00000000000000ff ] [ endian-test-struct-0f k>> ] unit-test
[ HEX: 00000000000000ff ] [ endian-test-struct-0f l>> ] unit-test


[ HEX: ff00 ] [ endian-test-struct-f0 c>> ] unit-test
[ -256 ] [ endian-test-struct-f0 d>> ] unit-test
[ HEX: 00ff ] [ endian-test-struct-f0 a>> ] unit-test
[ HEX: 00ff ] [ endian-test-struct-f0 b>> ] unit-test

[ HEX: ff000000 ] [ endian-test-struct-f0 g>> ] unit-test
[ -16777216 ] [ endian-test-struct-f0 h>> ] unit-test
[ HEX: 000000ff ] [ endian-test-struct-f0 e>> ] unit-test
[ HEX: 000000ff ] [ endian-test-struct-f0 f>> ] unit-test

[ HEX: ff00000000000000 ] [ endian-test-struct-f0 k>> ] unit-test
[ -72057594037927936 ] [ endian-test-struct-f0 l>> ] unit-test
[ HEX: 00000000000000ff ] [ endian-test-struct-f0 i>> ] unit-test
[ HEX: 00000000000000ff ] [ endian-test-struct-f0 j>> ] unit-test

[ t ]
[ endian-test-struct-0f binary [ write ] with-byte-writer endian-bytes-0f = ] unit-test

[ t ]
[ endian-test-struct-f0 binary [ write ] with-byte-writer endian-bytes-f0 = ] unit-test
