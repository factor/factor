USING: arrays kernel math namespaces sequences tools.test crypto.sha1 ;

[ "a9993e364706816aba3e25717850c26c9cd0d89d" ] [ "abc" byte-array>sha1str ] unit-test
[ "84983e441c3bd26ebaae4aa1f95129e5e54670f1" ] [ "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" byte-array>sha1str ] unit-test
! [ "34aa973cd4c4daa4f61eeb2bdbad27316534016f" ] [ 1000000 CHAR: a fill string>sha1str ] unit-test ! takes a long time...
[ "dea356a2cddd90c7a7ecedc5ebb563934f460452" ] [ "0123456701234567012345670123456701234567012345670123456701234567"
10 swap <array> concat byte-array>sha1str ] unit-test

[
    ";\u00009b\u0000fd\u0000cdK\u0000a3^s\u0000d0*\u0000e3\\\u0000b5\u000013<\u0000e8wA\u0000b2\u000083\u0000d20\u0000f1\u0000e6\u0000cc\u0000d8\u00001e\u00009c\u000004\u0000d7PT]\u0000ce,\u000001\u000012\u000080\u000096\u000099"
] [
    "\u000066\u000053\u0000f1\u00000c\u00001a\u0000fa\u0000b5\u00004c\u000061\u0000c8\u000025\u000075\u0000a8\u00004a\u0000fe\u000030\u0000d8\u0000aa\u00001a\u00003a\u000096\u000096\u0000b3\u000018\u000099\u000092\u0000bf\u0000e1\u0000cb\u00007f\u0000a6\u0000a7"
    byte-array>sha1-interleave
] unit-test
